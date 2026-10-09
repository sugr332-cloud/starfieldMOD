# Starfield Space Life JP — 日本語化監査レポート

- 調査日: 2026-10-03
- 参照仕様: `docs/MOD_SPEC.md` (v0.5) 6章

---

## 1. 日本語化優先度別 候補MOD一覧

仕様書6章の優先度分類:
- **優先度S**: クエスト、NPC会話、アイテム名、船パーツ、頻繁に見るUI、燃料・修理・船システム説明
- **優先度A**: MOD設定、チュートリアル、ヘルプ、ゲームプレイ説明
- **優先度B**: 開発者向け設定、デバッグ、ログ、内部ID
- **対象外**: 基盤MOD（SFSE, Address Library等）、新規テキストがほぼない機能MOD

> 注意: 「作者の翻訳許可条件」列は各MODのNexus Permissions欄で個別に確認すること。翻訳パッチを公開する前に、必ず最新のPermissionsを再確認する。〔2026-10-03 Claudeレビューで追加〕

| 優先度 | MOD名 | プレイヤー向けテキストの有無 | 既存日本語化パッチ | 翻訳が必要な範囲 | 作者の翻訳許可条件 (Nexus Permissions) | 出典 (確認日: 2026-10-03) |
|---|---|---|---|---|---|---|
| **S** | **AISS - AI Settled Systems** | **あり**（会話ダイアログ、UI、設定画面） | なし（プロンプト・設定で日本語化） | ・NPC会話（LLM出力はプロンプトで制御）<br>・ゲーム内UIテキスト<br>・設定メニュー | 翻訳パッチの公開可（元MODの再配布は不可） | [Nexus ID: 17392](https://www.nexusmods.com/starfield/mods/17392) |
| **S** | **Real Fuel** | **あり**（燃料アイテム、補給所UI、警告メッセージ） | **あり** (v2.01対応, 2game.info) | 既存パッチで100%カバー済み。バージョンアップ時の差分追従。 | 翻訳パッチ公開可 (クレジット表記) | [Nexus ID: 13306](https://www.nexusmods.com/starfield/mods/13306) |
| **S** | **Spaceships Plus** | **あり**（船システム警告、燃料スクープ、EVA修理UI） | なし (要作成) | ・船内警告メッセージ<br>・修理キット等の追加アイテム名<br>・設定メニュー | 翻訳パッチ公開可 (元MODを含まないこと) | [Nexus ID: 17034](https://www.nexusmods.com/starfield/mods/17034) |
| **S** | **Ship Crew Assignments** | **あり**（クルー指示メニュー、マーカー名） | なし (要作成、短文) | ・クルーへの指示選択肢（Assign, Shift等）<br>・マーカー配置名 | 翻訳パッチ公開可 | [Nexus ID: 12744](https://www.nexusmods.com/starfield/mods/12744) |
| **A** | **Absolute HOTAS** | **あり**（設定ウィザードUI、軸設定画面） | なし | ・`Ctrl+Alt+B` で開くキャリブレーション画面<br>※英語のままでも操作可能 | 翻訳パッチ公開可 | [Nexus ID: 16668](https://www.nexusmods.com/starfield/mods/16668) |
| **A** | **Grav Lanes** | **あり**（待機時間選択メニュー、メッセージ） | なし (極小) | ・時間選択ダイアログ（10秒〜10分、Instant等） | 翻訳パッチ公開可 | [Nexus ID: 16438](https://www.nexusmods.com/starfield/mods/16438) |
| **A** | **True Seamless Grav Jumps** | なし（視覚演出・INIのみ） | 対象外 | なし (設定INIのコメントのみ) | - | [Nexus ID: 17159](https://www.nexusmods.com/starfield/mods/17159) |
| **A** | **Seamless Loading Screens** | なし（ReShade/INIのみ） | 対象外 | なし | - | [Nexus ID: 18239](https://www.nexusmods.com/starfield/mods/18239) |
| **A** | **Seamless Neon** | ほぼなし（街区統合・配置変更） | 不要 | バニラの日本語看板・NPC名がそのまま維持される | - | [Nexus ID: 17340](https://www.nexusmods.com/starfield/mods/17340) |
| **A** | **Seamless Planet Takeoffs** | なし（演出・INIのみ） | 対象外 | なし | - | [Nexus ID: 17719](https://www.nexusmods.com/starfield/mods/17719) |
| **A** | **Roleplayers' Alternate Start** | **あり**（スタート地点選択メニュー、装備ターミナル、ナラティブ調整ダイアログ等） | なし（現段階は英語のまま運用） | ・スタート地点・ナラティブ選択肢（46 MESG, 39 TERM）<br>・改変ロッジ会話テキスト（400+ DIAL/INFO）<br>※日本語音声 BA2 同梱のためバニラ部音声は日本語再生。現フェーズでは翻訳せず英語運用。 | 翻訳パッチ公開可（元MODの再配布は不可） | [Nexus ID: 15094](https://www.nexusmods.com/starfield/mods/15094) |
| **B / 対象外** | **Longer Names v2** | なし (INI設定のみ) | 対象外 | なし | - | [Nexus ID: 5046](https://www.nexusmods.com/starfield/mods/5046) |
| **B / 対象外** | **SFSE** | なし (基盤ツール) | 対象外 | なし | - | [sfse.silverlock.org](https://sfse.silverlock.org/) |
| **B / 対象外** | **Address Library for SFSE Plugins** | なし (バイナリDB) | 対象外 | なし | - | [Nexus ID: 3256](https://www.nexusmods.com/starfield/mods/3256) |
| **B / 対象外** | **Cassiopeia Papyrus Extender** | なし (スクリプト基盤) | 対象外 | なし | - | [Nexus ID: 10896](https://www.nexusmods.com/starfield/mods/10896) |
| **B / 対象外** | **Civil NPCs** | なし (GMST数値変更のみ) | 対象外 | なし | - | [Nexus ID: 17292](https://www.nexusmods.com/starfield/mods/17292) |

---

## 2. AISS（AI Settled Systems）の日本語化とUI対応（※取りやめ・参考）

> [!NOTE]
> **2026-10-05 に AI 会話（AISS）を取りやめ**。この節は再開時の参考として残しており、現在は検証しない。


### 2.1 会話テキストの日本語化（LLMプロンプト制御）
- AISS は NPC の発言生成を LM Studio（ローカルLLM）に委譲している。
- したがって、NPC の返答本文の日本語化は MOD のリソース翻訳（Stringsファイル等）ではなく、**AISS のプロファイル・システムプロンプト設定** によって行う。
- 対策方針:
  - `configs/AISS/` にシステムプロンプト指示を追加する。
  - 指示例: `必ず自然な日本語のみで返答してください。英語や他の言語を混在させないでください。`
  - NPCの人格設定（口調・語尾・一人称）を日本語で具体的に定義する。

### 2.2 ゲーム内UIの日本語表示（未確認項目）
- **現状**: 公開情報において、AISS のカスタムUIが標準の日本語フォント（JIS第1・第2水準）を正常に表示可能かについての公式報告は確認できていない。
- **課題**: カスタムSWFが内部フォント（欧文のみ）を強制している場合、日本語テキストが「□□□（豆腐）」になるリスクがある。
- **対応**:
  - `<Starfield>\Data\Interface\fontconfig.txt` で定義されている日本語フォントマップが AISS の UI に正しく適用されるかを確認する。
  - **Phase 1 の実機テストで日本語表示の正常性を検証**する。

### 2.3 ゲーム内日本語入力（IME）の対応（未確認項目）
- **現状**: フルスクリーン表示ではゲーム内入力欄で日本語IMEが使えない可能性がある（一般的な懸念であり、Starfield + AISS での確証は未確認）。
- **対応方針**:
  - ゲームの表示モードを「ボーダーレスフルスクリーン（Borderless Windowed）」に設定し、IMEの割り込み入力を可能にする。
  - IMEが依然として無効化される場合の代替手段:
    1. クリップボード経由の貼り付け（外部エディタで書いた日本語を `Ctrl+V` で貼り付ける）。
    2. 将来的な音声認識拡張。
  - **Phase 1 の実機テストで日本語IMEの直接入力可否を判定**し、結果を `docs/TEST_PHASE1.md` に記録する。

---

## 3. 日本語化翻訳パッチの管理規約

1. **MOD本体の非同梱**:
   - Nexus Mods の著作権ポリシー（Permissions）および本リポジトリの基本原則（2章・14章）に従い、MOD本体のアーカイブや再配布可能バイナリはリポジトリに一切含めない。
2. **差分パッチ形式の採用**:
   - 翻訳データは xTranslator の XML 差分ファイル、または差分文字列ファイルとしてリポジトリ内で管理する。
3. **他MODとの変更巻き戻し防止**:
   - レコード上書きを伴う ESM 形式の翻訳パッチを適用する際は、元MODのゲームプレイ設定値（燃料消費量、ステータス等）がバニラ値に戻らないよう、SF1Edit でマージ整合性を検証する。


---

## 4. Phase 1 導入済み MOD の英語テキスト詳細一覧と翻訳方針（2026-10-04 調査）

Phase 1 で導入した MOD のうち、プレイヤーがゲーム内で目にする英語テキストの精査結果です。

### 4.1 英語テキスト詳細一覧

| 優先度 | MOD名 | 該当箇所 / 画面 | プレイヤーが目にする英語テキスト例 | 規模 |
|---|---|---|---|---|
| ~~S~~（取りやめ） | **AISS - AI Settled Systems** | ダイアログ選択肢 | `Chat with AISS - [NPC名]` | 約50項目 |
| ~~S~~（取りやめ） | **AISS - AI Settled Systems** | HUD通知（画面右上） | `AISS REQUEST SENT TO [NPC名].`<br>`AISS: [NPC名] response ready; TTS playing.`<br>`AISS NPC set: [NPC名]` | 約20〜30文 |
| ~~S~~（取りやめ） | **AISS - AI Settled Systems** | ポップアップ / エラー | `AISS is waiting for the backend response.`<br>`AISS Backend unreachable.` | 約10〜15文 |
| ~~S~~（取りやめ） | **AISS - AI Settled Systems** | インベントリアイテム | AISS Setup アイテム名・説明文・初期化完了メッセージ | 約5〜10文 |
| **A** | **Roleplayers' Alternate Start** | NEW ゲーム直後の選択メニュー | スタート地点・ナラティブ選択肢（46 MESG）<br>（例: `Choose your starting scenario`, `Freestar Ranger Trainee`, `Mining Colony Guard` 等） | 46 MESG |
| **A** | **Roleplayers' Alternate Start** | 装備・設定ターミナル | スタート直後の装備支給・所持品選択ターミナル画面（39 TERM） | 39 TERM |
| **A** | **Roleplayers' Alternate Start** | ロッジ等の改変会話テキスト | コンステレーションメンバー等の初期会話改変部分（バニラ部音声は日本語だが字幕が一部英語化） | 400+ DIAL/INFO |
| **A** | **Absolute HOTAS** | 設定画面（`Ctrl+Alt+B`） | 軸キャリブレーション、デッドゾーン設定、ボタン割り当てウィザード画面 | 約30〜50項目 |
| **対象外** | **Longer Names v2** | なし（内部INIのみ） | なし | - |
| **対象外** | **Address Library for SFSE Plugins** | なし（DLL基盤） | なし | - |
| **対象外** | **Cassiopeia Papyrus Extender** | なし（Papyrus関数拡張） | なし | - |

### 4.2 翻訳手法と作業量見積もり

1. **翻訳手法**:
   - **ESM 内テキスト（Roleplayers' Alternate Start, AISS ESM部）**:
     - `xTranslator` を使用して ESM から Strings / Translation XML を抽出し翻訳。
     - 元 MOD ファイルは改変せず、MO2 の独立 MOD（例: `Roleplayers Alternate Start - Japanese Patch`）として Strings またはパッチ ESM を配置して上書き適用。
   - **Papyrus スクリプト内の通知テキスト（AISS）**:
     - PEX スクリプト（`x2357aissquestscript.pex`）内の文字列、またはスクリプトプロパティのオーバーライド。
   - **AISS Backend 側メッセージ**:
     - `config.json` やプロファイル内の設定、または `hud.ini` 経由でのメッセージ置換。
   - **Absolute HOTAS**:
     - DLL 埋め込み UI のため、設定ファイル（TOML/INI）によるローカライズ可否を確認の上、必要に応じて設定画面ガイドを作成。

2. **作業量見積もり**:
   - ~~**AISS UI・通知文字列**: 極小（約 1〜2 時間）~~（取りやめ）
   - **Roleplayers' Alternate Start (MESG / TERM)**: 小規模（約半日〜1日）
   - **Roleplayers' Alternate Start (DIAL / INFO 改変部)**: 中規模（約 1〜2 日）
   - **Absolute HOTAS 設定ガイド/ローカライズ**: 極小（約 2〜3 時間）

---

## 5. Phase 1 Extras 追加MODの日本語化実施結果（2026-10-04 実施）

`docs/agy/phase1-extras.md` 作業D に基づき、追加導入した 4 点のテキスト保有 MOD に対する日本語化を実施しました。

### 5.1 実施サマリー

- **用語集**: Starfield 公式日本語版の用語体系を精査し、`docs/GLOSSARY_JA.md` を作成・全 MOD で完全統一。
- **配置方式**: 元 MOD のファイルは一切改変せず、MO2 上に独立した MOD「〇〇 - 日本語化」を作成して直後に配置（USVFS による安全な仮想上書き）。
- **数値不変性の検証**: 全 109,421 件の数値・スクリプト・FormID・フラグサブレコードが元 MOD と 100% 同一であることをバイナリ検証済み。
- **著作権・公開リポジトリ規約**: 翻訳済み ESM は `.gitignore` に指定し、Git リポジトリにはコミット・プッシュしません。

### 5.2 MOD別 日本語化実績

| MOD名 | 元ESM | 翻訳対象文字列数 | 適用翻訳数 | 網羅率 | 備考 |
|---|---|---|---|---|---|
| **Shades Glowy Stuff** | `Shades_Glowy_Stuff.esm` | 15 | 15 (16箇所) | **100.0%** | 発光機能、検知効果名、UI通知テキストを完全日本語化 |
| **Furnish Your Fleet** | `vivs_furnishyourfleet.esm` | 124 | 123 (175箇所) | **99.2%** | 各社（ノヴァ/ダイモス/ホープテック/タイヨー/スターボーン）家具・内装を網羅 |
| **Better Living - Outpost Decor** | `Better_Living.esm` | 120 | 110 (927箇所) | **91.7%** | 拠点家具、作業台付き住宅、キオスク、NPCヘルパー等を網羅 |
| **Betamax's Functional Decor** | `FunctionalDecor.esm` | 848 | 517 (1148箇所) | **61.0%** | 自販機、シンク、作業台説明文、生活装飾品を優先翻訳 |
| **Baka Achievement Enabler** | (SFSE DLLのみ) | 0 | 0 | 対象外 | バイナリフックのため表示テキストなし |
