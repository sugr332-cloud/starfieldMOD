# LLM Proxy (AISS <-> LM Studio 中継プロキシ)

## 概要

AISS Backend (`AISS_Backend.exe`) と LM Studio (`llama-server`) の間に配置される軽量な中継プロキシです。

### 解決する課題
Gemma 4 などの思考（Thinking / Reasoning）機能を備えたローカルモデルを LM Studio で実行する際、OpenAI 互換 API 経由のリクエストに `"reasoning_effort": "none"` が明示されていないと、モデルはデフォルトで思考トークンを大量に生成します。
AISS Backend の現在の実装は `"reasoning": {"enabled": false}` を送信しますが、LM Studio はこれを認識せず思考を停止しません。その結果、AISS の `max_tokens`（250トークン等）が思考のみで枯渇し、本文（`content`）が空になってゲーム内で以下のエラーが発生します：

```
AISS BACKEND ERROR: LM STUDIO RESPONSE MISSING A PLAIN TEXT REPLY.
```

### プロキシの機能
1. **思考抑制の強制注入**: AISS Backend からの `POST /v1/chat/completions` リクエストに `"reasoning_effort": "none"` を強制的に付加・上書きして LM Studio に転送します。これにより思考トークンは 0 となり、即座に本文の生成が開始されます。
2. **フェイルセーフ救済**: 万が一 `content` が空で `reasoning_content` に文章が格納されていた場合、`content` へ自動コピーして AISS Backend に返却します。
3. **ヘルスチェック**: `GET /health` エンドポイントを提供し、プロキシ自身および LM Studio アップストリームの稼働状態を確認できます。
4. **透過的プロキシ**: `/v1/models` などその他のリクエストは変更せずそのまま LM Studio に転送します。
5. **ゼロ依存**: Python 3 の標準ライブラリ（`http.server`, `urllib` 等）のみで動作し、追加パッケージのインストールは不要です。

## ポート構成

- **LM Studio (Upstream)**: `http://127.0.0.1:1234`
- **LLM Proxy**: `http://127.0.0.1:1235`
- **AISS Backend 設定 (`config.json`)**: `base_url = "http://127.0.0.1:1235/v1"`

## 使用方法

### 手動起動
```bash
python tools/llm-proxy/llm_proxy.py --port 1235 --upstream http://127.0.0.1:1234
```

### ヘルスチェック
```bash
curl http://127.0.0.1:1235/health
```

### ワンクリックランチャーとの連携
`tools/launcher/Start-StarfieldAI.ps1` が自動的にバックグラウンド起動およびヘルスチェックを行い、ゲーム起動シーケンスを管理します。
