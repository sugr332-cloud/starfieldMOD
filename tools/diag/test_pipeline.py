#!/usr/bin/env python3
"""
test_pipeline.py - AISS 全経路疎通テスト (True End-to-End Pipeline Test)

【目的】
ゲーム本体を起動せずに、
[latest_request.ini] -> [AISS Backend] -> [LLM Proxy (1235)] -> [LM Studio (1234)] -> [latest_response.ini]
の実経路が完全に動作しているかを検証します。

【出力仕様】
- 会話本文・プロンプト本文は一切画面に出力しません。
- 所要時間、思考トークン数、文字数、日本語文字割合（ひらがな・カタカナ・漢字）、判定結果のみを出力します。
"""

import os
import re
import sys
import time
import json
import subprocess
import urllib.request
import urllib.error

if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

def get_aiss_mod_dir():
    local_app_data = os.environ.get("LOCALAPPDATA")
    if not local_app_data:
        raise RuntimeError("LOCALAPPDATA environment variable not set")
    mod_dir = os.path.join(local_app_data, "ModOrganizer", "Starfield", "mods", "AISS - AI Settled Systems")
    if not os.path.isdir(mod_dir):
        raise RuntimeError(f"AISS mod directory not found at: {mod_dir}")
    return mod_dir

def check_url(url, timeout=3):
    try:
        req = urllib.request.Request(url, method="GET")
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return resp.status == 200
    except Exception:
        return False

def calc_japanese_ratio(text):
    """本文に含まれる日本語（ひらがな・カタカナ・漢字・和文記号）の文字の割合を算出"""
    if not text:
        return 0.0, 0, 0
    cleaned = "".join(text.split())
    if not cleaned:
        return 0.0, 0, 0
    jp_pattern = re.compile(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF\u3400-\u4DBF\u3000-\u303F]')
    jp_chars = len(jp_pattern.findall(cleaned))
    total_chars = len(cleaned)
    ratio = (jp_chars / total_chars) * 100.0
    return ratio, jp_chars, total_chars

def get_latest_proxy_stats(log_file):
    """中継プロキシログから直近の prompt_tokens, reasoning_tokens, completion_tokens, finish_reason を取得"""
    if not os.path.exists(log_file):
        return {"prompt_tokens": 0, "reasoning_tokens": 0, "completion_tokens": 0, "finish_reason": "unknown"}
    try:
        with open(log_file, "r", encoding="utf-8", errors="replace") as f:
            lines = f.readlines()
        for line in reversed(lines):
            if "Response completed in" in line:
                m_pt = re.search(r'prompt_tokens=(\d+)', line)
                m_rt = re.search(r'reasoning_tokens=(\d+)', line)
                m_ct = re.search(r'completion_tokens=(\d+)', line)
                m_fr = re.search(r'finish_reason=(\w+)', line)
                return {
                    "prompt_tokens": int(m_pt.group(1)) if m_pt else 0,
                    "reasoning_tokens": int(m_rt.group(1)) if m_rt else 0,
                    "completion_tokens": int(m_ct.group(1)) if m_ct else 0,
                    "finish_reason": m_fr.group(1) if m_fr else "unknown"
                }
    except Exception:
        pass
    return {"prompt_tokens": 0, "reasoning_tokens": 0, "completion_tokens": 0, "finish_reason": "unknown"}

