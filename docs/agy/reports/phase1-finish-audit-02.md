# phase1-finish-audit 報告 02

- 日時: 2026-10-09
- 状態: 停止中（OK 待ち）
- 停止した理由: 完了（作業1〜3のWeb調査・ドキュメント作成・報告を完了し、Claude のレビュー待ちのため停止）

---

## 実施したこと

1. **Orca 内蔵ブラウザによる事前監査（作業1）**:
   - `orca` CLI を用い、Nexus Mods（Starfield）の公開ページ（Description、Files、Posts、Requirements、Permissions）を直接閲覧・検証しました（報告01の HTTP 403 を回避）。
   - 対象 8 件の MOD ID・タイトル・バージョン・更新日・1.16.244 対応根拠・種別・前提・競合・テキスト量・権利関係を網羅的に調査しました。
2. **ドキュメント案の作成・更新（作業2）**:
   - `docs/DOWNLOAD_LIST.md`: Phase 2 の前に「## Phase 1 仕上げ」節を追加し、8件の Nexus URL、ダウンロード対象ファイル名（Main/Optional）、備考を表形式で追加しました。
   - `docs/MOD_COMPATIBILITY.md`: 6章の後に「## 7. Phase 1 仕上げ 8件の監査（2026-10-09）」を追加し、8件の個別監査詳細、重点監査項目（StarUI HUD × インベントリUI、Neutral LUTs × ReShade、武器2件の依存関係、Engine Fixes × 既存 SFSE DLL）、および採用判定とグループ改編案を記録しました。
3. **報告ファイルの作成・push（作業3）**:
   - 本報告ファイルを作成し、`phase1-finish-audit` ブランチへ commit・push します。

---

## 確認した事実

### 8件の事前監査まとめ

| MOD | Nexus ID | 最新Ver | 更新日 | 1.16.244 対応根拠 | 種別 | 前提MOD | 判定 |
|---|---|---|---|---|---|---|---|
| **Starfield Engine Fixes - SFSE** | 10457 | v21.2 | 2026-10-04 | ファイル名・説明文・作者固定投稿に明記 | SFSE DLL + INI | SFSE 0.2.21 | **採用** |
| **Orbit Traffic Fix** | 18325 | v1.0.0 | 2026-09-26 | 作者説明文（1.16.244 のスクリプトからビルド） | ルーズ PEX / ESM+BA2 | なし | **採用** |
| **StarUI HUD** | 3444 | v1.4 | 2026-09-06 | 2026-09-06 更新、動作確認済み | ルーズ UI（GFX/SWF/INI） | Archive Invalidation | **採用** |
| **Decal Fix** | 17576 | v2.1/v2 | 2026-07-24 | 1.16.244 リリース後に公開・更新 | ルーズ DDS / ESM+BA2 | なし | **採用** |
| **Neutral LUTs - No Color Filters** | 323 | v1.5 | 2024-10-03 | 静的 DDS テクスチャ（exe バージョン非依存） | ルーズ DDS | Archive Invalidation | **採用** |
| **Easy Digipick (Lockpick)** | 451 | v1.4 | 2026-04-29 | Posts にて 1.16.244 での動作報告多数 | ESM (Light Master) | なし | **採用** |
| **Weapon Mod Fixes - WMF** | 9091 | v1.10 | 2025-06-19 | **未対応**（作者が Free Lanes 対応の必要性を明言） | ESM + BA2 | なし | **見送り（保留）** |
| **Weapon Quality Diversity** | 17044 | v1.0 | 2026-05-12 | 1.16.244 Free Lanes 対応 | ESM (Small Master) | **Shattered Space + Terran Armada** | **見送り（除外）** |

---

### 重点監査結果

1. **Starfield Engine Fixes - SFSE**:
   - 既定のエンジン修正（表情・デカール・マップマーカー・CTD修正など40件以上）は安全に機能。
   - `Baka Achievement Enabler`、`Absolute HOTAS` とのフック衝突なし。
   - INI 設定の `No Grav Jump Limit`（燃料無制限）は Phase 2 の `Real Fuel` を無力化するため、既定値（無効: 0）を厳守する。
2. **Orbit Traffic Fix**:
   - `Interstellar Traffic`（Nexus 12509）と排他だが、本環境には存在しないため問題なし。
   - ルーズ版（`OrbitTrafficFix 1.0.0`）を使用することで MO2 上の競合検知が容易。
3. **StarUI HUD**:
   - HUD 画面（`hudmenu.gfx`）および照準ロールオーバー窓（`hudrolloverwidget.gfx`）を担当。
   - 将来のインベントリ UI（`StarUI Inventory` / `PraxisUI`）はインベントリ画面等を担当するため競合しない。
   - `AstralUI` 併用時は Quick Loot モジュールを除外するか StarUI HUD を優先させる。
   - 日本語ソート用 swf（`NamesIndex_ja.swf`）が標準同梱されており、テキストも txt 形式で日本語化容易。
4. **Decal Fix & Neutral LUTs**:
   - どちらも純粋なテクスチャ/メッシュ修正であり、プラグイン枠やスクリプトを圧迫しない。
   - Neutral LUTs は ReShade（Phase 3 の `Seamless Loading Screens` 前提）と完全共存可能（作者も推奨）。
5. **Easy Digipick**:
   - v1.4 は ESM 形式（Light Master）。UI テキストや Perk 判定の英語化・改変なし。
6. **Weapon Mod Fixes - WMF の重大な懸念**:
   - Nexus 公開版は 2025-06 の v1.10 のまま。
   - 2026-04〜05 の作者投稿にて「Free Lanes による武器品質・レジェンダリクラフト変更に対応した更新が必要であり、xEdit 更新を待っている」と明言されているが、現在まで更新版は未公開。
   - 1.16.244 に v1.10 を導入すると、Free Lanes の武器仕様が pre-Free Lanes の古いレコードで上書きされるリスクがある。
7. **Weapon Quality Diversity の致命的ブロッカー**:
   - 必須前提に `Shattered Space DLC` と **`Terran Armada DLC`** が指定されている。
   - 本環境（`docs/agy/reports/phase1-extras-01.md` 確認済み）は `Terran Armada DLC` を未所持。
   - 必須マスター欠落（Missing Master）により、導入すると起動時に即座に CTD する。

---

## 次にやること（OK が出たら実行すること）

1. Claude による事前監査結果のレビューおよび本ブランチの main へのマージ。
2. Phase 1 仕上げの実機導入:
   - 採用 6 件（グループ 1: 安定化 2件、グループ 2: 表示/QoL 4件）のダウンロード・MO2 導入・動作検証（グループ 3: 武器 はスキップ）。

---

## 問題・仕様との食い違い

- **仕様との食い違い（グループ 3 の見送り）**:
  - `docs/MOD_SPEC.md` 10.1章では「グループ 3: 武器（WMF, Weapon Quality Diversity）」の追加が計画されていましたが、監査の結果、WMF は 1.16.244 未対応、Weapon Quality Diversity は未所持 DLC（Terran Armada）必須のため、現環境では 2 件とも導入できません。
  - 仕様書（MOD_SPEC.md）のルールに基づき、agy 側での仕様書改変は行っていません。Claude のレビュー時に「Phase 1 仕上げはグループ 1・2 の計 6 件で完了とする」方針への改定を提案します。
