# Starfield Space Life JP — Phase 1 実機テストチェックリスト

本書は、Starfield Space Life JP プロジェクトにおける Phase 1（Core）基盤の実機テスト手順および評価チェックリストです。仕様書（`docs/MOD_SPEC.md`）第10章に基づいて構成されています。

> [!IMPORTANT]
> **実機テスト起動に関する最重要事項**
> **ゲームは必ず Mod Organizer 2（MO2）の GUI から「SFSE」を実行して起動してください。**
> デスクトップやゲームフォルダの `sfse_loader.exe` を直接ダブルクリックして起動した場合、MO2 の仮想ファイルシステム（USVFS）がバイパスされ、MO2 で管理されている MOD（Address Library、Cassiopeia、Longer Names、AISS、HOTAS、日本語アドオン等）が一切読み込まれません。
> また、PowerShell 等のスクリプトによる非対話起動は Windows セキュリティ（DLL インジェクション拒否・Error 5）が発生するため、必ず Windows デスクトップ上で MO2 GUI を開いて起動してください。

---

## 1. テスト環境

- **ゲーム本体**: Starfield 1.16.244.0 (Steam)
- **Mod Manager**: Mod Organizer 2 (MO2) v2.5.2 (プロファイル: `Stable`)
- **ハードウェア**: AMD Ryzen 7 7800X3D / Radeon RX 9070 16GB / RAM 32GB
- **LLM**: LM Studio 0.4.25 / `unsloth/gemma-4-12B-it-qat-GGUF` (UD-Q4_K_XL, 16K, Q8_0 KV Cache, Flash Attention, 100% GPU)
- **AISS**: v3.75 (TTS無効化、LM Studioローカル接続、公式アドオン方式による日本語プロンプト適用)

---

## 2. 自動検証・事前確認済み項目（agy 実施結果）

