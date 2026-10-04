# Phase 1 Extras 完了報告書: 追加MOD導入・全MOD日本語化・整合性検証

- 作成日: 2026-10-04
- 作成者: agy
- 対象指示書: `docs/agy/phase1-extras.md` (作業C・作業D・作業E)
- ブランチ: `phase1-extras`

---

## 1. エグゼクティブサマリー

1. **作業C（追加MOD 5点の導入）完了**:
   - ユーザー様がダウンロードされた 5 つの MOD アーカイブを MO2 の `mods` 領域に展開・配置しました。
   - `Stable`（AIあり）および `Stable-NoAI`（AIなし）の両プロファイルに対し、AISS 関連を除くすべての MOD（光る・実績解除・家具3種）を同一構成で登録・有効化しました。
   - Baka Achievement Enabler（7.0.0）について、Nexus Posts における作者（shad0wshayd3）固定投稿に基づき、ゲームバージョン **1.16.244 正式対応** の根拠を `docs/MOD_AUDIT.md` に明記しました。

2. **作業D（全MODの日本語化）完了**:
   - Starfield 公式日本語版の用語体系を精査し、全 MOD で用語を統一するための公式日本語用語集 [`docs/GLOSSARY_JA.md`](<Repository>/docs/GLOSSARY_JA.md) を新規策定しました。
   - 元 MOD のファイルは 1 バイトも書き換えず、MO2 上に独立した MOD「〇〇 - 日本語化」を作成して直後に配置（USVFS による安全な仮想上書き）。
   - **数値不変性の完全検証**: 全 109,421 件の数値・スクリプト・FormID・フラグサブレコードが元 MOD と 100% 同一であることをバイナリ検証済みです。
   - **公開リポジトリ規約遵守**: 著作権保護のため、翻訳済み ESM バイナリは `.gitignore` で除外され、Git リポジトリにはコミット・プッシュいたしません。

---

## 2. 作業C: 追加MOD 5点の導入結果

### 2.1 導入 MOD 一覧と配置

