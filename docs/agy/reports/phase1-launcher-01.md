# Phase 1 補足: ワンクリック起動 報告 01

- 日時: 2026-10-04
- 状態: 完了（作業1〜2全完了、作業3部分検証完了、commit・push 完了）
- 停止した理由: 指示書（`docs/agy/phase1-launcher.md`）の作業3の規定に従い、agy 側でのスクリプト部分検証（ステップ1〜3）およびドキュメント更新を完了し、ユーザーによる実機ワンクリック起動確認へ引き渡すため停止

---

## 1. 方式選定結果

### 採用方式: 【方式2（起動スクリプト＋MO2アイコンショートカット）】

- **選定理由**:
  - AISS 付属ドキュメント（`docs/mod/AISS/README.md`、`AISS 3.70 Readme and Config Guide.pdf`、`aiss_backend.py` 内部仕様）を調査した結果、SFSE（ゲーム側 DLL プラグイン）から外部プロセスである `AISS_Backend.exe` を自動起動する仕組みは存在せず、**ゲーム起動前にあらかじめバックエンドが常駐していることが前提動作**となっていました。
  - バックエンドが不在のまま SFSE を起動した場合、AISS HUD に警告が表示され、リクエスト送信に失敗（タイムアウト・エラー応答）します。
  - したがって、MO2 単独の SFSE ショートカット（方式1）ではバックエンド常駐が満たせず、ゲーム前にバックエンドおよび LM Studio を自動連携させる統合ランチャー（方式2）が不可欠と判断しました。
  - デスクトップには MO2 アイコンを付与したショートカット「Starfield（MOD）」を配置しており、ユーザーから見た操作感・外観は方式1と完全に同等（ワンクリック起動）となります。

---

## 2. 作業1: LM Studio のモデル別既定設定・JIT 実証結果

### 2.1 既定設定の反映
- `<UserDir>\.lmstudio\settings.json` の `defaultContextLength.value` を `16384` に設定。
- オプションなしの `lms load gemma-4-12b-it-qat` でロードした場合でも、コンテキスト長 `16384` が自動適用されることを確認。
- プリセット手動選択（AISS-Standard-Q8_0）を行わなくても、K/V Cache Q8_0・Flash Attention・コンテキスト長 16384・GPU 100% オフロードが自動適用される環境を確立。

### 2.2 Just-in-Time（JIT）モデル読み込みの実証
- LM Studio 設定の `justInTimeModelLoading: true` を確認。
- モデルを完全に取り外した（アンロード）状態から、ローカル API（`http://127.0.0.1:1234/v1/chat/completions`）にテストリクエストを送信。
- LM Studio がリクエスト受信をトリガーにして `gemma-4-12b-it-qat` を自動ロードし、既定設定のまま正常に応答（TTFT 225ms / 全文 1.05s）を生成・返却することを実証確認。

### 2.3 思考（Reasoning）無効化の実証
- 短文テスト（TTFT 117ms / 全文 594ms / 思考出力 0 文字）
- 長文 10,000 トークン入力テスト（TTFT 7.68s / 思考出力 0 文字）
- `configs/LMStudio/gemma-4-12b.md` に JIT 実証および既定化設定を追記完了。

---

## 3. 作業2: 起動スクリプトの構築とショートカット配置

### 3.1 成果物一覧
1. **`tools/launcher/launcher.config.example.json`**（Git 管理用テンプレート）:
   - 環境依存パスをプレースホルダー（`<MO2>`, `<Documents>` 等）で記載した設定テンプレート。
2. **`tools/launcher/launcher.config.json`**（実環境設定・Git 除外）:
   - ユーザーの実機環境（MO2 実パス、監視プロセス等）を保持。`.gitignore` に追加済みでリポジトリにはコミットされません。
