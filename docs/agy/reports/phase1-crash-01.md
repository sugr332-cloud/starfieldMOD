# Phase 1 調査: ニューゲーム開始時の PC フリーズ調査 報告 01

- 日時: 2026-10-04
- 状態: 停止中（ユーザーテスト・OK 待ち）
- 停止した理由: 指示書（`docs/agy/phase1-crash.md` 作業3）の規定に従い、証拠収集および推測原因の整理、切り分け環境（`-NoLLM`、デスクトップショートカット、`Test-NoAltStart` プロファイル、`docs/TEST_CRASH.md`）の準備を完了し、ユーザーによる切り分けテスト待ちのため停止。agy はゲームを起動していません。

---

## 1. 実施したこと

1. **ブランチ作成**: `main` から `phase1-crash` ブランチを作成・チェックアウト。
2. **作業1: フリーズ前後の証拠収集（読み取り調査）**:
   - Windows システムログ（Kernel-Power 41, EventLog 6008, Display, WHEA, メモリ警告等）の抽出。
   - Windows アプリケーションログ（Starfield.exe, ModOrganizer.exe, LM Studio 等）の抽出。
   - Starfield 本体のクラッシュログ・ダンプの確認（`<Documents>\My Games\Starfield` および MO2 配下）。
   - SFSE の初期化ログ（`sfse.txt`, `sfse_loader.txt`, `SF-LongerNames.log`, `X2357AISSCompanionLog.log`）の確認。
   - AISS の稼働・ヘルスチェックログ（`runtime_health.json`, `aiss_rebuilt_backend.log`）の確認。
   - ランチャーログ（`tools/launcher/logs/launcher-20261004-132130.log`）の確認。
   - LM Studio サーバーログ（`server-logs/2026-10/2026-10-04.1.log`）の確認。
   - システムメモリ・仮想メモリ（ページファイル）設定および空き状況の確認。
   - GPU ドライババージョンの確認。
3. **作業2: 切り分け環境の準備**:
   - ランチャー（`Start-StarfieldAI.ps1`）に `-NoLLM` スイッチを追加。LM Studio モデルの読み込みをスキップし、ロード済みモデルがあればアンロードして VRAM を解放した上で AISS Backend と SFSE のみを起動するロジックを実装。
   - ランチャーのドキュメント（`tools/launcher/README.md`）に `-NoLLM` の説明を追記。
   - デスクトップに切り分け用ショートカット「Starfield（MOD・LLMなし）.lnk」を作成（リンク先: `Start-StarfieldAI.bat -NoLLM`）。
   - MO2 に切り分け用プロファイル「Test-NoAltStart」を作成（`Stable` を完全複製し、`Roleplayers' Alternate Start` のみを無効化。`Stable` 本体は変更なし）。
   - 切り分けテスト手順書 `docs/TEST_CRASH.md` を作成。

---

## 2. 確認した事実（証拠とタイムライン）

### 2.1 発生タイムライン（秒単位の復元）
- **13:21:30**: ランチャー起動。msedge (19プロセス)、Discord (6プロセス) の起動を検出（ユーザーは終了スキップ）。
- **13:21:40**: LM Studio サーバー起動。
- **13:21:44**: LM Studio にて `gemma-4-12b-it-qat`（KV 16K, mmproj含む）を GPU にロード開始。
- **13:21:54**: ランチャーからの疎通確認テスト成功（260 ms、26トークン生成）。
- **13:21:57**: Windows Application Log にて `ModOrganizer.exe` (v2.5.2.0) が例外コード `0xc0000005`（アクセス違反）を記録。
- **13:21:58**: `sfse_loader.exe` が Starfield.exe をフック起動。
- **13:22:00**: SFSE 初期化完了（プラグイン4種: AbsoluteHOTAS, CassiopeiaPapyrusExtender, SF-LongerNames, X2357AISSCompanionLog がすべて正常ロード）。
- **13:22:07**: Windows System Log にて `Display` (Auto HDR) 記録。Starfield のフルスクリーン描画開始。
- **13:22:28**: MO2 overwrite ディレクトリの `Textures\Motd_Media\MOTDImage.png` が更新。Starfield がメインメニューに到達し MOTD 画像の取得に成功。
- **13:22:30〜13:23:18**: ユーザーがメインメニューで「NEW」を押した直後、画面暗転し PC 全体が操作不能（完全フリーズ）に陥る。
- **13:23:18**: Windows EventLog 6008 が示す「予期しないシャットダウン時刻」。ログ書き込み不能のままハードウェア/カーネルが停止。
- **13:24:14**: 電源長押し等による強制リセット後の再起動ログ（`Kernel-Power 41`）が記録される。

### 2.2 各ログの調査結果
1. **Windows システムログ**:
   - **Kernel-Power 41**: 13:24:14 に記録（電源断による強制再起動を確認）。
   - **EventLog 6008**: 直前の異常停止時刻は 13:23:18 と特定。
   - **TDR (Display 4101) / WHEA / Resource-Exhaustion-Detector**: 該当時間帯に**一切記録なし**。OS や GPU ドライバがエラーイベントをディスクにフラッシュする余裕すらなく、即座にハードウェアレベルで完全停止（ハングアップ）したことを示しています。
