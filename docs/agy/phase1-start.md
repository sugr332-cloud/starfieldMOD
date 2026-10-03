# 指示書: 起動演出のスキップと代替スタート（Phase 1 補足）

- 作成: Claude（2026-10-04）
- 運用ルール: docs/agy/README.md に従うこと
- 目的: ニューゲームを快適に始められるようにする
  1. ゲーム起動時のオープニング映像・ロゴを飛ばす
  2. ニューゲームの導入（ヴェクテラの鉱山〜アーティファクト）を飛ばす
- 作業ブランチ: main から phase1-start を作成する

## 作業1: オープニング映像のスキップ（INI のみ。止まらずに進めてよい）

- MO2 の Stable プロファイルの `StarfieldCustom.ini` に以下を追記する（既存の [Archive] 等は残す）
  ```ini
  [General]
  sIntroSequence=
  uMainMenuDelayBeforeAllowSkip=0
  ```
- 追記前の INI を `D:\StarfieldMODs\Backup\` に日付付きで保存する
- 参考: Nexus mods/586「Skip Intro Videos」と同等の設定。MOD ファイル（UI の差し替え）は入れない。日本語 UI を壊すおそれがあるため、メインメニューの SWF を置き換える MOD（Undelayed Launching 等）は使わない
- CONFIG_GUIDE.md の INI 設定欄に追記する

## 作業2: Roleplayers' Alternate Start の導入

- 対象: Nexus mods/15094「Roleplayers' Alternate Start」（2026-09-24 更新、本体のみで動作、メインクエストは維持される）
- **ダウンロードはユーザーが行う**（Nexus の「Mod Manager Download」で MO2 に直接入る）。MO2 の Downloads タブに入っていなければ、報告して止まる
- MO2 の Stable プロファイルに導入する。作者の説明ページと同梱ドキュメントを読み、以下を確認・記録する
  - 前提MOD、プラグインの読み込み順の指定
  - 非互換（作者明記: 他の Alternate Start 系、Starborn Trait by IgnusT）
  - Shattered Space / Terran Armada 等の DLC 用パッチの有無。ユーザーの所有 DLC は Steam のインストール状況（Data フォルダの esm）から判断し、該当するパッチだけ有効にする
- MO2 の競合表示でファイルの上書きを確認する
- プレイヤー向けテキストの量（スタート地点の選択肢など）を確認し、docs/MOD_JAPANESE.md に追記する（翻訳は今は行わない。英語のまま使う）
- docs/MOD_COMPATIBILITY.md に「AISS との相性は Phase 1 の実機テストで確認」と追記する
- docs/INSTALL_GUIDE.md に導入内容を追記する

## 作業3: 仕様書への反映（止まらずに進めてよい）

- docs/MOD_SPEC.md の 3章（採用候補）と 7章の Stable の表に、Roleplayers' Alternate Start（導入フェーズ: Phase 1）を追加する。役割は「ニューゲーム導入のスキップ」
- 17章の表に 1行追加する

## 作業4: 報告（ここで止まる）

- phase1-start ブランチに、変更したドキュメントと `docs/agy/reports/phase1-start-01.md` を commit・push して止まる
- 報告には、ニューゲーム開始時にユーザーが何を選べばよいか（スタート地点の選び方の要点）を日本語で短くまとめる

---

これから何をするかを説明し、許可を得てから作業を開始すること。
