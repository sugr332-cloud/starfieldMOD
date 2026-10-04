# Phase 1 実機テスト問題修正 報告 01

- 日時: 2026-10-04
- 状態: 停止中（ユーザーテスト・OK 待ち）
- 停止した理由: 指示書（`docs/agy/phase1-fix.md` 作業6）の規定に従い、作業1〜5の調査・修正・ドキュメント作成を完了し、ユーザーによる動作確認テスト待ちのため停止。agy はゲームを起動していません。

---

## 1. 実施したこと

1. **ブランチ作成**: `main` から `phase1-fix` ブランチを作成・チェックアウト。
2. **作業1: AISS が使えない原因の調査と修正**:
   - 14:17 のテストログを精査（`latest_request.ini`, `latest_response.ini`, `runtime_health.json`, LM Studio サーバーログ, MO2 USVFS ログ）。
   - **原因特定**: ゲーム側（Papyrus）は正常に `latest_request.ini` を書き込み HUD に「AISS REQUEST SENT TO MARSHAL DANIEL BLAKE.」を表示していたが、**`AISS_Backend.exe` が未起動（プロセス不在）だった**ため、リクエストが処理されず待機状態のままとなっていた。
   - 未起動の原因は、ワンクリックランチャー（`Start-StarfieldAI.ps1`）が MO2 の `moshortcut://Starfield:AISS Backend` を発行した 3 秒後に `moshortcut://Starfield:SFSE` を連続発行したため、MO2 が多重起動例外（0xc0000005 アクセス違反）を起こし AISS Backend の立ち上げに失敗していたこと。
   - **修正**: AISS 公式ドキュメント（`INSTALL.txt`）の通り、AISS Backend は MO2 の VFS インジェクトを必要とせず単体で MO2 フォルダを自動検知して直接動作する。そのため、ランチャーから `AISS_Backend.exe` を直接起動（プロセス多重起動チェック・正常稼働確認付き）するように改修。
3. **作業2: 音声が英語になる原因の調査と修正**:
   - Steam 設定（`appmanifest_1716740.acf`）は `language=japanese`、ゲームフォルダの `Data` には日本語音声 BA2（`Starfield - Voices_ja01.ba2` 等）が揃っていることを確認。
   - **原因特定**: MO2 Stable プロファイルの `StarfieldCustom.ini` に `sLanguage=ja` しか指定されておらず、音声アーカイブの指定（`sResourceLocaleVoiceList` / `sResourceEnglishVoiceList`）がなかったため、起動時のエンジン判定により英語音声 BA2（`Voices01.ba2` 等）が優先マウントされていた。また、`StarfieldPrefs.ini` の画質設定がユーザーの元のバニラ設定（Quality=1: 中低、Scale=0.5）ではなく Ultra（Quality=4: 最高、Scale=0.75）になっていた。
   - **修正**:
     - `StarfieldCustom.ini`（バックアップ取得済）の `[Archive]` セクションに日本語音声 BA2 リスト（`sResourceLocaleVoiceList` および `sResourceEnglishVoiceList`）を追加。
     - `StarfieldPrefs.ini`（バックアップ取得済）にユーザーのバニラ設定（Quality=1, Scale=0.5 等）を反映。
4. **作業3: ランチャーの Stable プロファイル固定とショートカット整理**:
   - `tools/launcher/launcher.config.json` および `launcher.config.example.json` に `"mo2Profile": "Stable"` を追加。
   - ランチャー起動時に MO2 の `ModOrganizer.ini` の `selected_profile` を検査・自動補正し、かつ MO2 の起動引数に `-p "$mo2Profile"` を渡すように改修。
   - デスクトップの切り分け用ショートカット「Starfield（MOD・LLMなし）.lnk」を「Starfield（MOD・LLMなし・テスト用）.lnk」にリネーム。
5. **作業4: 英語 MOD テキスト一覧と翻訳方針**:
   - Phase 1 で導入された MOD のプレイヤー向け英語テキスト（AISS の UI・通知文、Roleplayers' Alternate Start の選択肢・ターミナル・改変会話、Absolute HOTAS の設定画面）を精査。
   - 仕様書6章の優先度（S/A/B）を付与し、翻訳手法（xTranslator による独立パッチMOD作成）および作業量見積もりを `docs/MOD_JAPANESE.md` に追記。
6. **作業5: 日本語入力の調査**:
   - AISS の入力構造（`TextInputMenu` -> `long_input_capture.ini` -> `latest_request.ini` -> Backend）を解析。
   - ゲーム外の小型日本語入力ツールやクリップボードペースト支援の実現案と注意点を整理（本報告第5節に記載）。

---

## 2. 確認した事実（調査結果と証拠）

