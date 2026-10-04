# phase1-aiss-02 完了報告書: 思考停止の完全根絶と中継プロキシ導入

## 1. 概要

実機テスト（Helga Dubray）において約20秒待機後に発生した以下のエラーについて、原因の徹底究明、実証実験、および恒久的な対策（中継プロキシアーキテクチャの導入）を実施しました。

```
HELGA DUBRAY: AISS BACKEND ERROR: LM STUDIO RESPONSE MISSING A PLAIN TEXT REPLY.
RESPONSE KEYS: ID, OBJECT, CREATED, MODEL, CHOICES, USAGE, STATS, SYSTEM_FINGERPRINT
```

本対応により、思考（Reasoning）トークンを **確実に 0** に抑え込み、モデルの応答時間を **約25秒から 0.5〜1.6秒へ劇的に短縮**（約15倍〜50倍高速化）することに成功しました。

---

## 2. 事実確認（LM Studio サーバーログの解析）

エラー発生時刻（2026-10-04 18:34:15）の LM Studio サーバーログを詳細に解析しました。

- **リクエストパラメータ**:
  ```json
  "reasoning": { "enabled": false },
  "max_tokens": 250,
  "temperature": 0.85
  ```
  ※ AISS Backend は `config.json` に記述された未知のキーを破棄し、独自仕様の `"reasoning": {"enabled": false}` のみを送信していました。
- **LM Studio (llama-server) の挙動**:
  - LM Studio は `"reasoning": {"enabled": false}` を解釈できず、デフォルトの推論（Thinking）モードのまま推論を開始。
  - 生成結果:
    - `reasoning_tokens`: **247**
    - `completion_tokens`: **250**（上限 `max_tokens: 250` に到達）
    - `content`: **""**（空文字列）
    - `finish_reason`: **"length"**
- **結論**:
  思考だけで上限トークン（250）を使い切ってしまい、本文（`content`）が生成される前に出力が強制終了（length）したため、AISS Backend が「本文がない」としてエラーを表示したことが確定しました。

---

## 3. 原因究明と対策の検証結果

思考を 100% 確実に停止させるための各アプローチを実証実験しました。

| アプローチ | 手法 | 結果 | 判定 |
|:---|:---|:---|:---:|
| **パラメータなし** | デフォルト送信 | reasoning: 47 tokens (2.46s), content: 空 | ✕ |
| **AISS標準パラメータ** | `reasoning: {enabled: false}` | reasoning: 47 tokens (1.96s), content: 空 | ✕ 効果なし |
| **Chat Template 引数** | `chat_template_kwargs: {thinking: false}` | reasoning: 47 tokens (2.01s), content: 空 | ✕ 効果なし |
| **LM Studio 公式仕様** | **`reasoning_effort: "none"`** | **reasoning: 0 tokens (0.57s), finish: stop, 本文完全出力** | **◯ 完全成功** |

### アプローチ a / b / c の検討
- **a. モデル既定プリセット / b. チャットテンプレート (Jinja) 編集**:
  LM Studio のバックエンド（llama-server）は、モデルロード時に GGUF 内蔵のチャットテンプレートをメモリ上に保持するため、一時ファイル側の Jinja 編集や UI 側のプリセット設定が API リクエスト時に確実に反映されない構造的制約がありました。
- **c. 中継プロキシ（採用）**:
  AISS Backend と LM Studio の間に常駐する軽量プロキシ（`tools/llm-proxy/`）を配置し、AISS からのリクエストに公式仕様の `"reasoning_effort": "none"` を強制注入して LM Studio に転送する方式を採用。これにより、AISS Backend のバイナリ変更不要で 100% 確実に思考トークンを 0 に抑え込むことができます。

---

## 4. 実施した修正内容

### (1) 中継プロキシの設計と実装 (`tools/llm-proxy/`)
- `<Repository>/tools/llm-proxy/llm_proxy.py`:
  - Python 3 標準ライブラリのみで動作（外部パッケージ不要）。
  - ポート `1235` で待受、LM Studio (`http://127.0.0.1:1234`) へプロキシ。
  - `POST /v1/chat/completions` リクエストに `"reasoning_effort": "none"` を強制注入。
  - **フェイルセーフ機構**: 万が一 `content` が空で `reasoning_content` に出力された場合、自動で `content` にコピーして AISS に返却。
  - `GET /health` エンドポイントでプロキシ自身および LM Studio の稼働状態をヘルスチェック。
- `<Repository>/tools/llm-proxy/README.md`: 構成仕様および単体利用方法を記載。
- `<Repository>/tools/llm-proxy/run_proxy.bat`: 手動起動用のバッチスクリプトを作成。

