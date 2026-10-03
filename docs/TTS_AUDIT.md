# Starfield Space Life JP — 無料AI音声（TTS）監査レポート

- 調査日: 2026-10-03
- 参照仕様: `docs/MOD_SPEC.md` (v0.5) 5.1章・9章・14章

---

## 1. AISS の TTS 対応状況と公開仕様

### 1.1 公式対応状況
- AISS公式でサポートされているTTSプロバイダ: **ElevenLabs** および **Fish Audio**（いずれもクラウドAPI、要アカウント、APIキー、従量課金/クレジット制）。
- ローカル無料TTSに対する公式対応は現時点で未提供。
- ローカル常駐プログラム `AISS_Backend.exe` が AI/TTS 通信、音声再生キュー、口パク（リップシンク）の同期処理を担当。
- 生成音声のキャッシュ保存先: `<Starfield>\Data\SFSE\AISS\audio` (MP3形式)。
- 送信・受信ログの出力先:
  - `<Starfield>\Data\SFSE\AISS\requests\latest_request.ini`
  - `<Starfield>\Data\SFSE\AISS\responses\latest_response.ini`

### 1.2 送り先URL（base URL）変更・xtts枠・ダミーキーの検証状況
- **送り先URL（base URL / endpoint）の変更可否**:
  - Nexus Mods の公式説明文および公開ドキュメントには、TTSの接続先URLを変更する設定項目（`base_url` や `endpoint`）の記載は存在しない。
  - ローカル実機調査の結果、手元に AISS が未導入（未入手）であるため、`<Starfield>\Data\AISS\config.json` 内に未公開の内部エンドポイント指定項目が存在するかは**未確認（Phase 1 導入時に実設定ファイルを確認）**。
- **「xtts」枠の実装状況**:
  - 設定ファイルに「xtts」に関する項目が存在するとのコミュニティ報告があるが、実際にバイナリ側でローカル XTTS サーバーと通信するロジックが組み込まれているかは**未確認**。
- **ダミーキーの動作可否**:
  - 公式プロバイダ（ElevenLabs / Fish Audio）はクラウド認証を前提としており、正規のAPIキーがない場合は認証エラーとなる。

