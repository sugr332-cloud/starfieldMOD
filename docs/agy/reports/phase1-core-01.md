# Phase 1（Core）報告 01

- 日時: 2026-10-03 19:10
- 状態: 停止中（OK 待ち）
- 停止した理由: 止まる場面 1（元に戻せない操作: SFSE ファイルのゲーム直下配置、MO2 インスタンス作成・INI 構成の事前承認）および指示書手順2（チェックポイント1）の計画提示による承認待ち

---

## 実施したこと

1. `main` ブランチの最新コミットを pull し、`phase1-core` ブランチに取り込み（Fast-forward マージ完了）。
2. `docs/agy/README.md`（運用ルール）および `docs/agy/phase1-core.md`（Phase 1 指示書）を精読・把握。
3. 手順1の前提確認を実施（ゲームバージョン、LM Studio モデル認識、MOD アーカイブ 6 件の検出と適合性確認、AISS 付属ドキュメント精査）。
4. 手順3〜6 の具体的な作業計画を策定。

---

## 確認した事実

### 1. ゲーム本体およびツール
- **Starfield.exe**: バージョン `1.16.244.0`（`<Steam>\steamapps\common\Starfield\Starfield.exe`、確認完了）。
- **Mod Organizer 2**: バージョン `2.5.2`（`<MO2>\ModOrganizer.exe`、確認完了）。

### 2. LM Studio モデル
- **モデル**: `gemma-4-12b-it-qat`（`unsloth/gemma-4-12B-it-qat-GGUF`、量子化: `UD-Q4_K_XL`、実測 6,716,356,800 bytes / 約 6.72 GB）。
- `lms ls` にてローカルモデルとして正常登録されていることを確認。
- `mmproj-F32.gguf`（209 MB）は保持。`lms load --estimate-only` にて要求メモリが本体相当の 6.45 GiB のみであることを確認（テキスト推論時には mmproj は読み込まれない挙動）。
- 以前に中断した一時ファイル（465 MB 等）は完全削除済みであることを確認。

### 3. Phase 1 MOD アーカイブ 6 件の一覧と適合性
保存場所: `<Downloads>\`

| MOD名 | アーカイブファイル名 | サイズ (bytes) | バージョン / 適合性確認結果 |
|---|---|---|---|
| **SFSE** | `SFSE 106 0.2.21 2026-06-11T15-06Z F5ipYCCxI.7z` | 380,962 | **0.2.21**<br>内部に `sfse_1_16_244.dll` を含み、本体 `1.16.244.0` に**完全対応**。 |
| **Address Library for SFSE Plugins** | `All in one - v22 (1.16.244.0) SFSE Address Library 3256 22 2026-06-13T10-55Z mN0iaXX3W.zip` | 27,424,645 | **v22**<br>内部に `versionlib-1-16-244-0.bin` を含み、本体 `1.16.244.0` に**完全対応**。 |
| **Cassiopeia Papyrus Extender** | `Cassiopeia Papyrus Extender 10896 10.0 2026-09-07T22-11Z HqFZQYEjo.zip` | 618,585 | **v10.0** (最新版、正常) |
| **Longer Names v2** | `SF LongerNames SFSE-5046-2-0-2-1748345647.zip` | 359,496 | **v2.0.2** (正常) |
| **AISS - AI Settled Systems** | `X2357's AISS - AI Settled Systems 17392 3.75 2026-10-03T06-45Z 4Cgtq5QTS.zip` | 28,770,555 | **v3.75** (最新版、正常) |
| **Absolute HOTAS** | `AbsoluteHOTAS V5.1.0 Release 16668 5.1.0 2026-08-23T05-17Z sVh6UPNvl.zip` | 512,551 | **V5.1.0** (最新版、正常) |

### 4. AISS 付属ドキュメント精査結果
一時フォルダ（リポジトリ外）へ展開して確認：
- **LM Studio 連携**: `config.json` にて `llm.provider: "lmstudio"`, `base_url: "http://127.0.0.1:1234/v1"`, `model: "gemma-4-12b-it-qat"` で直接接続可能。
- **コンテキスト長**: AISS は毎ターン約 11,000〜13,000 トークン（プロンプト＋記憶＋シーン）を送出するため、LM Studio 側のコンテキスト長は 16,384（16K）が最低ライン、32,768（32K）が推奨。
- **起動順序**: LM Studio サーバー起動 → `AISS_Backend.exe` 起動 → SFSE 経由で Starfield 起動。
- **TTS 構造**: `tts.local`（OpenAI `/v1/audio/speech` および fish-speech `/v1/tts`）が設定項目として内蔵されていることを確認。今回の Phase 1 では `tts.enabled: false` に設定し、完全無効化・APIキー不要で運用。
- **出力先**: `latest_response.ini` は `<Starfield>\Data\SFSE\AISS\responses\latest_response.ini` に出力される仕様を確認。