def ensure_services(mod_dir, repo_root):
    print("--- [1] サービス稼働確認 ---")
    
    # 1. LM Studio (1234)
    if not check_url("http://127.0.0.1:1234/v1/models"):
        raise RuntimeError("LM Studio がポート 1234 で応答しません。LM Studio を起動してください。")
    print("  ✓ LM Studio (http://127.0.0.1:1234) : 稼働中")

    # 2. LLM Proxy (1235)
    proxy_ok = False
    try:
        req = urllib.request.Request("http://127.0.0.1:1235/health", method="GET")
        with urllib.request.urlopen(req, timeout=2) as resp:
            if resp.status == 200:
                h = json.loads(resp.read().decode("utf-8"))
                if h.get("status") == "ok":
                    proxy_ok = True
    except Exception:
        proxy_ok = False

    if not proxy_ok:
        print("  ! LLM Proxy が未稼働です。独立バックグラウンド起動します...")
        proxy_script = os.path.join(repo_root, "tools", "llm-proxy", "llm_proxy.py")
        proxy_log = os.path.join(repo_root, "tools", "launcher", "logs", "llm_proxy.log")
        flags = subprocess.CREATE_NEW_PROCESS_GROUP
        if hasattr(subprocess, "DETACHED_PROCESS"):
            flags |= subprocess.DETACHED_PROCESS
        subprocess.Popen(
            [sys.executable, proxy_script, "--port", "1235", "--upstream", "http://127.0.0.1:1234", "--log-file", proxy_log],
            cwd=os.path.dirname(proxy_script),
            creationflags=flags
        )
        time.sleep(2)
        if not check_url("http://127.0.0.1:1235/health"):
            raise RuntimeError("LLM Proxy の起動に失敗しました。")
    print("  ✓ LLM Proxy (http://127.0.0.1:1235) : 稼働中")

    # 3. AISS Backend
    aiss_exe = os.path.join(mod_dir, "AISS", "AISS_Backend.exe")
    aiss_dir = os.path.join(mod_dir, "AISS")
    
    is_running = False
    if sys.platform == "win32":
        tasks = subprocess.check_output("tasklist /FI \"IMAGENAME eq AISS_Backend.exe\"", shell=True).decode("cp932", errors="ignore")
        is_running = "AISS_Backend.exe" in tasks

    if not is_running:
        print("  ! AISS Backend が未起動です。独立バックグラウンド起動します...")
        flags = subprocess.CREATE_NEW_PROCESS_GROUP
        if hasattr(subprocess, "DETACHED_PROCESS"):
            flags |= subprocess.DETACHED_PROCESS
        subprocess.Popen([aiss_exe], cwd=aiss_dir, creationflags=flags)
        time.sleep(3)
        print("  ✓ AISS Backend を起動しました。")
    else:
        print("  ✓ AISS Backend : 稼働中")

