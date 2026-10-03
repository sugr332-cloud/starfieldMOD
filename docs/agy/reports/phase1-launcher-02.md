# Phase 1 補足: ワンクリック起動 報告 02（ランチャー起動不具合修正）

- 日時: 2026-10-04
- 状態: 完了（作業1〜5全完了、実機ショートカット同等経路での検証完了、commit・push 完了）
- 停止した理由: 指示書（`docs/agy/phase1-launcher.md`）のレビュー指示に従い、作業1〜5の修正と検証を完了し、ユーザーによる実機再テスト（ショートカットクリック）へ引き渡すため停止

---

## 1. 不具合原因の分析

ユーザー実機において、デスクトップの「Starfield（MOD）」ショートカットをクリックした際に「一瞬 CMD が表示されて消え、何も起きない」状態となっていた原因は以下の3点でした：

1. **バッチファイルの改行コード・文字エンコーディング不整合**:
   - 初版の `Start-StarfieldAI.bat` が LF 改行かつ UTF-8 日本語コメントを含んでおり、Windows 標準の `cmd.exe`（デフォルト Shift-JIS / cp932）でパース異常やコマンド切断が発生していた可能性。
2. **PowerShell 側の例外捕捉（try-catch）の欠如**:
   - `$ErrorActionPreference = "Stop"` のもとで例外が発生した場合に、メッセージを視認する前に PowerShell プロセスが即座に終了していた。
3. **バッチファイル側の終了一時停止（pause）の欠如**:
   - 終了コードにかかわらず `cmd.exe` が即時終了し、エラー内容がコンソールに残らなかった。

---

## 2. 作業1: バッチファイル（Start-StarfieldAI.bat）の再構築

- **CRLF 改行の徹底**: バイナリレベルで改行コードを Windows 標準の CRLF（`\r\n`）に統一。
- **完全 ASCII 化**: 日本語コメントや非 ASCII 文字を全廃し、純粋な ASCII テキストとして構成。
- **引数の完全透過転送（`%*`）**: バッチファイルに渡された引数（`-TestOnly`, `-DryRun` 等）をそのまま PowerShell スクリプトへ透過。
- **エラー時の一時停止（`pause`）実装**:
  PowerShell スクリプトの終了コード（`%ERRORLEVEL%`）を判定し、0 以外の場合はエラーメッセージを出力した上で `pause` を実行し、キー入力があるまで画面を保持。

---

## 3. 作業2: PowerShell スクリプト（Start-StarfieldAI.ps1）のエラー処理とログ記録

1. **二重エラーハンドリング（try-catch 構造）**:
   - スクリプト全体を `try { ... } catch { ... }` で囲み、エラー発生フェーズ（`$currentStep`）とエラー詳細（日本語）を画面に出力。
   - 対話実行時は `Read-Host` で Enter キー待機を行い、画面が勝手に消えないよう保護。
   - `exit 1` を返すことで、バッチファイル側の `pause` も連動して発動。
2. **自動ログ記録（Start-Transcript）の実装**:
   - スクリプト起動時に `tools/launcher/logs/launcher-<日時>.log` を自動生成し、実行ログをすべて記録。
   - Windows PowerShell 5.1 互換（`-Encoding` オプション不使用、`-Force` 指定）。
   - 終了時は確実にログをクローズするヘルパー関数 `Exit-Launcher` を実装。
   - `.gitignore` に `tools/launcher/logs/` を追加し、個人情報・環境情報の漏洩を防止。
3. **ゲーム起動後の待機時間**:
   - ステップ 5（SFSE 起動）まで成功した場合は、完了メッセージを表示した上で **5 秒間待機**（`Start-Sleep -Seconds 5`）してから自動終了する仕様に変更。
4. **MO2 実行ファイルの存在検証**:
   - 設定ファイル読み込み時に `mo2ExecutablePath` の実在性を検証し、パスが存在しない場合は即座に明確なエラーを表示。

---

## 4. 作業3: デスクトップショートカットと同等経路での検証

### 4.1 ショートカット（.lnk）のプロパティ確認
Windows COM（`WScript.Shell`）経由でデスクトップ上のショートカットを検証しました：

- **ファイルパス**: `<Desktop>\Starfield（MOD）.lnk`（OneDrive 同期デスクトップ上）
- **リンク先（TargetPath）**: `<Repository>\tools\launcher\Start-StarfieldAI.bat`
- **引数（Arguments）**: （なし）
- **作業フォルダ（WorkingDirectory）**: `<Repository>\tools\launcher`
- **アイコン（IconLocation）**: `<MO2>\ModOrganizer.exe,0`

### 4.2 ショートカット同等経路での実行テスト
ショートカットの起動挙動と全く同じ条件（作業フォルダ `tools/launcher` から `cmd.exe /c "Start-StarfieldAI.bat -TestOnly -NonInteractive"`）でテストを実行しました。