3. **`tools/launcher/Start-StarfieldAI.ps1`**（ランチャー本体）:
   - 日本語 Windows PowerShell 5.1 で安全に動作する BOM 付き UTF-8 エンコーディング。
   - ステップ 1: VRAM 監視プロセス（WardogsClient, msedge, Discord）検出時の確認プロンプト（Y/N、通常終了試行）。
   - ステップ 2: LM Studio サーバー稼働確認＆自動起動（`lms server start`）。
   - ステップ 3: モデル読み込み確認＆API 疎通テスト（失敗時は自動停止）。
   - ステップ 4: MO2 経由での「AISS Backend」起動（`moshortcut://Starfield:AISS Backend`）および常駐待機。
   - ステップ 5: MO2 経由での「SFSE」自動起動（`moshortcut://Starfield:SFSE`）。
   - 予備手段: 設定 `launchViaMoShortcut: false` による MO2 単独起動フォールバックを完備。
   - `-TestOnly` スイッチ（ステップ 1〜3 のみ実行して終了）および `-NonInteractive` スイッチ（確認プロンプトスキップ）を実装。
4. **`tools/launcher/Start-StarfieldAI.bat`**（ダブルクリック用ラッパー）:
   - PowerShell 実行ポリシーを `-ExecutionPolicy Bypass` で自動回避し、ps1 を起動。
5. **`tools/launcher/README.md`**（仕様書・運用ガイド）:
   - 各ステップの動作、設定ファイルの各項目、トラブルシューティングを網羅。
6. **デスクトップショートカット**:
   - パス: `<Desktop>\Starfield（MOD）.lnk`
   - リンク先: `tools/launcher/Start-StarfieldAI.bat`
   - アイコン: `<MO2>\ModOrganizer.exe`（MO2 公式アイコン）
7. **ドキュメント更新**:
   - `docs/CONFIG_GUIDE.md`: 3.2（プリセット自動適用注記）および第6章（ワンクリック統合ランチャー推奨＋手動代替手順）を更新。
   - `docs/TEST_PHASE1.md`: 冒頭の重要事項および 3.1 起動準備（ワンクリックランチャー推奨＋手動代替手順）を更新。

---

## 4. 作業3: 確認と検証結果

### 4.1 agy による部分テスト実行結果
- 実行コマンド:
  `powershell -ExecutionPolicy Bypass -File tools/launcher/Start-StarfieldAI.ps1 -TestOnly -NonInteractive`
- 実行ログ抜粋:
  ```
  ======================================================
    Starfield AI 統合ランチャー (テストモード)
  ======================================================
  [1/5] VRAM 解放確認 (常駐アプリチェック)...
  [情報] 監視対象の常駐プロセスは検出されませんでした。(VRAM は十分に確保されています)
  [2/5] LM Studio サーバー確認...
  [OK] LM Studio サーバーは正常に稼働しています (ポート: 1234)。
  [3/5] モデル読み込み＆疎通確認...
  [OK] 対象モデル 'gemma-4-12b-it-qat' はロード済みです。
  [情報] API 疎通テストを実行中...
  [OK] API 疎通テスト成功 (応答時間: 277 ms)
  [情報] -TestOnly 指定のため、MO2・ゲーム起動をスキップして終了します。
  ```
- **判定**: **PASS**（ステップ 1〜3 正常稼働）

### 4.2 MO2 / SFSE 起動の取り扱い
- 指示書およびプロジェクト運用ルールの規定に従い、ゲーム起動（ステップ 4〜5）は agy からは実行せず、ユーザーの実機確認に委ねます。

---

## 5. 次のステップ（ユーザー実機テスト）

1. デスクトップの **「Starfield（MOD）」** アイコンをダブルクリックしてください。
2. 常駐アプリ（WardogsClient、Edge 等）が起動している場合は「閉じますか？ (Y/N)」と聞かれますので、`Y` を入力して VRAM を解放してください。
3. LM Studio の疎通確認、AISS Backend の起動、SFSE（Starfield）の起動が全自動で進行することを確認してください。
4. ゲーム起動後、`docs/TEST_PHASE1.md` に従って実機動作テスト（会話、日本語フォント、HOTAS 等）を実施してください。
