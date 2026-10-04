# Starfield Space Life JP — 設定・構成ガイド（Phase 1: Core）

本書は、Starfield Space Life JP プロジェクトにおける Phase 1（Core）の環境設定、INI設定、LM Studio・AISS設定、およびプロセス起動順の運用手順書です。

> [!IMPORTANT]
> **ゲーム起動に関する最重要事項**
> **ゲームは必ず Mod Organizer 2（MO2）の GUI から「SFSE」を実行して起動してください。**
> デスクトップやゲームフォルダの `sfse_loader.exe` を直接ダブルクリックして起動した場合、MO2 の仮想ファイルシステム（USVFS）が適用されず、MO2 配下にインストールされた MOD（Address Library、Cassiopeia、Longer Names、AISS、HOTAS、日本語アドオン等）が一切読み込まれません。
> また、Windows のセキュリティ制約（プロセス整合性レベル・DLL インジェクション分離）により、PowerShell 等の外部スクリプト・非対話セッションからの MO2 ショートカット起動（`moshortcut://`）は USVFS の Access Denied（Error 5）となるため、必ずユーザーの対話型デスクトップセッションで MO2 GUI を開いて実行してください。

---

## 1. MO2（Mod Organizer 2）の構成

### 1.1 インスタンス
- **種別**: グローバルインスタンス（Global Instance）
- **インスタンス名**: `Starfield`
- **保存先パス**: `<MO2>\Starfield\`（`%LOCALAPPDATA%\ModOrganizer\Starfield\`）
- **ゲームパス**: `<Starfield>\`（`D:\SteamLibrary\steamapps\common\Starfield\`）

### 1.2 プロファイル構成とセーブデータ管理

MO2 上に以下の 2 つのプロファイルを構築・運用します。両プロファイルとも `local_saves=true`（プロファイル別セーブ）が有効となっており、セーブデータは完全に分離されます。

1. **`Stable`（AIあり構成）**:
   - **用途**: AISS（AI NPC 会話）および全 MOD をフル稼働させる標準環境。
   - **セーブデータ保存先**: `<MO2>\Starfield\profiles\Stable\saves\`
   - **AISS 関連 MOD**: 有効（`AISS - AI Settled Systems`, `AISS - Japanese Language Addon`, `*x2357aiss.esm`）

2. **`Stable-NoAI`（AIなし構成）**:
   - **用途**: バニラ本来の会話システム＋非AI系MOD（操作・宇宙生活・装飾等）でプレイする軽量・安定環境。
   - **セーブデータ保存先**: `<MO2>\Starfield\profiles\Stable-NoAI\saves\`
   - **AISS 関連 MOD**: 無効化（`-AISS - AI Settled Systems`, `-AISS - Japanese Language Addon`, plugins.txt から `x2357aiss.esm` を除外）

> [!IMPORTANT]
> **セーブデータの引き継ぎ・移行手順**
> - **AIなし → AIありへ移行する場合**:
>   `profiles/Stable-NoAI/saves/SaveXXXX_*.sfs` を `profiles/Stable/saves/` にコピーするだけで、安全にそのままプレイを継続できます。
> - **AIあり → AIなしへ移行する場合**:
>   `profiles/Stable/saves/SaveXXXX_*.sfs` を `profiles/Stable-NoAI/saves/` にコピーすることでロード自体は可能ですが、AISS 側のスクリプト状態がセーブデータ内に記録されているため、バニラ会話へ復帰した直後は不要なリクエストが送出されないか挙動を確認してください（最初から AIなしで進める場合は新規セーブまたは AI導入前のセーブを推奨）。
> - **MOD追加時のルール**:
>   今後 MOD を追加・更新する際は、原則として **Stable と Stable-NoAI の両プロファイル** に同一構成で導入します（AISS関連を除く）。

### 1.3 NXM リンク（Nexus Mods）関連付け
- **設定ファイル**: `<MO2>\nxmhandler.ini`
- **設定内容**:
  ```ini
  [handlers]
  size=2
  1\games=bannerlord
  1\executable=C:\\Modding\\MO2\\ModOrganizer.exe
  1\arguments=@ByteArray()
  2\games=starfield
  2\executable=C:\\Modding\\MO2\\ModOrganizer.exe
  2\arguments=@ByteArray(-i Starfield)
  ```
  Nexus Mods の「Mod Manager Download」ボタンから MO2 の Starfield インスタンスへ直接ダウンロード可能です。

### 1.4 登録済み実行ファイル（Executables）
設定ファイル: `<MO2>\Starfield\ModOrganizer.ini`

1. **SFSE**:
   - バイナリ: `<Starfield>\sfse_loader.exe`
   - 作業ディレクトリ: `<Starfield>\`
   - `1\steamAppID`: `1716740`（Starfield の Steam App ID。切り分け検証後に正常値へ復元済み）
2. **AISS Backend**:
   - バイナリ: `<MO2>\Starfield\mods\AISS - AI Settled Systems\AISS\AISS_Backend.exe`
   - 作業ディレクトリ: `<MO2>\Starfield\mods\AISS - AI Settled Systems\AISS\`
3. **Starfield**:
   - バイナリ: `<Starfield>\Starfield.exe`
   - 作業ディレクトリ: `<Starfield>\`

---

## 2. INI 設定

### 2.1 StarfieldCustom.ini
MO2 のプロファイル別 INI（`<MO2>\Starfield\profiles\Stable\StarfieldCustom.ini`）に以下を配置し、ルーズファイルの読み込みおよび起動時オープニング映像・ロゴのスキップを有効化しています。

```ini
[Archive]
bInvalidateOlderFiles=1
sResourceDataDirsFinal=

