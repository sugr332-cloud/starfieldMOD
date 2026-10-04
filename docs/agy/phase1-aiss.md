# 指示書: AISS の返事が来ない問題の特定と、状態確認ツール

- 作成: Claude（2026-10-04）
- 運用ルール: docs/agy/README.md に従うこと
- 作業ブランチ: main から phase1-aiss を作成する

## 経緯

- phase1-fix でランチャーが AISS_Backend.exe を直接起動するよう修正した
- ユーザーが 15:2x 頃に「Starfield（MOD）」で起動し、AISS で `hi` と送ったが、**返事が来ない**（エラー表示もなく、返事が無いのか遅いのかも分からない）

## 作業1: どこで止まっているかの特定（最優先。止まらずに進めてよい）

送信から返事までの各段階について、15:20〜15:30 頃の記録を時刻付きで確認し、どこまで進んだかを表にする。

| 段階 | 確認するもの |
|---|---|
| 1. ランチャーが Backend を起動したか | ランチャーのログ、AISS_Backend.exe のプロセスが現在も動いているか |
| 2. ゲームがリクエストを書いたか | requests/latest_request.ini の内容（message=hi、ready 等）と更新時刻 |
| 3. Backend がリクエストを読んだか | Backend のログ（aiss_rebuilt_backend.log 等）、runtime_health.json |
| 4. Backend が LM Studio に送ったか | Backend のログ、LM Studio のサーバーログ |
| 5. LM Studio が返事を生成したか | LM Studio のサーバーログ（生成時間・エラー） |
| 6. Backend が返事を書いたか | responses/latest_response.ini の内容と更新時刻 |
| 7. ゲームが返事を読んだか | state/hud.ini、SFSE / AISS のログ |

- Backend が、ランチャーから直接起動されたことで、MO2 経由のときと違うフォルダを監視していないか確認する（requests を読むパス・responses を書くパスがゲーム側と一致しているか）
- Backend が直接起動されたときにコンソールウィンドウが表示されるか、すぐに終了していないかを確認する
- 原因が特定できたら修正する。ゲームでの確認が必要ならユーザーへの手順を報告に書く

## 作業2: 状態確認ツール（止まらずに進めてよい）

ユーザーが「返事が無いのか、遅いのか、壊れているのか」をすぐ分かるようにする。

- `tools/diag/Check-AISS.ps1` と `Check-AISS.bat`（ダブルクリック用、ASCII・CRLF）を作る
- 実行すると、以下を日本語で一覧表示する（OK / NG と、NG のときの対処の一言）
  - LM Studio のサーバーが動いているか、gemma-4-12b-it-qat が読み込まれているか（未読み込みなら JIT で読み込まれる旨）
  - AISS_Backend.exe が動いているか
  - 最新のリクエスト（時刻・送信内容の先頭20文字）と、最新の返事（時刻・本文の先頭40文字）。リクエストより返事が古ければ「返事待ち」
  - Backend のログの最後の数行（エラーがあれば強調）
- デスクトップにショートカット「AISS 状態確認」を作る
- tools/diag/README.md に使い方を書く

## 作業3: 報告（ここで止まる）

- phase1-aiss ブランチに、変更したファイル（設定・ログを除く）と `docs/agy/reports/phase1-aiss-01.md` を commit・push して止まる
- 報告には、作業1の表、原因と修正、ユーザーが次に試す手順を書く

---

これから何をするかを説明し、許可を得てから作業を開始すること。
