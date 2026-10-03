# 指示書: ワンクリック起動（Phase 1 補足）

- 作成: Claude（2026-10-04）
- 運用ルール: docs/agy/README.md に従うこと
- 目的: ユーザーが毎回 LM Studio のプリセットを選んだり、複数のアプリを順番に起動したりしなくて済むようにする。**デスクトップのショートカットをダブルクリックするだけで、プレイできる状態になる**ことを目標とする
- 作業ブランチ: main から phase1-launcher を作成する

## ユーザーの要望（最優先）

**デスクトップに置いた MO2 のアイコンをクリックするだけで、MOD 入りの Starfield が起動する**こと。LM Studio や AISS Backend を別に操作する手間をなくす。

これを、以下の優先順で実現する。

- **方式1（第一候補）: MO2 自身のショートカットだけで完結させる**
  - MO2 の実行ファイル一覧の「SFSE」から、MO2 の機能（実行ファイルのドロップダウン → ショートカット作成 → デスクトップ）でデスクトップショートカットを作る。これは MO2 のアイコンで、クリックすると MO2 経由で SFSE（MOD 入り Starfield）が直接起動する
  - そのためには、ゲーム起動前に必要な LM Studio と AISS Backend が「何もしなくても動いている」状態にする必要がある:
    - LM Studio: ログイン時にサーバーを自動起動する設定（Run LLM server on login 等）と、JIT 読み込み（作業1）を有効にする。ゲーム中に AISS から最初のリクエストが来た時点で、モデルが既定設定で自動的に読み込まれる
    - AISS Backend: AISS 付属ドキュメントを読み、**ゲーム（SFSE プラグイン）側から AISS_Backend.exe を自動起動する設定**、または常駐・自動起動の仕組みがあるか確認する。あれば有効にする
  - 両方が満たせれば方式1を採用し、作業2の起動スクリプトは作らない
- **方式2（方式1が無理な場合）: 起動スクリプトを MO2 のアイコンで置く**
  - 作業2の起動スクリプトを作り、デスクトップのショートカットのアイコンを MO2 のアイコン（ModOrganizer.exe のアイコン）にする。名前は「Starfield（MOD）」
  - 見た目と操作は方式1と同じ（アイコンを1回クリック）

どちらを採用したか、理由とともに報告すること。

## 作業1: LM Studio のモデル別既定設定（止まらずに進めてよい）

- LM Studio で gemma-4-12b-it-qat の**モデル別の既定読み込み設定**（My Models のモデルごとの設定。GUI で保存される設定ファイル）に、以下を保存する
  - コンテキスト長 16384、GPU オフロード 最大、Flash Attention オン、K/V キャッシュ Q8_0
  - 思考（thinking / reasoning）オフ（モデル既定に保存できない場合は、AISS 側の reasoning_effort 設定に任せ、その旨を記録）
- LM Studio の **Just-in-Time（JIT）モデル読み込み**を有効にする（API にリクエストが来たら自動でモデルを読み込む設定）
- 確認: LM Studio でモデルをすべて取り外した状態から、`lms load gemma-4-12b-it-qat`（オプションなし）で読み込み、既定設定（16384・Q8_0・Flash Attention）が適用されることを、ログまたは VRAM 実測で確認する
- 確認: JIT が有効な状態で、モデル未読み込みのまま API にリクエストを送り、自動で既定設定のまま読み込まれることを確認する
- 結果を configs/LMStudio/gemma-4-12b.md に記録する。プリセット選択の手順は不要になるので、CONFIG_GUIDE.md と TEST_PHASE1.md の該当手順を「自動で適用される」に書き換える

## 作業2: 起動スクリプト（方式2の場合のみ。止まらずに進めてよい）

`tools/launcher/` に以下を作る。

- `Start-StarfieldAI.ps1`（本体）と `Start-StarfieldAI.bat`（ダブルクリック用。PowerShell の実行ポリシーで止まらないよう、bat から `-ExecutionPolicy Bypass -File` で ps1 を呼ぶ）
- パスは `launcher.config.example.json`（テンプレート、リポジトリに入れる）と `launcher.config.json`（実際の値、.gitignore で除外）に分ける。スクリプト内に個人のパスを直接書かない
- 処理の流れ:
  1. VRAM を多く使う常駐アプリ（設定ファイルで一覧を指定。初期値: WardogsClient-Win64-Shipping、msedge、Discord）が起動していたら、**一覧を表示して「閉じますか？ (Y/N)」と聞く**。勝手に終了しない。Y なら通常終了を試みる（強制終了はしない）
  2. LM Studio のサーバーを起動する（`lms server start`。起動済みなら何もしない）
  3. gemma-4-12b-it-qat を読み込む（`lms load gemma-4-12b-it-qat`。読み込み済みなら何もしない。既定設定が使われる）
  4. 読み込み後、API に短いテストを送り、応答が返ることを確認する。失敗したらメッセージを出して止まる
  5. MO2 を起動し、Starfield インスタンスの「AISS Backend」を実行する（`ModOrganizer.exe "moshortcut://Starfield:AISS Backend"` 等。MO2 の実行ファイル名に合わせる）
  6. AISS_Backend の起動を待ち（プロセスの確認、または数秒待機）、MO2 から「SFSE」を実行する（`moshortcut://Starfield:SFSE`）
  7. 各段階で何をしているかを日本語で画面に表示する