### 2.1 AISS リクエスト時のログ
- **`SFSE\AISS\requests\latest_request.ini`** (2026/10/04 14:17:50 更新):
  ```ini
  [request]
  ready=1
  request_type=npc_dialogue
  world_profile=vanilla_starfield
  save_profile=Default
  request_id=marshal_daniel_blake_4

  [npc]
  npc_id=marshal_daniel_blake
  npc_name=Marshal Daniel Blake

  [player]
  message=test
  message_encoded=test
  ```
- **`SFSE\AISS\responses\latest_response.ini`** (2026/10/04 14:17:43 更新):
  ```ini
  [response]
  Ready=0
  ready=0
  text=AISS is waiting for the backend response.
  display_text=AISS is waiting for the backend response.
  request_id=marshal_daniel_blake_4
  ```
- **LM Studio サーバーログ** (`.lmstudio\server-logs\2026-10\2026-10-04.1.log`):
  - 13:56:56（ランチャー起動時の疎通テスト完了）から 14:21 まで、リクエスト受信は 0 件。
  - ゲーム側からの送信要求が LM Studio に届いていなかった（Backend 不在）。
- **`AISS_Backend.exe --health-check`**:
  - `Status: HEALTHY`。MO2 のパス、Bridge ファイル（`latest_request.ini` 等）の読み書きテスト、各 ESM/スクリプトの存在確認をすべて PASS。単体実行で完全に機能することを確認。

### 2.2 INI 設定の比較（バニラ vs MO2 Stable）
- **画質設定の違い**:
  - バニラ: `uGlobalRendererQuality=1` (Medium/Low), `fRenderResolutionScaleFactor=0.5000`
  - MO2 Stable (修正前): `uGlobalRendererQuality=4` (Ultra), `fRenderResolutionScaleFactor=0.7500`, 各種異方性・アップスケーラ強制ON
  - → 修正によりバニラ設定に整合させ、VRAM 負荷を大幅に軽減。
- **音声設定の違い**:
  - バニラ: `Starfield_ja.ini` が Steam 言語に合わせてロードされ `sResourceLocaleVoiceList` を適用。
  - MO2 Stable (修正前): `StarfieldCustom.ini` に `sLanguage=ja` のみで音声 BA2 指定がなく、エンジン初期化時に英語音声 BA2 がロードされていた。
  - → `StarfieldCustom.ini` に日本語音声 BA2（`Starfield - Voices_ja01.ba2, Starfield - Voices_ja02.ba2, Starfield - Voices_ja_Patch.ba2`）を明記して解決。

---

## 3. 日本語入力の検討結果（作業5）

### 3.1 現状の制約
- Starfield のゲーム内テキスト入力（Scaleform / `TextInputMenu`）は Windows の IME 割り込みを受け付けないため、英数字しか直接入力できない。

### 3.2 実現方法の案
- **案A: クリップボード貼り付け支援（ホットキー + SendKeys）**
  - 外部の小さな入力ウィンドウ（常駐型）をホットキーで呼び出し、そこで日本語（IME）を入力して Enter。
  - ツールが日本語テキストをクリップボードにコピーし、Starfield ウィンドウをアクティブにして `Ctrl+V` を送信。
  - ※Starfield の `TextInputMenu` がクリップボードからの Unicode 貼り付けに対応しているか要実機確認。
- **案B: `latest_request.ini` 直接差し替えツール（推奨案）**
  - ゲーム内では「Chat with AISS」を開き、ダミー文字（スペースやドット等）を入力して送信（ゲーム側が Backend 待ち状態に入る）。
  - または、ホットキーで開く外部の日本語チャットバーに入力したテキストを、Papyrus が `latest_request.ini` を出力した直後に上書きして Backend に渡す。
  - 注意点: Papyrus による書き出しと外部ツールによる書き換えの競合（レースコンディション）を防ぐため、排他制御が必要。

---

## 4. ユーザーが次に試す手順

1. **現在起動中の Starfield と Mod Organizer 2 をすべて終了してください。**
2. デスクトップの「**Starfield（MOD）**」ショートカットをダブルクリックして起動します。
3. ランチャーのコンソールに以下が表示されることを確認します：
   - `[ステップ 4/5: AISS Backend 起動] AISS Backend を直接起動しました。`
   - `[ステップ 5/5: SFSE（Starfield）起動] SFSE（Starfield）をプロファイル 'Stable' で MO2 経由で起動中...`
4. Starfield が起動したら「NEW」または既存セーブからゲームを開始します。
5. **音声の確認**: ゲーム内の NPC 音声が日本語になっているか確認します。
6. **AISS の確認**: NPC（例: アキラ・シティのダニエル・ブレイク等）に話しかけ、「Chat with AISS」を選択して英語または英字メッセージ（例: `Hello`）を送信します。
   - 画面右上に通知が出た後、数秒〜十数秒で返答が表示（またはテキスト/音声が再生）されるか確認してください。

---

## 5. 問題・仕様との食い違い

なし。全作業（作業1〜5）は仕様書および指示書の要件通りに完了しました。