[General]
sIntroSequence=
uMainMenuDelayBeforeAllowSkip=0
```

> [!NOTE]
> `sIntroSequence=` および `uMainMenuDelayBeforeAllowSkip=0` は Nexus mods/586「Skip Intro Videos」と同等の INI 設定です。メインメニュー等の SWF を置き換える MOD（Undelayed Launching 等）は日本語フォント・UI 破損のリスクがあるため使用せず、純粋な INI 設定のみで安全にスキップしています。

### 2.2 StarfieldPrefs.ini
`<MO2>\Starfield\profiles\Stable\StarfieldPrefs.ini` にゲーム解像度・グラフィック設定・コントロール設定が保持されます。

---

## 3. LM Studio 設定（Phase 1 標準）

### 3.1 モデル構成
- **モデル名**: `unsloth/gemma-4-12b-it-qat-GGUF`
- **量子化形式**: `UD-Q4_K_XL`（約 6.72 GB、ファイル名: `gemma-4-12B-it-qat-UD-Q4_K_XL.gguf`）
  ※仕様書想定の Q4_K_M から、品質と量子化効率が向上した UD-Q4_K_XL を採用。
- **モデル識別子（API Identifier）**: `gemma-4-12b-it-qat`
- **コンテキスト長**: `16384`（16K、AISS の推奨最低値に準拠。32K は VRAM 超過のため不採用）
- **GPU オフロード**: 100%（全レイヤー max）
- **KV キャッシュ量子化**: **Q8_0（K キャッシュ / V キャッシュ）**（専用 VRAM を約 1.18 GiB 削減）
- **Flash Attention**: **オン（有効）**
- **思考（Reasoning）**: **完全無効化（OFF）**（会話の即答テンポを確保）
- **マルチモーダル（mmproj）**:
  自動取得された `mmproj-F32.gguf`（約 837 MB）が同梱されていますが、AISS はテキスト会話のみを使用するため Vision 推論は行われません（削除せず保持）。

### 3.2 プリセットファイル構成とロード手順
LM Studio に以下のプリセットを配備済みです：
- パス: `<UserDir>\.lmstudio\config-presets\AISS-Standard.preset.json`
- 設定内容:
  ```json
  {
    "name": "AISS-Standard-Q8_0",
    "load": {
      "fields": [
        { "key": "llm.load.contextLength", "value": 16384 },
        { "key": "llm.load.llama.flashAttention", "value": true },
        { "key": "llm.load.llama.kCacheQuantizationType", "value": { "checked": true, "value": "q8_0" } },
        { "key": "llm.load.llama.vCacheQuantizationType", "value": { "checked": true, "value": "q8_0" } }
      ]
    },
    "prediction": {
      "fields": [
        { "key": "llm.prediction.reasoning.enableThinking", "value": false },
        { "key": "llm.prediction.temperature", "value": 0.85 },
        { "key": "llm.prediction.maxTokens", "value": 1800 }
      ]
    }
  }
  ```

> [!TIP]
> **LM Studio のロード設定について**
> - `<UserDir>\.lmstudio\settings.json` の `defaultContextLength: 16384` および JIT 設定により、通常はリクエスト時に自動的に適正な設定でロードされます。
> - LM Studio GUI から手動でロードする場合は、ロード画面上部の **Preset ドロップダウンから「AISS-Standard-Q8_0」を選択** してロードしてください。Context: 16384、GPU: MAX、K/V Cache: Q8_0、Flash Attention: ON、Thinking: OFF が一括適用されます。

### 3.3 サーバー設定
- **ローカルサーバー**: 有効（ポート `1234`）
- **インターフェース**: `127.0.0.1`
- **エンドポイント**: `http://127.0.0.1:1234/v1`

---

## 4. AISS 設定（変更差分およびアドオン方式）

