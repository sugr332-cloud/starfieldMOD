# 指示書: AIあり/なし起動、追加MOD（光る・家具・実績解除）、全MODの日本語化

- 作成: Claude（2026-10-04）
- 運用ルール: docs/agy/README.md に従うこと
- 作業ブランチ: main から phase1-extras を作成する
- **phase1-aiss（AISS の日本語化・高速化）が終わってから着手すること**。並行して進めない

## ユーザーの要望

1. デスクトップに「AI MOD あり」と「AI MOD なし」の2つの起動アイコンを置く
2. 大事なもの（拾えるアイテム等）が光る MOD、家具 MOD、MOD 使用中でも実績が解除できる MOD などを追加する
3. 入れた MOD を**すべて日本語化**する

## 作業A: AI あり / なしの起動アイコン（止まらずに進めてよい）

- MO2 に「Stable-NoAI」プロファイルを作る（Stable の複製から、AISS と AISS - Japanese Language Addon を無効化）。プロファイル別セーブは Stable と**別**になることを確認し、TEST/CONFIG ガイドに注意として書く（AI なしで遊んだセーブを AI ありで続けたい場合の扱いも記載）
- ランチャーに「AI なし」モードを追加する（LM Studio と AISS Backend を起動せず、Stable-NoAI で SFSE を起動）
- デスクトップのアイコンを次の2つにする（どちらも MO2 のアイコン）
  - 「Starfield（AIあり）」: 現在の「Starfield（MOD）」を改名
  - 「Starfield（AIなし）」
- 「LLMなし・テスト用」のアイコンは削除する
- 以後、MOD を追加するときは Stable と Stable-NoAI の両方に入れる（AISS 関係を除く）

## 作業B: 追加 MOD の選定と監査（ここで1回止まる）

- ユーザーは「選定はリポジトリに push 済み」と言っているが、Claude が確認した時点で main・全ブランチに該当する一覧は見つからなかった。agy の手元（未 push のファイル、別リポジトリ、メモ等）に一覧があれば、それを使う。なければ以下の候補で監査する
- 候補（Claude が見つけたもの。最新版・ゲーム 1.16.244 対応・前提・競合・日本語化・Permissions を Phase 0 と同じ形式で確認する）
  - 光る: Shades Glowy Stuff（Nexus 内で検索）、およびその Terran Armada 対応修正版「Shades Glowy Stuff Terran Armada Fix」（Nexus 17615、Terran Armada DLC が前提。ユーザーが Terran Armada を持っているかを Data の esm で確認）
  - 実績解除: Baka Achievement Enabler（SFSE 版）。ゲーム 1.16.244 に対応した版があるか必ず確認する。古い ASI 版（Nexus 252「Achievement Enabler」、2023年）は使わない
  - 家具: 船内・アウトポストに置ける家具を増やす MOD を2〜3個調べ、候補として挙げる（Bethesda 公式 Creations と Nexus の両方を確認。Creations の有料品は除外）
- 監査結果を docs/MOD_AUDIT.md と docs/MOD_COMPATIBILITY.md に追記し、仕様書（MOD_SPEC.md）の3章・7章に追加案を書く
- `phase1-extras-01.md` に、**ユーザーがダウンロードする MOD の一覧（Nexus のリンクと「Mod Manager Download」で入れるファイル名）**を書いて push し、止まる

## 作業C: 追加 MOD の導入（ユーザーのダウンロード後。止まらずに進めてよい）

- Stable と Stable-NoAI に導入し、MO2 の競合表示と SF1Edit の考え方（docs/MOD_COMPATIBILITY.md 4章）で確認する
- 実績解除 MOD の導入後、SFSE ログで読み込みを確認する

## 作業D: 全 MOD の日本語化（止まらずに進めてよい）

- 対象: 導入済みのすべての MOD のうち、プレイヤーが目にするテキストがあるもの（docs/MOD_JAPANESE.md の一覧と、作業C で追加したもの）
- 方法: xTranslator（または同等の方法）で、各 MOD ごとに日本語の翻訳ファイルを作り、MO2 の別 MOD「〇〇 - 日本語化」として元の MOD の直後に置く。元の MOD のファイルは書き換えない
- 既存の日本語化パッチがあるもの（Real Fuel 等）はそれを優先する
- 用語は Starfield 日本語版の公式訳に合わせる（バニラの日本語 strings から用語を拾う）。用語集を `docs/GLOSSARY_JA.md` に作り、全 MOD で統一する
- 翻訳後、SF1Edit 等で元 MOD の数値（燃料消費量など）が変わっていないことを確認する
- **重要: リポジトリは公開されている。翻訳ファイル（翻訳済みの esm / strings / xTranslator の辞書）は commit・push しない**（MOD 作者の許可がない限り公開できないため）。リポジトリに入れてよいのは、用語集・手順・翻訳対象の一覧だけ
- AISS 本体の UI の日本語化は、phase1-aiss の結果（アドオンでの扱い）を踏まえて行う

## 作業E: 報告（ここで止まる）

- phase1-extras ブランチに、変更したドキュメント・ランチャー・用語集と `phase1-extras-02.md` を commit・push して止まる
- 報告には、日本語化した MOD の一覧、未翻訳で残ったもの（理由付き）、ユーザーが確認する手順を書く

---

これから何をするかを説明し、許可を得てから作業を開始すること。

---

## phase1-extras-01 へのレビュー（Claude、2026-10-04）

作業A・B と phase1-aiss の修正1・2を確認し、main にマージした（報告内の実ユーザー名を含むデスクトップのパスは Claude が `<Desktop>` に置き換えた。今後は絶対に書かないこと）。思考オフ（思考トークン 0、キャッシュ時 約2秒）は大きな成果。

### 指摘: Baka Achievement Enabler のゲームバージョン

- Nexus 658 の最新版（7.0.0、2026-04-08）の対応ゲームバージョンは **1.15.216** と明記されている。現在のゲームは **1.16.244**。監査では「1.16.244 対応」としていたが、根拠が確認できない
- SFSE プラグインはゲームバージョンが合わないと読み込まれない（sfse.txt に非対応と出る）か、Address Library 経由で動く場合もある。作業C で導入したら、**sfse.txt で読み込み結果を必ず確認**し、非対応なら無効化して「1.16.244 対応版の公開待ち」と記録すること。ゲームが不安定になる兆候があれば即座に無効化する
- MOD_AUDIT.md の該当箇所を、根拠（Nexus の記載）に合わせて修正すること

### 訂正（Claude、16:28）: Baka Achievement Enabler は 1.16.244 対応

- ユーザーが確認した作者（shad0wshayd3）の固定投稿に「**バージョン 7.0.0 はゲームバージョン 1.16.236、1.16.242、1.16.244 をサポートしています**」とあった。上の指摘は Claude の誤り（ページの要約だけを見ていた）。7.0.0 は 1.16.244 に対応している
- 導入後は通常どおり sfse.txt で読み込みを確認すること。MOD_AUDIT.md には、根拠として作者の固定投稿を記載する

### 作業C・D の進め方

- ユーザーのダウンロード完了後、作業C（導入）→ 作業D（日本語化）を止まらずに進めてよい
- 導入は Stable と Stable-NoAI の両方に行う（AISS 関係を除く）
- 作業D の翻訳ファイルは commit・push しない（公開リポジトリのため）
- 完了したら `phase1-extras-02.md` を push して止まる