### (2) AISS 設定の更新
- `%LOCALAPPDATA%\ModOrganizer\Starfield\mods\AISS - AI Settled Systems\AISS\config.json`:
  - `llm.providers.lmstudio.base_url` を `"http://127.0.0.1:1235/v1"` に変更。
  - 保険として一時的に `max_tokens` を 600 に設定して検証後、思考トークンが完全に 0 になることを実証したため、既定値の **250** に復元。

### (3) ワンクリックランチャーへの自動統合
- `<Repository>/tools/launcher/launcher.config.json` および `example`:
  - `llmProxy` 設定ブロックを追加（ポート 1235、スクリプトパス）。
- `<Repository>/tools/launcher/Start-StarfieldAI.ps1`:
  - **ステップ 3.5/5** として「LLM Proxy（思考抑制中継）の確認・自動起動」を追加。
  - `pythonw.exe` を用いたバックグラウンド独立プロセスとして自動常駐。
  - 起動後の自動ヘルスチェックおよび思考抑制テスト（応答速度・思考トークン 0）を統合。
  - `-NoAI` モード時には AISS Backend とともに LLM Proxy プロセスも自動終了するクリーンアップ処理を実装。

---

## 5. 検証結果（数値記録）

ランチャー統合テストおよび AISS 形式リクエストの計測結果です。

- **事前状態（不具合発生時）**:
  - reasoning_tokens: 247〜446
  - 所要時間: **20〜25 秒**
  - 結果: トークン枯渇（length）により本文が空、ゲーム内エラー
- **対策適用後（中継プロキシ経由）**:
  - reasoning_tokens: **0**（完全停止）
  - completion_tokens: 10〜35 tokens
  - finish_reason: **stop**（正常終了）
  - 所要時間: **0.54〜1.66 秒**（大幅短縮）
  - 返事本文: 正常な日本語テキストを即座に返却

---

## 6. 修正2への回答: 返事の表示方法の選択肢

AISS 付属ドキュメントおよび `config.json` の仕様調査結果です。
現在使用している HUD 通知（画面右上）以外に、以下のモードが用意されています。

| モード名 (`conversation_presentation.mode`) | 表示方法 | 特徴 |
|:---|:---|:---|
| **`full_dialogue_tts`**（現在の設定） | 画面右上 HUD 通知（非ブロッキング） | ゲームが止まらず進行する。文が長いと読み切る前に消える場合がある。 |
| **`text_box_tts`** | クラシック・メッセージボックス（モーダル） | バニラ風のポップアップ画面が表示され、プレイヤーがボタンを押すまで待機。**長い返事でもじっくり読める**。TTS 音声再生あり。 |
| **`text_only`** | クラシック・メッセージボックス（モーダル） | 最速・最軽量。TTS 音声なしでテキストのみを読みたい場合向け。 |

※ 現在は HUD 通知（`full_dialogue_tts`）のままとしていますが、会話をじっくり読みたい場合は `config.json` の `conversation_presentation.mode` を `"text_box_tts"` に切り替えることで、ダイアログボックス形式で表示させることが可能です。

---

## 7. phase1-extras の進捗状況

- **作業A〜D**:
  - 追加MOD 5点の配置、両プロファイル（`Stable` / `Stable-NoAI`）への登録。
  - 公式日本語用語集（90件）の策定。
  - 全5MODの xTranslator 日本語化処理（合計109,421レコード）。
  - ゲーム内数値・英語文字列の完全一致（不変性）バイナリ検証完了。
- **ブランチ状況**:
  - リモート `phase1-extras` ブランチへコミット `155b04a` でプッシュ済み。
  - ユーザーおよび Claude による確認待ち状態です。

---

## 8. ユーザー確認手順

ワンクリックランチャーを用いて、思考が停止し高速に返答が返ることを実機でご確認ください。

1. **事前確認（任意）**:
   PowerShell から以下のコマンドを実行し、ステップ 1〜3.5 の健全性テストがパスすることを確認します。
   ```powershell
   powershell -ExecutionPolicy Bypass -File tools/launcher/Start-StarfieldAI.ps1 -TestOnly
   ```
   ※「Proxy 疎通確認成功！（思考トークン: 0、応答速度: 約500ms）」が表示されます。

2. **ゲームの起動**:
   デスクトップの「Starfield AI 起動」ショートカット（またはランチャー）を通常通り実行します。
   - LM Studio、LLM Proxy（ポート1235）、AISS Backend が全自動で起動し、ゲームが立ち上がります。

3. **ゲーム内での会話テスト**:
   - 前回エラーが発生した NPC（Helga Dubray 等）に話しかけ、AI で会話を送信します。
   - **確認ポイント**:
     - 送信から **約2〜4秒以内** に返答が表示されること。
     - 「MISSING A PLAIN TEXT REPLY」や「DEBUG」エラーが出ず、自然な日本語の返答が表示されること。
