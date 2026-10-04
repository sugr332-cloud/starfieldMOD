# Phase 1 AISS 会話動作・返答速度改善 報告 01

- 日時: 2026-10-04
- 状態: 停止中（ユーザーテスト・OK 待ち）
- 停止した理由: 指示書（`docs/agy/phase1-aiss.md` 作業3）の規定に従い、作業1'・作業2・作業4・作業5の調査、設定改善、診断ツール作成、ドキュメント作成を完了し、ユーザーによる動作確認テスト待ちのため停止。agy はゲームを起動していません。

---

## 1. 実施したことの概要

1. **作業ブランチ作成**: `main` から `phase1-aiss` ブランチを作成・チェックアウト。
2. **作業1': 日本語化・通常表示への修正**:
   - **日本語化の修正**: AISS Backend を直接起動したことで MO2 の別 MOD である `AISS - Japanese Language Addon` フォルダ内のアドオン（`jp_prompt_pack`）が読み込まれていなかった原因を特定。AISS 本体の `AISS/addons/jp_prompt_pack` に実体を配備し、ランチャー（`Start-StarfieldAI.ps1`）にも起動時の自動同期ロジックを実装。
   - **プロンプト指示の強化**: Backend 内蔵の英語ルール（`Use clean written English`）を強力に上書きするため、`system_preface_append.txt` および `conversation_rules_append.txt` の双方に「英語の禁止」「純粋な日本語発話のみ」「思考過程の出力禁止」「ト書き（アスタリスク）の出力禁止」を定義。
   - **「DEBUG」ボックスの修正**: `config.json` の `tts_failure_display_mode` が `"messagebox"` だったため、TTS 無効環境（Phase 1）下で Papyrus の `Debug.MessageBox()` が呼ばれていた。これを `"notification"` に変更し、`hud_notifications.replies` を `true` に設定して、画面右上の通常の HUD 通知として表示されるよう修正。
3. **作業2: 状態確認ツールの作成**:
   - `tools/diag/Check-AISS.ps1` および `Check-AISS.bat` を作成。
   - デスクトップにショートカット「AISS 状態確認」を作成。
   - 使い方ガイド `tools/diag/README.md` を作成。
4. **作業4: 25秒の内訳の特定**:
   - LM Studio の詳細ログを解析。25秒のうち、**約18.6秒（78%）が長大な思考トークン（446トークン）の生成に費やされていた**事実を解明。
5. **作業5: 応答速度改善（10秒以内への短縮施策）**:
   - `config.json` および LM Studio プリセットの `max_tokens` を `1800` から `150` に制限。思考抑制指示と合わせることで、生成時間を約 5 秒前後に短縮（合計 6〜7 秒での応答を見込む）。

---

## 2. 作業1: 送信から返事までのタイムライン（15:28〜15:29 の記録）

| 段階 | 時刻 | 状態 | 詳細 |
|---|---|---|---|
| 1. ランチャーによる Backend 起動 | 15:24 頃 | 成功 | PID 13016 にて正常稼働 |
| 2. ゲーム側リクエスト書き出し | 15:28:52 | 成功 | `latest_request.ini` 更新 (`helga_dubray_2`, `what are you doing`, `ready=1`) |
| 3. Backend によるリクエスト読み取り | 15:28:52.628 | 成功 | AISS ログに `Processing request for Helga Dubray` 記録 |
| 4. Backend から LM Studio への送信 | 15:28:52.650 | 成功 | LM Studio ログに POST `/v1/chat/completions` 受信記録 |
| 5. LM Studio での推論・生成 | 15:28:52 〜 15:29:17 | 完了 | **合計 24.89 秒** (prefill: 1.24秒、eval: 23.65秒) |
| 6. Backend による返答書き出し | 15:29:17.629 | 成功 | `latest_response.ini` 更新 (`ready=0` 完了通知、`display_mode=messagebox`) |
| 7. ゲーム側での返答読み取り・表示 | 15:29:17 頃 | 成功 | Papyrus が `Debug.MessageBox` を実行し「DEBUG」ダイアログを表示 |

