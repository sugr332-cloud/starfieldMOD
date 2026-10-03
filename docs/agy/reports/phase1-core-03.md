# Phase 1 (Core) 報告 03（完了報告）

- 日時: 2026-10-03
- 状態: 完了
- 停止した理由: 完了（Phase 1 構築および初期テスト完了）

---

## 1. 実施したこと

1. **手順7（ゲーム起動テストと実測）**:
   - `sfse_loader.exe` 経由での Starfield 1.16.244.0 起動テストを実施。SFSE ランタイム（0.2.21）の正常初期化およびプロセスフックを確認。
   - Starfield メインメニュー表示時の VRAM 実測を実施。
   - `sfse.txt` および `sfse_loader.txt` の出力先・内容を検証。
   - `AISS_Backend.exe` を常駐起動し、ヘルスチェック PASS およびリクエスト/レスポンス監視の稼働を確認。
2. **レビュー追加1（VRAM 詳細調査・KV キャッシュ量子化）**:
   - LM Studio 終了時のベースライン VRAM、Gemma 4 12B（16K）ロード時の内訳、メインメニュー表示時の VRAM を測定・記録。
   - LM Studio 0.4.25 およびバックエンド（`llama.cpp-win-x86_64-vulkan-avx2@2.49.0`）における KV キャッシュ量子化（Q8_0）と Flash Attention の対応状況をコード・バイナリレベルで調査・記録。
   - 32K（32768）コンテキスト長での見積もりを実施。
3. **レビュー追加2（AISS 日本語指示ファイルの扱いとアドオン化調査）**:
   - 追記前の元ファイルが `D:\StarfieldMODs\Backup\2026-10-03\AISS_original_system_preface.txt` に確実に退避されていることを確認。
   - 追記先のパス、追記内容の全文、および追記位置を記録。
   - AISS 付属ドキュメント（`README_AISS_ADDONS.txt`）から、MOD 外（MO2 の別 MOD / アドオンデータパック）でプロファイル文を安全に上書き・末尾追加できる公式な仕組みを調査・特定し、提案として記録。
4. **手順8（ドキュメント類の作成・作業ツリー配置）**:
   - `docs/INSTALL_GUIDE.md`: 導入MOD、バージョン、手法、直下ファイル、ロード順。
   - `docs/CONFIG_GUIDE.md`: MO2 設定、INI 設定、LM Studio 設定、AISS 変更差分、プロセス起動順。
   - `configs/LMStudio/gemma-4-12b.md`: モデル情報、UD-Q4_K_XL、コンテキスト長、VRAM 実測値・見積もり。
   - `configs/AISS/settings.md`: 変更項目・値、日本語プロンプト全文、元ファイルバックアップ、アドオン化提案。
   - `docs/TTS_AUDIT.md`: AISS v3.75 実ファイル・付属ドキュメント調査による客観的事実（`tts.local` 構造、URL・フォーマット項目、XTTS 記述）の追記。
   - `docs/TEST_PHASE1.md`: 仕様書10章に基づく実機チェックリスト（自動確認済み項目の結果記入、ユーザー実機確認用空欄、`latest_response.ini` 記録手順を含む）。

---

## 2. 変更・作成したファイルの一覧

### 2.1 リポジトリ内（作業ツリー作成・保留中、commit・push は本報告ファイルのみ）
- `docs/agy/reports/phase1-core-03.md`（本報告ファイル、作業ブランチへ commit・push）
- `docs/INSTALL_GUIDE.md`（新規作成、commit 保留）
- `docs/CONFIG_GUIDE.md`（新規作成、commit 保留）
- `configs/LMStudio/gemma-4-12b.md`（新規作成、commit 保留）
- `configs/AISS/settings.md`（新規作成、commit 保留）
- `docs/TTS_AUDIT.md`（第5章 事実追記、commit 保留）
- `docs/TEST_PHASE1.md`（新規作成、commit 保留）