| 項目 | 検証内容 | 結果 | 備考 |
|---|---|---|---|
| **SFSE 適合性** | SFSE 0.2.21 と Starfield 1.16.244.0 の整合性 | **PASS (適合)** | `sfse_loader.txt` および `sfse.txt` で正常フック・DLL一致確認済み |
| **Address Library** | `version-1-16-244-0.bin` の配置 | **PASS (確認済み)** | `<MO2>\Starfield\mods\Address Library for SFSE Plugins\` に配置 |
| **MOD 競合** | Phase 1 全 MOD のファイル競合確認 | **PASS (競合0件)** | 全ファイルで上書き衝突なし（完全独立） |
| **日本語アドオン** | `AISS - Japanese Language Addon` 構築 | **PASS (正常)** | MO2 別 MOD として配置、AISS 本体ファイルは初期状態へ完全復元 |
| **LM Studio サーバー** | ローカル API (http://127.0.0.1:1234/v1) 応答 | **PASS (正常稼働)** | `gemma-4-12b-it-qat` ロード完了 |
| **LLM 日本語応答** | 日本語テストプロンプト送出 | **PASS (正常応答)** | 自然な日本語での自己紹介・役割の応答を確認済み |
| **AISS Backend** | `AISS_Backend.exe --health-check` | **PASS (HEALTHY)** | 全 11 項目 PASS、常駐稼働・ロック生成確認 |
| **ベースライン VRAM** | LM Studio 終了時のデスクトップ・常駐 VRAM | **約 5.54 GiB** | Windows 11 デスクトップ環境 |
| **常駐プロセス内訳** | GPU メモリ上位プロセスの特定 | **特定完了** | `WardogsClient` (2.3GB), `dwm` (4.3GB), `msedge` (0.6GB) 等 |
| **LLM ロード時 VRAM** | `gemma-4-12b-it-qat` 16K ロード時 VRAM | **約 14.10 GiB** | モデル 7.13 GB + コンテキスト 2.70 GB（計 9.84 GB） |
| **メインメニュー VRAM** | LM Studio 稼働 + Starfield メインメニュー表示 | **約 15.34 GiB** | 実測値: 16,469,893,120 bytes（安全域上限） |

---

## 3. ユーザー実機テスト項目（チェックリスト）

以下の手順に従い、ユーザー実機での動作確認を行い、結果・数値を記入してください。

### 3.1 起動準備
1. [ ] **バックグラウンドアプリの終了**: VRAM を約 3GB 解放するため、`WardogsClient`（別ゲームクライアント）、ブラウザ（Edge 等）、Discord 等を終了する。
2. [ ] **LM Studio 起動確認**: ローカルサーバーがポート `1234` で起動しており、`gemma-4-12b-it-qat`（16K, Q8_0 KV Cache, Flash Attention）がロードされていること。
3. [ ] **AISS Backend 起動**: MO2 の実行ファイルドロップダウンから「AISS Backend」を実行（または AISS フォルダ内の `AISS_Backend.exe` を直接起動）。コンソールが開き、常駐待機状態になること。
4. [ ] **MO2 から SFSE 起動**: MO2 でプロファイル「Stable」を選択し、右上ドロップダウンから「SFSE」を選択して「実行」をクリック。

### 3.2 基本動作テスト
| テスト項目 | 確認手順・観点 | 判定 (PASS/FAIL) | 備考・メモ |
|---|---|---|---|
| **メインメニュー表示** | 画面左下にバージョン `1.16.244.0` が表示され、CTD（強制終了）なく起動するか | [ ] PASS / [ ] FAIL | |
| **新規ゲーム** | 「NEW」からゲームを開始し、鉱山シーン〜キャラメイク〜初期戦闘まで進行可能か | [ ] PASS / [ ] FAIL | |
| **既存セーブロード** | 「LOAD」から退避済みの既存セーブデータを読み込み、正常にゲーム内へ復帰できるか | [ ] PASS / [ ] FAIL | |
| **バニラ NPC 会話** | 任意の NPC（例: バレット、リン、乗組員等）に話しかけ、通常ダイアログが機能するか | [ ] PASS / [ ] FAIL | |

### 3.3 AISS 日本語 AI 会話テスト
| テスト項目 | 確認手順・観点 | 判定 (PASS/FAIL) | 備考・メモ |
|---|---|---|---|
| **AISS 起動** | 対象 NPC（主要コンパニオン等）に話しかけ、「Chat with AISS」の選択肢が出るか | [ ] PASS / [ ] FAIL | |
| **日本語 IME 入力** | 会話入力欄（テキストボックス）に日本語（ローマ字漢字変換）が正常に入力できるか | [ ] PASS / [ ] FAIL | |
| **日本語フォント表示** | NPC の返答テキストが文字化け（□や文字化け記号）せず、正常に日本語表示されるか | [ ] PASS / [ ] FAIL | |
| **日本語応答品質** | 指示書通りの日本語のみで返答するか（英語混じり・AIアシスタント口調の有無） | [ ] PASS / [ ] FAIL | |
| **会話の長さ** | 返答が 1〜3 文（40〜120 文字程度）の簡潔なテンポで返ってくるか | [ ] PASS / [ ] FAIL | |
| **応答時間（TTFT）** | 送信から返答が表示され始めるまでの秒数 | 実測値: ______ 秒 | 目安: 2〜5 秒以内 |
| **生成完了時間** | 全文が表示完了するまでの総秒数 | 実測値: ______ 秒 | |

### 3.4 HOTAS 入力テスト
| テスト項目 | 確認手順・観点 | 判定 (PASS/FAIL) | 備考・メモ |
|---|---|---|---|
| **HOTAS デバイス認識** | 宇宙船搭乗時に HOTAS 操縦桿・スロットルの各軸・ボタン入力が認識されるか | [ ] PASS / [ ] FAIL | |
| **操縦・飛行制御** | ピッチ・ロール・ヨー・推力増減が意図通りに動作するか | [ ] PASS / [ ] FAIL | |

### 3.5 負荷・性能・安定性テスト
| 計測項目 | 計測状況・場面 | 計測値 | 判定・所感 |
|---|---|---|---|
| **ゲームプレイ中 VRAM** | 宇宙空間またはニューアトランティス等の市街地 | ______ GiB / 16 GB | 16GB 超過の有無 |
| **フレームレート (平均)** | 通常プレイ中（FHD、設定に応じる） | ______ fps | |
| **フレームレート (最低)** | AI 会話生成中の瞬間最低 fps | ______ fps | 大幅なカクつきの有無 |
| **セーブ＆ロード安定性** | AI 会話後にセーブを行い、そのデータを再ロードして継続プレイ可能か | [ ] PASS / [ ] FAIL | |

---

## 4. 会話後の `latest_response.ini` の記録手順

NPC との AISS 会話が完了した後、ゲームを終了（または最小化）し、以下のファイルを確認してください。

- **ファイルパス**:
  `<MO2>\Starfield\mods\AISS - AI Settled Systems\SFSE\AISS\responses\latest_response.ini`

### 4.1 記録フォーマット
```ini
[確認日: 2026-XX-XX]
実ファイルパス: 
文字エンコーディング: (例: UTF-8 / UTF-8 with BOM / Shift-JIS)

--- ファイル内容（抜粋） ---
[Response]
speaker=
text=
...
```
※本ファイルの内容を `docs/TEST_RESULTS.md`（Phase 1 実機テスト結果）に転記してください。