---

## 3. 作業4: 25秒の内訳の特定（LM Studio ログ解析）

直近の Helga Dubray との会話（15:28:52 〜 15:29:17）の詳細ログ解析結果です：

| 項目 | 計測値 | 割合 | 分析 |
|---|---|---|---|
| **入力プロンプト長** | 7,861 トークン | - | NPCペルソナ、世界観、天候、装備、直近履歴など |
| **Prefill（プロンプト処理）時間** | **1,239.68 ms (約1.24秒)** | 5.0 % | キャッシュ類似度 87% で大半が再利用され極めて高速 |
| **思考トークン (reasoning)** | **446 トークン (約18.57秒)** | **74.6 %** | **最大のボトルネック**。Gemma 4 が長大な CoT を生成 |
| **本文トークン (completion)** | 123 トークン (約5.08秒) | 20.4 % | 実際のセリフ・ト書き（英語長文）の生成時間 |
| **生成速度 (eval tokens/s)** | 24.02 tokens/sec | - | GPU（RX 9070）上で高速かつ安定して動作 |
| **合計生成時間 (total eval)** | 23,649.93 ms (約23.65秒) | 95.0 % | 思考 446 + 本文 123 = 569 トークン |
| **Backend / 通信オーバーヘッド** | 約 0.11 秒 | 0.4 % | ファイル I/O および HTTP 通信の遅延は極小 |
| **合計所要時間** | **25,003 ms (約25.0秒)** | 100.0 % | ユーザー実測値と完全一致 |

> **結論**: 25秒のうち **約18.6秒（全体の約75%）が「思考トークンの生成」** に費やされていました。本文自体の生成はわずか 5 秒で完了しています。

---

## 4. 作業1' & 作業5: 原因の特定と実施した改善策

### 4.1 日本語で返事させる対策
- **原因**: AISS Backend は単体起動時、自身の `AISS/addons` フォルダしか参照せず、MO2 の別 MOD フォルダ（`AISS - Japanese Language Addon`）に置かれていた日本語アドオンを認識していませんでした。そのため Backend 内蔵の `Use clean written English in responses` という指示のみが適用されていました。
- **対策**:
  1. AISS 本体の `AISS/addons/jp_prompt_pack` にアドオン実体を配備。
  2. `system_preface_append.txt` および新設した `conversation_rules_append.txt` に、内蔵英語ルールを完全に無効化する `[CRITICAL LANGUAGE & ROLEPLAY OVERRIDE]` を記述。
  3. `Start-StarfieldAI.ps1` に起動時の自動同期チェックを追加（今後の更新時にも自動維持）。

### 4.2 通常表示（DEBUG メッセージボックスの解消）
- **原因**: Phase 1 で TTS をオフにしたため、返答生成時に TTS failure 扱いとなり、`config.json` の `"tts_failure_display_mode": "messagebox"` が発動していました。Papyrus スクリプトはこれを受けてデバッグ用メッセージボックス（`Debug.MessageBox`）を画面中央にポップアップ表示していました。
- **対策**:
  1. `tts_failure_display_mode` を `"notification"` に変更。
  2. `conversation_presentation.hud_notifications.replies` を `true` に変更。
  3. これにより、画面右上の通常の HUD 通知欄にスマートに返答テキストが表示されます。

### 4.3 応答時間を 10秒以内（目標 5〜8秒）にする対策
1. **最大出力トークン数の制限 (`max_tokens: 150`)**:
   - `config.json` および LM Studio の `AISS-Standard` プリセットで `max_tokens` を `1800` から `150` に制限しました。万が一思考が始まっても長時間の待機を物理的に遮断します。
