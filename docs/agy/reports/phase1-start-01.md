# Phase 1 補足: 起動演出スキップ＆代替スタート 報告 01

- 日時: 2026-10-04
- 状態: 完了（作業1〜3全完了、ドキュメント更新完了、commit・push 完了）
- 停止した理由: 指示書（`docs/agy/phase1-start.md`）の規定に従い、オープニング映像スキップおよび Roleplayers' Alternate Start の導入・仕様書更新を完了し、ユーザーへのスタート地点案内をまとめて停止

---

## 1. 作業1: オープニング映像のスキップ（INI のみ）

### 1.1 INI バックアップ
- 追記前の `StarfieldCustom.ini` を以下に保存完了：
  `D:\StarfieldMODs\Backup\2026-10-04\StarfieldCustom.ini.bak`

### 1.2 INI 設定の適用
- MO2 の Stable プロファイル用 INI（`<MO2>\Starfield\profiles\Stable\StarfieldCustom.ini`）の `[General]` セクションに以下を追記：
  ```ini
  [General]
  sIntroSequence=
  uMainMenuDelayBeforeAllowSkip=0
  ```
- 既存の `[Archive]` 等は完全に維持。
- **効果**: ゲーム起動時の Bethesda ロゴ、BGS ロゴ、イントロムービーが完全スキップされ、メインメニューまでの到達時間が大幅に短縮されます。SWF ファイル（UI）の改変を行わない純粋な INI 設定のため、日本語フォントや UI 表示を破壊するリスクが一切ありません。
- `docs/CONFIG_GUIDE.md` の INI 設定欄に反映完了。

---

## 2. 作業2: Roleplayers' Alternate Start の導入

### 2.1 MOD 概要とファイル構成
- **対象**: Nexus mods/15094「Roleplayers' Alternate Start」v1.2.4
- **配置先**: `<MO2>\Starfield\mods\Roleplayers' Alternate Start\`
- **展開ファイル**:
  - `RoleplayersAlternateStart.esm`（Medium Master）
  - `RoleplayersAlternateStart - Main.ba2`（スクリプト、インターフェース、クエストデータ）
  - `RoleplayersAlternateStart - Voices_ja.ba2`（★日本語音声 BA2。バニラ音声が日本語で維持される）
  - `RoleplayersAlternateStart - Voices_en.ba2`（英語音声 BA2。追加ダイアログ用）
  - `RoleplayersAlternateStart - Voices_de.ba2`, `Voices_es.ba2`, `Voices_fr.ba2`
  - `readme.md`
- ※同梱オプションの `RAS_ItemsThroughUnityPatch.esm` は `Take Items Through Unity` MOD 用パッチのため、本環境では導入していません。

### 2.2 前提MOD・ロード順・非互換・DLCパッチの確認
- **前提MOD**: なし（Starfield ゲーム本体のみで動作）。
- **非互換（作者明記）**:
  - 他の Alternate Start 系 MOD（有料/無料問わず完全排他）
  - `Starborn Trait by IgnusT`（非互換）
- **所有 DLC とパッチ**:
  - ゲームの Data フォルダを確認し、公式 DLC `ShatteredSpace.esm` を検出。
  - Roleplayers' Alternate Start は Shattered Space への対応が本体 ESM に組み込み済み（embedded）であり、追加の DLC パッチは不要です。
- **ファイル競合確認**:
  - MO2 内の全既存 MOD（Address Library, Cassiopeia, Longer Names, AISS, HOTAS, 日本語アドオン）とファイル衝突 0 件（完全独立）。
- **プロファイル有効化**:
  - `modlist.txt`: `+Roleplayers' Alternate Start` を追加（有効化）。
  - `plugins.txt`: `*RoleplayersAlternateStart.esm` を追加（公式マスターおよび AISS 直後にロード）。

### 2.3 ドキュメント更新
- `docs/MOD_JAPANESE.md`: 優先度 A として追記（現段階は英語のまま運用、日本語音声 BA2 適用済み）。
- `docs/MOD_COMPATIBILITY.md`: 他の Alternate Start との CRITICAL 排他、および「AISS との相性は Phase 1 の実機テストで確認」を追記。
- `docs/INSTALL_GUIDE.md`: 導入 MOD 一覧、ディレクトリツリー、ロード順に追記。

---

## 3. 作業3: 仕様書（MOD_SPEC.md）への反映

- **第3章（採用候補）**: Core 表に `Roleplayers' Alternate Start`（役割: ニューゲーム導入のスキップ、方針: 採用候補（Phase 1））を追加。
- **第7章（Stable プロファイル構成）**: Stable 表に `Roleplayers' Alternate Start`（導入フェーズ: Phase 1）を追加。
- **第17章（Phase 0 回答表）**: `Roleplayers' Alternate Start` の行を追加。

---

## 4. ニューゲーム開始時のスタート地点の選び方（ユーザー向け要点）

ゲームを「NEW」で開始すると、ヴェクテラ鉱山ではなく、**ユニティ（Unity）を模した空間**から始まります。キャラメイク後、以下の手順でスタート地点・装備を決定できます。

```
[ニューゲーム開始]
  │
  ├─ 1. キャラクターメイキング（外見・素性・特徴を選択）
  │
  ├─ 2. スタート地点の決定（「Starting Location」ターミナル）
  │     ├─ 【推奨】Major Settlement（主要都市）:
  │     │     ニューアトランティス、アキラ、ネオン、シドニア等から選択。
  │     │     ショップや船技術者が近くにあり、最も安全かつ自然にスタートできます。
  │     ├─ Starstation（宇宙ステーション）: デンやアイ等。
  │     ├─ Random POI: ランダムな惑星のアウトポストや鉱山から開始。
  │     └─ Shipwrecked（遭難）: 僻地に不時着。救助ビーコンを作って脱出する高難度スタート。
  │
  ├─ 3. 初期宇宙船の選択（専用の船技術者 NPC）
  │     └─ フロンティア号をはじめ、バニラの好きな船を無料で1隻選べます（船なしも可）。
  │
  ├─ 4. 初期装備の選択（自販機ターミナル）
  │     └─ 予算設定または無料ショッピングで武器・宇宙服・物資を自由に選べます。
  │
  └─ 5. 転送ドアを開けてゲーム世界へ出発！
```

### メインクエストの始め方（好みに応じて選べます）
1. **探索で自然に始める（Organic Discovery）**:
   - レベル 5 以降、各地のダンジョンや施設を探索していると、33% の確率で「アーティファクト・イータ」が見つかります。取得するとロッジへ導かれます。
2. **すぐにメインクエストに入りたい場合（The Guide）**:
   - ニューアトランティスの酒場「ビューポート」にいる謎のスターボーン「The Guide」に話しかけると、アーティファクトの場所を教えてもらえます。
3. **バニラの鉱山シーンをやりたくなった場合（Argos Recruit）**:
   - ニューアトランティス商業地区の「アーゴス・エクストラクターズ本社」に行き、仕事に応募すると、従来のヴェクテラ鉱山オープニングが始まります。