---

## 次にやること（OK が出たら実行すること）

手順3〜6 を以下の計画に沿って一気に実施します：

### 1. 手順3: バックアップの取得
- **保存先**: `<Documents>\My Games\Starfield_Backup_Phase1\`（リポジトリ外）
- **対象**:
  - セーブデータ: `<Documents>\My Games\Starfield\Saves\`
  - INIファイル: `<Documents>\My Games\Starfield\` 内の全 `.ini`
  - ゲーム初期状態記録: `<Starfield>\` 直下のファイル一覧リストを取得・保存

### 2. 手順4: MO2 の準備
- **インスタンス**: Starfield 用のグローバルインスタンスを作成（既存の Bannerlord 用インスタンスは維持）。
- **プロファイル**: `Stable` を作成し、「プロファイル別のセーブゲーム」および「プロファイル別のゲーム設定（INI）」を有効化。
- **INI設定**: MO2 のプロファイル別 `StarfieldCustom.ini` にルーズファイル読み込み設定を追加：
  ```ini
  [Archive]
  bInvalidateOlderFiles=1
  sResourceDataDirsFinal=
  ```
- **nxm 関連付け**: Starfield インスタンスにて nxm リンクの関連付けを有効化。

### 3. 手順5: MOD の導入
- **SFSE 0.2.21**:
  - ゲームフォルダ直下（`<Starfield>\`）に手動配置: `sfse_loader.exe`, `sfse_1_16_244.dll`。
  - MO2 の実行ファイル一覧に `sfse_loader.exe` を登録。
- **他 5 MOD（MO2 経由導入）**:
  1. `Address Library for SFSE Plugins` (v22)
  2. `Cassiopeia Papyrus Extender` (v10.0)
  3. `Longer Names v2` (v2.0.2)
  4. `AISS - AI Settled Systems` (v3.75)
  5. `Absolute HOTAS` (V5.1.0)
- MO2 上でファイルの競合・上書き関係およびプラグイン読み込み順を記録。

### 4. 手順6: LM Studio と AISS の設定
- **LM Studio**:
  - `gemma-4-12b-it-qat` を GPU オフロード 100%、コンテキスト長 8,192（指示書記載の初期値。動作確認後に推奨 32K への拡張を検討）、画像入力（Vision）無効でロード。
  - ローカルサーバー（`http://127.0.0.1:1234`）を起動し、API モデル識別子を確認。
- **AISS `config.json`**:
  - `llm.provider`: `"lmstudio"`
  - `llm.providers.lmstudio.enabled`: `true`
  - `llm.providers.lmstudio.base_url`: `"http://127.0.0.1:1234/v1"`
  - `llm.providers.lmstudio.model`: `"gemma-4-12b-it-qat"`
  - `tts.enabled`: `false`
  - 日本語会話プロンプト指示（仕様書5章準拠）の追加。
- **起動順序の確立**:
  1. LM Studio ローカルサーバー起動
  2. `AISS_Backend.exe` 起動（MO2 仮想環境またはツール経由）
  3. MO2 から `sfse_loader.exe` 起動

---

## 問題・仕様との食い違い

1. **アーカイブの保存場所**:
   - 指示書記載: `D:\StarfieldMODs\Phase1`
   - 実際: `<Downloads>\`（ユーザーによる直接ダウンロード。6件すべて存在確認済み）
   - *影響*: パスのみの差異であり、内容・バージョンに問題はありません。
2. **LM Studio モデル量子化形式**:
   - 仕様書想定: `Q4_K_M`
   - 実際: `UD-Q4_K_XL`（約 6.72 GB、Unsloth QAT リポジトリの提供仕様）
   - *影響*: ユーザー承認済み。VRAM 16GB の環境で問題なく動作可能。