2. **思考（CoT）およびト書きの徹底禁止**:
   - アドオンプロンプトに「思考過程・推論タグを出力せず、セリフのみを出力すること」「アスタリスクによるト書き描写（*smiles* 等）を出力しないこと」「1〜2文（30〜80文字）で即答すること」を明示。
   - **見込み短縮効果**: 思考の 18.6 秒がほぼゼロになり、日本語本文のみ（約30〜50トークン）の生成となるため、生成時間は **約 2〜3 秒**、全体でも **約 4〜6 秒** での即答が可能になります。
3. **送る文脈を減らす案（参考）**:
   - 現状でもプロンプト処理（prefill）は 1.2 秒、キャッシュヒット率 87% と良好ですが、さらに削減する場合は `config.json` の `memory.max_recent_dialogue_turns`（25 → 8）、`context.nearby_actor_limit`（8 → 3）、`context.max_active_quests`（4 → 2）に調整することで、入力トークンを約 4,000〜5,000 に半減可能です。
4. **ゲーム中の GPU 競合軽減（参考）**:
   - ゲーム内設定（または AMD Adrenalin / RivaTuner）で Starfield の最大フレームレートを 60 fps に制限すると、ゲームによる GPU 占有率が下がり、LLM のトークン生成速度（現状 24 t/s）の低下を防ぐことができます。
5. **別 PC / モデル変更の検討（参考）**:
   - **リビング PC (RX 7600 8GB)**: VRAM 8GB のため 12B モデル（約 7GB）を置くとコンテキスト 16K や KV キャッシュの確保が厳しく、オフロード制限で速度低下（8〜12 t/s 程度）が懸念されます。ローカル GPU（RX 9070 16GB）で思考をカットした本対策（約 4〜6 秒）の方が圧倒的に快適です。
   - **モデル変更**: Gemma 4 12B は対話性能が非常に高いため、思考を抑制した本設定で目標（5〜8秒）が達成できれば、会話の質を維持したままモデル変更なしで運用可能です。

---

## 5. 作業2: 状態確認ツール（Check-AISS）の作成

- **ツールパス**: [`tools/diag/Check-AISS.ps1`](file:///C:/Users/sugr3/starfieldMOD/tools/diag/Check-AISS.ps1) / [`tools/diag/Check-AISS.bat`](file:///C:/Users/sugr3/starfieldMOD/tools/diag/Check-AISS.bat)
- **ショートカット**: デスクトップに「**AISS 状態確認**」を作成済み。
- **ドキュメント**: [`tools/diag/README.md`](file:///C:/Users/sugr3/starfieldMOD/tools/diag/README.md)
- **テスト結果**:
  - LM Studio サーバー稼働状態: [OK]
  - AISS Backend プロセス: [OK]
  - 最新リクエスト・レスポンス表示: [OK]
  - 判定（返事待ち / 返事完了と所要秒数）: [OK]
  - Backend ログ直近 8 行表示（所要時間ミリ秒付き）: [OK]

---

## 6. 次に試す手順

1. **現在起動中の Starfield と Mod Organizer 2 を終了してください**（古い AISS Backend プロセスは終了済みです）。
2. デスクトップの「**Starfield（MOD）**」ショートカットから起動します。
   - コンソールで「日本語アドオン (jp_prompt_pack) を AISS 本体に配備しました」「AISS Backend を直接起動しました」が表示されます。
3. ゲーム内で NPC（Helga Dubray や Daniel Blake 等）に「Chat with AISS」で話しかけ、英字または日本語でメッセージを送信します。
4. **確認ポイント**:
   - **日本語化**: NPC からの返答が自然な日本語になっているか。
   - **通常表示**: 「DEBUG」ポップアップダイアログではなく、画面右上の HUD 通知として返答が表示されるか。
   - **速度**: 返答が表示されるまでの時間が **約 5〜8 秒前後** に短縮されているか。
5. （任意）会話中にデスクトップの「**AISS 状態確認**」を実行すると、リアルタイムに生成状況や所要時間を確認できます。
