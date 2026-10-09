# Starfield Space Life JP — 競合分析および運用管理規約

- 調査日: 2026-10-03
- 参照仕様: `docs/MOD_SPEC.md` (v0.5) 8章・4章・7.1章

---

## 1. 確定した競合および重大度一覧（出典あり）

仕様書8章の定義に基づく重大度分類:
- **CRITICAL**: 起動不能、セーブロード不能、CTD、永久ロード、操作不能、主要処理破綻
- **HIGH**: クエスト進行不能、NPC/クルー停止、船機能停止、Grav Jump不能、AISS会話不能
- **MEDIUM**: UI崩れ、テキスト欠落、一部アニメーション/ロード演出不良
- **LOW**: 表示順、翻訳漏れ、ログ警告のみ

| 領域 / 組み合わせ | 重大度 | 内容・競合メカニズム | 出典 (確認日: 2026-10-03) | 対策・管理方針 |
|---|---|---|---|---|
| **Real Fuel × Ships Need Gas** | **CRITICAL** | 同一機能（He-3燃料消費によるGrav Jump制限、ステーション補給機能）の重複による完全破綻。 | 仕様書4章、[Nexus ID: 13306](https://www.nexusmods.com/starfield/mods/13306), [Nexus ID: 7197](https://www.nexusmods.com/starfield/mods/7197) | **完全排他（同時導入不可）**。Real Fuel を単独採用し、Ships Need Gas は除外。 |
| **全SFSEプラグイン × ゲーム本体バージョン** | **HIGH** | ゲーム本体（`Starfield.exe`）の更新によりメモリアドレスが変化し、未対応DLLが起動時CTDを引き起こす。 | [SFSE公式](https://sfse.silverlock.org/) | ゲームバージョン `1.16.244` に対応したSFSE 0.2.21および各プラグインのみを使用。本体更新時は起動停止。 |
| **Seamless Neon（ワールドスペース改変）** | **HIGH** | ネオン内部セルを外部ワールドスペースへ統合。作者は途中導入で一部のクエストが壊れると警告。 | [Nexus ID: 17340 (作者説明)](https://www.nexusmods.com/starfield/mods/17340) | **New Game または NG+ (Unity jump) が前提**。作者が非互換と明記する大型Neon改変MOD（Seamless City Interiors、Neon Core Disguised Seamless Project、Neon Core Apartment、Kansha - Neon Apartment、The Dark Side of Neon 等）と排他。SFBGS00D.esm（2026年4月以降のゲームバージョン）必須。 |
| **Grav Lanes の非互換MOD** | **HIGH** | Grav Lanes は Immersive Grav Jumps と非互換（競合）。 | [Nexus ID: 16438 (作者説明)](https://www.nexusmods.com/starfield/mods/16438) | Immersive Grav Jumps は導入しない。 |
| **Civil NPCs × AISS**（※AISS取りやめ・参考） | **LOW** | Civil NPCs は GMST（ゲーム設定値8項目）の調整のみでスクリプトなし。AISS の会話開始に干渉せず共存。 | [Nexus ID: 17292](https://www.nexusmods.com/starfield/mods/17292), [Nexus ID: 17392](https://www.nexusmods.com/starfield/mods/17392) | 競合なし。共存可能。 |
| **Roleplayers' Alternate Start × 他の Alternate Start 系** | **CRITICAL** | 同一のニューゲーム開始処理・Unity 開始処理をフックするため完全排他。 | [Nexus ID: 15094 (作者説明)](https://www.nexusmods.com/starfield/mods/15094) | 他の Alternate Start 系 MOD（有料/無料問わず）は一切導入しない。IgnusT 作「Starborn Trait」とも非互換のため除外。 |

---

## 2. Grav Lanes × True Seamless Grav Jumps の再調査結果

- **以前の判定（CRITICAL）の撤回**:
  - 当初、ジャンプ中船内歩行スクリプトとロード画面スキップDLLの衝突を懸念してCRITICALと推測判定していましたが、公式情報の再調査により**CRITICAL判定を正式に取り下げます**。仕様書4章への「排他化」提案も撤回します。
- **事実と出典 (確認日: 2026-10-03)**:
  - **作者併用推奨**: Grav Lanes の Nexus ページにおいて、作者（slamanna）は **True Seamless Grav Jumps を併用推奨（Recommended）** として明記しています（出典: [Nexus Mods ID: 16438](https://www.nexusmods.com/starfield/mods/16438)）。
  - **併用前提MODの存在**: 両MODを併用することを前提とした MOD（例: [Nexus Mods ID: 17417](https://www.nexusmods.com/starfield/mods/17417) "Alien Juggernaut Jump Sound Replacer"）が公開されています。
- **今後の対応**:
  - 「互換性あり」と確定的に断定することは避け、**「作者が併用を推奨。実機での動作および視覚演出の調和は Phase 3 で検証」** と記録して段階的にテストします。

---

## 3. 未確認項目（推測）— 重大度判定保留

以下の項目は、公式の明記や複数ユーザーの確定的な不具合報告が確認できておらず、現時点では技術的な懸念・推測にとどまるため、重大度判定を行わずに「未確認（推測）」として記録します。実機テスト（Phase 1〜4）にて実際の挙動を検証します。

### 3.1 Spaceships Plus × Real Fuel の燃料連携
- **推測される懸念**:
  - Spaceships Plus の作者説明には「works with or without Real Fuel」とあり、Real Fuel との連携機能が謳われている（出典: [Nexus Mods ID: 17034](https://www.nexusmods.com/starfield/mods/17034)）。
  - しかし、両者を同時に有効化した際、設定メニューで明示的に調整しない場合に He-3 燃料の消費が二重に発生しないかについては、公式に明記されていないため**未確認の推測**である。
- **検証計画**: Phase 2 において、ジャンプ時・航行時の燃料消費量を実測して確認する。

### 3.2 Spaceships Plus × Ship Crew Assignments の干渉
- **推測される懸念**:
  - Spaceships Plus の船体破損・減圧イベント時、Ship Crew Assignments のアニメーションマーカーに固定されたクルーが退避行動をとれるかについて。
  - 両MOD間の相互干渉に関する作者の明記やユーザー報告は確認されておらず、**未確認の推測**である。
- **検証計画**: Phase 2 において、船内減圧時のクルー挙動を実機で観察する。

### 3.3 Absolute HOTAS × 航行系MOD の入力割り込み
- **推測される懸念**:
  - Grav Lanes による自動航行中や Seamless Planet Takeoffs による離陸上昇中に、HOTAS のアナログ軸入力がスクリプト制御に割り込んでベクトルを乱さないかについて。
  - 公式の不具合報告は確認されておらず、**未確認の推測**である。
- **検証計画**: Phase 3 / 4 において、自動シーケンス中のスティック入力挙動を実機で検証する。

### 3.4 Seamless Loading Screens × Seamless Planet Takeoffs（離陸時の画面遷移）
- **懸念**:
  - Seamless Loading Screens は、作者説明によればドア・エレベーター・搭乗・船外移動に加えて**離陸時の遷移**にも作用する（出典: [Nexus ID: 18239](https://www.nexusmods.com/starfield/mods/18239)）。
  - Seamless Planet Takeoffs も離陸のロードを排除するMODであり、同じ遷移に両方が作用する可能性がある。
  - 両MOD間の相互作用に関する作者の明記は未確認。
- **検証計画**: Phase 4 で Seamless Planet Takeoffs を追加する際、離陸遷移を重点的に検証する。必要なら Seamless Loading Screens 側で離陸遷移を無効化できる設定があるかを確認する。
- 〔2026-10-03 Claudeレビューで追加〕

### 3.5 AISS UI の日本語表示・IME入力（※取りやめ・参考）
> [!NOTE]
> **2026-10-05 に AI 会話（AISS）を取りやめ**。この節は再開時の参考として残しており、現在は検証しない。

- **推測される懸念**:
  - AISS のカスタムSWFが日本語フォントグリフを正しく描画できるか、DirectX 12排他フルスクリーン下で日本語IMEが直接入力できるかについて。
  - 公開ドキュメントに確証がなく、**未確認の推測**である。
- **検証計画**: Phase 1 の実機テストで検証し、表示不良時はフォント設定、入力不能時はボーダーレスウィンドウや貼り付け等の代替手段を検証する。

### 3.6 Roleplayers' Alternate Start × AISS（AI 会話）の相互作用（※取りやめ・参考）
> [!NOTE]
> **2026-10-05 に AI 会話（AISS）を取りやめ**。この節は再開時の参考として残しており、現在は検証しない。

- **推測される懸念**:
  - Roleplayers' Alternate Start はバニラの初期クエスト「One Small Step」をスキップし、アーティファクト取得やロッジ導入クエストを独自のフックに置き換える。
  - AISS の NPC 会話フックや会話要求（`latest_request.ini`）が、代替スタート後の NPC（バレット、サラ等）で正常に機能するかについて。
  - 相互干渉に関する作者の明記はなく、互いに独立したスクリプト／フック構造を持つが、クエスト進行フラグの差異が AISS 会話のトリガーに影響しないか確認が必要。
- **検証計画**: **AISS との相性は Phase 1 の実機テストで確認**する（代替スタート後にロッジ等でコンパニオンと会話可能か実機検証）。

---

## 4. MOD運用・競合防止ルール案

### 4.1 SF1Edit によるレコード競合チェック手順
SF1Edit (Starfield xEdit v4.1.5以上) を用いた競合監査の標準手順:
1. **MO2への登録**: `SF1Edit64.exe` を MO2 の実行可能プログラム一覧に登録する。
2. **起動**: 必ず MO2 経由で起動する（MO2の仮想ファイルシステム VFS を通すことで、アクティブなMODプラグインがすべて読み込まれる）。
3. **モジュール選択**: チェック対象のプロファイル（Stable / Immersion-Test 等）で有効化されている全プラグインにチェックを入れて「OK」を押す。
4. **競合フィルタの適用**: バックグラウンドローダー完了後、左側のツリーで右クリックし、`Apply Filter to show Conflicts` を実行する。
5. **判定基準**:
   - **赤色（Conflict / Overwrite）**: 他のMODによってレコードが上書きされている状態。意図した上書き（パッチ等）か、予期せぬ破壊かを右ペインの詳細ビューで確認。
   - **緑色（No Conflict）**: 単独追加または完全に調和している状態。
6. **競合解消パッチの作成**: 複数MODの変更点を統合する必要がある場合、右クリックから `Copy as override into...` を選択し、新規パッチESL（例: `SpaceLife_Patch.esp`）にマージする。

### 4.2 MO2 のファイル競合（上書き）確認手順
ファイルレベル（Mesh, Texture, Script PEX, UI SWF）の競合確認:
1. MO2の左ペイン（MODインストール一覧）の「Flags」列を確認する。
   - **赤マイナスアイコン (`-`)**: 下のMODによってファイルが上書きされている。
   - **緑プラスアイコン (`+`)**: 上のMODのファイルを上書きしている。
   - **赤緑両方 (`+-`)**: 上書きしつつ、さらに下からも上書きされている。
2. 対象MODをダブルクリックし、「Conflicts（競合）」タブを開く。
3. 上書きされているファイル一覧を確認し、特に `.pex`（スクリプト）や `.swf`（UI）が意図せず上書きされていないかを検証する。
4. 優先すべきMODを左ペインでドラッグ＆ドロップし、下位（優先度大）へ配置する。

### 4.3 日本語化パッチのロード順ルール
**問題の背景**:
日本語化パッチ（ESM形式）をMODの後にロードする際、古いバージョンのバニラデータに基づいて作成されたパッチをそのまま配置すると、元MODが行ったパラメータ変更（攻撃力、消費燃料、AI設定等）がバニラ値に巻き戻ってしまう「レコード逆行現象」が発生する。

**運用ルール**:
1. **翻訳パッチの形式優先順位**:
   - 第1優先: **Stringsファイル / xTranslator による文字列のみの差分適用**（プラグイン自体のレコード構造を変更しないため逆行が発生しない）。
   - 第2優先: レコード更新後の最新プラグインに対応した翻訳ESM。
2. **ロード順の原則**:
   - 翻訳ESMが存在する場合、必ず「元MODの直後」に配置する。
3. **SF1Editでの逆行監査**:
   - 翻訳ESMを配置した後、SF1Editで元MODと翻訳ESMを比較し、英語テキスト以外のゲームプレイ数値レコードが元MODの値を正しく保持しているかを確認する。

### 4.4 全SFSEプラグインのゲームバージョン一括確認方法
起動時にゲームエンジンがロードした全DLLのステータスを一括で検証する標準手順:
1. SFSE経由（`sfse_loader.exe`）でゲームを一度起動し、メインメニュー表示後に終了する。
2. 生成されたログファイルを確認する。
   - パス: `<Starfield>\Data\SFSE\sfse.log`（MO2環境下では MO2の `overwrite\SFSE\sfse.log` または各MODフォルダに出力される）。
3. ログ内の以下のような記述を検索・点検する（下記は記述のイメージであり、実際の書式は実ログで確認すること）:
   ```text
   checking plugin: <PluginName>.dll
   plugin version: x.x.x
   compatible: YES (target version: 1.16.244.0)
   ```
4. もし `disabled, incompatible version` や `failed to load` のエラーが存在した場合、そのプラグインは現在の本体バージョンで動作していないと判定し、MO2で無効化する。

---

## 5. 追加MOD（Phase 1 Extras）の競合・ロード順分析

- 調査日: 2026-10-04
- 対象MOD: Shades Glowy Stuff, Baka Achievement Enabler, Furnish Your Fleet, Better Living, Betamax's Functional Decor

### 5.1 競合マトリクス

| MOD名 | 種別 | 主要機能 | 既存レコード改変 (Override) | 新規レコード (New Form) | 競合リスク | 対策 / 配置方針 |
|---|---|---|---|---|---|---|
| **Shades Glowy Stuff** | ESM / PEX | アイテム・コンテナの発光 | なし（近接オブジェクト動的シェーダー付与） | 発光設定・スクリプト | **LOW** | 既存セル・レコードを破壊しないため、ロード順任意。 |
| **Baka Achievement Enabler** | SFSE DLL | 実績解除・警告抑止 | なし（メモリフック） | なし | **LOW** | Address Library 必須。プラグイン（ESM）不要のためロード順なし。 |
| **Furnish Your Fleet** | ESM | 船内家具・生活設備追加 | なし（独立ビルドメニュー） | 各種船内家具 Form | **LOW** | 船内セル自体を編集せず、プレイヤーが配置する家具フォームを追加するため競合なし。 |
| **Better Living - Outpost Decor** | ESM | 拠点家具・装飾追加 | なし（独立ビルドメニュー） | 拠点装飾 Form | **LOW** | アウトポスト用ビルドツリーに独自カテゴリを展開。安全に共存可能。 |
| **Betamax's Functional Decor** | ESM | 機能性家具・自販機追加 | なし（独立ビルドメニュー） | 機能家具 Form | **LOW** | 独自カテゴリで整理されており、他家具MODと共存可能。 |

### 5.2 ロード順とプロファイル運用ルール
1. **プロファイルへの適用**:
   - 追加MOD（光る・実績解除・家具3種）は、**`Stable`（AIあり）と `Stable-NoAI`（AIなし）の両プロファイル**に同一構成で登録・有効化する。
   - ※AISS関連（`AISS - AI Settled Systems`、`AISS - Japanese Language Addon`）のみ `Stable` 専用とし、`Stable-NoAI` では無効化を維持する。
2. **推奨ロード順（plugins.txt）**:
   ```text
   *x2357aiss.esm                     (Stable プロファイルのみ)
   *RoleplayersAlternateStart.esm
   *Shades_Glowy_Stuff.esm
   *vivs_furnishyourfleet.esm
   *Better_Living.esm
   *FunctionalDecor.esm
   ```
3. **日本語化パッチの配置原則**:
   - 後続の作業Dで作成する各MODの「〇〇 - 日本語化」MODは、MO2左ペインにおいて元のMODの直下に配置する。

## 6. 安定化・バグ修正MODの採用判定

調査日: 2026-10-07

### 6.1 Starfield Engine Fixes - SFSE
- **判定: 採用 / Stable候補**
- Free Lanes 1.16.244対応版が公開されており、エンジン由来のバグ修正、負荷最適化、カスタムマップマーカー消失、スターマップのデータベース位置クラッシュ等を対象とする。
- 既存構成ではSFSEを基盤として使用するため、直接の機能重複はない。
- **競合回避:** SFSEプラグインのため、ゲーム本体更新時は必ず対応版へ更新する。任意機能を追加するINI設定は、必要性を確認してから有効化する。
- **出典:** Nexus Mods Starfield Engine Fixes - SFSE（2026-10-04更新、Free Lanes 1.16.244対応）。

### 6.2 Orbit Traffic Fix
- **判定: 採用 / Stable候補**
- Free Lanes環境で残る軌道上船舶トラフィック管理スクリプトの不具合を修正する。
- 既存構成には同じ SQ_TrafficManagerScript を置換するMODがなく、直接競合なしと判断。
- SFCP/USFPとも互換と作者が明記しているため、将来これらを比較導入する場合も競合監査対象にはなるが、初期Stableでは総合パッチを併用しない方針を維持する。
- **出典:** Nexus Mods Orbit Traffic Fix（Starfield 1.16.244向け）。

### 6.3 不採用: 総合バグ修正パッチ
- **Starfield Community Patch (SFCP):** 多数の修正を含むが、今回の構成では個別修正を選択管理する方針と重複するため初期Stableには入れない。
- **Unofficial Starfield Patch (USFP):** 修正範囲が広く、個別修正MODとの上書き・機能重複を監査する負担が大きいため初期Stableには入れない。
- これらは「悪いMOD」ではなく、**今回の競合回避・最小構成方針に合わないため除外**する。

---

## 7. Phase 1 仕上げ 8件の監査（2026-10-09）

- **調査日**: 2026-10-09
- **対象環境**: Starfield 1.16.244.0 (Steam) / SFSE 0.2.21 / `Stable-NoAI` プロファイル
- **調査手法**: Orca 内蔵ブラウザ（`orca` CLI）による Nexus Mods 公開ページ（Description、Files、Posts、Requirements、Permissions）の直接閲覧および検証。

### 7.1 8件の個別監査詳細

#### 1. Starfield Engine Fixes - SFSE
- **MOD ID / URL**: [Nexus 10457](https://www.nexusmods.com/starfield/mods/10457)
- **正式名**: Starfield Engine Fixes - SFSE
- **作者**: LarannKiar
- **最新版 / 更新日**: v21.2 (2026-10-04)
- **1.16.244 対応の根拠**:
  - Files タブの Main File 名が `Starfield Engine Fixes - Game version 1.16.244`（v21.2、2026-10-04）。
  - 説明文に「Supports Game version 1.16.244 (June 11 2026)」。
  - 作者の固定投稿（Sticky）にて「v20.0 - 2026-06-13: Added support for Game version 1.16.244 (June 11 2026 update)」と明記。
- **種別**: SFSE DLL プラグイン（`SFSE\Plugins\StarfieldEngineFixes.dll` + `StarfieldEngineFixes.ini`）。プラグイン（ESM/ESP）なし、BA2 なし。
- **前提MOD**: SFSE（Nexus Requirements: Starfield Script Extender）。SFSE 0.2.21 に対応。Address Library は要求されない。
- **非互換・推奨ロード順**: ESM がないためロード順なし。INI 設定の `AI Update Patch` は一部の AI MOD と相性問題が起きる可能性ありと記載。
- **競合の可能性**:
  - `Baka Achievement Enabler`: Baka は実績解除フックを担当。Engine Fixes にはセーブ名の `[C]` プレフィックスを非表示にする `Disable Save Mod Mark`（v6.2）があるが、実績解除フックそのものは含まれず競合しない。
  - `Absolute HOTAS`: HOTAS は入力・操縦フックを担当。Engine Fixes の宇宙船カメラ修正（`Flight Camera On Free Look Exit fix`）は POV 復帰時のカメラ注視角リセットのみで、操縦入力とは干渉しない。
  - `Real Fuel`（Phase 2）: Engine Fixes の INI 任意機能 `No Grav Jump Limit`（燃料・航続距離の制限撤廃）を有効化すると Real Fuel の設計と真っ向から衝突する。**必ず既定（無効: 0）のまま運用すること**。
- **英語テキスト**: ゲーム内に追加されるテキストは基本的に皆無（純粋なエンジンバグ修正）。INI 設定ファイルが英語。
- **Permissions**: 個人利用・設定変更に支障なし（無断再配布は禁止）。
- **Creations版との関係**: SFSE DLL のため Nexus 専用。

#### 2. Orbit Traffic Fix - Persistent Ship Traffic Manager Script Fix
- **MOD ID / URL**: [Nexus 18325](https://www.nexusmods.com/starfield/mods/18325)
- **正式名**: Orbit Traffic Fix - Persistent Ship Traffic Manager Script Fix
- **作者**: dwnfdrknss
- **最新版 / 更新日**: v1.0.0 (2026-09-26)
- **1.16.244 対応の根拠**:
  - 作者説明文の Credits に「Fix: Built against SQ_TrafficManagerScript from Starfield 1.16.244」と明記。
  - 公開日が 2026-09-26 であり、1.16.244 環境でテスト済み。
- **種別**:
  - 形式A（推奨）: ルーズスクリプト（`Scripts/SQ_TrafficManagerScript.pex`、プラグインなし）。
  - 形式B: ESM + BA2（`OrbitTrafficFix.esm` [Light Master] + `OrbitTrafficFix - Main.ba2`）。
- **前提MOD**: バニラゲーム本体のみ（SFSE 不要）。
- **非互換・推奨ロード順**:
  - 非互換: `Interstellar Traffic`（Nexus 12509、同じ `SQ_TrafficManagerScript` を改変するため排他）。
  - 互換: SFCP、USFP、交通量・船種追加 MOD と互換。
  - 推奨形式: ルーズスクリプト版。プラグインスロットを消費せず、MO2 上でスクリプトの上書き衝突を即座に検知可能。
- **競合の可能性**: 既存 MOD（INSTALL_GUIDE 2章）および他7件で `SQ_TrafficManagerScript` を触るものは皆無。競合なし。
- **英語テキスト**: なし（バックグラウンドで周回するゴーストタイマーの停止ロジックのみ。UI・ダイアログ・通知なし）。
- **Permissions**: 個人利用に支障なし。
- **Creations版との関係**: MO2 管理のため Nexus 版を使用。

#### 3. StarUI HUD
- **MOD ID / URL**: [Nexus 3444](https://www.nexusmods.com/starfield/mods/3444)
- **正式名**: StarUI HUD
- **作者**: m8r98a4f2
- **最新版 / 更新日**: v1.4 (2026-09-06)
- **1.16.244 対応の根拠**: 2026-09-06 に v1.4 が公開され、Free Lanes / 1.16.244 環境で動作確認済み。
- **種別**: ルーズ UI ファイル（`Interface/hudmenu.gfx`, `Interface/hudrolloverwidget.gfx`, `.swf`, `.ini` 等）。ESM/ESP なし、SFSE DLL なし。
- **前提MOD**: Archive Invalidation（`bInvalidateOlderFiles=1`）。SFSE 不要。
- **非互換・推奨ロード順**:
  - 同じ HUD ファイル（`hudmenu.gfx` 等）を変更する他の HUD MOD と排他。
  - 将来のインベントリ UI 候補（AstralUI / StarUI Inventory / PraxisUI）との関係:
    - `StarUI Inventory` / `PraxisUI`: 主に `inventorymenu.gfx` / `containermenu.gfx` を変更するため、StarUI HUD（探索 HUD / ロールオーバー UI）とは競合せず併用可能。
    - `AstralUI`: インベントリ・コンテナに加え Quick Loot（`hudrolloverwidget.gfx`）を含む場合がある。AstralUI 併用時は Quick Loot モジュールを除外するか、MO2 左ペインで StarUI HUD を下位（優先度高）に配置して StarUI HUD 側を優先させる。
- **競合の可能性**: 既存 MOD 中に UI GFX ファイルを変更するものはなし。競合なし。
- **英語テキスト**:
  - UI 項目（DPS、V/W、タグアイコン等）。
  - 本 MOD（v1.4）には日本語用のアイテムソート辞書 `Interface/ItemSorter/NamesIndex_ja.swf` が標準同梱されている。
  - テキスト翻訳は `Interface/Translation/StarUI_HUD_en.txt`（724 bytes）で管理されており、日本語化ファイル（`StarUI_HUD_ja.txt`）の適用またはローカル翻訳が極めて容易。
- **Permissions**: 作者が翻訳パッチの作成条件を明記（`Interface\Translation\StarUI_HUD_[LanguageCode].txt` の同梱を許可、元 MOD 必須）。非公開の個人利用にも一切支障なし。
- **Creations版との関係**: Nexus 版を使用。

#### 4. Decal Fix
- **MOD ID / URL**: [Nexus 17576](https://www.nexusmods.com/starfield/mods/17576)
- **正式名**: Decal Fix
- **作者**: MelodicJJ
- **最新版 / 更新日**: v2.1 (Loose: 2026-07-24) / v2 (Packaged: 2026-07-24)
- **1.16.244 対応の根拠**: 2026-06-26 初版公開、2026-07-24 更新（1.16.244 リリース後）。バニラ由来の未表示デカールパターンの修正。
- **種別**:
  - Packaged 版: `DecalFix.esm` (Light Master / 97 bytes) + `DecalFix - Main.ba2` (79.5 KB)。ESM は BA2 読み込み用ダミーでレコード改変なし。
  - Loose 版: ルーズテクスチャ/メッシュ (17 KB)。
- **前提MOD**: なし（バニラ本体のみ）。
- **非互換・推奨ロード順**: 非互換なし。レコード変更がないためロード順任意。
- **競合の可能性**:
  - 既存 MOD との競合なし。
  - Starfield Engine Fixes の #41「Actor Decal fix」（DLL 側の弾痕デカール浮遊バグ修正）とは対象が異なり（本 MOD はワールドデカールパターンのアセット修正）、相互に干渉せず共存可能。
- **英語テキスト**: なし（純粋なアセット修正）。
- **Permissions**: 個人利用に支障なし。
- **Creations版との関係**: Nexus 版を使用。

#### 5. Neutral LUTs - No Color Filters
- **MOD ID / URL**: [Nexus 323](https://www.nexusmods.com/starfield/mods/323)
- **正式名**: Neutral LUTs - No Color Filters
- **作者**: fadingsignal
- **最新版 / 更新日**: v1.5 (2024-10-03)
- **1.16.244 対応の根拠**: 静的 DDS テクスチャ（`textures/effects/LUTs/*.dds`）のルーズファイル差し替え。実行ファイルのバージョンに依存せず、1.16.244 でも完全動作。
- **種別**: ルーズテクスチャ（DDS）。プラグインなし、SFSE DLL なし。
- **前提MOD**: Archive Invalidation。
- **非互換・推奨ロード順**:
  - 他の LUT 差し替え MOD（Native Light LUT Overhaul 等）と排他。1系統のみ有効化する。
  - ReShade / Phase 3 Seamless Loading Screens との関係:
    - 作者自身が「This works especially good as a base for a ReShade preset.」と明記。
    - Seamless Loading Screens は ReShade 6.8.0+ のアドオン機能でロード画面を隠すものであり、LUT との競合・干渉は皆無。
  - Luma（Native HDR）との関係: 将来 Luma を導入する場合は LUT 処理との重複を確認する必要があるが、現在の `Stable-NoAI` には含まれないため問題なし。
- **競合の可能性**: 既存 MOD とのファイル衝突なし。
- **英語テキスト**: なし（純粋な画像テクスチャ）。
- **Permissions**: 個人利用に支障なし。
- **Creations版との関係**: Nexus 版を使用。

#### 6. Easy Digipick (Lockpick)
- **MOD ID / URL**: [Nexus 451](https://www.nexusmods.com/starfield/mods/451)
- **正式名**: Easy Digipick (Lockpick)
- **作者**: Ixion XVII (IxionXVII)
- **最新版 / 更新日**: v1.4 (2026-04-29)
- **1.16.244 対応の根拠**:
  - Posts タブにて 2026-06-14「it's working with the latest patch」、2026-06-25「The latest version confirms that this mod still works」、2026-07-06「It still works」と、1.16.244 環境での動作が複数報告されている。
- **種別**: ESM プラグイン（`Easy Digipick.esm`、Small / Light Master）。※初期の bat / CCR 方式から v1.4 で ESM 方式へ刷新済み。
- **前提MOD**: なし（SFSE 不要）。
- **非互換・推奨ロード順**: デジピックのミニゲームルールを変更する他 MOD と排他。`plugins.txt` のゲームプレイ調整枠に配置。
- **競合の可能性**: 既存 MOD および他7件との競合なし。セキュリティスキルのパーク要求判定はバニラ通り維持される。
- **英語テキスト**: なし（パズル生成アルゴリズムのパラメータ変更のみで、UI 文字列・Perk 名・通知メッセージの追加・改変なし）。
- **Permissions**: 個人利用に支障なし。
- **Creations版との関係**: Nexus 版を使用（MO2 で管理）。

#### 7. Weapon Mod Fixes - WMF
- **MOD ID / URL**: [Nexus 9091](https://www.nexusmods.com/starfield/mods/9091)
- **正式名**: Weapon Mod Fixes - WMF
- **作者**: frogs345
- **最新版 / 更新日**: v1.10 (2025-06-19)
- **1.16.244 対応の根拠**: **【未対応・重大な懸念】**
  - Nexus の最新版は 2025-06-19 の v1.10 のまま更新されていない。
  - 作者 frogs345 自身が 2026-04-14 および 2026-05-16 の Posts で以下のように明言:
    > "I'm definitely planning on updating this with support for Free Lanes... I'm just waiting for xEdit to update, as that's going to make it a lot easier to make the changes I need, particularly with the changes around legendary and quality crafting."
    > "I'm using the p version, but that doesn't properly support the Free Lanes update yet, particularly when it comes to weapons. The changes around quality upgrades and legendary crafting/rolling means that a number of records related to weapons either don't work in xEdit, or really shouldn't be edited in xEdit."
  - Starfield 1.16.244（Free Lanes アップデート以降）では武器品質（Tier 5/6）やレジェンダリクラフトに関する内部レコード構造が変更されているが、Nexus 公開版（v1.10）はこれらより前のデータ構造を上書き（Override）してしまう。
- **種別**: ESM + BA2（`WeaponModFixes.esm` + BA2 2種 + オプション ESM 群）。
- **前提MOD**: バニラ本体。
- **非互換・推奨ロード順**: 武器ホルスター機能は武器レコードを変更する他 MOD と手動パッチが必要。
- **競合の可能性**: 1.16.244 のバニラ武器レコード・武器 MOD（OMOD）レコードを pre-Free Lanes の値で上書きし、Free Lanes の武器機能やクラフトを巻き戻す危険性あり。
- **英語テキスト**: 武器モジュール名、説明文などに大量の英語テキストあり（日本語化必須）。
- **Permissions**: 個人利用に支障なし。
- **Creations版との関係**: Nexus 版。
- **総合判定**: **採用見送り・保留**。作者による Free Lanes / 1.16.244 対応版のリリースを待つべきである。

#### 8. Weapon Quality Diversity
- **MOD ID / URL**: [Nexus 17044](https://www.nexusmods.com/starfield/mods/17044)
- **正式名**: Weapon Quality Diversity
- **作者**: Kilonova24
- **最新版 / 更新日**: v1.0 (2026-05-12)
- **1.16.244 対応の根拠**: 2026-05-12 公開。Free Lanes で追加された Tier 5（Superior）/ Tier 6（Exceptional）および X-Tech クラフトに対応。
- **種別**: ESM（`Weapon Quality Diversity.esm`、Small Master / Medium）。
- **前提MOD**: **【致命的ブロッカー】**
  - Nexus の Requirements に **`Shattered Space DLC`** および **`Terran Armada DLC`** が必須指定されている。
  - 本プロジェクトの環境（`docs/agy/reports/phase1-extras-01.md`、`docs/MOD_AUDIT.md` で実機確認済み）では `ShatteredSpace.esm` は所持しているが、**`Terran Armada DLC` は未所持**である。
  - 必須マスターが欠落しているため、有効化するとゲーム起動時に即座にクラッシュ（Missing Master CTD）する。
- **非互換・推奨ロード順**:
  - `Weapon Quality Tier Fix` と完全排他（作者明記）。
  - 武器のステータスや Tier を変更する全 MOD と競合。
- **競合の可能性**: WMF とも同一の武器レコード（Quality_TiersAny 等）を変更するため直接競合する。
- **英語テキスト**: 武器 Tier 配分に関するレコード変更。
- **Permissions**: 個人利用に支障なし。
- **Creations版との関係**: Nexus 版。
- **総合判定**: **採用見送り・除外**。本環境に `Terran Armada DLC` が導入されない限り、物理的にロード不能。

---

### 7.2 重点監査項目のまとめ

1. **StarUI HUD と将来のインベントリ UI（AstralUI / StarUI Inventory / PraxisUI）の組み合わせ**:
   - StarUI HUD は HUD・照準・クイックルート窓（`hudrolloverwidget.gfx`）を担当する。
   - `StarUI Inventory` / `PraxisUI` はインベントリ画面等を担当するため、UI 担当範囲が完全に分離しており衝突しない。
   - `AstralUI` を選択する場合、Quick Loot モジュールを無効化するか、MO2 で StarUI HUD を優先させることで安全に共存可能。
2. **Neutral LUTs の排他・共存条件**:
   - 他の LUT テクスチャ差し替え MOD とは完全排他（1系統のみ）。
   - Phase 3 の `Seamless Loading Screens`（ReShade 6.8.0+ 前提）とは競合しない（作者も ReShade のベースとして推奨）。
   - Luma（HDR）導入時は LUT 処理との重複を監査する必要があるが、現構成では導入しないため問題なし。
3. **武器系 2 件の相互関係と問題点**:
   - `Weapon Quality Diversity`: `Terran Armada DLC` 未所持のため導入不可（CTD ブロッカー）。**〔2026-10-09 Claude 訂正〕ユーザーは Terran Armada を所持（Shattered Space も所持）。前提は満たすため導入可能**
   - `Weapon Mod Fixes - WMF`: 2025 年 6 月の v1.10 のままであり、1.16.244 / Free Lanes の武器品質・レジェンダリクラフト変更に対応した更新が未リリース。バニラ最新レコードの破壊リスクがあるため保留。
4. **Starfield Engine Fixes - SFSE の機能と既存 DLL との共存**:
   - 既定のエンジン修正（表情リセット、デカール浮遊、マップマーカー消失、CTD 回避など 40 件以上）は安全に機能。
   - `Baka Achievement Enabler`、`Absolute HOTAS` とのフック衝突なし。
   - INI 設定の `No Grav Jump Limit`（燃料無限化）は Phase 2 の `Real Fuel` を無効化してしまうため、既定値（0 = 無効）のまま維持することが必須。

---

### 7.3 採用判定とグループ構成の改編案

事前監査の結果、MOD_SPEC 10.1章で計画された 8 件のうち、**6 件が安全に導入可能、2 件が導入見送り**と判定された。

| 当初グループ | MOD | 監査結果 | 判定理由 |
|---|---|---|---|
| **1. 安定化** | Starfield Engine Fixes - SFSE | **採用** | 1.16.244 / SFSE 0.2.21 完全対応（v21.2）。既存 DLL との競合なし |
| **1. 安定化** | Orbit Traffic Fix | **採用** | 1.16.244 のスクリプトからビルド（v1.0.0）。ルーズ版推奨 |
| **2. 表示/QoL** | StarUI HUD | **採用** | 1.16.244 適合（v1.4）。日本語ソート swf 同梱、UI 競合なし |
| **2. 表示/QoL** | Decal Fix | **採用** | 1.16.244 適合（v2/v2.1）。純粋なアセット修正で無害 |
| **2. 表示/QoL** | Neutral LUTs | **採用** | ルーズ DDS。1.16.244 適合、ReShade 併用問題なし |
| **2. 表示/QoL** | Easy Digipick | **採用** | 1.16.244 動作確認済み（v1.4 ESM）。UI 英語化なし |
| **3. 武器** | Weapon Mod Fixes - WMF | **見送り（保留）** | pre-Free Lanes 版（v1.10）のままであり、1.16.244 の新武器仕様と不整合 |
| **3. 武器** | Weapon Quality Diversity | **採用**（2026-10-09 訂正） | 前提の Shattered Space / Terran Armada をユーザーが所持。武器の性能・Tierを変える他MODは導入しない（WMF も保留中） |

**推奨実施手順**:
Phase 1 仕上げの実機導入は、グループ 1（安定化 2 件）およびグループ 2（表示/QoL 4 件）の計 6 件に絞って進め、グループ 3（武器）はスキップすることを提案する。

---

## 8. マップ系MOD 3件の監査（2026-10-09）

- **調査日**: 2026-10-09
- **対象環境**: Starfield 1.16.244.0 (Steam) / SFSE 0.2.21 / `Stable-NoAI` プロファイル / 所有DLC: Shattered Space, Terran Armada
- **調査手法**: Orca 内蔵ブラウザ（`orca` CLI）による Nexus Mods 公開ページ（Description, Files, Posts, Requirements, Permissions）の直接閲覧および検証。

### 8.1 3件の個別監査詳細

#### 1. Slightly Better Map Icons
- **MOD ID / URL**: [Nexus 4813](https://www.nexusmods.com/starfield/mods/4813)
- **正式名**: Slightly Better Map Icons
- **作者**: MindDoser
- **最新版 / 更新日**: Version XVII (17) (2026-04-08)
- **1.16.244 対応の根拠**:
  - 本 MOD はプラグイン（ESM）やスクリプト（PEX）、DLL ではなく、純粋な Scaleform ベクター UI アセット（`Data\Interface\mapicons.gfx` および `mapicons.swf`）の差し替え。
  - v17 は 1.16.236（Free Lanes / Terran Armada）で追加された新アイコン（REV-8、新ロケーション等）に合わせて作成された最新ビルド。
  - 1.16.244（2026-06-11）はマイナーパッチであり、マップアイコンのベクター仕様に変更はないため、1.16.244 でも完全動作する。
  - 作者 Posts にて「StarUI HUD、StarUI Inventory、BetterHUD など mapicons.swf/gfx を触らないすべての UI MOD と互換」と明記。
- **種別**: ルーズ UI ファイル（`mapicons.gfx`, `mapicons.swf`）。プラグインなし、SFSE DLL なし。
- **前提MOD**: なし（Archive Invalidation 有効化のみ）。
- **非互換・推奨ロード順**:
  - 非互換: 同じ `mapicons.gfx` / `mapicons.swf` を変更する他アイコン MOD。
  - ロード順: プラグインスロット不要。MO2 左ペインの優先度のみ。
- **競合の可能性**:
  - `Starfield Engine Fixes - SFSE`: Engine Fixes は DLL 側のマップマーカー処理（カスタムマーカー消失、スターマップ DB クラッシュ）を修正するものであり、UI ベクターとは非干渉。競合なし。
  - `StarUI HUD`: StarUI HUD（v1.4）の収録ファイルに `mapicons.gfx`/`swf` は含まれず、作者も互換性を保証。競合なし。
  - Phase 3（Seamless Neon, Grav Lanes 等）: ワールドスペースや遷移の MOD であり、アイコンアセットとは競合なし。
  - 他 2 件（12719, 15633）との競合: 他 2 件はマーカー配置の ESM であり、アイコン画像自体は触らないため競合なし。
- **セーブへの影響**: なし。純粋な UI 表示アセットのため、セーブデータへの書き込み・残留は皆無。途中導入・途中削除が完全に安全。
- **英語テキスト**: なし（0語）。純粋なベクター図形・シンボルアイコンであり、テキスト文字列を一切含まない。
- **Permissions**: 個人利用・改善に支障なし。
- **Creations版との関係**: MO2 管理のため Nexus 版を使用。
- **判定**: **【採用】**。安全・軽量で競合リスクのない優れた QoL 表示 MOD。

#### 2. City Interior Map Markers for Fast Travel
- **MOD ID / URL**: [Nexus 12719](https://www.nexusmods.com/starfield/mods/12719)
- **正式名**: City Interior Map Markers for Fast Travel
- **作者**: xtcrefugee and AssyMcGee
- **最新版 / 更新日**: v1.2 (2025-05-23)
- **1.16.244 対応の根拠**: **【未対応・リスクあり】**
  - 最新版 v1.2 は 2025-05-23（本体 1.15.216 時代）で更新停止。
  - 本 MOD は外部ワールドスペース（Mars, Titan, Jemison, Porrima III）と内部セル（Cydonia, New Homestead, Red Mile, The Well, The Lodge）のレコードを直接複製・変更（Override）している（ESM サイズが 934 kB に及ぶ）。
  - 1.16.236 / 1.16.244（Free Lanes、REV-8 追加、惑星・都市サーフェスマップ改変等）より前の古いセル・ワールドスペースレコードを上書きするため、1.16.244 のバニラ修正やワールドスペース変更を巻き戻す（逆行）リスクが高い。
- **種別**: ESM プラグイン（`CityInteriorMapMarkers.esm` [Medium/Full Master, 934 kB]、オプション `AdditionalMapMarkers_AkilaCity.esm` [Small Master, 1.1 kB]）。
- **前提MOD**: バニラ本体。
- **非互換・推奨ロード順**:
  - 作者明記: セルレコードおよびワールドスペースレコードを複製しているため、該当ロケーションを変更する全 MOD と競合する。
- **競合の可能性**:
  - `Roleplayers' Alternate Start`（Phase 1 導入済み）: ロッジ内部マーカー（The Lodge）を使用した場合、初期クエスト未完了状態でロッジへ不正に侵入できてしまい、メインクエスト進行フラグを破壊する恐れがある（作者も「is not advisable to use before completing the main quest」と警告）。
  - Phase 3 `Grav Lanes` / `True Seamless Grav Jumps`: 宇宙から直接インテリアへファストトラベルすると、星系間航行や軌道アプローチのゲームプレイが完全にバイパスされる。
  - プロジェクト基本方針との矛盾: Space Life JP の基本方針（ロード画面スキップのワープではなく、宇宙船航行や都市生活のシームレスな移動を楽しむ方針）と設計思想が対立する。
  - `Remove Overlapping Markers For Cities`（15633）との競合: 15633 はマーカー重複を排除して宇宙港着陸に統一する MOD であり、重複する内部マーカーを増やす 12719 とは設計思想が真逆で両立しない。
- **セーブへの影響**:
  - 配置された MapMarker および内部セルの XMarker linked reference は、一度プレイヤーが「発見（Discovered）」するとセーブデータ内に永続的に記録される。削除時に参照欠落・不整合のリスクあり。
- **英語テキスト**: あり。追加されるマーカー名がすべて英語（`Cydonia Central Hub`, `New Homestead Interior`, `Red Mile Interior`, `The Well Interior`, `The Lodge` 等）。日本語版環境では地名が英語で表示されるため日本語化が必要。
- **Permissions**: 個人利用に支障なし。
- **Creations版との関係**: Nexus 版。
- **判定**: **【採用見送り（保留・非推奨）】**。1.15.216 の古いセル・ワールドスペース上書きによる先祖返りリスク、英語地名、Alternate Start とのクエスト順序破壊リスク、没入感向上コンセプトとの不一致のため。

#### 3. Remove Overlapping Markers For Cities
- **MOD ID / URL**: [Nexus 15633](https://www.nexusmods.com/starfield/mods/15633)
- **正式名**: Remove Overlapping Markers For Cities
- **作者**: CompactPrism (CompactPrism2)
- **最新版 / 更新日**: v1.3 (2026-04-17)
- **1.16.244 対応の根拠**: 2026-04-17 更新（Free Lanes 1.16.236 向け）。
- **種別**: ESM + BA2（`DisableMarkers.esm` [832 kB] + `DisableMarkers - Main.ba2` [1.1 kB]）。Full/Medium Master。
- **前提MOD**: バニラ本体。
- **非互換・推奨ロード順**:
  - 主要都市の `WRLD`（Worldspace）Form を直接改変（NewAtlantis, NeonCity, LC167World）。
  - 都市ワールドスペースを変更する MOD と排他・競合。
- **競合の可能性**:
  - Phase 3 **`Seamless Neon` との CRITICAL 競合**:
    - Seamless Neon は `NeonCity` のワールドスペースを統合・改変する大型 MOD。
    - 本 MOD は `NeonCity` の WRLD レコードを直接改変し、さらに `Neon Core` マーカーを無効化（Disabled）する。Seamless Neon とのワールドスペース競合および着陸ポイント喪失の重大な危険がある。
  - クエスト重要地点の喪失:
    - ユーザー報告にある通り、紅の艦隊や UC ヴァンガードのクエストで必須となる `Red Devils HQ`（火星）の着陸マーカーまで軌道上から非表示・無効化してしまい、クエスト進行時に直接着陸できなくなる。
  - `City Interior Map Markers`（12719）との競合: 設計思想が真逆であり両立不可。
- **セーブへの影響**: **【致命的・不可逆（CRITICAL BLOCKER）】**
  - 作者自身が明記:
    > 「however after removing this mod, the changes will still be there so ensure that this is the right mod for you by using a backup before enabling it.」
  - マーカーの非表示・無効化フラグがセーブデータに直接書き込まれ、**MOD をアンインストールしても消えたマーカー（ニューアトランティス各地区、ネオンコア、レッドデビルズHQ等）が復活しない**（セーブデータ不可逆破壊）。
  - コンソールで 1 つずつ FormID を調べて enable しない限り復旧不能。
- **英語テキスト**: 地名・マーカー無効化処理が中心だが、WRLD レコードの上書きにより一部地名が英語化される懸念あり。
- **Permissions**: 個人利用に支障なし。
- **Creations版との関係**: Nexus 版。
- **判定**: **【不採用・完全除外（CRITICAL RISKS）】**。不可逆なセーブデータ改変（アンインストール後もマーカーが永久消失）、Seamless Neon との WRLD 衝突、クエスト重要マーカー消失の致命的欠陥があるため導入不可。

---

### 8.2 重点監査項目のまとめ

1. **Starfield Engine Fixes - SFSE との相互作用**:
   - Engine Fixes（v21.2）のカスタムマーカー消失修正（#40）はエンジンコードレベルの処理であり、Slightly Better Map Icons（ベクターアイコン）と完全に独立して共存可能。
2. **StarUI HUD との共存**:
   - Slightly Better Map Icons（`mapicons.gfx`/`swf`）と StarUI HUD（`hudmenu.gfx` 等）は変更対象ファイルが重複せず、作者 MindDoser もグリーンライト（互換）を明記。
3. **Phase 3 Seamless Neon / 宇宙旅行系 MOD との関係**:
   - `Remove Overlapping Markers For Cities` は `NeonCity` の WRLD レコードを改変し `Neon Core` を無効化するため、Phase 3 の Seamless Neon と致命的に衝突する。
   - `City Interior Map Markers` は宇宙から直接内部セルへワープするため、Phase 3 の Grav Lanes / True Seamless Grav Jumps が提供するシームレスな星系間・軌道間航行体験を損なう。
   - `Slightly Better Map Icons` はアイコン描画のみの変更であるため、Phase 3 のどの MOD とも一切衝突しない。
4. **セーブデータ安全性と不可逆性**:
   - `Remove Overlapping Markers For Cities`: **不可逆（セーブデータ汚染）**。削除後もマーカーが復活しないため絶対に使用してはならない。
   - `City Interior Map Markers`: マーカー発見状態がセーブデータに残留する。
   - `Slightly Better Map Icons`: **完全安全（セーブデータ非接触）**。

---

### 8.3 採用判定のまとめ

| MOD | 監査結果 | 判定理由 |
|---|---|---|
| **Slightly Better Map Icons** | **採用** | 純粋なベクター UI アセット（GFX/SWF）。1.16.244 適合、StarUI HUD 互換、英語テキストなし、セーブ汚染ゼロ |
| **City Interior Map Markers for Fast Travel** | **見送り（保留・非推奨）** | 1.15.216 の古いセル・ワールドスペース上書きによる先祖返りリスク、英語地名、Alternate Start とのクエスト干渉、没入感方針との不一致 |
| **Remove Overlapping Markers For Cities** | **不採用（完全除外）** | 削除後もマーカーが復活しない不可逆なセーブ改変、Seamless Neon との WRLD 衝突、クエスト重要マーカー消失 |