### 1.3 latest_response.ini および MO2 環境での出力先（未確認事項）
- `latest_response.ini` の正確な内部構造（セクション名、キー名、文字エンコーディング、ト書き等の混入形式）は、実ファイル未入手のため**未確認（Phase 1 導入時に実機で確認）**。
- MO2 環境下において、本ファイルが実際に `<Starfield>\Data\SFSE\AISS\` に出力されるか、あるいは MO2 の `overwrite\SFSE\AISS\` にリダイレクトされるかについても**未確認（Phase 1 で実機確認）**。

---

## 2. 接続方式（A / B / C / D）の成立性判定

仕様書5.1に定義された各方式の成立可否および判定根拠:

| 方式 | 概要 | 成立判定 | 判定根拠 |
|---|---|---|---|
| **方式A** | AISSのTTS接続先をローカルTTSブリッジに向ける（口パク同期あり） | **未確定 / 保留** | 公開ドキュメント上にTTSエンドポイント変更設定が明記されていない。手元にAISSファイルがないため未確認。**AISS入手後に `config.json` を確認して最終判定する**。 |
| **方式B** | AISS公式による無料/ローカルTTS対応 | **不可** | 現行バージョンでは未実装であり、公式アップデート予定も未確定。 |
| **方式C** | 接続先を変更できない場合（仕様書5.1定義の分岐） | **方式Dへ移行** | AISS本体の改変・逆解析は行わず、有料TTSの契約もしないため、方式Aが不可の場合は方式Dへ移行する。 |
| **方式D** | `latest_response.ini` の外部監視によるローカル読み上げ（口パクなし） | **【暫定採用】** | AISS本体や設定を改変せず、AISSのTTSを無効にした状態で、出力されるレスポンスログ（`latest_response.ini`）を外部ツール（`tools/tts-reader/`）が読み取り、ローカルTTSエンジンへ送出して再生する。**方式Aの可否が確定するまでの間、本方式を暫定採用とする**。 |

---

## 3. 無料ローカルTTSエンジン候補の比較評価

本プロジェクトのハードウェア環境（Windows 11、Ryzen 7 7800X3D、Radeon RX 9070 16GB）における各TTSエンジンの適合性評価:

| エンジン名 | 最新版 / 開発元 | Windows / AMD GPU 対応 | CPU実行の可否と速度 | 日本語品質・評判 | API 形式 | ライセンス / 利用規約 | 採用判定 |
|---|---|---|---|---|---|---|---|
| **AivisSpeech Engine** | 最新版 (v1.x)<br>Aivis-Project | **対応**<br>(DirectML / CPU) | **◎ 極めて高速**<br>(ONNX Runtime最適化) | **◎ 非常に自然**<br>(感情表現・イントネーション良好) | HTTP REST<br>(VOICEVOX互換) | エンジン: LGPL-3.0<br>モデル: Aivm形式 (**※モデルごとに利用規約の確認が必要**) | **【第一候補として採用】**<br>出典: [GitHub AivisSpeech-Engine](https://github.com/Aivis-Project/AivisSpeech-Engine) |
| **VOICEVOX Engine** | 最新版 (v0.21+)<br>Hiroshiba | **対応**<br>(DirectML / CPU) | **○ 高速** | **◎ 非常に良好**<br>(キャラ声が豊富) | HTTP REST<br>(ポート 50021) | エンジン: LGPL-3.0<br>キャラクター: クレジット表記必須 (例: VOICEVOX:ずんだもん) | **第二候補 (比較・検証用)**<br>出典: [GitHub voicevox_engine](https://github.com/VOICEVOX/voicevox_engine) |
| **Style-Bert-VITS2** | 最新版 (v2.x)<br>litagin02 | AMD GPU非対応<br>(CUDA中心) | **△ 可能だが負荷高**<br>(Python/PyTorch) | **◎ 最高峰**<br>(文脈理解・感情表現) | HTTP REST<br>(FastAPI) | エンジン: AGPL-3.0<br>モデル: 各作者規約に準拠 | 保留 (CPU負荷大、ライセンス厳格)<br>出典: [GitHub Style-Bert-VITS2](https://github.com/litagin02/Style-Bert-VITS2) |
| **fish-speech** | 最新版<br>Fish Audio OSS | Windowsネイティブ難<br>(WSL2推奨、AMD不可) | **× 極めて低速** | **○ 良好** | HTTP REST | コード: BSD-3<br>重み: 非商用 (CC-BY-NC-SA-4.0) | 見送り (環境構築難、重い)<br>出典: [GitHub fish-speech](https://github.com/fishaudio/fish-speech) |
| **XTTS v2** | 最終版 (v2.0.2)<br>Coqui (後継フォーク) | AMD GPU非対応<br>(CUDA中心) | **× リアルタイム未満**<br>(音声長より生成が遅い) | **△ やや不自然**<br>(日本語アクセント崩れ) | Python API / REST | CPML (非商用限定、商用ライセンス購入不可) | 見送り (低速、日本語品質難)<br>出典: [HuggingFace Coqui XTTS-v2](https://huggingface.co/coqui/XTTS-v2) |
| **Irodori-TTS** | 最新版 (v4.x)<br>Aratako | AMD GPU非対応<br>(CUDA推奨) | **× 低速**<br>(DiT拡散モデルのため重い) | **○ 高品質だが誤読あり**<br>(漢字の読みに前処理必要) | OpenAI互換 REST | MIT (倫理規定あり) | 見送り (推論コスト大)<br>出典: [GitHub Irodori-TTS](https://github.com/Aratako/Irodori-TTS) |
| **Windows標準 (SAPI/OneCore)** | OS標準機能 | **完全対応** | **◎ 最速・軽量** | **△ 機械的** | Win32 / COM | Windowsライセンス内 | 最終フォールバック用 |

---

## 4. 第一候補: AivisSpeech Engine を方式Dで運用する場合の注意点

方式D（`tools/tts-reader/` による外部読み上げ）および AivisSpeech Engine を採用する際の重要設計要件:

### 4.1 読み上げツール（tts-reader）の設計要件
1. **ファイルの監視と二重読み防止**:
   - `latest_response.ini` の最終更新日時およびコンテンツのハッシュ値を保持し、同一内容の多重再生を防止する。
   - ファイル書き込み途中の破損データを読み込まないよう、ファイル更新検知後にデバウンス待機（数十ミリ秒）を設ける。
2. **MO2環境におけるファイル監視パスの指定**:
   - MO2 の VFS 環境下で実際にログが出力されるパス（`<Starfield>\Data\SFSE\AISS\` または MO2 の `overwrite` フォルダ）を設定ファイル（`config.json` 等）で自由に指定可能にする。
3. **不要タグ・ト書きのサニタイズ（テキスト前処理）**:
   - LLM の返答に含まれるト書き（例: `*微笑みながら*`、`（小さく頷く）`）や、感情タグ・JSON断片を正規表現で事前に除去してから TTS に送出する。
   - 英字略称やStarfield固有の固有名詞に対する「読み替え辞書（`configs/TTS/replace_dict.json`）」を適用する。
4. **長文分割による再生遅延の最小化**:
   - 長文の回答が生成された場合、句点（「。」「！」「？」）で文単位に分割し、先頭文が合成された時点で即座に音声再生を開始する（パイプライン処理）。これにより体感遅延を最小化する。

### 4.2 ハードウェア・リソース配分
- **実行プロセッサ**: **CPU実行（Ryzen 7 7800X3D）**
  - ONNX Runtime 版の AivisSpeech Engine は CPU 最適化が施されており高速に動作するため、8コア/16スレッドの CPU を活用することで、GPUの VRAM（16GB）を Starfield と LM Studio（Gemma 4 12B QAT）に全量割り当てることが可能。
- **音声モデルのライセンス遵守**:
  - AivisSpeech で使用する音声モデル（`.aivm` ファイル）は、**モデルごとに個別の利用規約（商用利用の可否、クレジット表記の要否、改変条件等）が定められているため、採用するモデルごとに必ず利用規約を確認し遵守する**。