def run_test_turn(mod_dir, repo_root, prompt_text="こんにちは"):
    req_file = os.path.join(mod_dir, "SFSE", "AISS", "requests", "latest_request.ini")
    resp_file = os.path.join(mod_dir, "SFSE", "AISS", "responses", "latest_response.ini")
    proxy_log = os.path.join(repo_root, "tools", "launcher", "logs", "llm_proxy.log")

    if not os.path.exists(req_file):
        raise RuntimeError(f"latest_request.ini が見つかりません: {req_file}")

    print(f"\n--- [2] テストリクエスト送信 (入力文字数: {len(prompt_text)}文字) ---")

    with open(req_file, "r", encoding="utf-8", errors="replace") as f:
        lines = f.readlines()

    test_req_id = f"test_route_{int(time.time() * 1000)}"
    new_lines = []
    in_request = False
    in_player = False

    for line in lines:
        stripped = line.strip()
        if stripped == "[request]":
            in_request = True
            in_player = False
            new_lines.append(line)
            continue
        elif stripped.startswith("["):
            in_request = False
            if stripped == "[player]":
                in_player = True
            else:
                in_player = False
            new_lines.append(line)
            continue

        if in_request:
            if stripped.startswith("ready="):
                new_lines.append("ready=1\n")
                continue
            elif stripped.startswith("request_id="):
                new_lines.append(f"request_id={test_req_id}\n")
                continue
        elif in_player:
            if stripped.startswith("message="):
                new_lines.append(f"message={prompt_text}\n")
                continue
            elif stripped.startswith("message_encoded="):
                new_lines.append(f"message_encoded={prompt_text}\n")
                continue

        new_lines.append(line)

    start_time = time.time()
    with open(req_file, "w", encoding="utf-8") as f:
        f.writelines(new_lines)

    print(f"  リクエスト送信完了 (ID: {test_req_id})。Backend 処理待機中...")

    timeout_sec = 45
    deadline = start_time + timeout_sec
    response_found = False
    resp_text = ""
    error_detected = False
    saw_thinking = False

    while time.time() < deadline:
        time.sleep(0.3)
        if not os.path.exists(resp_file):
            continue

        try:
            with open(resp_file, "r", encoding="utf-8", errors="replace") as f:
                content = f.read()

            if f"request_id={test_req_id}" in content:
                current_text = ""
                for rline in content.splitlines():
                    if rline.startswith("text="):
                        current_text = rline[len("text="):].strip()
                        break
                    elif rline.startswith("display_text="):
                        current_text = rline[len("display_text="):].strip()
                        break

                if "is thinking..." in current_text:
                    if not saw_thinking:
                        saw_thinking = True
                        print("  [Backend] リクエスト受理確認（初期待機ステータス）。最終本文生成を待機中...")
                    continue

                elapsed = time.time() - start_time
                resp_text = current_text
                response_found = True

                if "AISS backend error" in resp_text or "LM Studio response missing" in resp_text:
                    error_detected = True

                break
        except Exception:
            pass

    if not response_found:
        raise TimeoutError(f"タイムアウト ({timeout_sec}s): AISS Backend からの最終応答が得られませんでした。")

    # 数値解析
    time.sleep(0.5)
    proxy_stats = get_latest_proxy_stats(proxy_log)
    jp_ratio, jp_cnt, total_cnt = calc_japanese_ratio(resp_text)
    is_japanese = jp_ratio >= 50.0

    print(f"--- [3] 経路応答結果 (数値解析) ---")
    print(f"  所要時間       : {elapsed:.2f} 秒")
    print(f"  入力トークン   : {proxy_stats['prompt_tokens']}")
    print(f"  思考トークン   : {proxy_stats['reasoning_tokens']}")
    print(f"  出力トークン   : {proxy_stats['completion_tokens']}")
    print(f"  終了理由       : {proxy_stats['finish_reason']}")
    print(f"  本文文字数     : {total_cnt} 文字")
    print(f"  日本語文字割合 : {jp_ratio:.1f}% ({jp_cnt}/{total_cnt} 文字)")
    print(f"  日本語判定     : {'✓ 合格 (50%以上)' if is_japanese else '✗ 不合格 (50%未満)'}")
    print(f"  エラー有無     : {'✗ エラー検出' if error_detected else '✓ 正常'}")

    success = (not error_detected) and is_japanese and (proxy_stats['reasoning_tokens'] == 0)
    return {
        "success": success,
        "elapsed": elapsed,
        "prompt_tokens": proxy_stats['prompt_tokens'],
        "reasoning_tokens": proxy_stats['reasoning_tokens'],
        "completion_tokens": proxy_stats['completion_tokens'],
        "finish_reason": proxy_stats['finish_reason'],
        "char_count": total_cnt,
        "jp_ratio": jp_ratio,
        "is_japanese": is_japanese,
        "error_detected": error_detected
    }

def main():
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
    mod_dir = get_aiss_mod_dir()

    ensure_services(mod_dir, repo_root)

    iterations = 3
    if len(sys.argv) > 1 and sys.argv[1].isdigit():
        iterations = int(sys.argv[1])

    success_count = 0
    results = []

    # 無害な短文プロンプト
    prompts = [
        "こんにちは",
        "こんにちは。調子はいかがですか？",
        "こんにちは。今日もよろしくお願いします。"
    ]

    for i in range(iterations):
        prompt = prompts[i % len(prompts)]
        print(f"\n==================== [ テスト実行 {i+1} / {iterations} ] ====================")
        res = run_test_turn(mod_dir, repo_root, prompt)
        res["turn"] = i + 1
        results.append(res)
        if res["success"]:
            success_count += 1
        time.sleep(1)

    print("\n==================== [ 経路テスト 総合検証結果 ] ====================")
    print("| 回数 | 判定 | 所要時間 | 入力トークン | 思考トークン | 本文文字数 | 日本語割合 | 終了理由 |")
    print("|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|")
    for r in results:
        status_str = "合格" if r["success"] else "不合格"
        print(f"| #{r['turn']} | {status_str} | {r['elapsed']:.2f}s | {r['prompt_tokens']} tokens | {r['reasoning_tokens']} tokens | {r['char_count']} 文字 | {r['jp_ratio']:.1f}% | {r['finish_reason']} |")

    print(f"\n総合結果: {success_count} / {iterations} 回 合格")
    if success_count == iterations:
        print(">> 全経路（Backend -> Proxy -> LM Studio -> Response）の正常疎通および日本語応答を確認しました！")
        sys.exit(0)
    else:
        print(">> 経路テストで不合格またはエラーが検出されました。")
        sys.exit(1)

if __name__ == "__main__":
    main()
