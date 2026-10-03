# LM Studio モデル設定記録: Gemma 4 12B IT QAT

Starfield Space Life JP プロジェクトにおけるローカル LLM（Gemma 4 12B）の構成、量子化、思考（reasoning）制御、および VRAM 実測・設定記録です。

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

## 2. LM Studio 推論・ロード設定（Phase 1 標準）

Phase 1 の標準設定は以下の通りです。**コンテキスト長は 16384（16K）とし、32K は VRAM 超過防止のため使用しません。**

- **ランタイムエンジン**: `llama.cpp-win-x86_64-vulkan-avx2@2.49.0`
- **コンテキスト長**: `16384`（16K）※32K は不採用
- **GPU オフロード**: 100%（全レイヤー max）
- **KV キャッシュ量子化**: **Q8_0（K キャッシュ / V キャッシュ）**
- **Flash Attention**: **オン（有効）**
- **思考（Reasoning / Thinking）**: **完全無効化（OFF）**
  - 会話テンポ維持のため、思考プロセス（CoT）を抑制し即座に会話文を生成。
- **プロンプトキャッシュ（Prompt Caching）**: 有効（`--cache-prompt`）
- **スレッド数**: 6
- **評価バッチサイズ**: `batch-size: 2048`, `ubatch-size: 512`
- **並列処理スロット**: 4（`--parallel 4`）

### 2.1 プリセット設定ファイル
LM Studio に以下のプリセットを配備済みです。
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
    },
    "prediction": {
      "fields": [
        { "key": "llm.prediction.reasoning.enableThinking", "value": false },
        { "key": "llm.prediction.temperature", "value": 0.85 },
        { "key": "llm.prediction.maxTokens", "value": 1800 }
      ]
    }
  }
  ```

### 2.2 環境変数の扱いについて
以前の切り分け時に設定したユーザー環境変数（`LLAMA_ARG_CACHE_TYPE_K`, `LLAMA_ARG_CACHE_TYPE_V`, `LLAMA_ARG_FLASH_ATTN`）は、他アプリへの予期せぬ副作用を排除するため**完全に削除**しました。設定は LM Studio のプリセットおよび AISS 側の設定のみで管理します。

---

## 3. 思考（Reasoning）無効化と推論実測結果

### 3.1 思考無効化の手法
1. **API パラメータ制御**:
   AISS の `config.json`（`llm.providers.lmstudio`）に `"reasoning_effort": "none"` および `"reasoning": { "enabled": false }` を設定。
2. **LM Studio プリセット制御**:
   `llm.prediction.reasoning.enableThinking: false` を設定。
3. **プロンプトディレクティブ**:
   `AISS - Japanese Language Addon` の `system_preface_append.txt` に思考タグや推論プロセスを出力せず直ちにセリフを出力する指示を追記。

### 3.2 日本語応答速度実測結果（ストリーミング計測）

| テスト条件 | 入力コンテキスト長 | TTFT (最初の文字が出るまで) | 全文生成完了時間 | Reasoning 出力文字数 | 出力品質・結果 |
|---|---|---|---|---|---|
| **思考有効時 (初期状態)** | 短文 (約19トークン) | 約 3,200 ms | 約 6,000 ms | 764 文字 | 思考展開後に日本語出力（テンポ遅延） |
| **思考無効時 (短文)** | 短文 (約19トークン) | **117 ms (0.12秒)** | **594 ms (0.59秒)** | **0 文字** | 思考ゼロで即座に応答。自然な日本語 |
| **思考無効時 (長文・AISS模擬)** | **約 10,000 トークン**<br>(28,644 文字) | **7,687 ms (約7.69秒)** | **10,488 ms (約10.49秒)** | **0 文字** | 思考ゼロ。バレットの口調・設定を完璧に反映したロールプレイ出力 |

> [!NOTE]
> 約1万トークンの長文入力時、初回は文脈 Prefill に約 7.6 秒を要しますが、思考プロセス（通常長文時は数十秒を要する）が完全にオフ（0文字）になっているため、文脈処理完了と同時にセリフ生成が始まります。また、AISS の会話2ターン目以降はプロンプトキャッシュ（KV キャッシュの再利用）が効くため、TTFT は大幅に短縮されます。

---

## 4. VRAM 計測結果（AMD Radeon RX 9070 16GB）

### 4.1 実測データ比較一覧
GPU パフォーマンスカウンター（`\GPU Process Memory(*)\Dedicated Usage`）による直接実測結果：

| 測定状態・構成 | 専用 VRAM 実測値 | 内訳・備考 |
|---|---|---|
| **1. LM Studio 終了時（ベースライン）** | **約 5.54 GiB** | Windows デスクトップ常駐分（後述） |
| **2. gemma-4-12b-it-qat (16K・f16 実測)** | **8,739.8 MB (8.54 GiB)** | モデル本体: 7.13 GB + f16 KV Cache: 約 2.70 GB |
| **3. gemma-4-12b-it-qat (16K・Q8_0 実測)** | **7,537.2 MB (7.36 GiB)** | モデル本体: 7.13 GB + Q8_0 KV Cache: 約 1.35 GB<br>**実測差分: 1,202.6 MB (約 1.18 GiB 削減)** |
| **4. Q8_0 稼働時システム全体推定値** | **約 12.90 GiB** | ベースライン 5.54 GiB + Q8_0 モデル 7.36 GiB |
| **5. Starfield 起動中（メインメニュー表示時）** | **約 15.34 GiB** | f16 稼働時実測値（専用 VRAM の約 96% 使用） |

### 4.2 常駐プロセス（ベースライン）の内訳と推奨終了アプリ
| プロセス名 | VRAM使用量 (MB) | VRAM使用量 (GiB) | 推奨アクション |
|---|---|---|---|
| `dwm` | 4,360.0 MB | 4.26 GiB | Windows デスクトップ合成（OS管理） |
| `WardogsClient-Win64-Shipping` | **2,306.2 MB** | **2.25 GiB** | **ゲーム前に終了（約 2.3 GB 解放）** |
| `steamwebhelper` | 808.8 MB | 0.79 GiB | Steam 内蔵ブラウザ |
| `msedge` | **598.7 MB** | **0.58 GiB** | **ゲーム前に終了（約 0.6 GB 解放）** |
| `Discord` | **154.3 MB** | **0.15 GiB** | **ゲーム前に終了（約 0.15 GB 解放）** |

※`WardogsClient`、`msedge`、`Discord` を終了することで、**合計 約 3.0 GiB 以上の VRAM が解放**され、Starfield 本編（FHD 7〜9 GB）と併用しても十分な安全マージンが確保されます。

### 4.3 コンテキスト長 32K（32768）不採用の結論
- **f16 KV キャッシュ時**: LM Studio 所要量 **11.62 GiB** + ベースライン 5.54 GiB = **約 17.16 GiB**（**16GB を超過**）。
- **Q8_0 KV キャッシュ時**: LM Studio 所要量 **約 9.38 GB** + ベースライン 5.54 GiB = **約 14.92 GiB**（Starfield 起動で確実に 16GB を突破しクラッシュ）。
- **結論**: **Phase 1 標準設定では 32K は一切使用せず、16K（16384）を絶対上限とします。**
