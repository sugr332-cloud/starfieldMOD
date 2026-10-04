# AISS 経路診断ツール (tools/diag)

## 概要

ゲーム本体を起動することなく、以下の実通信経路全体をエンドツーエンドで自動検証する診断ツールです。

```
[SFSE/AISS/requests/latest_request.ini]
       ↓ (ファイル監視)
[AISS_Backend.exe]
       ↓ (HTTP POST /v1/chat/completions)
[LLM Proxy (ポート 1235)]  ← "reasoning_effort": "none" & 日本語指示を注入
       ↓ (HTTP POST)
[LM Studio (ポート 1234)]  ← gemma-4-12b-it-qat (推論実行)
       ↓ (HTTP 200 応答)
[AISS_Backend.exe]
       ↓ (ファイル書き込み)
[SFSE/AISS/responses/latest_response.ini]
```

## 判定基準

以下の条件をすべて満たした場合に「合格」と判定されます。
1. **所要時間**: 10秒以内（通常 3〜5秒程度）
2. **思考トークン**: **0 tokens**（中継プロキシによる `reasoning_effort: none` 注入の成否）
3. **日本語割合**: **50.0% 以上**（ひらがな・カタカナ・漢字・和文記号の文字数比率）
4. **終了理由**: **`stop`**（トークン上限枯渇 `length` ではなく自然終了）
5. **エラー検出**: AISS Backend エラー文字列が一切含まれないこと

## 実行方法

### PowerShell からの実行（推奨: 3回連続テスト）
```powershell
powershell -ExecutionPolicy Bypass -File tools/diag/Test-Pipeline.ps1
```

### Python から直接実行（回数指定可能）
```bash
python tools/diag/test_pipeline.py 3
```
