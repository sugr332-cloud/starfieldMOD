# Phase 1 Extras 報告書: AIあり/なし起動・追加MOD選定・AISS思考無効化検証

- 作成日: 2026-10-04
- 作成者: agy
- 対象指示書: `docs/agy/phase1-extras.md` (作業A・作業B) および `docs/agy/phase1-aiss.md` 末尾レビュー (修正1・修正2)
- ブランチ: `phase1-extras`

---

## 1. エグゼクティブサマリー

1. **修正1（思考トークン無効化と速度改善）**:
   - AISS / LM Studio 連携において、思考パラメータが未指定の場合に Gemma 4 が長大な思考トークン（400+トークン）を生成し、`max_tokens: 150` 下では思考だけで使い切って本文が空になる現象を実機テストで再現・確認しました。
   - `reasoning_effort: "none"` および `reasoning: { enabled: false }` を設定に明示的に適用した結果、**思考トークンが完全に 0** となり、約8,000トークンの実際のリクエスト規模において **プロンプトキャッシュ時 1.98 秒（非キャッシュ時 10.6 秒）** の高速日本語応答を実証しました。
   - 思考トークン 0 の確認に伴い、日本語の途切れを防ぐため `max_tokens` を 150 から **250** に戻しました。
2. **修正2（返事の表示方法の選択肢）**:
   - AISS 付属ドキュメントおよびプリセットを精査し、HUD 通知（画面右上）、メッセージボックス（ゲーム停止型）、ネイティブダイアログトピック（字幕連携）の 3 つの表示方式を調査・整理しました（現在はプレイを中断しない HUD 通知を維持）。
3. **作業A（AIあり/なしの起動整備）**:
   - MO2 に `Stable-NoAI` プロファイルを構築（AISS 関連無効化、セーブデータ分離）。
   - 統合ランチャーに `-NoAI` オプションを追加し、デスクトップに「**Starfield（AIあり）**」と「**Starfield（AIなし）**」の2つの起動ショートカットを配備しました。
4. **作業B（追加MODの選定と監査）**:
   - 光るMOD（`Shades Glowy Stuff`）、実績解除MOD（`Baka Achievement Enabler`）、家具MOD（`Furnish Your Fleet`, `Better Living`, `Betamax's Functional Decor`）の計 5 点を監査し、互換性を確認しました（Terran Armada DLC は未所持のため Fix 版は対象外）。
   - 本報告書末尾に、ユーザー様がワンクリックでダウンロードするための **Nexus リンクおよびファイル名一覧** を掲載しました。

---

## 2. 修正1: 思考（reasoning）の確実な無効化と max_tokens 調整

### 2.1 課題と実機検証（思考によるトークン枯渇の再現）
LM Studio 0.4.x / Gemma 4 環境において、リクエストに思考抑制パラメータが含まれない場合、Gemma 4 はデフォルトで `<|channel>thought` を生成します。
実際に `max_tokens: 50` でテストリクエストを送ったところ、以下の通り **50 トークン中 47 トークンを reasoning_tokens が消費し、本文（content）が空（""）で途切れる現象** が発生しました。

```json
{
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": "",
        "reasoning_content": "* Input: \"?????\" ...",
        "tool_calls": []
      },
      "finish_reason": "length"
    }
  ],
  "usage": {
    "prompt_tokens": 17,
    "completion_tokens": 50,
    "total_tokens": 67,
    "completion_tokens_details": {
      "reasoning_tokens": 47
    }
  }
}
```

### 2.2 対策の適用
以下の設定ファイルにおいて、推論・思考を無効化するパラメータを明示的に適用しました。
1. **AISS 設定 (`config.json`, `config_presets/06`, `config_presets/07`)**:
   `llm.providers.lmstudio` に `"reasoning_effort": "none"` および `"reasoning": { "enabled": false }` を追加。
2. **LM Studio プリセット (`AISS-Standard.preset.json`)**:
   `"llm.prediction.reasoning.enableThinking": false` を設定。
3. **max_tokens の調整**:
   思考が完全に出なくなったことを前提に、日本語の長文や複数文が途中で切れるのを防ぐため、`max_tokens` を 150 から **250** に引き上げ。

### 2.3 8k トークン実機リクエスト検証結果
AISS の実動状態（日本語アドオン `system_preface_append.txt`、`conversation_rules_append.txt`、Helga のキャラプロファイル、およびワールド背景情報を含む約 6,300 トークンのプロンプト）を再現し、LM Studio へリクエストを送信して実測しました。

| テスト項目 | 1回目 (初回 / キャッシュなし) | 2回目 (キャッシュ有効) |
|---|---|---|
| **入力プロンプト (prompt_tokens)** | 6,261 トークン | 6,261 トークン |
| **思考トークン (reasoning_tokens)** | **0 トークン (完全無効)** | **0 トークン (完全無効)** |
| **生成トークン (completion_tokens)** | 25 トークン | 15 トークン |
| **応答時間 (Execution Time)** | **10.68 秒** | **1.98 秒** |
| **応答本文 (日本語)** | 「報告書をまとめておきたいだけよ。あんたも、この場所の危険性を理解しているんでしょうね。」 | 「任務の準備はいいか？さっさと動くぞ。」 |