2. **Windows アプリケーションログ**:
   - `Starfield.exe`、`LM Studio`、`python`（AISS Backend）のクラッシュログは存在せず。
   - 13:21:57 に `ModOrganizer.exe` が 0xc0000005 を記録（MO2 ショートカット呼び出し時の多重起動による終了処理例外の可能性）。ただし Starfield 本体はその後メインメニューまで正常到達。
3. **Starfield 本体のクラッシュログ・ダンプ**:
   - `<Documents>\My Games\Starfield` 配下および MO2 `crashDumps` 配下にクラッシュダンプ・ログは一切生成されていません（CTD ではなく PC 全体のハングのため）。
4. **SFSE ログ**:
   - `sfse.txt`: 全4プラグイン（AbsoluteHOTAS, CassiopeiaPapyrusExtender, SF-LongerNames, X2357AISSCompanionLog）が正常に読み込まれ、`init complete` で終了。
   - `SF-LongerNames.log`, `X2357AISSCompanionLog.log`: 正常動作。
5. **AISS ログ**:
   - `runtime_health.json`: 状態 `HEALTHY`。
   - `aiss_rebuilt_backend.log`: 前回（10/03）以降の新しい出力なし。
6. **LM Studio サーバーログ**:
   - 13:21:54 にランチャーとの疎通テスト完了後、フリーズに至るまで LM Studio へのリクエストは 1 件も受信されていません（ゲーム起動〜NEW の段階では AISS はまだプロンプト送信を行っていない）。
7. **メモリ・仮想メモリ設定**:
   - 搭載物理 RAM: 32 GB（空き物理メモリ: 約 21.5 GB）。
   - 仮想メモリ（ページファイル）: `C:\pagefile.sys`、システム管理（約 31 GB 確保、使用量約 2.4 GB）。
   - メインメモリ・仮想メモリの枯渇によるハングの可能性は極めて低い。
8. **GPU ドライバ**:
   - AMD Radeon RX 9070 (VRAM 16 GB)。
   - バージョン: `32.0.31041.1004` (2026/08/17)（Phase 0 から変更なし）。

---

## 3. 推測される原因

最も可能性が高い原因は、**ニューゲーム初期化時の瞬間的な VRAM 枯渇に伴う GPU ドライバ / ハードウェアのハングアップ**です。

1. **VRAM 競合の構図**:
   - RX 9070 の VRAM 上限: **16 GB**
   - LM Studio（`gemma-4-12b-it-qat` + 16K KV キャッシュ + マルチモーダル mmproj）: **約 7.5〜8.5 GB 常駐**
   - ブラウザ（Edge 19プロセス）+ Discord（6プロセス）の GPU ハードウェアアクセラレーション: **約 1.5〜2.5 GB**
   - **ゲーム起動前の時点で、すでに約 9〜11 GB の VRAM が消費されていた状態**。
2. **NEW 押下時の挙動**:
   - メインメニュー表示時点（MOTD 取得完了）では UI と背景描画のみのため 2〜3 GB 程度で収まり、正常に表示されていた。
   - 「NEW」を押した瞬間、Starfield はキャラメイク用ハイレゾアセット、シェーダー、ユニティ空間のテクスチャ等を一括して VRAM にロードしようとする（通常 6〜8 GB 以上を一気に要求）。
   - 空き VRAM（約 5〜7 GB）を瞬時に超過し、AMD ドライバが VRAM ページアウトまたはメモリ割り当てのクリティカルエラーに遭遇。ディスプレイドライバが TDR（タイムアウト検出回復）を試みる間もなく GPU が応答停止し、システム全体がハードハングしたと推測されます。

※次善の可能性として、Roleplayers' Alternate Start の Papyrus スクリプト初期化競合や MO2 の USVFS 異常が考えられますが、スクリプトエラーは通常ゲーム単体の CTD（クラッシュ・トゥ・デスクトップ）で終わるため、PC 全体の完全停止を引き起こす現象としては VRAM 枯渇が最も合致しています。

---

## 4. 次にやること（ユーザーによる切り分けテスト）

作成した手順書 `docs/TEST_CRASH.md` に従い、以下の順でテストを実施していただきます：

1. **テスト 1: LLM なしで NEW**:
   - 常駐アプリ（Edge, Discord）を終了し、デスクトップの「**Starfield（MOD・LLMなし）**」から起動して「NEW」を押す。
   - これで止まらなければ、原因は「VRAM 競合（LLM 常駐）」で確定。
2. **テスト 2: LLM なし・Alternate Start なしで NEW**（テスト 1 で止まった場合のみ）:
   - MO2 で「Test-NoAltStart」プロファイルを選び、SFSE から起動して「NEW」を押す。
   - これで止まらなければ、原因は「Roleplayers' Alternate Start」。
3. **テスト 3: MOD なしで NEW**（テスト 2 で止まった場合のみ）:
   - Steam から直接バニラ起動して「NEW」を押す。

---

## 5. 問題・仕様との食い違い

- なし。指示書（`docs/agy/phase1-crash.md`）の全要件を遵守して準備を完了しました。