### 4.1 config.json 変更差分
設定ファイル: `<MO2>\Starfield\mods\AISS - AI Settled Systems\AISS\config.json`

| キーパス | 変更後 | 変更前（デフォルト） | 目的・理由 |
|---|---|---|---|
| `llm.provider` | `"lmstudio"` | `"openrouter"` | ローカル LM Studio への接続 |
| `llm.providers.lmstudio.base_url` | `"http://127.0.0.1:1234/v1"` | （未設定または既定値） | ローカル API エンドポイント指定 |
| `llm.providers.lmstudio.model` | `"gemma-4-12b-it-qat"` | `"openai/gpt-4o-mini"` | ロード済みモデル識別子指定 |
| `llm.providers.lmstudio.reasoning_effort` | `"none"` | （未設定） | Gemma 4 の思考（CoT）を抑制し即答させる設定 |
| `llm.providers.lmstudio.reasoning.enabled` | `false` | （未設定） | 思考プロセスの無効化フラグ |
| `tts.enabled` | `false` | `true` | Phase 1 はテキスト会話のみ（TTS無効） |

※APIキーは一切入力しておらず、完全ローカル・無料環境として構成しています。

### 4.2 日本語プロンプト調整（MO2 別 MOD アドオン方式）
- **本体ファイルの完全復元**:
  AISS 本体の `system_preface.txt` は直接編集を廃止し、初期バックアップファイル（SHA-256 一致確認済み）から完全に元通りに復元されています。
- **独立アドオン MOD**:
  AISS 公式のアドオンデータパック機能（`README_AISS_ADDONS.txt` 準拠）を利用し、MO2 の別 MOD として独立管理しています。
  - MOD 名: `AISS - Japanese Language Addon`
  - 格納パス: `<MO2>\Starfield\mods\AISS - Japanese Language Addon\AISS\addons\jp_prompt_pack\profiles\vanilla_starfield\system_preface_append.txt`
  - MO2 優先度: 左ペインで `AISS - AI Settled Systems` の直下に配置（優先度高）
- **追記ディレクティブ全文**:
  ```
  [Language & Roleplay Directives]
  - Always reply in natural, immersive Japanese only (常に自然な日本語のみで返答すること). Do not output English unless repeating an in-game proper noun.
  - Never behave like an AI assistant or chatbot (AIアシスタントやチャットボットのように振る舞わないこと).
  - Never discuss anything outside the game world or 24th century Starfield reality (ゲーム世界の外の話を一切しないこと).
  - Keep replies concise, conversational, and natural for dialogue, typically 1 to 3 sentences (conversational length, around 40 to 120 Japanese characters) (会話のテンポを保つため、返答は簡潔に1〜3文程度を目安とすること).
  - Do not output internal monologue, thought process, or reasoning tags; reply immediately with in-character spoken dialogue only (思考過程や推論タグを出力せず、キャラクターとしての発話セリフのみを直ちに出力すること).
  ```

---

## 5. 出力ファイル・ログの実際の配置場所

AISS および SFSE が実行時にアクセスする出力先は以下の通りです。

| 項目 | 実際のパス | 備考 |
|---|---|---|
| SFSE ログ | `<Documents>\My Games\Starfield\SFSE\Logs\sfse.txt` | スクリプト拡張初期化ログ |
| SFSE ローダーログ | `<Documents>\My Games\Starfield\SFSE\Logs\sfse_loader.txt` | プロセスフック・インジェクションログ |
| AISS リクエスト | `<MO2>\Starfield\mods\AISS - AI Settled Systems\SFSE\AISS\requests\latest_request.ini` | ゲーム側からの会話要求 |
| AISS レスポンス | `<MO2>\Starfield\mods\AISS - AI Settled Systems\SFSE\AISS\responses\latest_response.ini` | LLM生成結果のゲーム側受け渡し先 |
| AISS HUD状態 | `<MO2>\Starfield\mods\AISS - AI Settled Systems\SFSE\AISS\state\hud.ini` | 通知・字幕表示状態 |
| AISS 実行時ヘルスログ | `<MO2>\Starfield\mods\AISS - AI Settled Systems\AISS\logs\runtime_health.json` | バックエンド健全性診断結果 |

※AISS_Backend は自モジュール配下のパスを直接読み書きしており、MO2 の overwrite ではなく MOD フォルダ内に出力されます。

---

## 6. 外部プロセスの起動順序（運用手順）

### 6.1 プレイ前に閉じるべきアプリ（VRAM 確保）
本環境（AMD Radeon RX 9070 16GB）では、LM Studio（約 7.4〜8.5 GB）と Starfield（FHD 推奨 7〜9 GB）が同時に VRAM を消費するため、**バックグラウンド常駐アプリを閉じて VRAM 余力を確保することが強く推奨されます**。