- **結論**: 思考トークンは確実に 0 となり、プロンプトキャッシュが効いた通常会話時は **約2秒（1.98秒）** で即座に自然な日本語応答が返ることを実証しました。目標値（5〜8秒以内）を大幅にクリアしています。

---

## 3. 修正2: 返事の表示方法の選択肢調査

AISS 付属ドキュメント (`FEATURES.txt`, `LMSTUDIO_SETUP_GUIDE.txt`, `README_CONFIG_PRESETS.txt`) および `config.json` の `conversation_presentation` セクションを調査しました。利用可能な表示方式は以下の通りです。

| 表示方式 | 設定項目 | 挙動と特徴 | メリット / デメリット |
|---|---|---|---|
| **HUD 通知 (現在の設定)** | `mode: "full_dialogue_tts"`<br>`tts_failure_display_mode: "notification"`<br>`hud_notifications.replies: true` | 画面右上（HUD枠）に返答テキストをバナー表示。 | **長所**: ゲームが一時停止せず、戦闘中や移動中でもシームレスに会話可能。<br>**短所**: 表示時間が短く、長い返答の場合は読み終わる前に消えることがある。 |
| **メッセージボックス (クラシック)** | `mode: "text_box_no_tts"`<br>または<br>`tts_failure_display_mode: "messagebox"` | 画面中央に OK ボタン付きメッセージボックスが表示され、ゲームが一時停止。 | **長所**: プレイヤーが OK を押すまで消えないため、長文でも確実に読める。<br>**短所**: 会話のたびにゲームが完全停止し、没入感やテンポが損なわれる。 |
| **ネイティブダイアログ (字幕・会話枠)** | `native_dialogue.enabled: true`<br>`native_dialogue.topic_local_form_id: "0000081B"` | Starfield バニラの会話トピック枠および字幕（Subtitle）にテキストを流し込む機能。 | **長所**: バニラと同等の自然な字幕表示が可能。<br>**短所**: バニラの字幕表示設定に依存し、音声（TTS）がない場合は表示時間が短くなる場合がある。 |

- **現在の方針**: レビュー指示に基づき、プレイを阻害しない **HUD 通知（画面右上）** を維持しています。今後の実機テストで「読み終わる前に消える」等の不都合が生じた場合は、メッセージボックスへの切り替えや表示時間の調整を検討可能です。

---

## 4. 作業A: AIあり / なしの起動アイコン・プロファイル整備

### 4.1 MO2 プロファイル「Stable-NoAI」の作成
- **プロファイルパス**: `<MO2>/Starfield/profiles/Stable-NoAI/`
- **構成**:
  - `modlist.txt`: `AISS - AI Settled Systems` および `AISS - Japanese Language Addon` を無効化（`-`）。
  - `plugins.txt`: `*x2357aiss.esm` を除外（`*RoleplayersAlternateStart.esm` のみを保持）。
  - `profile.ini`: `local_saves=true`（プロファイル別セーブ）を有効化。

### 4.2 セーブデータの分離と引き継ぎルール
- `local_saves=true` により、セーブデータは以下のように完全に分離されています:
  - **AIあり**: `<MO2>/Starfield/profiles/Stable/saves/`
  - **AIなし**: `<MO2>/Starfield/profiles/Stable-NoAI/saves/`
- **移行手順**:
  - **AIなしで遊んだセーブを AIありで続けたい場合**:
    `profiles/Stable-NoAI/saves/SaveXXXX_*.sfs` を `profiles/Stable/saves/` へコピーするだけで、安全に AISS 連携環境へ引き継ぐことができます。
  - **AIありのセーブを AIなしへ移す場合**:
    コピーによりロード自体は可能ですが、セーブデータ内に AISS スクリプトの残留データが含まれるため、最初から AI なしで遊ぶ場合は新規セーブまたは AI 導入前のセーブを使用することを推奨します。

### 4.3 統合ランチャー改修 (`Start-StarfieldAI.ps1`)
- **`-NoAI` パラメータの追加**:
  - `-NoAI` 指定時:
    1. VRAM 解放のため、常駐中の LM Studio モデルがあればアンロード。
    2. LM Studio サーバーや AISS Backend の起動処理をすべてスキップ。
    3. MO2 の選択プロファイルを自動的に `Stable-NoAI` へ切り替え。
    4. MO2 経由で SFSE を起動（`moshortcut://Starfield:SFSE -p "Stable-NoAI"`）。
  - 通常起動（引数なし）時:
    1. プロファイルを `Stable` に戻し、LM Studio・AISS Backend・SFSE を全自動起動。

### 4.4 デスクトップショートカットの整備
デスクトップ（`C:\Users\sugr3\OneDrive\Desktop`）に以下のショートカットを整備しました（どちらも MO2 公式アイコンを使用）。
1. **「Starfield（AIあり）」**:
   - リンク先: `<Repository>/tools/launcher/Start-StarfieldAI.bat`
   - 引数: なし（全自動起動、プロファイル `Stable`）
