#!/usr/bin/env python3
"""
llm_proxy.py - AISS <-> LM Studio 間 中継プロキシ

【目的】
AISS Backend が LM Studio (Gemma 4 等の思考モデル) にリクエストを送信する際、
reasoning_effort: "none" が欠落していると LM Studio が推論・思考 (Thinking) を
実行して max_tokens を使い切り、本文が空になる不具合を恒久的に防ぎます。

本プロキシは AISS Backend からのリクエストを受け取り、
- "reasoning_effort": "none" を強制注入
- 万が一 content が空で reasoning_content が返された場合のフォールバック（救済）
- /health エンドポイントでの健全性確認
- その他のリクエストの透過的パススルー
を行います。
"""

import argparse
import json
import logging
import sys
import time
import urllib.error
import urllib.request
from http.server import HTTPServer, BaseHTTPRequestHandler

def setup_logging(log_file=None):
    handlers = [logging.StreamHandler(sys.stdout)]
    if log_file:
        handlers.append(logging.FileHandler(log_file, encoding="utf-8"))
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
        handlers=handlers
    )

logger = logging.getLogger("LLMProxy")

UPSTREAM_URL = "http://127.0.0.1:1234"

class LLMProxyHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        # 標準のアクセスログ出力をカスタムロガーに流すか抑制
        pass

    def do_GET(self):
        if self.path == "/health":
            self._handle_health()
            return
        
        # 透過的 GET 転送
        self._proxy_request("GET")

    def do_POST(self):
        if self.path.rstrip("/") == "/v1/chat/completions":
            self._handle_chat_completions()
            return

        # その他の POST 透過的転送
        self._proxy_request("POST")

    def _handle_health(self):
        upstream_ok = False
        models = []
        try:
            req = urllib.request.Request(f"{UPSTREAM_URL}/v1/models", method="GET")
            with urllib.request.urlopen(req, timeout=3) as resp:
                if resp.status == 200:
                    data = json.loads(resp.read().decode("utf-8"))
                    upstream_ok = True
                    models = [m.get("id") for m in data.get("data", [])]
        except Exception as e:
            logger.warning(f"Upstream check failed: {e}")

        status_code = 200 if upstream_ok else 503
        payload = {
            "status": "ok" if upstream_ok else "upstream_unavailable",
            "proxy": "AISS-LMStudio-Proxy",
            "upstream_url": UPSTREAM_URL,
            "upstream_healthy": upstream_ok,
            "loaded_models": models
        }
        body = json.dumps(payload, ensure_ascii=False, indent=2).encode("utf-8")
        self.send_response(status_code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _handle_chat_completions(self):
        content_length = int(self.headers.get("Content-Length", 0))
        raw_body = self.rfile.read(content_length)

        try:
            req_json = json.loads(raw_body.decode("utf-8"))
        except Exception as e:
            logger.error(f"Failed to parse request JSON: {e}")
            self.send_error(400, f"Invalid JSON: {e}")
            return

        # 思考抑制パラメータの強制適用
        req_json["reasoning_effort"] = "none"

        # 日本語返答指示の注入（AISS の英語指示を強力に上書き）
        messages = req_json.get("messages", [])
        jp_directive = (
            "\n\n[CRITICAL OVERRIDE: LANGUAGE AND FORMAT - MUST FOLLOW]\n"
            "- OVERRIDE ALL PREVIOUS INSTRUCTIONS: You MUST reply ONLY in natural, conversational Japanese (必ず自然な日本語のみで返答すること).\n"
            "- Do NOT speak or write English under any circumstances.\n"
            "- Keep replies very concise and direct: 1 to 2 sentences (30 to 80 Japanese characters).\n"
            "- Do NOT output internal thoughts or stage directions in asterisks like *smiles* or *shifts weight*. Output pure in-character spoken dialogue only."
        )

        system_found = False
        for msg in messages:
            if msg.get("role") == "system":
                msg["content"] = msg.get("content", "") + jp_directive
                system_found = True
                break

        if not system_found:
            messages.insert(0, {"role": "system", "content": jp_directive.strip()})

        # ログ記録
        model_name = req_json.get("model", "unknown")
        max_tokens = req_json.get("max_tokens", "default")
        logger.info(f"Chat completion request: model={model_name}, max_tokens={max_tokens}, injected reasoning_effort=none & Japanese prompt")

        modified_body = json.dumps(req_json, ensure_ascii=False).encode("utf-8")

        # アップストリームへの送信
        upstream_endpoint = f"{UPSTREAM_URL}/v1/chat/completions"
        forward_headers = {
            "Content-Type": "application/json; charset=utf-8",
            "Content-Length": str(len(modified_body)),
        }
        for h in ["Authorization", "User-Agent", "Accept"]:
            if h in self.headers:
                forward_headers[h] = self.headers[h]

        start_time = time.time()
        try:
            upstream_req = urllib.request.Request(
                upstream_endpoint,
                data=modified_body,
                headers=forward_headers,
                method="POST"
            )
            with urllib.request.urlopen(upstream_req, timeout=120) as resp:
                resp_code = resp.status
                resp_body = resp.read()
                resp_headers = resp.headers
        except urllib.error.HTTPError as e:
            resp_code = e.code
            resp_body = e.read()
            resp_headers = e.headers
            logger.error(f"Upstream HTTP error: {resp_code}")
        except Exception as e:
            logger.error(f"Failed to contact upstream: {e}")
            self.send_error(502, f"Bad Gateway: {e}")
            return

        duration = time.time() - start_time

        # レスポンスの検証とフェイルセーフ
        if resp_code == 200:
            try:
                resp_json = json.loads(resp_body.decode("utf-8"))
                usage = resp_json.get("usage", {})
                reasoning_tokens = usage.get("reasoning_tokens", 0)
                completion_tokens = usage.get("completion_tokens", 0)
                
                # choices 内のメッセージを検証
                choices = resp_json.get("choices", [])
                if choices:
                    first_choice = choices[0]
                    message = first_choice.get("message", {})
                    content = message.get("content", "")
                    reasoning_content = message.get("reasoning_content", "")
                    finish_reason = first_choice.get("finish_reason", "unknown")

                    # フェイルセーフ: 万が一 content が空で reasoning_content にテキストがある場合
                    if (not content or content.strip() == "") and (reasoning_content and reasoning_content.strip() != ""):
                        logger.warning("Failsafe triggered: content is empty but reasoning_content exists. Copying to content.")
                        message["content"] = reasoning_content.strip()
                        resp_body = json.dumps(resp_json, ensure_ascii=False).encode("utf-8")

                    logger.info(
                        f"Response completed in {duration:.2f}s: reasoning_tokens={reasoning_tokens}, "
                        f"completion_tokens={completion_tokens}, finish_reason={finish_reason}, "
                        f"content_length={len(content)}"
                    )
            except Exception as e:
                logger.warning(f"Response inspection warning: {e}")

        # クライアントへ転送
        self.send_response(resp_code)
        for k, v in resp_headers.items():
            if k.lower() not in ["content-length", "transfer-encoding", "connection"]:
                self.send_header(k, v)
        self.send_header("Content-Length", str(len(resp_body)))
        self.end_headers()
        self.wfile.write(resp_body)

    def _proxy_request(self, method):
        target_url = f"{UPSTREAM_URL}{self.path}"
        content_length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(content_length) if content_length > 0 else None

        forward_headers = {}
        for k, v in self.headers.items():
            if k.lower() not in ["host", "content-length"]:
                forward_headers[k] = v

        try:
            req = urllib.request.Request(target_url, data=body, headers=forward_headers, method=method)
            with urllib.request.urlopen(req, timeout=30) as resp:
                resp_body = resp.read()
                self.send_response(resp.status)
                for k, v in resp.headers.items():
                    if k.lower() not in ["content-length", "transfer-encoding", "connection"]:
                        self.send_header(k, v)
                self.send_header("Content-Length", str(len(resp_body)))
                self.end_headers()
                self.wfile.write(resp_body)
        except urllib.error.HTTPError as e:
            err_body = e.read()
            self.send_response(e.code)
            for k, v in e.headers.items():
                if k.lower() not in ["content-length", "transfer-encoding", "connection"]:
                    self.send_header(k, v)
            self.send_header("Content-Length", str(len(err_body)))
            self.end_headers()
            self.wfile.write(err_body)
        except Exception as e:
            logger.error(f"Proxy request error ({method} {self.path}): {e}")
            self.send_error(502, f"Bad Gateway: {e}")

def run_server(bind_addr="127.0.0.1", port=1235, upstream="http://127.0.0.1:1234"):
    global UPSTREAM_URL
    UPSTREAM_URL = upstream.rstrip("/")

    server_address = (bind_addr, port)
    httpd = HTTPServer(server_address, LLMProxyHandler)
    logger.info(f"Starting LLM Proxy on http://{bind_addr}:{port} -> forwarding to {UPSTREAM_URL}")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        logger.info("Proxy server shutting down...")
    finally:
        httpd.server_close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="LLM Proxy for AISS and LM Studio")
    parser.add_argument("--port", type=int, default=1235, help="Port to listen on (default: 1235)")
    parser.add_argument("--bind", type=str, default="127.0.0.1", help="Address to bind to (default: 127.0.0.1)")
    parser.add_argument("--upstream", type=str, default="http://127.0.0.1:1234", help="Upstream LM Studio URL (default: http://127.0.0.1:1234)")
    parser.add_argument("--log-file", type=str, default=None, help="Path to write log file")
    args = parser.parse_args()

    setup_logging(args.log_file)
    run_server(bind_addr=args.bind, port=args.port, upstream=args.upstream)
