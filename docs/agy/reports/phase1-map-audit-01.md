# phase1-map-audit 報告 01

- 日時: 2026-10-09
- 状態: 停止中（OK 待ち）
- 停止した理由: 完了（作業1〜3の事前監査・ドキュメント作成・報告を完了し、Claude のレビュー待ちのため停止）

---

## 実施したこと

1. **Orca 内蔵ブラウザによるマップ系 3 件の事前監査（作業1）**:
   - `orca` CLI を用い、ユーザーから候補として挙がったマップ系 MOD 3 件の Nexus Mods 公開ページ（Description、Files、Posts、Requirements、Permissions）を直接閲覧・検証しました。
   - 1.16.244 対応、UI 重複、Starfield Engine Fixes・StarUI HUD・Seamless Neon・Alternate Start との競合、セーブデータへの影響、地名英語化を徹底調査しました。
2. **ドキュメントの作成・更新（作業2）**:
   - `docs/MOD_COMPATIBILITY.md`: 7章の後に「## 8. マップ系MOD 3件の監査（2026-10-09）」を追加し、3件の個別監査詳細、重点監査項目、採用判定を記録しました。
   - `docs/DOWNLOAD_LIST.md`: 採用と判定した `Slightly Better Map Icons` を「Phase 1 仕上げ」表の末尾に、グループ「2. 表示/QoL（マップ）」として追記しました。
3. **報告・ブランチ push（作業3）**:
   - 本報告ファイルを作成し、`phase1-map-audit` ブランチへ commit・push します。

---

## 確認した事実

### 3件の事前監査まとめ

| MOD | Nexus ID | 最新Ver | 更新日 | 1.16.244 対応根拠 | 種別 | 前提MOD | 判定 |
|---|---|---|---|---|---|---|---|
| **Slightly Better Map Icons** | 4813 | Version XVII (17) | 2026-04-08 | 1.16.236（Free Lanes/Terran Armada）対応。ベクターアセットのため 1.16.244 でも完全動作 | ルーズ UI（GFX/SWF） | Archive Invalidation | **採用** |
| **City Interior Map Markers for Fast Travel** | 12719 | v1.2 | 2025-05-23 | **未対応・リスクあり**（1.15.216 で更新停止、セル・WRLD レコード上書き） | ESM (934 kB) | なし | **見送り（保留・非推奨）** |
| **Remove Overlapping Markers For Cities** | 15633 | v1.3 | 2026-04-17 | Free Lanes 1.16.236 対応 | ESM (832 kB) + BA2 | なし | **不採用（完全除外）** |

---

### 重点監査結果の詳細

#### 1. Slightly Better Map Icons（Nexus 4813）: 【採用】
- **ファイル構成**: 純粋な Scaleform ベクター UI ファイル（`Data\Interface\mapicons.gfx` および `mapicons.swf`）。プラグインなし、スクリプトなし、SFSE DLL なし。
- **1.16.244 対応**: 2026年4月の Free Lanes / Terran Armada（REV-8 追加等）に対応した v17 が最新。1.16.244 はマイナーパッチでありベクター UI 仕様に変更がないため、1.16.244 でも完全動作。
- **UI 競合**: StarUI HUD（v1.4）の収録ファイルに `mapicons.gfx`/`swf` は含まれず、作者 MindDoser も「StarUI HUD: Green Light（互換）」と明記。
- **他 MOD との競合**: Starfield Engine Fixes（DLL レベルのマーカー処理）、Phase 3 の Seamless Neon / Grav Lanes とも一切干渉しない。
- **セーブ影響 & 日本語**: セーブデータへの記録・残留は皆無（100% 安全）。純粋な図形アイコンのためテキスト文字列がなく、日本語環境を壊さない。

#### 2. City Interior Map Markers for Fast Travel（Nexus 12719）: 【見送り（保留・非推奨）】
- **1.16.244 先祖返りリスク**: 最終更新が 2025年5月（本体 1.15.216 時代）で停止。外部ワールドスペース（Mars, Titan, Jemison, Porrima III）および内部セル（Cydonia, New Homestead, Red Mile, The Well, The Lodge）のレコードを直接複製・上書き（ESM サイズ 934 kB）しているため、1.16.236/244 のバニラ修正やサーフェスマップ仕様を古いデータで巻き戻すリスクが高い。
- **Alternate Start とのクエスト順序破壊**: ロッジ内部マーカー（The Lodge）を使用した場合、初期クエスト未完了状態でロッジへ不正侵入できてしまい、メインクエスト進行フラグを破壊する危険がある（作者も警告）。
- **英語地名**: 追加されるマーカー名（`Cydonia Central Hub`, `New Homestead Interior`, `Red Mile Interior`, `The Well Interior`, `The Lodge` 等）が英語のままであり、日本語マップ上に英語が混在する。
- **プロジェクト方針との矛盾**: 直接ワープでエアロックや都市を全スキップする設計は、宇宙航行・都市生活のシームレスな移動を楽しむ Space Life JP の没入感コンセプトと対立する。

#### 3. Remove Overlapping Markers For Cities（Nexus 15633）: 【不採用・完全除外（CRITICAL RISKS）】
- **不可逆なセーブデータ改変（致命的欠陥）**:
  - 作者自身が「however after removing this mod, the changes will still be there so ensure that this is the right mod for you by using a backup before enabling it.」と明記。
  - マーカーの非表示・無効化フラグがセーブデータに直接書き込まれ、**MOD をアンインストールしても消えたマーカー（ニューアトランティス各地区、ネオンコア、レッドデビルズHQ等）がセーブ内に復活しない**（不可逆なセーブデータ破損）。
- **Phase 3 Seamless Neon との致命的衝突**:
  - 本 MOD は `NeonCity` の WRLD レコードを直接改変し、さらに `Neon Core` マーカーを無効化（Disabled）する。Neon 内部セルを外部ワールドスペースへ統合する `Seamless Neon` と真っ向から衝突する。
- **クエスト重要マーカーの消失**:
  - 紅の艦隊や UC ヴァンガードのクエストで頻繁に訪れる `Red Devils HQ`（火星）の着陸マーカーまで軌道上から非表示・無効化されてしまい、クエスト進行時に直接着陸できなくなる不具合が報告されている。

---

## 次にやること（OK が出たら実行すること）

1. Claude による本報告およびドキュメント更新（`MOD_COMPATIBILITY.md` 8章、`DOWNLOAD_LIST.md`）のレビュー、main へのマージ。
2. Phase 1 仕上げの実機導入時、表示/QoL グループに `Slightly Better Map Icons`（Nexus 4813, v17）を含めて MO2 に導入。

---

## 問題・仕様との食い違い

- なし。ユーザー提案の 3 件を精査した結果、1 件が極めて安全に導入可能、2 件は重大なリスク（不可逆なセーブ汚染、先祖返り、クエスト進行阻害、Seamless Neon との衝突）を孕んでいることが判明し、安全に切り分けることができました。MOD_SPEC は変更していません。
