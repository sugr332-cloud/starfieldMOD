# Phase 1 (Core) 報告 05（実機テスト前最終調整報告）

- 日時: 2026-10-03
- 状態: 完了（作業A〜E全完了、ドキュメント commit・push 完了）
- 停止した理由: Claude レビュー指示（作業A〜E）完了、およびユーザー実機テストへの引き渡しのため停止

---

## 1. 実施したことの概要

Claude による `phase1-core-04` レビューで指示された「作業A〜E」をすべて実施・完了しました。

1. **作業A（Gemma 4 思考の無効化と推論速度実測）**:
   - API パラメータ（`reasoning_effort: "none"`）、AISS `config.json` 設定、LM Studio プリセット（`llm.prediction.reasoning.enableThinking: false`）、および日本語アドオンのプロンプトディレクティブを整備。
   - ストリーミング計測により、短文テストで **TTFT 117 ms（0.12秒）、全文生成 594 ms（0.59秒）、思考出力 0 文字** を実証。
   - AISS 想定の約1万トークン（28,644 文字）長文文脈入力でも **TTFT 7,687 ms、思考出力 0 文字** でバレットの自然なロールプレイ応答が即座に出力されることを実証。
   - `configs/LMStudio/gemma-4-12b.md` に記録。
2. **作業B（Q8_0 KV キャッシュの実測と既定化）**:
   - `llama-server.exe` を直接起動して専用 GPU メモリ（Dedicated VRAM）を実測。
   - Q8_0 KV Cache + Flash Attention 時の Dedicated VRAM: **7,537.2 MB (7.36 GiB)**。
   - f16 実測（8,739.8 MB / 8.54 GiB）と比較して **1,202.6 MB（約 1.18 GiB）の VRAM 削減を実測実証**。
   - `AISS-Standard.preset.json` を整備し、LM Studio GUI でプリセットを選択して読み込む運用手順を `CONFIG_GUIDE.md` および `TEST_PHASE1.md` に明記。
3. **作業C（ユーザー環境変数の削除）**:
   - 他アプリへの予期せぬ副作用を排除するため、ユーザー環境変数 `LLAMA_ARG_CACHE_TYPE_K`、`LLAMA_ARG_CACHE_TYPE_V`、`LLAMA_ARG_FLASH_ATTN` を完全削除。
   - 削除後も作業Bの設定（プリセット・直接引数）で Q8_0 が正常に機能することを確認。
