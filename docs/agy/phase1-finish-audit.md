# 指示書: Phase 1 仕上げ — 追加8件の事前監査とダウンロード一覧（READ-ONLY・Web調査）

- 作成: Claude（2026-10-09）
- 運用ルール: docs/agy/README.md に従うこと
- 作業ブランチ: main を pull してから、main から phase1-finish-audit を作成する
- **この指示書は Web 調査とドキュメント作成だけ**。ゲーム・MO2・Windows には触らない（この作業は Linux 側の agy が行う）
- Nexus へのログイン・ダウンロードはしない（公開ページの閲覧のみ）

## 背景

docs/MOD_SPEC.md 10.1章「Phase 1 仕上げ」で、次の8件を `Stable-NoAI` に3グループで追加する。ゲーム本体は **1.16.244.0**、SFSE は **0.2.21**（2026-10-09 実機確認）。

| グループ | MOD |
|---|---|
| 1. 安定化 | Starfield Engine Fixes - SFSE、Orbit Traffic Fix |
| 2. 表示/QoL | StarUI HUD、Decal Fix、Neutral LUTs、Easy Digipick |
| 3. 武器 | Weapon Mod Fixes - WMF、Weapon Quality Diversity |

導入済みMODの一覧は docs/INSTALL_GUIDE.md 2章、既存の判定は docs/MOD_COMPATIBILITY.md 6章と docs/MOD_SPEC.md 3章を読むこと。

## 作業1: 8件の事前監査（止まらずに進めてよい）

各MODについて Nexus Mods（Starfield）の公開ページ（説明文・Files タブ・Posts の作者固定投稿・Requirements）を読み、次を表にまとめる。推測で埋めず、確認できなかった項目は「未確認」と書く。

1. Nexus の MOD ID と URL、正式名
2. 最新版のバージョンと更新日、**ゲーム 1.16.244 対応の根拠**（説明文・ファイル名・作者投稿の該当箇所）
3. 種別（ESM / ESP / BA2 / SFSE DLL / ルーズファイル）と、プラグインがあれば Light / Medium / Full のどれか
4. 前提MOD（SFSE、Address Library、Cassiopeia、Starfield Community Patch 等）。SFSE DLL のものは **SFSE 0.2.21 で動くか**
5. 作者が明記している非互換MOD・推奨ロード順
6. 導入済みMOD（INSTALL_GUIDE 2章）および他の7件との競合の可能性（同じ機能・同じレコード・同じUIファイルを変更するか）
7. プレイヤーが目にする英語テキストの有無と量（MCM・設定画面・アイテム名・通知など）。日本語化パッチが公開されているか
8. 作者の権利・再配布条件（Permissions）で、日本語化パッチを自作・非公開で使うことに支障がないか
9. Creations（Bethesda公式）版とNexus版の両方がある場合は、どちらを使うべきか（MO2 管理のため原則 Nexus 版）

特に確認すること:

- **StarUI HUD**: 既存の UI 系MODはないが、将来のインベントリUI候補（AstralUI / StarUI Inventory / PraxisUI）との組み合わせ条件
- **Neutral LUTs**: 他の LUT / ReShade / Luma 系との排他条件。Phase 3 の Seamless Loading Screens は ReShade 前提なので、その組み合わせで問題がないか
- **Weapon Quality Diversity**: Weapon Quality Tier Fix と併用しないこと（MOD_SPEC 3章）、および WMF との競合（同じレコードを触るか）
- **Starfield Engine Fixes - SFSE**: 既定で有効になる修正と、INI で任意に有効化する機能の一覧。既存MOD（Baka Achievement Enabler、Absolute HOTAS 等の SFSE DLL）と同じ箇所をフックしないか

## 作業2: ドキュメント案の作成（止まらずに進めてよい）

- `docs/DOWNLOAD_LIST.md` の Phase 2 の前に「## Phase 1 仕上げ」節を追加し、8件の入手先（Nexus URL）、ダウンロードするファイル名（Main / Optional の区別）、備考を表にする
- `docs/MOD_COMPATIBILITY.md` 6章の後に「## 7. Phase 1 仕上げ 8件の監査（2026-10-09）」として作業1の結果を書く
- 監査の結果、**採用を見送るべき・順番を変えるべき**と判断できるものがあれば、理由とともに報告に書く（MOD_SPEC は書き換えない）

## 作業3: 報告

- `docs/agy/reports/phase1-finish-audit-01.md` を書き、作業2のドキュメントと一緒に phase1-finish-audit ブランチへ commit・push して止まる（この指示書では DOWNLOAD_LIST.md と MOD_COMPATIBILITY.md の変更も commit してよい。main へのマージは Claude が行う）
- 個人のパス・ユーザー名は書かない

---

これから何をするかを説明し、許可を得てから作業を開始すること。