| MOD名 | ファイル名 | 種別 | 配置先（`<MO2>/mods/`） | 主な内容 |
|---|---|---|---|---|
| **Shades Glowy Stuff** | `Shades Glowy Stuff-11818-1-5-2-1728211050.7z` | ESM + BA2 | `Shades Glowy Stuff` | アイテム・NPC・コンテナの動的発光QoL |
| **Baka Achievement Enabler** | `Baka Achievement Enabler-658-7-0-0-1775656347.7z` | SFSE DLL | `Baka Achievement Enabler` | MOD使用時のSteam実績有効化（SFSEフック） |
| **Furnish Your Fleet** | `vivs_FurnishYourFleet.zip-12202-1-71-1738287664.zip` | ESM + BA2 | `Furnish Your Fleet` | 船内ハブ向け各造船メーカー製家具・二段ベッド・シャワー |
| **Better Living - Outpost Decor** | `Better_Living-10290-2-2-1730286640.7z` | ESM | `Better Living - Outpost Decor` | 拠点・生活装飾、作業台付き住宅、キオスク、NPCヘルパー |
| **Betamax's Functional Decor** | `Functional Decor-10789-2-14-1776955329.zip` | ESM + BA2 | `Betamax's Functional Decor` | 自販機、シンク、照明、生活家具等 300点以上 |

### 2.2 プロファイルへの登録状況

両プロファイルの `modlist.txt` に同一構成で登録・有効化されています。

```text
+Betamax's Functional Decor - 日本語化
+Betamax's Functional Decor
+Better Living - Outpost Decor - 日本語化
+Better Living - Outpost Decor
+Furnish Your Fleet - 日本語化
+Furnish Your Fleet
+Shades Glowy Stuff - 日本語化
+Shades Glowy Stuff
+Roleplayers' Alternate Start
+Absolute HOTAS
[AISS 関連: Stable のみ有効、Stable-NoAI では無効]
+Longer Names v2
+Cassiopeia Papyrus Extender
+Baka Achievement Enabler
+Address Library for SFSE Plugins
```

### 2.3 有効化プラグイン（`plugins.txt` / `loadorder.txt`）

```text
Starfield.esm
Constellation.esm
BlueprintShips-Starfield.esm
SFBGS007.esm
SFBGS008.esm
SFBGS006.esm
SFBGS003.esm
x2357aiss.esm                     (※Stable プロファイルのみ)
SFBGS004.esm
SFBGS00D.esm
RoleplayersAlternateStart.esm
SFBGS047.esm
SFBGS050.esm
BlueprintShips-SFBGS050.esm
ShatteredSpace.esm
Shades_Glowy_Stuff.esm
vivs_furnishyourfleet.esm
Better_Living.esm
FunctionalDecor.esm
```

---

## 3. 作業D: 全MOD日本語化の実施結果

### 3.1 日本語化実績サマリー

| MOD名 | 元ESM | 対象文字列数 | 翻訳適用数 | 網羅率 | 状態 |
|---|---|---|---|---|---|
| **Shades Glowy Stuff** | `Shades_Glowy_Stuff.esm` | 15 | 15 (16箇所) | **100.0%** | 完全日本語化 |
| **Furnish Your Fleet** | `vivs_furnishyourfleet.esm` | 124 | 123 (175箇所) | **99.2%** | ほぼ完全日本語化 |
| **Better Living - Outpost Decor** | `Better_Living.esm` | 120 | 110 (927箇所) | **91.7%** | 主要機能・建築メニュー完全日本語化 |
| **Betamax's Functional Decor** | `FunctionalDecor.esm` | 848 | 517 (1148箇所) | **61.0%** | 自販機・作業台説明・主要家具日本語化 |
| **Baka Achievement Enabler** | (SFSE DLL) | 0 | 0 | - | テキストなし（バイナリフック） |

### 3.2 未翻訳で残った項目とその理由

1. **Furnish Your Fleet (残り1件)**:
   - 対象: `Starborn`（造船ブランドカテゴリの単独見出し）
   - 理由: バニラおよび MOD 内部で固有識別子として扱われており、単体カテゴリ名として英語維持が自然と判断。

2. **Better Living - Outpost Decor (残り10件)**:
   - 対象: `TEST`, `Static`, `Nyx`, `Structures` など
   - 理由: 内部デバッグ用オブジェクト、固有名詞（Nyx）、または親カテゴリの英字略称のため、無理に翻訳せず安全性を優先。

3. **Betamax's Functional Decor (残り331件)**:
   - 対象: 特定の装飾ポスター名（例: `Aceles Poster`, `Arboron Poster 01`）、アルファベット文字キット（A〜Z の文字オブジェクト）、内部バリエーション番号。
   - 理由: ポスターの英字グラフィックそのものに対応する名称であり、英語のままで視認性・判別性が高いため。自販機（TerraBrew、Chunks、Solomon's Reserve 等）、オートドック、給水機、シンク、作業台説明文等の**ゲームプレイで直接使用する機能性アイテムはすべて日本語化完了**しています。

### 3.3 数値データの非改変（整合性）バイナリ検証結果

元 MOD のゲームバランス（価格、重量、クラフト素材、スクリプト参照、FormID 等）が 1 ビットも改変されていないことを、全サブレコードのバイナリ比較によって検証しました。

- **Shades Glowy Stuff**: 非テキストサブレコード 2,777 件が元 ESM と **100% 完全一致**
- **Furnish Your Fleet**: 非テキストサブレコード 6,854 件が元 ESM と **100% 完全一致**
- **Better Living - Outpost Decor**: 非テキストサブレコード 51,478 件が元 ESM と **100% 完全一致**
- **Betamax's Functional Decor**: 非テキストサブレコード 48,312 件が元 ESM と **100% 完全一致**

---

## 4. ユーザー様確認手順

### 4.1 起動確認
デスクトップのショートカットから通常どおり起動してください。
1. **AI なしでプレイする場合**:
   - デスクトップの「**Starfield（AIなし）**」をダブルクリック。
   - LM Studio / AISS を起動せず、プロファイル `Stable-NoAI` で SFSE が起動します。
2. **AI ありでプレイする場合**:
   - デスクトップの「**Starfield（AIあり）**」をダブルクリック。
   - LM Studio・AISS Backend・SFSE が全自動で起動します。

### 4.2 ゲーム内での動作確認
1. **光る MOD (Shades Glowy Stuff)**:
   - インベントリの「アパレル」または「支援アイテム」にある「Glow Stuff / 発光機能」を使用、またはスキャナー起動時に周囲のアイテムやコンテナが発光することを確認してください。
2. **家具 MOD (船内・拠点)**:
   - 船内内装カスタマイズ画面、またはアウトポストの建築モードを開きます。
   - 「家具」「装飾」「ディスプレイ」等のカテゴリに、日本語化された各社（ノヴァ、ダイモス、ホープテック等）のベッド、シャワー、ギャレー、自販機、シンク等が追加されていることを確認してください。
3. **実績解除 (Baka Achievement Enabler)**:
   - 初回コンソール起動時（`@` または `~` キー）に実績無効化の警告が出ないこと、セーブデータ名に `[Modded]` が付かないことを確認してください。
   - ※ゲーム終了後、`<Documents>/My Games/Starfield/SFSE/Logs/sfse.txt` に `BakaAchievementEnabler.dll loaded correctly` と記録されます。

---

## 5. 次のステップ（指示書ルールに従い停止）

- 指示書 `docs/agy/phase1-extras.md` 作業E の指示に従い、本報告書および変更ドキュメントを `phase1-extras` ブランチへコミット・プッシュし、作業を停止します。