4. **作業D（AISS 本体フォルダ内のアドオン複製の削除）**:
   - `<MO2>\Starfield\mods\AISS - AI Settled Systems\AISS\addons\jp_prompt_pack\` の複製を完全削除。
   - 日本語アドオンは MO2 別 MOD「AISS - Japanese Language Addon」の1か所のみで一元管理。
   - 削除後に `AISS_Backend.exe --health-check` を実行し、Status: HEALTHY（全11項目 PASS）を確認。
   - `configs/AISS/settings.md` および `docs/INSTALL_GUIDE.md` を修正。
5. **作業E（TEST_PHASE1.md の補足）**:
   - 「既存セーブロード」テストにおいて、既存セーブを Stable プロファイル用セーブフォルダへ手動コピーして使用する手順と Steam Cloud 保護の注意点を追記。
   - 3.1 に「思考（reasoning）がオフであること」の確認項目を追加。
   - 3.3 に「latest_response.ini を開き、構造（セクション名・キー名・NPC名・本文書式）をメモする」チェック項目を追加。

---

## 2. 作業A: Gemma 4 思考（reasoning）無効化と推論実測（詳細結果）

### 2.1 思考無効化の設定反映
- **API レベル**: AISS の `<MO2>\Starfield\mods\AISS - AI Settled Systems\AISS\config.json` に `"reasoning_effort": "none"` および `"reasoning": { "enabled": false }` を追加。
- **LM Studio プリセット**: `<UserDir>\.lmstudio\config-presets\AISS-Standard.preset.json` の `prediction.fields` に `llm.prediction.reasoning.enableThinking: false` を追加。
- **プロンプト指示**: `<MO2>\Starfield\mods\AISS - Japanese Language Addon\...\system_preface_append.txt` に「思考過程や推論タグを出力せず、キャラクターとしての発話セリフのみを直ちに出力すること」を追記。

### 2.2 ストリーミング推論速度実測結果
| 条件 | 入力コンテキスト長 | TTFT (最初の文字が出るまで) | 全文生成完了時間 | Reasoning 出力文字数 | 出力本文（抜粋） |
|---|---|---|---|---|---|
| **短文テスト (思考無効)** | 約19トークン | **117 ms (0.12秒)** | **594 ms (0.59秒)** | **0 文字** | 「こんにちは。私はGemma 4です。Google DeepMindによって開発された...」 |
| **長文テスト (思考無効・AISS模擬)** | **約 10,000 トークン**<br>(28,644 文字) | **7,687 ms (約7.69秒)** | **10,488 ms (約10.49秒)** | **0 文字** | （バレットのロールプレイ）「ああ、最高だよ！ 最高の旅だね。正直に言っていいなら...」 |

- **結論**:
  - 思考有効時は短文でも約 6 秒を要していましたが、思考無効化により **0.59 秒で即座に応答** が完了します。
  - 約1万トークンの長文文脈入力時も、文脈 Prefill（約7.6秒）完了と同時にセリフ生成が始まり、思考展開による無駄な遅延（数十秒以上）が完全に排除されました。

---

## 3. 作業B: Q8_0 KV キャッシュの実測と既定化（詳細結果）

### 3.1 Dedicated VRAM 実測結果（AMD Radeon RX 9070 16GB）
GPU パフォーマンスカウンター（`\GPU Process Memory(*)\Dedicated Usage`）によるプロセス単体実測：

| 構成 | 専用 VRAM 実測値 | 差分・効果 |
|---|---|---|
| **f16 KV Cache (16K)** | **8,739.8 MB (8.54 GiB)** | 基準実測値 |
| **Q8_0 KV Cache (16K)** | **7,537.2 MB (7.36 GiB)** | **-1,202.6 MB (約 1.18 GiB 削減)** |

- **システム全体推定（ベースライン 5.54 GiB 合算）**:
  - f16 時: 約 14.10 GiB（余裕 約 1.9 GiB）
  - Q8_0 時: **約 12.90 GiB（余裕 約 3.1 GiB に拡大）**
- **既定化方針**:
  - LM Studio プリセット `AISS-Standard.preset.json` を整備。
  - `CONFIG_GUIDE.md` および `TEST_PHASE1.md` に「モデル読み込み時はプリセット『AISS-Standard-Q8_0』を選択してロードする」手順を明記。

---

## 4. 作業C: ユーザー環境変数の削除

- **削除対象**: `LLAMA_ARG_CACHE_TYPE_K`, `LLAMA_ARG_CACHE_TYPE_V`, `LLAMA_ARG_FLASH_ATTN`
- **確認結果**:
  - `[System.Environment]::GetEnvironmentVariable(..., "User")` で全項目が空（削除完了）であることを確認。
  - 削除後も作業Bの設定で Q8_0 および Flash Attention が正常に動作することを確認済み。

---

## 5. 作業D: AISS 本体フォルダ内のアドオン複製の削除

- **削除対象**: `<MO2>\Starfield\mods\AISS - AI Settled Systems\AISS\addons\jp_prompt_pack\`
- **確認結果**:
  - 複製ディレクトリの完全削除を確認。
  - `AISS - Japanese Language Addon` 側にのみアドオンパックが存在することを確認。
  - `AISS_Backend.exe --health-check` を実行し、全11項目 PASS、`Status: HEALTHY`、`Install mode: mo2` を確認。
  - `configs/AISS/settings.md` および `docs/INSTALL_GUIDE.md` の記述を単一アドオン管理方式に修正。

---

## 6. 作業E: TEST_PHASE1.md の補足

1. **既存セーブロード手順の追記**:
   - MO2 の Stable プロファイルはプロファイル別セーブが有効なため、既存セーブ（`D:\StarfieldMODs\Backup\2026-10-03\Saves\`）から1件を `<MO2>\Starfield\profiles\Stable\saves\` へ手動コピーして使用する手順を記載。
   - プロファイル別セーブにより Steam Cloud のバニラデータが保護される旨の注意書きを追加。
2. **思考オフの確認項目の追加**:
   - 3.1 の LM Studio 起動確認項目に「思考（Reasoning / Thinking）が OFF になっていること」を追加。
3. **`latest_response.ini` メモ項目の追加**:
   - 3.3 に「会話後、テキストエディタで `<MO2>\Starfield\mods\AISS - AI Settled Systems\SFSE\AISS\responses\latest_response.ini` を開き、構造（セクション名・キー名・NPC名・本文書式）をメモする」チェック項目を追加。

---

## 7. ドキュメント類の整備・commit・push 状況

### 7.1 個人情報・APIキー監査
- 全更新ドキュメントにおいて、実ユーザー名・API キーが含まれていないことを自動検査（CLEAN）済み。

### 7.2 commit・push 対象ファイル一覧
作業ブランチ: `phase1-core`

- `configs/LMStudio/gemma-4-12b.md`（思考無効化 TTFT 実測値、Q8_0 実測値、環境変数削除記録）
- `configs/AISS/settings.md`（思考抑制設定、アドオン一元管理、複製削除記録）
- `docs/INSTALL_GUIDE.md`（アドオン単一管理の明記）
- `docs/CONFIG_GUIDE.md`（GUI プリセット選択手順、思考無効化、セーブコピー注意点）
- `docs/TEST_PHASE1.md`（セーブコピー手順、思考オフ確認、latest_response メモ項目、事前確認 PASS 反映）
- `docs/agy/reports/phase1-core-05.md`（本報告ファイル）

---

## 8. 次にやること

1. Claude による本報告（`phase1-core-05.md`）の確認および `main` ブランチへのマージ。
2. ユーザーによる実機テスト（`docs/TEST_PHASE1.md` に沿った MO2 GUI からの SFSE 起動・日本語 AI 会話テスト）の実施。
3. 会話後の `latest_response.ini` 記録と Phase 1 最終判定。
4. Phase 1.5（無料 TTS / 音声出力構成）への移行検討。
