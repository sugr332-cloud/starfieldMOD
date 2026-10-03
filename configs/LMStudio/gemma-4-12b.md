# LM Studio モデル設定記録: Gemma 4 12B IT QAT

Starfield Space Life JP プロジェクトにおけるローカル LLM（Gemma 4 12B）の構成、量子化、および VRAM 実測・設定記録です。

---

## 1. モデル基本情報

- **モデル名**: `unsloth/gemma-4-12B-it-qat-GGUF`
- **取得元**: Hugging Face / LM Studio Hub (`unsloth/gemma-4-12B-it-qat-GGUF`)
- **ファイル名**: `gemma-4-12B-it-qat-UD-Q4_K_XL.gguf`
- **ファイルサイズ**: 約 6.72 GB（6,934,228,832 bytes）
- **モデル識別子（API Identifier）**: `gemma-4-12b-it-qat`
- **量子化形式**: `UD-Q4_K_XL`（Unsloth Dynamic Q4_K_XL）
  - **変更経緯**: `docs/MOD_SPEC.md`（v0.6）での想定は `Q4_K_M` でしたが、Unsloth による QAT（Quantization-Aware Training）および重要層への動的ビット配分（UD-Q4_K_XL）版が提供されており、12B クラスの推論品質と VRAM 効率の観点から採用しました。
- **マルチモーダルファイル**: `mmproj-F32.gguf`（約 837 MB、自動取得、削除せず保持）
  - AISS はテキスト会話のみを使用するため、Vision 推論は行われません。

---

## 2. LM Studio 推論設定（Phase 1 標準）

Phase 1 の標準設定は以下の通りです。**コンテキスト長は 16384（16K）とし、32K は VRAM 超過防止のため使用しません。**

- **ランタイムエンジン**: `llama.cpp-win-x86_64-vulkan-avx2@2.49.0`
- **コンテキスト長**: `16384`（16K）※32K は不採用
- **GPU オフロード**: 100%（全レイヤー max）
- **KV キャッシュ量子化**: **Q8_0（K キャッシュ / V キャッシュ）**
- **Flash Attention**: **オン（有効）**
- **プロンプトキャッシュ（Prompt Caching）**: 有効（`--cache-prompt`）
- **スレッド数**: 6
- **評価バッチサイズ**: `batch-size: 2048`, `ubatch-size: 512`
- **並列処理スロット**: 4（`--parallel 4`）

### 2.1 プリセット設定ファイル
LM Studio に以下のプリセットを登録済みです。
- 格納先: `<UserDir>\.lmstudio\config-presets\AISS-Standard.preset.json`
- プリセット内容:
  ```json
  {
    "name": "AISS-Standard-Q8_0",
    "load": {
      "fields": [
        { "key": "llm.load.contextLength", "value": 16384 },
        { "key": "llm.load.llama.flashAttention", "value": true },
        { "key": "llm.load.llama.kCacheQuantizationType", "value": { "checked": true, "value": "q8_0" } },
        { "key": "llm.load.llama.vCacheQuantizationType", "value": { "checked": true, "value": "q8_0" } }
      ]
    }
  }
  ```

---

## 3. 日本語推論テスト結果

LM Studio ローカル API（`POST http://127.0.0.1:1234/v1/chat/completions`）に対して日本語テストプロンプトを送信し、正常な応答を確認しました。

- **入力プロンプト**: `こんにちは。あなたの名前と役割を短く教えてください。`
- **応答結果（抜粋）**:
  > こんにちは！私はGoogleによってトレーニングされた大規模言語モデル（AI）です。
  > 私の役割は、あなたの質問に答えたり、文章の作成・要約、翻訳、プログラミングのサポートなど、さまざまなことのお手伝いをすることです。
- **推論動作**: Thinking / Reasoning プロセス（約 760 文字の思考展開）を経て、崩れのない自然な日本語が出力されることを実証済み。

---

## 4. VRAM 計測結果（AMD Radeon RX 9070 16GB）

### 4.1 実測データ一覧
| 測定状態 | VRAM使用量 | 内訳・備考 |
|---|---|---|
| **1. LM Studio 終了時（ベースライン）** | **約 5.54 GiB** | Windows デスクトップ常駐分（後述の内訳参照） |
| **2. gemma-4-12b-it-qat ロード時（16K・f16）** | **約 14.10 GiB** | モデル本体: **7.13 GB**<br>コンテキスト: **2.70 GB**<br>LM Studio 所要計: **9.84 GB** |
| **3. gemma-4-12b-it-qat ロード時（16K・Q8_0）** | **約 12.75 GiB (理論値)** | モデル本体: **7.13 GB**<br>コンテキスト: **約 1.35 GB**（半減）<br>LM Studio 所要計: **約 8.48 GB**（約 1.35 GB 削減） |
| **4. Starfield 起動中（メインメニュー表示時）** | **約 15.34 GiB** | LM Studio 16K 稼働 + Starfield メインメニュー<br>実測値: 16,469,893,120 bytes（専用 VRAM の約 96% 使用） |

### 4.2 常駐プロセス（ベースライン 5.54 GiB）の内訳
GPU パフォーマンスカウンターによる実測値上位プロセス：
| プロセス名 | VRAM使用量 (MB) | VRAM使用量 (GiB) | 備考 |
|---|---|---|---|
| `dwm` | 4,360.0 MB | 4.26 GiB | Windows デスクトップ合成 |
| `WardogsClient-Win64-Shipping` | 2,306.2 MB | 2.25 GiB | 常駐ゲームクライアント（プレイ前終了推奨） |
| `steamwebhelper` | 808.8 MB | 0.79 GiB | Steam 内蔵ブラウザ |
| `msedge` | 598.7 MB | 0.58 GiB | Edge ブラウザ（プレイ前終了推奨） |
| `Discord` | 154.3 MB | 0.15 GiB | Discord（プレイ前終了推奨） |
| `WindowsTerminal` | 143.7 MB | 0.14 GiB | ターミナル |

※`WardogsClient`、`msedge`、`Discord` を終了することで、**約 3.0 GiB 以上の VRAM が即座に解放**されます。

### 4.3 コンテキスト長 32K（32768）不採用の結論
- **f16 KV キャッシュ時**: LM Studio 所要量 **11.62 GiB** + ベースライン 5.54 GiB = **約 17.16 GiB**（**16GB を超過**）。
- **Q8_0 KV キャッシュ時**: LM Studio 所要量 **約 9.38 GB** + ベースライン 5.54 GiB = **約 14.92 GiB**。
  - ゲーム起動前でほぼ上限に達し、Starfield 本編（7〜9 GB）を起動すると確実に 16GB を突破してクラッシュまたは著しいフレームレート低下を引き起こします。
- **結論**: **Phase 1 標準設定では 32K は一切使用せず、16K（16384）を絶対上限とします。**
