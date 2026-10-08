# 指示書: 現状の棚卸しとドキュメント整理の準備（READ-ONLY）

- 作成: Claude（2026-10-09）
- 運用ルール: docs/agy/README.md に従うこと
- 作業ブランチ: main を pull してから、main から phase1-cleanup を作成する
- **この指示書は READ-ONLY 調査だけ**。MOD・INI・プロファイル・セーブ・ゲームフォルダには一切書き込まない。ゲームも起動しない

## 背景

2026-10-05 に AI 会話（AISS + LM Studio）を取りやめ、以後は `Stable-NoAI` プロファイルで遊んでいる。
2026-10-07 に main の docs/MOD_SPEC.md へ、未導入の MOD 8件（安定化2・表示/QoL 4・武器2）が追加された。
次の導入作業に入る前に、**実機の状態**と**ドキュメントの記述**のずれを洗い出す。

## 作業1: 実機の現状確認（止まらずに進めてよい・読み取りのみ）

次を確認して報告に表でまとめる。

1. Starfield 本体のバージョン（Starfield.exe のファイルバージョン）。仕様の基準 1.16.244 と一致するか
2. SFSE のバージョン（sfse_loader.exe / sfse_1_*.dll のファイル名・バージョン）
3. MO2 のプロファイル一覧（`<MO2>\Starfield\profiles\` 配下のフォルダ名）
4. `Stable-NoAI` の `modlist.txt` と `plugins.txt` の中身（有効 `+`/`*` と無効 `-` の区別がわかる形で、そのまま転記）
5. `Stable` と `Test-NoAltStart` が残っていれば、`Stable-NoAI` との差分（MOD 名だけでよい）
6. `<MO2>\Starfield\mods\` 配下のフォルダ一覧（MOD 名と、分かればバージョン）。どのプロファイルでも使われていないものに印を付ける
7. 各プロファイルの `saves\` のセーブ件数と最新の日時（ファイル名・中身は開かない。件数と日時だけ）
8. デスクトップの Starfield 関係のショートカット名とリンク先
9. LM Studio・AISS Backend・llm-proxy が動いていないこと、自動起動が無効のままであること

## 作業2: ドキュメントの古い記述の洗い出し（止まらずに進めてよい・ファイルは書き換えない）

AI 会話の取りやめと作業1 の実機状態を前提に、以下のファイルで**実態と合わない記述**を探し、「ファイル名・行番号・今の記述（短く）・どう直すべきか」の表にする。**直すのは Claude が行うので、agy はファイルを編集しない。**

- README.md（「現在のフェーズ: Phase 0」など）
- docs/MOD_SPEC.md（特に 3章・7章・10章 Phase 1・11章 Phase 2 のテスト項目に残る AISS / LM Studio 前提の記述、1.1章の環境表）
- docs/INSTALL_GUIDE.md（導入 MOD 一覧・ロード順が実機と一致しているか）
- docs/CONFIG_GUIDE.md、docs/MOD_COMPATIBILITY.md、docs/MOD_JAPANESE.md、docs/TEST_PHASE1.md

あわせて次の2点について、事実だけを書く（判断はしない）。

- **Cassiopeia Papyrus Extender と Longer Names v2**: AISS の前提 MOD として入れたもの。`Stable-NoAI` で有効になっているか。AISS 以外に、これらを前提とする導入済み MOD があるか（各 MOD の Nexus 説明文・同梱 readme・ESM のマスター一覧で確認）
- **ニューゲーム直後のフリーズ（docs/TEST_CRASH.md）**: 10/04 以降に同様のフリーズが起きた形跡があるか（Windows イベントログの Kernel-Power 41 / EventLog 6008 の日時一覧だけでよい）

## 作業3: 報告

- `docs/agy/reports/phase1-cleanup-01.md` を書き、phase1-cleanup ブランチに commit・push して止まる
- 報告ファイル以外は commit しない
- 個人のパス・ユーザー名は `<Starfield>`、`<MO2>`、`<Documents>`、`<Steam>` のように伏せる

---

これから何をするかを説明し、許可を得てから作業を開始すること。