- 注意: 以前、agy の非対話セッションから moshortcut を実行すると Error 5 になった。ユーザーがダブルクリックで起動する対話セッションなら動く見込みだが、**agy からは実行しない**（ゲーム起動になるため）。動作確認はユーザーが行う
- 予備手段: moshortcut が使えない場合に備え、手順5・6を飛ばして「MO2 を開くだけ」にするオプション（設定ファイルの値）を用意する
- デスクトップにショートカット「Starfield（MOD）」（Start-StarfieldAI.bat を指す、アイコンは MO2）を作る
- README（tools/launcher/README.md）に使い方・設定ファイルの書き方を書く
- CONFIG_GUIDE.md と TEST_PHASE1.md の起動手順を「デスクトップの Starfield AI をダブルクリック」に書き換える。手動の手順は「ランチャーが動かないとき」として残す

## 作業3: 確認と報告（ここで止まる）

- 方式1の場合: デスクトップショートカットの作成と、LM Studio の自動起動・JIT の設定確認まで。ショートカットからのゲーム起動はユーザーが確認する
- 方式2の場合: agy が実行してよいのは、手順1〜4（常駐アプリの確認は表示のみで N 扱い、LM Studio の起動・読み込み・テスト）までの部分確認。手順5・6（MO2 経由の起動）は実行しない
- phase1-launcher ブランチに以下を commit・push する: tools/launcher/ 一式（launcher.config.json を除く）、.gitignore の更新、configs/LMStudio/gemma-4-12b.md、docs/CONFIG_GUIDE.md、docs/TEST_PHASE1.md、docs/agy/reports/phase1-launcher-01.md
- commit 前に、個人のパス・ユーザー名・APIキーが含まれていないことを確認する
- 報告 `phase1-launcher-01.md` を push して止まる

---

これから何をするかを説明し、許可を得てから作業を開始すること。

---

## phase1-launcher-01 へのレビュー（Claude、2026-10-04）: ショートカットが動かない

**ユーザーの実機結果: デスクトップの「Starfield（MOD）」をクリックすると、一瞬 CMD が出て消えるだけで何も起きない。**

agy の確認は `Start-StarfieldAI.ps1 -TestOnly` を直接実行しただけで、ショートカット → bat → ps1 の経路は確認していなかった。以下の作業1〜5を行い、`phase1-launcher-02.md` を push して止まること。作業1〜5は止まらずに進めてよい。

### 原因の候補（Claude がリポジトリ上のファイルで確認したこと）

1. `Start-StarfieldAI.bat` の改行が LF のみ（Windows の CRLF ではない）で、日本語（UTF-8）のコメント行を含む。cmd.exe は LF のみ・UTF-8 の bat を正しく解釈できないことがある
2. ps1 は `$ErrorActionPreference = "Stop"` で、例外を捕まえる処理がない。どこかでエラーになると、メッセージを出す前にウィンドウが閉じる
3. bat の最後に `pause` がないため、成功・失敗にかかわらずウィンドウがすぐ閉じる

### 作業1: bat の作り直し

- 改行を CRLF にする
- bat の中は ASCII 文字だけにする（日本語コメントは削除。説明は README に書く）
- ps1 の終了コードが 0 以外なら、`pause` して画面を残す

### 作業2: ps1 のエラー処理とログ

- スクリプト全体を try / catch で囲み、エラー時は「どの段階で・何が起きたか」を日本語で表示し、Enter を押すまで閉じない
- 毎回のログを `tools/launcher/logs/launcher-<日時>.log` に残す（Start-Transcript 等）。logs/ は .gitignore で除外する
- ゲームの起動まで成功したら、5秒ほど表示してから閉じる

### 作業3: 本当の経路での確認

- **デスクトップのショートカット（.lnk）と同じ方法で起動して**確認する。.lnk のリンク先・引数・作業フォルダを報告に書く
- 確認は `-TestOnly` に相当する範囲（ステップ1〜3）まで。bat 経由で TestOnly を渡せるよう、bat に引数をそのまま ps1 へ渡す仕組み（`%*`）を入れる
- agy の環境で、ショートカットと同じ経路で TestOnly が最後まで通り、ログファイルが生成されることを確認する
- 前回のユーザー実行でログやエラーの痕跡（イベントログ、PowerShell の履歴等ではなく、スクリプト自身が残したもの）があれば、それも確認する

### 作業4: MO2 経由の起動部分（ステップ4・5）の確認方法

- agy はゲームを起動しない。ただし、ステップ4・5で実行するコマンド（ModOrganizer.exe のパスと moshortcut の引数）を、実行せずに画面とログに表示する「ドライラン」オプション（例: `-DryRun`）を追加し、その出力を報告に書く
- launcher.config.json の `mo2ExecutablePath` が実在するパスになっているか確認する（値はリポジトリに書かない）

### 作業5: commit・push

- phase1-launcher ブランチに、tools/launcher/（launcher.config.json と logs/ を除く）、.gitignore、docs/agy/reports/phase1-launcher-02.md を commit・push する

### ユーザーへの再テスト手順（報告の最後に書くこと）

修正後、ユーザーがもう一度ショートカットをクリックする。今度は、エラーがあれば画面に残り、ログファイルも残るので、それを Claude に伝えればよい形にする。