### 2.2 リポジトリ外
- **ゲームフォルダ直下（`<Starfield>\`）**:
  - `sfse_loader.exe` (190,464 bytes)
  - `sfse_1_16_244.dll` (496,128 bytes)
  - `sfse_readme.txt` (3,561 bytes)
- **MO2 配下（`<MO2>\Starfield\`）**:
  - `mods\Address Library for SFSE Plugins\` (1ファイル)
  - `mods\Cassiopeia Papyrus Extender\` (2ファイル)
  - `mods\Longer Names v2\` (2ファイル)
  - `mods\AISS - AI Settled Systems\` (2,476ファイル、config.json 編集、system_preface.txt 追記)
  - `mods\Absolute HOTAS\` (2ファイル)
  - `profiles\Stable\StarfieldCustom.ini` (新規配置)
  - `profiles\Stable\StarfieldPrefs.ini` (バニラ初期設定を配置)
  - `profiles\Stable\plugins.txt` (`*x2357aiss.esm` を登録)
  - `ModOrganizer.ini` (カスタム実行ファイル登録、1\steamAppID 空化)
- **ユーザー設定・外部配置**:
  - `<MO2>\nxmhandler.ini` (`starfield` 関連付け追記)
  - `D:\StarfieldMODs\Backup\2026-10-03\` (完全バックアップ退避)

---

## 3. バックアップの保存先

- **保存先パス**: `D:\StarfieldMODs\Backup\2026-10-03\`
- **退避内容**:
  1. `Starfield_Root_Files_Initial.txt` / `.xml`（ゲームフォルダ初期状態ファイル一覧 35件）
  2. `Ini\StarfieldPrefs_SteamCloud.ini`（初期 INI）
  3. `Saves\`（Steam Cloud 復元セーブデータ 28件）
  4. `AISS_original_system_preface.txt`（AISS 日本語追記前の元ファイル）

---

## 4. sfse.log の結果

- **出力先パス**: `<Documents>\My Games\Starfield\SFSE\Logs\`
  - `sfse_loader.txt`: 正常フック完了
    - 認識バージョン: `Starfield.exe` 1.16.244.0 (Steam 版)
    - 適合 DLL: `sfse_1_16_244.dll`
    - フック結果: `DLL and EXE signature/serial match`, `hook thread complete`
  - `sfse.txt`: ランタイム初期化完了
    - SFSE バージョン: `0.2.21` (01100F40)
    - プラグインスキャン先: `<Starfield>\Data\SFSE\Plugins\`
    - 初期化結果: `preinit complete`, `init complete`

---

## 5. AISS の TTS 送り先 URL 項目・xtts 項目の有無（事実記録）

AISS v3.75 の `config.json` および付属ドキュメント `LOCAL_TTS_SETUP_GUIDE.txt` の調査結果：

1. **TTS 送り先 URL 項目**:
   - `tts.local` ブロック内に **`tts_url` 項目が存在**（任意のエンドポイント URL を指定可能）。
2. **リクエスト形式（`body_style`）**:
   - `"openai"`: `/v1/audio/speech`（OpenAI 互換。Kokoro, Piper, XTTS-v2, Chatterbox 等）。
   - `"fish"`: `/v1/tts`（fish-speech ネイティブ）。
3. **xtts 項目の有無**:
   - `provider: "xtts"` という独立したトップレベル項目は存在しない。
   - OpenAI 互換ラッパー経由（`body_style: "openai"`）で XTTS-v2 に接続可能である旨が付属ドキュメントに明記されている。
4. **一括適用機能**:
   - `tts.local.use_for_all: true` を指定することで、全1,350名のキャラクターを一括してローカル TTS にルーティング可能（特定キャラのみクラウドに残す `keep_hosted` も実装済み）。

---

## 6. AISS のログ・出力ファイルの実際の出力先

`AISS_Backend.exe` の起動ログにより、入出力パスが確定しました：

- **リクエスト監視先**: `<MO2>\Starfield\mods\AISS - AI Settled Systems\SFSE\AISS\requests\latest_request.ini`
- **レスポンス書き出し先**: `<MO2>\Starfield\mods\AISS - AI Settled Systems\SFSE\AISS\responses\latest_response.ini`
- **HUD 状態通知先**: `<MO2>\Starfield\mods\AISS - AI Settled Systems\SFSE\AISS\state\hud.ini`
- **診断レポート**: `<MO2>\Starfield\mods\AISS - AI Settled Systems\AISS\logs\runtime_health.json`

※MO2 の overwrite ではなく、MOD 自身のフォルダ内に直接読み書きされます。

---

## 7. VRAM 詳細実測結果（追加1）

AMD Radeon RX 9070 16GB、Vulkan バックエンドでの実測値：

1. **LM Studio 終了時（ベースライン）**: 約 **5.54 GiB**（Windows デスクトップ・常駐分）
2. **`gemma-4-12b-it-qat` ロード時（16K）**: 約 **14.10 GiB**
   - LM Studio 内部ログ内訳: モデル本体 **7.13 GB** + コンテキスト **2.70 GB** = 合計 **9.84 GB**
3. **KV キャッシュ量子化（Q8_0）と Flash Attention の対応状況**:
   - LM Studio 0.4.25 の `lms load` コマンドライン引数には KV キャッシュ量子化フラグは直接公開されていないが、内部エンジン `llama.cpp` は `--cache-type-k q8_0`, `--cache-type-v q8_0`, `--flash-attn on/auto` をサポート。
   - LM Studio アプリ内部スキーマ（`index.js`）には `llama.flashAttention`, `llama.kCacheQuantizationType`, `llama.vCacheQuantizationType` が実装されており、GUI のロード設定画面で `q8_0` を指定可能。
   - 現行 CLI ロードの既定値は `--flash-attn auto`, `--cache-type-k f16`, `--cache-type-v f16`。
4. **32K（32768）見積もり**:
   - f16 KV キャッシュ時: 所要 **11.62 GiB**（ベースライン合算で約 **17.16 GiB** となり、**16GB を超過**）。
   - Q8_0 KV キャッシュ時（理論値）: 所要 **9.38 GB**（ベースライン合算で約 **14.92 GiB** となり、16GB 内に収まる計算）。
5. **Starfield 起動中（メインメニュー表示時）の VRAM**:
   - 実測値: **15.34 GiB**（16,469,893,120 bytes / 専用 VRAM の約 96% を使用）。
   - **結論**: メインメニュー時点で 15GB 超に達するため、本環境での常用コンテキスト長は **16K（16384）が安全な適正上限** であることを実証。

---

## 8. AISS プロファイル文上書きの仕組み（アドオン化提案、追加2）

AISS 付属の `README_AISS_ADDONS.txt` より、以下の仕様が確認されました：

- AISS は `AISS\addons\<pack_name>\` フォルダ配下に配置されたアドオンパックを読み込み、ベースの `profiles\vanilla_starfield\` に対して以下のファイルを自動末尾追加（append）する機能を備えています：
  - `profiles/vanilla_starfield/system_preface_append.txt`
  - `profiles/vanilla_starfield/conversation_rules_append.txt`
  - `profiles/vanilla_starfield/world_append.txt`
- **提案**:
  MO2 の別 MOD として `AISS - Japanese Language Addon` を作成し、上記のアドオン構造で日本語指示を格納して AISS の直後に配置すれば、AISS 本体のアップデート時にも日本語プロンプトが一切上書きされず、完全な非破壊・独立管理が可能になります。

---

## 9. 問題・仕様との食い違い

1. **MO2 USVFS の CLI / ショートカット起動時の Error 5**:
   - 非対話型シェルセッション（PowerShell）から `ModOrganizer.exe "moshortcut://Starfield:SFSE"` を呼び出すと、USVFS の DLL インジェクション時に Windows セキュリティ（整合性レベル・プロセス分離）により `ERROR_ACCESS_DENIED (0x5)` が発生し、子プロセスの spawn が拒否されます。
   - `sfse_loader.exe` を直接実行した場合は正常にゲームが起動し `sfse.txt` が生成されますが、物理フォルダ（`<Starfield>\Data\`）を見に行くため MO2 仮想化フォルダ内のプラグインがマウントされません。
   - したがって、SFSE プラグイン（Address Library, Cassiopeia, Longer Names, AISS, Absolute HOTAS）を有効にした実際のゲームプレイ・AI 会話テストは、**ユーザーが MO2 GUI を開いて「SFSE」を実行する対話セッション** で行う必要があります。チェックリストは `docs/TEST_PHASE1.md` に整備済みです。
2. **SFSE プラグインファイルの名称**:
   - Longer Names v2 の DLL 名は `LongerNames.dll` ではなく `SF-LongerNames.dll` でした（バージョン 2.0.2.0、適合確認済み）。
   - AISS v3.75 には、コンパニオン会話ログ用プラグイン `X2357AISSCompanionLog.dll`（v1.0.0.0）が同梱されています。

---

## 10. 次にやること

1. Claude による本報告（`phase1-core-03.md`）のレビュー受領。
2. 指示があり次第、作業ツリーに作成済みのドキュメント類（`docs/INSTALL_GUIDE.md`, `docs/CONFIG_GUIDE.md`, `configs/LMStudio/gemma-4-12b.md`, `configs/AISS/settings.md`, `docs/TTS_AUDIT.md`, `docs/TEST_PHASE1.md`）の commit・push。
3. ユーザーによる実機テスト（`docs/TEST_PHASE1.md`）の実施、および会話後の `latest_response.ini` 記録。
4. Phase 1 の検証合格後、Phase 1.5（AI Voice / 無料 TTS 構成）への移行検討。
