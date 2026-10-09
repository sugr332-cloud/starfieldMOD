# Starfield Space Life JP — インストールガイド（Phase 1: Core）

本書は、Starfield Space Life JP プロジェクトにおける Phase 1（Core）基盤MODの導入手順および構成記録です。

> [!NOTE]
> **2026-10-05 に AI 会話（AISS + LM Studio）を取りやめ**、標準プロファイルは `Stable-NoAI` になりました。AISS 関連の記述は再開時の参考として残しています。実機の構成は 2026-10-09 に再確認済み（`docs/agy/reports/phase1-cleanup-01.md`）。

> [!IMPORTANT]
> **ゲーム起動に関する最重要事項**
> **ゲームは必ず Mod Organizer 2（MO2）の GUI から「SFSE」を実行して起動してください。**
> デスクトップやゲームフォルダの `sfse_loader.exe` を直接ダブルクリックして起動した場合、MO2 の仮想ファイルシステム（USVFS）がバイパスされ、MO2 配下にインストールされた MOD が一切読み込まれません。

---

## 1. 環境前提

- **ゲーム本体**: Starfield 1.16.244.0 (Steam版)
- **Mod Manager**: Mod Organizer 2 (MO2) v2.5.2
  - インスタンス種別: グローバルインスタンス `Starfield`
  - プロファイル名: `Stable-NoAI`（標準）。`Stable`（AISS有効）は休止中、`Test-NoAltStart` はフリーズ切り分け用
- **GPU**: AMD Radeon RX 9070 16GB
- **LLM環境**: LM Studio 0.4.25（2026-10-05 取りやめ。停止・自動起動なし）

---

## 2. 導入MOD一覧（Phase 1）