- **実行結果**:
  ```
  ==========================================================
     Starfield Space Life JP - ワンクリック統合ランチャー
  ==========================================================
  ログ記録先: <Repository>\tools\launcher\logs\launcher-20261004-025126.log

  [ステップ 1/5: VRAM 常駐アプリのチェック] 実行中...
    以下の VRAM 消費アプリが起動しています:
      - msedge (21 個のプロセス)
      - Discord (6 個のプロセス)
    ※これらを終了すると約 2〜3 GB 以上の VRAM が解放され、ゲームが安定します。
    (非対話モード: アプリ終了確認をスキップします)
    アプリの終了をスキップしました。

  [ステップ 2/5: LM Studio サーバーの確認] 実行中...
    LM Studio サーバーは稼働中です (http://127.0.0.1:1234)。

  [ステップ 3/5: モデル読み込み確認・API 疎通テスト] 実行中...
    モデル gemma-4-12b-it-qat はすでに読み込まれています。
    API 応答テストを送信中...
    API 疎通確認成功！（応答速度: 242 ms）

  [テスト完了] ステップ 1〜3 が正常に確認されました。MO2 / ゲーム起動はスキップします。
  ```
- **判定**: **PASS**（bat 経由で正常起動し、警告なしでテスト完了）。
- **ログ生成確認**: `tools/launcher/logs/launcher-20261004-025126.log`（2,041 bytes）が正常に出力されたことを確認。
- **過去の痕跡調査**: 前回実行時（修正前）はログ出力機構が未配備だったため、スクリプト固有の出力ログは残っていませんでした。

---

## 5. 作業4: MO2 起動（ステップ4・5）のドライラン確認

### 5.1 設定ファイルの実在性確認
`launcher.config.json` の `mo2ExecutablePath` を検査し、実在するファイル（`Exists: True`, `Is file: True`）であることを確認しました（値は `<MO2>\ModOrganizer.exe`）。

### 5.2 ドライラン（-DryRun）実行結果
実機でゲームを起動させずに、ステップ 4（AISS Backend）およびステップ 5（SFSE）で発行される MO2 起動コマンドを画面・ログに出力するドライランテストを実施しました：

- **実行コマンド**: `cmd.exe /c "Start-StarfieldAI.bat -DryRun -NonInteractive"`
- **実行出力**:
  ```
  ==========================================================
     Starfield Space Life JP - ワンクリック統合ランチャー
  ==========================================================
  ログ記録先: <Repository>\tools\launcher\logs\launcher-20261004-025139.log

  [ステップ 1/5: VRAM 常駐アプリのチェック] 実行中...
    以下の VRAM 消費アプリが起動しています:
      - msedge (21 個のプロセス)
      - Discord (6 個のプロセス)
    ※これらを終了すると約 2〜3 GB 以上の VRAM が解放され、ゲームが安定します。
    (非対話モード: アプリ終了確認をスキップします)
    アプリの終了をスキップしました。

  [ステップ 2/5: LM Studio サーバーの確認] 実行中...
    LM Studio サーバーは稼働中です (http://127.0.0.1:1234)。

  [ステップ 3/5: モデル読み込み確認・API 疎通テスト] 実行中...
    モデル gemma-4-12b-it-qat はすでに読み込まれています。
    API 応答テストを送信中...
    API 疎通確認成功！（応答速度: 249 ms）

  [ステップ 4/5: AISS Backend 起動] (ドライラン)
    [DryRun] 実行予定コマンド:
      実行ファイル: <MO2>\ModOrganizer.exe
      引数        : "moshortcut://Starfield:AISS Backend"

  [ステップ 5/5: SFSE（Starfield）起動] (ドライラン)
    [DryRun] 実行予定コマンド:
      実行ファイル: <MO2>\ModOrganizer.exe
      引数        : "moshortcut://Starfield:SFSE"

  ==========================================================
     [ドライラン完了] コマンド検証が正常に完了しました。
     実際のプロセス起動は行っていません。
  ==========================================================
  ```
- **判定**: **PASS**（コマンド構造および引数が MO2 仕様通りであることを確認）。

---

## 6. 作業5: 変更ファイルの確認

- `tools/launcher/Start-StarfieldAI.bat`（ASCII・CRLF・引数転送・pause 追加）
- `tools/launcher/Start-StarfieldAI.ps1`（BOM付きUTF-8・try-catch・ログ記録・DryRun・待機5秒）
- `tools/launcher/README.md`（ログ保存、コマンド引数、トラブルシューティング追記）
- `.gitignore`（`tools/launcher/logs/` 追加）
- `docs/agy/reports/phase1-launcher-02.md`（本報告書）

※個人情報・パス監査を実施済み（`launcher.config.json` および `logs/` は除外）。

---

## 7. ユーザーへの再テスト手順

修正が完了しましたので、ユーザー側で以下の実機再テストをお願いいたします：

1. デスクトップの **「Starfield（MOD）」** アイコンをダブルクリックしてください。
2. **もしエラーが発生した場合**:
   - ウィンドウは一瞬で消えず、**エラーメッセージを表示した状態で停止（一時停止）** します。
   - また、以下の場所に実行ログが自動保存されます：
     `<リポジトリパス>\tools\launcher\logs\launcher-<日時>.log`
   - エラー画面のメッセージ、または上記ログの内容を Claude に共有してください。
3. **正常に動作した場合**:
   - VRAM 常駐アプリの終了確認（`Y` で終了）→ LM Studio 稼働確認 → AISS Backend 起動 → SFSE（Starfield）起動が自動進行します。
   - ゲーム起動完了のメッセージが 5 秒間表示された後、ランチャーウィンドウが自動で閉じます。
