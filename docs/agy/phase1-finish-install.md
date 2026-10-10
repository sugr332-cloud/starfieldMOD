# 指示書: Phase 1 仕上げ — 9件の導入（Stable-NoAI）

- 作成: Claude（2026-10-10）
- 運用ルール: docs/agy/README.md に従うこと
- 作業ブランチ: main を pull してから、main から phase1-finish-install を作成する
- 対象プロファイル: **`Stable-NoAI` のみ**（`Stable` と `Test-NoAltStart` は変更しない）
- 根拠: `docs/MOD_SPEC.md` 10.1章、`docs/MOD_COMPATIBILITY.md` 7章・8章、`docs/DOWNLOAD_LIST.md`「Phase 1 仕上げ」

## 入力（ユーザーがダウンロード済み。`<Downloads>` = ユーザーのダウンロードフォルダ）

| グループ | MOD | アーカイブ |
|---|---|---|
| 1 | Starfield Engine Fixes - SFSE 21.2 | `Starfield Engine Fixes - Game version 1.16.244 10457 21.2 ...zip` |
| 1 | Orbit Traffic Fix 1.0.0（ルーズ版） | `OrbitTrafficFix 1.0.0 18325 1.0.0 ...zip` |
| 2 | StarUI HUD 1.4 | `StarUI HUD 3444 1.4 ...7z` |
| 2 | Decal Fix 2.1（ルーズ版） | `DecalFix-LooseFiles 17576 2.1 ...zip` |
| 2 | Neutral LUTs 1.5 | `Neutral LUTs - No Color Filters v1-5-323-...rar` |
| 2 | Easy Digipick 1.4 | `Easy Digipick-451-1-4-...rar`（483 バイト。中身を確認すること） |
| 2 | Shades Glowy Stuff Terran Armada Fix 1.0.2 | `Shades Glowy Stuff TerranArmada Fix 17615 1.0.2 ...zip` |
| 2 | Slightly Better Map Icons 17 | `XVII-4813-17-...rar` |
| 3 | Weapon Quality Diversity 1.0 | `QualityTierVariation-17044-1-0-...zip` |

## 共通ルール