| 優先度 | MOD名 | バージョン | アーカイブ名 | 導入方式 | 備考 |
|---|---|---|---|---|---|
| - | **SFSE (Starfield Script Extender)** | 0.2.21 | `sfse_0_02_21.7z` | ゲームフォルダ直下配置 | スクリプト拡張・プラグインローダー |
| 1 | **Address Library for SFSE Plugins** | v22 | `Address Library-3278-22-1773539745.7z` | MO2 経由導入 | 1.16.244.0 適合（`version-1-16-244-0.bin`） |
| 2 | **Cassiopeia Papyrus Extender** | v10.0 | `Cassiopeia-14227-10-0-1768413158.7z` | MO2 経由導入 | AISS・Real Fuel（Phase 2）の必須前提 |
| 3 | **Longer Names v2** | v2.0.2 | `Longer Names v2-10651-2-0-2-1748281145.7z` | MO2 経由導入 | 船・拠点・アイテム名の文字数上限拡張（AISS の前提でもある） |
| 4 | **AISS - AI Settled Systems** | v3.75 | `AISS - AI Settled Systems-15636-3-75-1772401777.zip` | MO2 経由導入 | AI会話基盤（ESM+DLL+Backend）。**取りやめ・`Stable-NoAI` では無効** |
| 5 | **AISS - Japanese Language Addon** | v1.0.0 | （新規構築） | MO2 経由導入（別MOD） | AISS 公式アドオン構造による日本語プロンプト。**`Stable-NoAI` では無効** |
| 6 | **Absolute HOTAS** | V5.1.0 | `Absolute HOTAS - Flight and System Control-11756-V5-1-0-1740925232.zip` | MO2 経由導入 | 操縦・HOTAS入力基盤（DLL+ルーズスクリプト） |
| 7 | **Roleplayers' Alternate Start** | 1.2.4 | `Roleplayers' Alternate Start 15094 1.2.4 2026-09-24T14-20Z qd5Tg9F6T.zip` | MO2 経由導入 | ニューゲーム導入スキップ（ESM+BA2） |
| 8 | **Shades Glowy Stuff** + 日本語化 | 1.5.2 | `Shades Glowy Stuff-11818-1-5-2-1728211050.7z` | MO2 経由導入 | 発光QoL（ESM+BA2）。Phase 1 追加 |
| 9 | **Baka Achievement Enabler** | 7.0.0 | `Baka Achievement Enabler-658-7-0-0-1775656347.7z` | MO2 経由導入 | MOD使用時の実績有効化（SFSE DLL）。Phase 1 追加 |
| 10 | **Furnish Your Fleet** + 日本語化 | 1.71 | `vivs_FurnishYourFleet.zip-12202-1-71-1738287664.zip` | MO2 経由導入 | 船内家具（ESM+BA2）。Phase 1 追加 |
| 11 | **Better Living - Outpost Decor** + 日本語化 | 2.2 | `Better_Living-10290-2-2-1730286640.7z` | MO2 経由導入 | 拠点・生活装飾（ESM）。Phase 1 追加 |
| 12 | **Betamax's Functional Decor** + 日本語化 | 2.14 | `Functional Decor-10789-2-14-1776955329.zip` | MO2 経由導入 | 機能付き家具（ESM+BA2）。Phase 1 追加 |

日本語化MOD（「〇〇 - 日本語化」）は元MODの直上（優先度が高い側）に置く別MODで、翻訳済みESMはリポジトリに含めない（`docs/agy/reports/phase1-extras-02.md`）。

※競合確認結果: 全ファイルで上書き衝突 0 件（完全独立）。
※日本語アドオンは MO2 別 MOD「AISS - Japanese Language Addon」の1か所のみで独立管理し、AISS 本体のフォルダは一切改変しません。

---

## 3. ゲームフォルダ直下に配置したファイル

SFSE は作者の仕様に基づき、ゲームフォルダ直下（`<Starfield>\`）に配置しています。

- `<Starfield>\sfse_loader.exe` (68,600 bytes)
  - SHA-256: `16916C2EC47E31774E3D550609A1844FCB368B03060C03511891564B7F5F7526`
- `<Starfield>\sfse_1_16_244.dll` (116,216 bytes)
  - SHA-256: `28C5BDA41D9959C885EFCB6E889DE69E92767C80A1A66842D711D215F722F82B`
- `<Starfield>\sfse_readme.txt` (3,561 bytes)
  - SHA-256: `95098F603FECB7CBA8459DDE2E4AC14B0C8DCF7361A469D97B8E554C6B9321E1`

※公式アーカイブ（`SFSE 106 0.2.21 2026-06-11T15-06Z F5ipYCCxI.7z`）と SHA-256 完全一致確認済み。
※それ以外のゲームフォルダ直下のファイルはバニラ状態を維持しており、変更・追加はありません。

---

## 4. MO2 内のファイル・ディレクトリ構成

`<MO2>\Starfield\mods\` 配下に以下の構造で展開されています。

```
<MO2>\Starfield\mods\
├── Address Library for SFSE Plugins\
│   └── SFSE\
│       └── Plugins\
│           └── version-1-16-244-0.bin
├── Cassiopeia Papyrus Extender\
│   └── SFSE\
│       └── Plugins\
│           └── CassiopeiaPapyrusExtender.dll
├── Longer Names v2\
│   └── SFSE\
│       └── Plugins\
│           └── SF-LongerNames.dll
├── AISS - AI Settled Systems\
│   ├── x2357aiss.esm
│   ├── AISS\
│   │   ├── AISS_Backend.exe
│   │   ├── config.json
│   │   ├── addons\
│   │   ├── docs\
│   │   ├── profiles\
│   │   └── ...
│   ├── Interface\
│   ├── Scripts\
│   └── SFSE\
│       └── Plugins\
│           └── X2357AISSCompanionLog.dll
├── AISS - Japanese Language Addon\
│   └── AISS\
│       └── addons\
│           └── jp_prompt_pack\
│               ├── manifest.json
│               └── profiles\
│                   └── vanilla_starfield\
│                       └── system_preface_append.txt
├── Absolute HOTAS\
│   ├── Scripts\
│   └── SFSE\
│       └── Plugins\
│           └── AbsoluteHOTAS.dll
└── Roleplayers' Alternate Start\
    ├── RoleplayersAlternateStart.esm
    ├── RoleplayersAlternateStart - Main.ba2
    ├── RoleplayersAlternateStart - Voices_ja.ba2
    ├── RoleplayersAlternateStart - Voices_en.ba2
    ├── RoleplayersAlternateStart - Voices_de.ba2
    ├── RoleplayersAlternateStart - Voices_es.ba2
    ├── RoleplayersAlternateStart - Voices_fr.ba2
    └── readme.md
```

---

## 5. ロード順（Load Order）

`Stable-NoAI` の実機構成（2026-10-09 確認）。

### 5.1 MO2 左ペイン（MOD優先度順。上が低優先度・下が高優先度）
1. Address Library for SFSE Plugins
2. Baka Achievement Enabler
3. Cassiopeia Papyrus Extender
4. Longer Names v2
5. ~~AISS - AI Settled Systems~~（無効）
6. ~~AISS - Japanese Language Addon~~（無効）
7. Absolute HOTAS
8. Roleplayers' Alternate Start
9. Shades Glowy Stuff
10. Shades Glowy Stuff - 日本語化
11. Furnish Your Fleet
12. Furnish Your Fleet - 日本語化
13. Better Living - Outpost Decor
14. Better Living - Outpost Decor - 日本語化
15. Betamax's Functional Decor
16. Betamax's Functional Decor - 日本語化

（`modlist.txt` は逆順＝先頭が最高優先度で書かれる）

### 5.2 plugins.txt（`Stable-NoAI`）

公式マスター（Starfield.esm、Constellation.esm、OldMars.esm、BlueprintShips-Starfield.esm、sfxfirefly.esm、SFBGS 系、ShatteredSpace.esm）はゲーム側が自動で先に読み込むため、plugins.txt には書かれない。

```
*RoleplayersAlternateStart.esm
*Shades_Glowy_Stuff.esm
*vivs_furnishyourfleet.esm
*Better_Living.esm
*FunctionalDecor.esm
```

`Stable`（AISS有効・休止中）は、上記に加えて `*x2357aiss.esm` を `RoleplayersAlternateStart.esm` の前に読み込む。