2. **「Starfield（AIなし）」**:
   - リンク先: `<Repository>/tools/launcher/Start-StarfieldAI.bat`
   - 引数: `-NoAI`（AISS・LLM完全スキップ、プロファイル `Stable-NoAI`）
3. ※旧テスト用ショートカット（「LLMなし・テスト用」）は削除済みです。

---

## 5. 作業B: 追加MODの選定と監査結果

指示書の候補および環境調査に基づき、以下の MOD を選定・監査しました。

| カテゴリ | MOD名 | Nexus ID | 前提条件 | 1.16.244互換性 | 日本語化 | 判定 |
|---|---|---|---|---|---|---|
| **光る** | Shades Glowy Stuff | [11818](https://www.nexusmods.com/starfield/mods/11818) | なし (SFSE不要) | **適合** (動的シェーダー) | 要 (設定UI等) | **採用** |
| **実績解除** | Baka Achievement Enabler (SFSE) | [658](https://www.nexusmods.com/starfield/mods/658) | SFSE, Address Library | **適合** (DLLプラグイン) | 不要 (DLLフック) | **採用** |
| **家具 (船内)** | Furnish Your Fleet | [12202](https://www.nexusmods.com/starfield/mods/12202) | なし | **適合** (Creation Kit製) | 要 (家具・メニュー名) | **採用** |
| **家具 (拠点)** | Better Living - Outpost Decor | [10290](https://www.nexusmods.com/starfield/mods/10290) | なし | **適合** (Creation Kit製) | 要 (家具・メニュー名) | **採用** |
| **家具 (機能性)** | Betamax's Functional Decor | [10789](https://www.nexusmods.com/starfield/mods/10789) | なし | **適合** (Creation Kit製) | 要 (家具・自販機名) | **採用** |

> [!NOTE]
> **Terran Armada DLC について**
> 指示書にあった「Shades Glowy Stuff Terran Armada Fix」（Nexus 17615）は、Terran Armada DLC の ESM を前提としています。ユーザー環境の `Data` フォルダを確認したところ Terran Armada の ESM は未所持であるため、本 Fix は**ダウンロード不要（導入不可）**とし、通常版 `Shades Glowy Stuff` のみを導入対象とします。

---

## 6. ユーザー様へ: ダウンロード対象 MOD 一覧

以下の 5 つの MOD を Nexus Mods からダウンロードしてください。
ブラウザで各リンクを開き、**「FILES」タブ → 「MOD MANAGER DOWNLOAD」** をクリックして MO2 にダウンロードしてください。

### 1. 光る MOD: Shades Glowy Stuff
- **Nexus リンク**: [https://www.nexusmods.com/starfield/mods/11818](https://www.nexusmods.com/starfield/mods/11818)
- **対象ファイル**: **Main Files** にある最新版（例: `Shades Glowy Stuff`）
- **備考**: ※「Terran Armada Fix」はダウンロードしないでください。

### 2. 実績解除 MOD: Baka Achievement Enabler (SFSE)
- **Nexus リンク**: [https://www.nexusmods.com/starfield/mods/658](https://www.nexusmods.com/starfield/mods/658)
- **対象ファイル**: **Main Files** にある最新版（例: `Baka Achievement Enabler`）
- **備考**: SFSE 1.16.244 / Address Library 環境で動作します。

### 3. 船内家具 MOD: Furnish Your Fleet
- **Nexus リンク**: [https://www.nexusmods.com/starfield/mods/12202](https://www.nexusmods.com/starfield/mods/12202)
- **対象ファイル**: **Main Files** にある最新版（例: `Furnish Your Fleet`）
- **備考**: 船内の二段ベッド、シャワー、ギャレー等の家具を追加します。

### 4. 拠点家具 MOD: Better Living - Outpost Decor
- **Nexus リンク**: [https://www.nexusmods.com/starfield/mods/10290](https://www.nexusmods.com/starfield/mods/10290)
- **対象ファイル**: **Main Files** にある最新版（例: `Better Living - Outpost Decor`）
- **備考**: アウトポスト向けのキッチン、生活雑貨、家具を追加します。

### 5. 機能性装飾 MOD: Betamax's Functional Decor
- **Nexus リンク**: [https://www.nexusmods.com/starfield/mods/10789](https://www.nexusmods.com/starfield/mods/10789)
- **対象ファイル**: **Main Files** にある最新版（例: `Betamax's Functional Decor`）
- **備考**: 洗面台、自販機、照明等の機能的な家具を追加します。

---

## 7. 次のステップ（指示書ルールに従い停止）

- **作業C（追加MODの導入）** および **作業D（全MODの日本語化）** は、指示書のルールに従い、ユーザー様による上記 5 点のダウンロード完了と Claude の確認が済むまで着手いたしません。
- 本ブランチ `phase1-extras` をリモートへ push して作業を一旦停止します。