- 作業中は MO2 を起動しない（`modlist.txt` / `plugins.txt` を直接編集するため。MO2 が起動していたら止まって報告）
- 導入方法は Phase 1 追加MODと同じ: アーカイブを `<MO2>\Starfield\mods\<MOD名>\` に展開する（アーカイブ内の余計な親フォルダは除き、`Data` 直下相当の構成にする）。`meta.ini` に `version=` と `modid=` を書く
- `Stable-NoAI` の `modlist.txt` に `+<MOD名>` を追加する。位置は「既存MODより高優先度（ファイル先頭側）」。ただし下の個別指示に従う
- 新しいプラグイン（ESM/ESP）は `Stable-NoAI` の `plugins.txt` の末尾に `*<ファイル名>` で追加する（個別指示があればそれに従う）
- 各グループの後、MO2 の競合に相当する確認として、**新MODのファイルと既存MODのファイルの相対パスの重複**を一覧にする（重複があれば、どちらが勝つかと、それが意図どおりかを書く）
- 1つのアーカイブに複数の選択肢（FOMOD・Main/Optional）が入っていたら、止まって報告する（推測で選ばない）
- 英語テキストを持つものは一覧にする（翻訳は後で別指示。今回はしない）

## 作業0: バックアップ（止まらずに進めてよい）

- `<MO2>\Starfield\profiles\Stable-NoAI\` をフォルダごと（saves を含む）`D:\StarfieldMODs\Backup\2026-10-10\Stable-NoAI\` にコピーする
- `<Documents>\My Games\Starfield\` の `StarfieldCustom.ini` / `StarfieldPrefs.ini` があれば同じ場所にコピーする
- コピーの件数とサイズを報告に書く

## 作業1: グループ1（安定化）を導入し、止まる

1. **Starfield Engine Fixes - SFSE**
   - SFSE プラグイン（`SFSE\Plugins\` の DLL と INI/TOML）。SFSE 0.2.21・1.16.244 用であることをファイル名・同梱 readme で確認する
   - 設定ファイルは**既定値のまま**。ただし Grav Jump の距離・燃料制限を外す類の任意機能（例: No Grav Jump Limit）が既定で無効であることを確認し、値を報告に書く（Phase 2 の Real Fuel と矛盾するため、有効なら止まって報告）
2. **Orbit Traffic Fix**（ルーズ版）: スクリプト（PEX）のみのはず。上書きするバニラスクリプト名を報告に書く
3. 重複ファイルの確認、`modlist.txt` / `plugins.txt` の差分（前後）を報告に書く
4. **ここで止まる**（理由: 2 ゲームの起動）。報告 `phase1-finish-install-01.md` を push し、ユーザーへのテスト手順を書く:
   - デスクトップの「Starfield（MOD）」で起動 → 既存セーブをロード → 手動セーブ → 惑星への着陸・離陸 → Grav Jump 1回 → 終了
   - 終了後に agy が確認すること: `sfse.txt`（Engine Fixes の読み込み成功）、Engine Fixes のログ、CTD の有無

## 作業2: グループ2（表示/QoL）— ユーザーの「OK」後に実行し、止まる

1. **StarUI HUD**: `Interface\` 配下のファイルと設定 INI。日本語用ファイル（`NamesIndex_ja.swf` 等）が同梱されていれば有効になる配置にする
2. **Decal Fix**（ルーズ版）
3. **Neutral LUTs**: LUT の DDS。他に LUT を変更する既存MODがないことを確認する
4. **Easy Digipick**: ESM（483 バイトのアーカイブ）。展開できること、中身が ESM 1つであることを確認する。plugins.txt 末尾へ
5. **Shades Glowy Stuff Terran Armada Fix**（Main 版。Optional 版が同梱なら止まって報告）
   - `modlist.txt` では **Shades Glowy Stuff と「Shades Glowy Stuff - 日本語化」より高優先度**に置く（作者: 元MODとの競合に勝たせる）
   - `plugins.txt` では `Shades_Glowy_Stuff_Anchorpoint_Fix.esm` を `Shades_Glowy_Stuff.esm` の**直後**に置く
   - Fix の ESM が英語の名前・説明（FULL / DESC 等）を持つレコードを上書きしていないか確認する。上書きしていれば、日本語化が英語に戻る箇所として一覧にする
6. **Slightly Better Map Icons**: `Interface\` の `mapicons.*`。**StarUI HUD と同じファイルを含まないか**を必ず確認する（含む場合は止まって報告）
7. 重複ファイル・差分・英語テキスト一覧を報告 `phase1-finish-install-02.md` に書いて push し、**止まる**。ユーザーのテスト手順: 起動 → ロード → HUD 表示・スキャナー・マップ（星系マップ・地表マップのアイコン）・デジピック1回・アイテムの発光（Anchorpoint 以外でよい）→ セーブ → 終了

## 作業3: グループ3（武器）— ユーザーの「OK」後に実行し、止まる

1. **Weapon Quality Diversity**: ESM。plugins.txt の**末尾**（武器レコードを触るため最後に読む）
   - マスターに `ShatteredSpace.esm` と Terran Armada（`SFBGS050.esm` 等）が含まれることを ESM ヘッダで確認し、どちらも Data にあることを確認する
   - 他に武器の性能・Tier を変更する導入済みMODがないことを確認する
2. 報告 `phase1-finish-install-03.md` を push して止まる。ユーザーのテスト手順: 起動 → ロード → 商人の武器在庫を見る → 敵を数体倒してドロップ武器の Tier を見る → セーブ → 終了

## 作業4: 記録（グループ3のテスト OK 後、指示があれば）

- `docs/INSTALL_GUIDE.md` の MOD 一覧・ロード順を更新する（この作業は Claude が指示したときだけ）

---

説明と許可待ちは不要。作業0〜1を実行し、報告を push して止まること。
