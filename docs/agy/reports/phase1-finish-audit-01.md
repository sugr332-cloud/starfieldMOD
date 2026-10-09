# phase1-finish-audit 報告 01

- 日時: 2026-10-09
- 状態: 停止中（OK 待ち）
- 停止した理由: 3（指示書の前提が満たされていない。Nexus Mods の公開ページを読めない）

## 実施したこと

- main を pull し、`phase1-finish-audit` ブランチを作成した
- `docs/MOD_SPEC.md`（3章・10.1章）、`docs/INSTALL_GUIDE.md` 2章、`docs/MOD_COMPATIBILITY.md`、`docs/DOWNLOAD_LIST.md` を読んだ
- Nexus Mods の公開ページを取得しようとした（HTTP 取得。ログインなし）
  - 9091（WMF）、3444（StarUI HUD）、323（Neutral LUTs）はすべて **HTTP 403** で拒否された
  - 他の MOD ページも同様の可能性が高いが、未試行
- Web 検索で8件を調べた。検索結果の要約は二次情報で、バージョン・更新日・作者の固定投稿・Permissions の原文は得られなかった
- **作業2（`DOWNLOAD_LIST.md` / `MOD_COMPATIBILITY.md` の変更）は行っていない**。根拠のない表を作ると誤情報になるため

## 確認した事実

検索要約で見えた範囲のみ。Nexus 原文での裏取りはできていない。

| MOD | Nexus ID（検索要約より） | 備考（二次情報） |
|---|---|---|
| Weapon Mod Fixes - WMF | 9091 | 作者 frogs345。武器MODの不具合修正。一部のオプション機能は Real Time Form Patcher が必要とされる |
| StarUI HUD | 3444 | 作者は更新が止まる時期があり、コミュニティ製パッチで補われているとの情報あり |
| Neutral LUTs - No Color Filters | 323 | 作者 fadingsignal。ゲームのカラーフィルタを無効化するLUT差し替え（ルーズファイル） |
| Easy Digipick | 451 | 版によって Plugins.txt Enabler や SFSE が必要との情報あり。Creations 版に別物の同系MODあり |
| Starfield Engine Fixes - SFSE | 未確認 | SFSE 必須。`StarfieldEngineFixes.ini` で機能を切り替える。既存の MOD_COMPATIBILITY 6.1 の記述（1.16.244 対応、2026-10-04 更新）は検証できていない |
| Orbit Traffic Fix | 未確認 | 検索では該当ページが見つからなかった |
| Decal Fix | 未確認 | 検索では該当ページが見つからなかった |
| Weapon Quality Diversity | 未確認 | 検索では該当ページが見つからなかった |

作業1の9項目（1.16.244 対応の根拠、種別、前提MOD、SFSE 0.2.21 での動作、非互換、競合、英語テキスト、Permissions、Creations 版との関係）は、**8件すべて未確認**。

## 次にやること（OK が出たら実行すること）

次のどれかを選んでほしい。

1. ユーザーが各 Nexus ページ（説明文、Files、Posts の作者固定投稿、Requirements）を開き、本文を貼る、またはファイルに保存して渡す。agy は受け取った内容から作業1・2を完成させる
2. ブラウザ操作が使える環境で、公開ページの閲覧だけを許可する（ログイン・個人データへのアクセスはしない）
3. 未確認のまま、ID と検索で分かった範囲だけを `DOWNLOAD_LIST.md` に書く。ただし 1.16.244 対応の根拠がないため、非推奨

## 問題・仕様との食い違い

- 指示書は Nexus の公開ページ原文を前提としているが、この環境からは 403 で読めない
- MOD_COMPATIBILITY 6.1 / 6.2 の「1.16.244 対応」の出典も、今回は再確認できなかった。Engine Fixes と Orbit Traffic Fix の 1.16.244 対応は、実機導入時に確認が必要
- 採用見送り・順序変更の判断材料は得られていない。MOD_SPEC は変更していない
