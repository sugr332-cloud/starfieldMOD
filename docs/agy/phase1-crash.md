# 指示書: ニューゲーム開始時の PC フリーズ調査

- 作成: Claude（2026-10-04）
- 運用ルール: docs/agy/README.md に従うこと
- 作業ブランチ: main から phase1-crash を作成する

## 症状（ユーザー報告）

- ランチャー（Starfield（MOD））から起動 → メインメニュー → **「NEW」を押した直後に画面が暗転し、PC 全体が止まる**（ゲームが落ちるだけではなく、PC が操作できなくなる）
- 構成: Stable プロファイル（SFSE、Address Library、Cassiopeia、Longer Names v2、AISS、Absolute HOTAS、AISS - Japanese Language Addon、Roleplayers' Alternate Start）＋ LM Studio で gemma-4-12b-it-qat（Q8_0 KV、16K）を GPU に常駐

## Claude の見立て（確定ではない）

PC 全体が止まるのは、MOD の不具合でゲームだけが落ちる（CTD）のとは違い、**GPU ドライバの応答停止や、VRAM・メインメモリの枯渇**で起きることが多い。ニューゲームの読み込みは VRAM とメモリを一気に使う場面で、LM Studio がモデル（約7.4GB）を GPU に載せたままなので、まずこれを疑う。ただし MOD（特にニューゲーム開始時に動く Roleplayers' Alternate Start と AISS）が原因の可能性もあるため、切り分ける。

## 作業1: 証拠の収集（読み取りのみ。止まらずに進めてよい）

フリーズした時刻の前後を対象に、以下を確認して報告に書く。個人データ（ブラウザ履歴等）には触れないこと。
1. Windows のイベントログ（システム）: 次のようなイベントの有無と時刻・内容
   - ディスプレイドライバーの応答停止・回復（Display / amdkmdag 等、イベント ID 4101 など）
   - Kernel-Power 41（予期しない再起動）、WHEA のハードウェアエラー
   - リソース枯渇（メモリ不足）に関する警告
2. Windows のイベントログ（アプリケーション）: Starfield.exe、LM Studio、AISS_Backend のエラー
3. Starfield 本体のクラッシュログ・ダンプの有無（<Documents>\My Games\Starfield 配下など）
4. SFSE のログ（sfse.txt）の最終行。プラグインがすべて読み込まれていたか
5. AISS のログ（AISS\logs\ 配下、runtime_health.json 等）の最終内容
6. ランチャーのログ（tools/launcher/logs/）の最終内容
7. LM Studio のログ（サーバーログ）の、フリーズ時刻付近の内容
8. メモリ設定: Windows のページファイル（仮想メモリ）の設定（自動管理か、サイズ）、搭載 RAM 32GB に対する空き状況
9. GPU ドライバのバージョン（Phase 0 時点 32.0.31041.1004 から変わっていないか）

## 作業2: 切り分け用の準備（止まらずに進めてよい）

ユーザーが短時間で順番に試せるようにする。

- ランチャーに `-NoLLM` オプションを追加する。LM Studio のモデルを読み込まず（読み込み済みなら取り外して）、AISS Backend と SFSE だけを起動する
- デスクトップに切り分け用のショートカットを作る:
  - 「Starfield（MOD・LLMなし）」: `-NoLLM` 付き
- MO2 に、切り分け用のプロファイル「Test-NoAltStart」を作る。Stable の複製から Roleplayers' Alternate Start だけを無効にしたもの（Stable 自体は変えない）
- 各テストの手順を `docs/TEST_CRASH.md` に日本語で短く書く（下の「ユーザーが行うテスト」）

## 作業3: 報告（ここで止まる）

- 作業1の結果と、作業1から推測される原因を報告に書く
- phase1-crash ブランチに、tools/launcher/ の変更（設定ファイル・ログを除く）、docs/TEST_CRASH.md、docs/agy/reports/phase1-crash-01.md を commit・push して止まる
- agy はゲームを起動しない

## ユーザーが行うテスト（TEST_CRASH.md に書く内容）

上から順に、フリーズしたらそこで止めて結果を伝える。各テストの前に、常駐アプリ（WardogsClient、ブラウザ、Discord）を閉じる。

1. **LLM なしで NEW**: 「Starfield（MOD・LLMなし）」で起動 → NEW
   - 止まらなければ、原因は VRAM の取り合い（LLM 常駐）の可能性が高い
2. **LLM なし・Alternate Start なしで NEW**: 1 で止まった場合のみ。MO2 で「Test-NoAltStart」プロファイルを選び、MO2 から SFSE を実行 → NEW
   - 止まらなければ、原因は Roleplayers' Alternate Start
3. **MOD なしで NEW**: 2 でも止まった場合のみ。Steam から普通に Starfield を起動 → NEW
   - これでも止まるなら、MOD ではなくゲーム本体・ドライバ・PC 側の問題

---

これから何をするかを説明し、許可を得てから作業を開始すること。
