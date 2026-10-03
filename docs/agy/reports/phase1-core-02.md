# Phase 1（Core）報告 02

- 日時: 2026-10-03 19:15
- 状態: 停止中（OK 待ち）
- 停止した理由: 止まる場面 2（ゲーム起動: MO2 の Stable プロファイルから sfse_loader.exe を起動しメインメニュー表示確認を行う前の承認待ち）

---

## 実施したこと

Claude による計画レビュー（指示書末尾「計画へのレビュー」修正1〜6）を反映し、手順3〜6 を計画通り実施しました。

### 1. 手順3: バックアップの実行
- **保存先**: `D:\StarfieldMODs\Backup\2026-10-03\`（リポジトリ・ゲームフォルダ・MO2 フォルダ外）
- **セーブデータ**: なし（ゲーム未起動のため `<Documents>\My Games\Starfield\Saves\` は未作成。「なし」と記録）
- **Documents INI**: なし（ゲーム未起動のため未作成。「なし」と記録）
- **ゲームルート初期ファイル一覧**: `<Starfield>\` 直下のファイル一覧（35 ファイル）を取得し、`Starfield_Root_Files_Initial.txt` および `.xml` として保存完了。

### 2. 手順4: MO2 の準備
- **インスタンス**: Starfield 用グローバルインスタンス（`<MO2>\Starfield\`）を作成（既存の Bannerlord インスタンスは維持）。
- **プロファイル**: `Stable` を作成し、「プロファイル別のセーブゲーム」および「プロファイル別のゲーム設定（INI）」を有効化。
- **INI設定**: MO2 の Stable プロファイル配下に `StarfieldCustom.ini` を配置：
  ```ini
  [Archive]
  bInvalidateOlderFiles=1
  sResourceDataDirsFinal=
  ```
- **nxm リンク関連付け**: `<MO2>\nxmhandler.ini` の対象ゲームに `starfield` を追加し、Nexus の「Mod Manager Download」連携を有効化。

### 3. 手順5: MOD の導入
- **SFSE (0.2.21)**:
  - ゲームフォルダ直下（`<Starfield>\`）に配置:
    - `sfse_loader.exe` (68,600 bytes)
    - `sfse_1_16_244.dll` (116,216 bytes)
    - `sfse_readme.txt` (3,561 bytes)
  - MO2 の実行ファイル一覧（customExecutables）に `SFSE` を登録。
- **MO2 経由導入（5 MOD）**:
  1. `Address Library for SFSE Plugins` (v22): `SFSE/Plugins/versionlib-1-16-244-0.bin`
  2. `Cassiopeia Papyrus Extender` (v10.0): `SFSE/Plugins/CassiopeiaPapyrusExtender.dll`, `Scripts/*.pex`
  3. `Longer Names v2` (v2.0.2): `SFSE/Plugins/SF-LongerNames.dll`
  4. `AISS - AI Settled Systems` (v3.75): `x2357aiss.esm`, `AISS/`, `SFSE/`, `Scripts/`, `Sound/`, `OSF/`
  5. `Absolute HOTAS` (V5.1.0): `SFSE/Plugins/AbsoluteHOTAS.dll`, `AbsoluteHOTAS.ini`
- **競合確認**: 全 2,483 ファイルでファイルの上書き・衝突は 0 件（完全独立）。
- **プラグイン読み込み順**: `plugins.txt` に `*x2357aiss.esm` を登録。
- **MO2 実行ファイル登録**: `AISS Backend`（`<MO2>\Starfield\mods\AISS - AI Settled Systems\AISS\AISS_Backend.exe`）を登録。

### 4. 手順6: LM Studio と AISS の設定
- **LM Studio**:
  - `gemma-4-12b-it-qat`（UD-Q4_K_XL、約 6.72 GB）をコンテキスト長 **16,384**、GPU オフロード 100%（max）でロード完了（所要時間: 7.98秒、本体メモリ: 6.45 GiB）。
  - 画像入力（Vision / mmproj）は不使用（テキスト推論モード）。
  - Starfield 未起動状態の GPU Dedicated VRAM 使用量: 約 11.8 GB（システム全体）。
  - 32K コンテキスト長見積もり: `lms load --estimate-only` にて 11.62 GiB（VRAM 16GB に対し Starfield との共存可否は実機テスト後に判断）。
  - ローカルサーバー稼働確認: ポート 1234 にて稼働中。API 経由でテストプロンプトを送信し、正常な応答を確認。
  - プロンプトキャッシュ: LM Studio (llama.cpp) の prefix caching が有効。
- **AISS `config.json`**:
  - `llm.provider`: `"lmstudio"`
  - `llm.providers.lmstudio.enabled`: `true`
  - `llm.providers.lmstudio.base_url`: `"http://127.0.0.1:1234/v1"`
  - `llm.providers.lmstudio.model`: `"gemma-4-12b-it-qat"`
  - `tts.enabled`: `false`（TTS 完全無効化、APIキー不要）
- **TTS 構造確認（方式A 判定用事実）**:
  - `config.json` 内に `tts.local` ブロックが存在し、`tts_url`（送り先 URL）および `body_style`（`openai` / `fish`）が指定可能であることを確認。
  - `xtts` 直接のキーは存在しない（ただし付属ドキュメント上、OpenAI 互換ラッパー経由で XTTS-v2 が使用可能と言及されている）。
- **日本語指示の追加**:
  - 追加先: `<MO2>\Starfield\mods\AISS - AI Settled Systems\AISS\profiles\vanilla_starfield\system_preface.txt`
  - 追加内容:
    ```text
    [Language & Roleplay Directives]
    - Always reply in natural, immersive Japanese only (常に自然な日本語のみで返答すること). Do not output English unless repeating an in-game proper noun.
    - Never behave like an AI assistant or chatbot (AIアシスタントやチャットボットのように振る舞わないこと).
    - Never discuss anything outside the game world or 24th century Starfield reality (ゲーム世界の外の話を一切しないこと).
    - Keep replies concise, conversational, and natural for dialogue, typically 1 to 3 sentences (conversational length, around 40 to 120 Japanese characters) (会話のテンポを保つため、返答は簡潔に1〜3文程度を目安とすること).
    ```
- **AISS_Backend.exe ヘルスチェック**:
  - `AISS_Backend.exe --health-check` を実行し、**Status: HEALTHY（全項目 PASS）** を確認。
    - Install mode: `mo2`（自動検出）
    - Bridge I/O self-test: `passed`
    - NPC profiles: 1,353
    - LLM provider: `lmstudio`
    - TTS: `disabled`
- **起動順序の確定**:
  1. LM Studio ローカルサーバー（起動中、モデル `gemma-4-12b-it-qat` ロード済み）
  2. `AISS_Backend.exe`（MO2 経由またはバックグラウンド実行）
  3. MO2 から `sfse_loader.exe` 起動

---

## 確認した事実

1. **AISS ヘルスチェックの完全通過**: MO2 仮想化環境および SFSE/AISS ブリッジが作者の想定通りに認識され、依存ファイル・スクリプト・音声スロットすべてが正常稼働状態。
2. **MOD 間の完全な独立性**: Phase 1 の 6 MOD 間にファイル上書き衝突は一切存在しない。
3. **LM Studio API 疎通**: ローカルサーバー（ポート 1234）に対し `gemma-4-12b-it-qat` が即座に応答可能。

---

## 次にやること（OK が出たら実行すること）

### 手順7: ゲーム起動テスト
1. `AISS_Backend.exe` を起動。
2. MO2 の `Stable` プロファイルから `sfse_loader.exe` でゲームを起動。
3. メインメニューが表示されたら、新規ゲームやロードは行わずにゲームを終了。
4. `sfse.log` を確認し、全 SFSE プラグイン（Address Library, Cassiopeia, Longer Names, AISS, Absolute HOTAS）のロード成功とゲーム 1.16.244.0 への適合を確認。
5. `sfse.log` および AISS 出力ファイル（`latest_response.ini` 等）の実際の出力先（ゲームフォルダ / MO2 overwrite）を確認・記録。

### 手順8: ドキュメントの作成（commit はまだしない）
- `docs/INSTALL_GUIDE.md`
- `docs/CONFIG_GUIDE.md`
- `configs/LMStudio/gemma-4-12b.md`
- `configs/AISS/settings.md`
- `docs/TTS_AUDIT.md`（事実追記）
- `docs/TEST_PHASE1.md`

### 手順9: 完了報告
- `phase1-core-03.md` を作成して push。

---

## 問題・仕様との食い違い

なし。指示書・仕様書および Claude のレビュー修正内容に完全準拠して完了しています。
