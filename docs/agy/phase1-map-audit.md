# 指示書: マップ系MOD 3件の事前監査（READ-ONLY・Web調査）

- 作成: Claude（2026-10-09）
- 運用ルール: docs/agy/README.md に従うこと
- 作業ブランチ: main を pull してから、main から phase1-map-audit を作成する
- Web 調査とドキュメント作成だけ。ゲーム・MO2・Windows には触らない。Nexus は `docs/agy/phase1-finish-audit.md` の「Nexus ページの読み方」（Orca 内蔵ブラウザ）で読む。ログイン・ダウンロードはしない

## 背景

ユーザーから、マップ系の追加候補として次の3件が挙がった（ユーザーが外部で調べた紹介文に基づく。内容は未検証）。

| MOD | Nexus | 紹介文の要点（未検証） |
|---|---|---|
| Slightly Better Map Icons | 4813 | マップアイコンを見やすくする。v17 は本体 1.16.236 向けと記載 |
| City Interior Map Markers for Fast Travel | 12719 | シドニア・ウェル・ニューホームステッド・レッドマイル等の内部へ直接ファストトラベル。アキラ・シティ用の追加ファイルあり |
| Remove Overlapping Markers For Cities | 15633 | 星系マップで重なる都市マーカーを整理。既存セーブ可だが、削除後も変更が残る場合あり |

ゲーム本体 1.16.244.0、SFSE 0.2.21。Shattered Space と Terran Armada を所持。

## 作業1: 3件の事前監査（止まらずに進めてよい）

`docs/agy/phase1-finish-audit.md` 作業1 の 1〜9 と同じ項目を調べる。加えて次を必ず確認する。

- **1.16.244 対応**: 特に Slightly Better Map Icons。1.16.236 向けファイルが 1.16.244 で動くか（作者の説明・Posts・ファイル種別から判断。根拠がなければ「未確認」）
- **導入済み・導入予定MODとの競合**:
  - Starfield Engine Fixes - SFSE（カスタムマップマーカー消失の修正を含む。`docs/MOD_COMPATIBILITY.md` 7章）
  - StarUI HUD（UI ファイルの重複がないか）
  - Phase 3 の **Seamless Neon**（Neon 内部セルを外部ワールドスペースへ統合する。`docs/MOD_COMPATIBILITY.md` の該当行）と、Grav Lanes / True Seamless Grav Jumps。都市内部へのマップマーカーやファストトラベル先が、ワールドスペースの変更で壊れないか
  - 3件同士の競合（同じマーカー・同じアイコンファイルを変更するか）
- **セーブへの影響**: 途中導入・途中削除ができるか。削除後に何が残るか
- **日本語**: マーカー名・地名が英語で追加・上書きされるか（日本語版の地名を英語に戻してしまわないか）

## 作業2: ドキュメント案（止まらずに進めてよい）

- `docs/MOD_COMPATIBILITY.md` の 7章の後に「## 8. マップ系MOD 3件の監査（2026-10-09）」を追加する
- 採用してよいもの・見送るもの・Phase 3 以降に回すものを、理由とともに報告に書く。採用してよいものがあれば `docs/DOWNLOAD_LIST.md` の「Phase 1 仕上げ」表の末尾に、グループ「2. 表示/QoL（マップ）」として追記する
- MOD_SPEC は書き換えない

## 作業3: 報告

- `docs/agy/reports/phase1-map-audit-01.md` を書き、作業2のドキュメントと一緒に phase1-map-audit ブランチへ commit・push して止まる

---

説明と許可待ちは不要。最後まで実行し、push したら止まること。
