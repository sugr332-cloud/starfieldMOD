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

