# 指示書: 実機テストで見つかった問題の修正（Phase 1）

- 作成: Claude（2026-10-04）
- 運用ルール: docs/agy/README.md に従うこと
- 作業ブランチ: main から phase1-fix を作成する

## 経緯（ユーザー報告）

- PC フリーズはゲーム本体＋AMD ドライバーの問題だった（バニラでも発生）。AMD Adrenalin 26.9.2（Optional）に更新して解決
- MO2 のプロファイルが切り分け用の「Test-NoAltStart」のままになっており、バニラの導入（エレベーター）が始まった。「Stable」に戻して解決
- 現在、Stable で NEW → カスタム → ゲーム開始まで成功し、AISS のチャット画面も出る

残っている問題:
1. **AISS で英語のメッセージを送っても「AISS は利用できない」旨のポップアップが出て、会話できない**
2. **ゲームの音声が日本語ではなく英語になっている**
3. **MOD のテキストが英語のまま**（少なくとも一部）
4. AISS の入力欄で日本語入力ができない（英字は可）

## 作業1: AISS が使えない原因の調査と修正（最優先。止まらずに進めてよい）

- **追記（Claude、14:17）**: ユーザーが共有したポップアップの文面は「**AISS REQUEST SENT TO MARSHAL DANIEL BLAKE.**」。これは「利用できない」というエラーではなく、**リクエストを送信した**という通知。問題は「送信後に返事が来ない（または表示されない）」ことの可能性が高い。送信以降の流れ（latest_request.ini の書き込み → Backend の受信 → LM Studio へのリクエスト → latest_response.ini の書き込み → ゲーム側の表示）のどこで止まっているかを、各ログの時刻で特定すること

- ポップアップの正確な文面はユーザーに確認中。報告の時点で分かっていなければ、ログから推定する
- 以下を確認する
  - ユーザーがどのショートカットで起動したか（「Starfield（MOD）」か「LLMなし」か）。ランチャーのログで判断する
  - AISS_Backend のログ（aiss_rebuilt_backend.log 等）、runtime_health.json、requests/latest_request.ini、responses/latest_response.ini の、会話を試した時刻付近の内容
  - LM Studio のサーバーログで、その時刻にリクエストが届いたか、モデルが読み込まれていたか
  - AISS Setup アイテムの使用が必要か（未使用だとこのポップアップが出るか）を AISS 付属ドキュメントで確認する
  - Roleplayers' Alternate Start で始めた場合に、AISS 側で必要な初期化（クエストの開始等）が行われているか。AISS 付属ドキュメントに、代替スタート系 MOD との相性や注意があれば記録する
- 原因が設定やランチャーにあれば修正する。ゲームの起動が必要な確認はユーザーに依頼する（手順を報告に書く）

## 作業2: 音声が英語になる原因の調査と修正（止まらずに進めてよい）

- **追記（Claude、14:20）**: ユーザーが共有した StarfieldPrefs.ini には言語の項目（sLanguage）が含まれていなかった。Prefs が直接の原因ではない可能性が高い。次を優先して確認すること
  1. ゲームフォルダの `Starfield.ini` の `[General] sLanguage` の値
  2. Steam から起動したときと、MO2 → sfse_loader.exe で起動したときで、言語の決まり方が違うか（Steam の起動時引数・言語設定が sfse_loader 経由では渡らない可能性）
  3. 対策の第一候補: MO2 の Stable プロファイルの `StarfieldCustom.ini` の `[General]` に `sLanguage=ja` を追加する（既存の sIntroSequence 等は残す）。追加前にバックアップする
  4. Data フォルダに日本語の音声アーカイブ（Voices の _ja 等）があるか。なければ Steam の言語設定が日本語でないか、日本語音声が未ダウンロード
- **追記（Claude、14:20）**: Stable プロファイルの StarfieldCustom.ini（ユーザー共有）は `[Archive]` セクションが2回重複しており、`sLanguage` が無い。重複を1つにまとめ、`[General]` に `sLanguage=ja` を追加すること（`sLocalSavePath=__MO_Saves\` と `bUseMyGamesDirectory=1` は MO2 のプロファイル別セーブ用なので残す）
- 注意: StarfieldPrefs.ini の `[Bethesda.net]` の UUID はアカウントに紐づく値なので、リポジトリに書かない

- Starfield は日本語音声がある。以下を確認する
  - Steam の Starfield の言語設定（appmanifest の言語、Steam のプロパティ）
  - Data フォルダにある音声アーカイブ（Voices の ba2）のうち、日本語（_ja 等）が存在するか
  - ゲームフォルダの Starfield.ini と、MO2 の Stable プロファイルの StarfieldCustom.ini / StarfieldPrefs.ini の言語設定（sLanguage 等）
  - Phase 1 で agy が Stable プロファイルに置いた「バニラ初期設定」の StarfieldPrefs.ini の中身（言語・画質設定など、ユーザーの元の設定と違う項目）
- バニラ（Steam 起動）で使われている設定と、MO2 の Stable プロファイルで使われている設定を比較し、違いを一覧にする
- 原因が MO2 のプロファイル INI にあれば、日本語（テキスト・音声とも）になるよう修正する。修正前の INI はバックアップする
- 必要なら、ユーザーの元の StarfieldPrefs.ini（バックアップの Ini フォルダ）の画質設定を Stable プロファイルにも反映する（言語以外の設定もバニラと揃える）

## 作業3: ランチャーが必ず Stable プロファイルで起動するようにする（止まらずに進めてよい）

- MO2 で選ばれているプロファイルに関係なく、ランチャーは Stable で起動するようにする（MO2 のコマンドライン引数でプロファイルを指定する等）。プロファイル名は launcher.config.json で設定できるようにし、初期値を Stable にする
- 「LLMなし」ショートカットは切り分け用なので、デスクトップから削除するか、名前に「（テスト用）」を付けて区別する

## 作業4: 英語のままの MOD テキストの一覧（止まらずに進めてよい）

- Phase 1 で導入した MOD のうち、プレイヤーが目にする英語テキストがあるもの（AISS の UI・ポップアップ・メニュー、Roleplayers' Alternate Start のメニュー・ターミナル、Absolute HOTAS の設定画面など）を一覧にする
- 仕様書6章の優先度（S/A/B）を付けて docs/MOD_JAPANESE.md に追記する
- 翻訳はまだ行わない。翻訳の方法（xTranslator 等、MO2 の別MODとして日本語化パッチを作る）と作業量の見積もりを報告に書く

## 作業5: 日本語入力（調査のみ。止まらずに進めてよい）

- AISS 付属ドキュメントに、入力欄の IME・貼り付け（Ctrl+V）・外部からの入力に関する記述があるか確認する
- AISS の入力が「ゲーム内の入力欄 → SFSE プラグイン → requests/latest_request.ini → Backend」という流れなら、ゲーム外の小さな入力ウィンドウ（日本語 IME で入力）から AISS に発言を渡す方法が作れるかを、AISS の仕組みを読んで検討する（AISS 本体は改変しない前提）。実装はまだしない。実現方法の案と注意点を報告に書く

## 作業6: 報告（ここで止まる）

- phase1-fix ブランチに、変更したファイル（設定ファイル・ログを除く）と `docs/agy/reports/phase1-fix-01.md` を commit・push して止まる
- 報告には、ユーザーが次に試す手順を短く書く

---

これから何をするかを説明し、許可を得てから作業を開始すること。