GPU メモリ使用量調査（実測上位プロセス）:
| プロセス名 | VRAM使用量 | プレイ前の推奨アクション | 期待される解放量 |
|---|---|---|---|
| `WardogsClient-Win64-Shipping` | **約 2,306 MB (2.25 GiB)** | **必ず終了する**（別ゲームクライアント） | **約 2.3 GB 解放** |
| `msedge`（ブラウザ） | **約 599 MB (0.58 GiB)** | **終了する**（GPU アクセラレーション使用） | **約 0.6 GB 解放** |
| `Discord` | **約 154 MB (0.15 GiB)** | **終了または最小化** | **約 0.15 GB 解放** |
| `steamwebhelper` | 約 809 MB (0.79 GiB) | 必要に応じて Steam ミニモードまたは GPU 加速無効化 | 数百 MB 解放 |

> [!TIP]
> 上記のゲームクライアントおよびブラウザを終了することで、**合計 約 3.0 GiB 以上の VRAM が即座に解放**され、ゲームプレイ中のクラッシュやテクスチャ破綻を未然に防止できます。後述の統合ランチャーを使用する場合、起動時に終了確認プロンプトが表示され、ワンタッチで通常終了できます。

---

### 6.2 推奨手順: ワンクリック統合ランチャー（デスクトップショートカット）

デスクトップに **「Starfield（AIあり）」** と **「Starfield（AIなし）」** の 2 つの専用ショートカットが用意されており、ダブルクリックするだけで目的のプロファイル・プロセスが自動構成されます。

1. **「Starfield（AIあり）」**:
   - AISS / LM Studio サーバー / SFSE を自動起動し、プロファイル `Stable` でゲームを開始します。
2. **「Starfield（AIなし）」**:
   - LM Studio モデルや AISS Backend を起動せず（稼働中なら自動停止）、プロファイル `Stable-NoAI` で SFSE を直接起動します。

```
[デスクトップの「Starfield（MOD）」をダブルクリック]
  │
  ├─ 1. 常駐アプリの VRAM 解放確認
  │     └─ WardogsClient, msedge, Discord 等の起動を検知した場合、「閉じますか？ (Y/N)」を確認
  │     └─ Y の場合はプロセスを通常終了して VRAM を即座に解放
  │
  ├─ 2. LM Studio サーバー確認＆起動
  │     └─ ポート 1234 の稼働を確認（未起動なら `lms server start` を実行）
  │
  ├─ 3. モデル読み込み＆疎通テスト
  │     └─ `gemma-4-12b-it-qat` をロード（既定設定: 16K, Q8_0, Flash Attention, 思考OFF）
  │     └─ ローカル API へ短いテストリクエストを送信して正常応答を確認
  │
  ├─ 4. AISS Backend 起動
  │     └─ MO2 経由で「AISS Backend」を起動（moshortcut://Starfield:AISS Backend）
  │     └─ プロセス待機＆ロックファイル生成確認（約3秒）
  │
  └─ 5. SFSE（MOD 入り Starfield）起動
        └─ MO2 経由で「SFSE」を自動実行（moshortcut://Starfield:SFSE）
```

- **ランチャー本体**: `tools/launcher/Start-StarfieldAI.bat`（PowerShell 実行ポリシーを自動バイパス）
- **設定ファイル**: `tools/launcher/launcher.config.json`（環境ごとの MO2 パスや監視プロセスを管理）
- **詳細ドキュメント**: [`tools/launcher/README.md`](file:///tools/launcher/README.md)

---

### 6.3 代替手順: 手動起動（ランチャーが動かない場合）

ランチャーを使用しない場合、またはトラブル発生時は以下の手順で手動起動します。

```
[1. 常駐アプリの終了]
   └─ WardogsClient、Edge ブラウザ、Discord 等を手動で終了して VRAM を解放

[2. LM Studio 起動]
   └─ LM Studio を起動し、Local Server を ON（ポート 1234）にする
   └─ モデル `gemma-4-12b-it-qat` はモデル既定設定（16384, Q8_0, Flash Attention, 思考OFF）が
      自動適用されるため、プリセットの手動選択は不要（JIT によるオンデマンド読み込みも可能）

[3. AISS_Backend.exe 起動]
   └─ MO2 を開き、右上ドロップダウンから「AISS Backend」を選択して「実行」をクリック
   └─ コンソールが開き、常駐待機状態（HEALTHY）になることを確認

[4. MO2 GUI からゲーム起動（必須）]
   └─ MO2 でプロファイル「Stable」が選択されていることを確認
   └─ 右上ドロップダウンから「SFSE」を選択して「実行」をクリック
```

※ゲーム終了後は、AISS_Backend.exe および LM Studio を必要に応じて終了してください。

