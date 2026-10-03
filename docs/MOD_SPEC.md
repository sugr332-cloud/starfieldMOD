# Starfield Space Life JP — MODパッケージ実装仕様書

**Status:** READ-ONLY / Implementation Specification Draft  
**Target:** Windows / Starfield（FHD）/ RX 9070 16GB / X52 HOTAS / LM Studio local LLM（密な12B級）  
**Version:** 0.5  
**Date:** 2026-10-03

## 1. 目的

Starfieldを「宇宙船で移動し、船内で生活し、NPCと会話し、宇宙空間を操縦する」方向へ拡張するWindows向けMOD環境を構築する。

最重要目標:
1. ロード画面を可能な範囲で削減する。
2. 宇宙船を生活・活動拠点にする。
3. NPCにAI会話・記憶・状況認識を追加する。
4. LM StudioによるローカルLLMを使用する。
5. X52 HOTASで宇宙船を操作する。
6. 日本語プレイを維持し、追加MODのプレイヤー向けテキストを可能な限り日本語化する。
7. MOD同士の機能重複・競合を避ける。
8. MOD本体を無断再配布せず、構成・設定・日本語化・検証情報を管理する。
9. AI会話に無料（ローカル優先）の日本語AI音声（TTS）を付ける。

## 2. 基本原則

- 最初にREAD-ONLY調査を行う。
- MOD本体をいきなり編集しない。
- 1機能1担当MODを原則とする。
- 同一機能を変更するMODは原則として複数採用しない。
- 実験的MODはStableから分離する。
- MOD、Starfield、依存MODのバージョンを記録する。
- 日本語化はプレイヤーが頻繁に見るテキストを優先する。
- LLM生成会話は日本語出力を要件とする。
- AISS + LM StudioをAI基盤候補とする。
- 各フェーズで起動・セーブ・ロード・会話・移動を検証する。
- Starfield本体のバージョンを固定する。SFSEプラグイン（DLL）は本体更新で動かなくなるため、本体更新はSFSE・Address Library・各SFSEプラグインの対応を確認してから行う。
- 各フェーズの開始前にセーブデータをバックアップする。スクリプト系MOD（AISS等）は途中で外すとセーブが壊れる可能性があるため、検証は専用のテスト用セーブで行う。

## 3. 採用候補

### Core / 優先候補

| MOD/ソフト | 役割 | 初期方針 |
|---|---|---|
| SFSE | スクリプト/プラグイン基盤 | 必須 |
| Address Library for SFSE Plugins | SFSE依存 | 必須 |
| Cassiopeia Papyrus Extender | AISS依存 | 必須候補 |
| Longer Names v2 | AISS依存 | 必須候補 |
| AISS - AI Settled Systems | AI NPC | 中核候補 |
| LM Studio | ローカルLLM（標準モデル: Gemma 4 12B QAT） | 中核 |
| AivisSpeech Engine（他TTS候補は5.1） | 無料ローカルTTS | 採用候補（Phase 1.5） |
| Absolute HOTAS | HOTAS操作 | 採用候補 |
| Civil NPCs | NPC挙動改善 | 採用候補 |
| Ship Crew Assignments | クルー生活 | 採用候補 |
| Real Fuel | 燃料 | 採用候補 |

### Immersion / 段階導入

| MOD | 役割 | 方針 |
|---|---|---|
| Grav Lanes | 星系内航行時間 | 実機検証後 |
| True Seamless Grav Jumps SFSE | Grav Jumpロード削減 | 実機検証後 |
| Seamless Loading Screens | 残存ロードの視覚的シームレス化 | 採用候補 |
| Seamless Neon | Neonロード削減 | 実機検証後 |
| Spaceships Plus | 船システム拡張 | 実機検証後 |

### Experimental

| MOD | 理由 |
|---|---|
| Seamless Planet Takeoffs SFSE | Beta。最後に導入 |
| Astrogate等の別系統航行オーバーホール | 航行処理の重複リスクがあるため初期構成から除外 |

## 4. 明示的な競合回避ルール

### 燃料

以下は同時導入しない:
- Real Fuel
- Ships Need Gas

初期候補はReal Fuel。Ships Need Gasは比較対象として記録する。

### Grav Jump / 航行

航行処理を変更するMODを無制限に重ねない。

初期検証候補:
`Grav Lanes + True Seamless Grav Jumps`

Astrogate等は別プロファイルで検証する。

### AISS

AISSの旧版、旧backend、旧config、旧パッチを混在させない。
同時に複数backend/configを有効化しない。

### TTS

TTSエンジン/ブリッジは同時に1系統のみ有効化する。
AISSのTTS設定（ElevenLabs / Fish Audio / ローカルブリッジ）は1つだけを有効にする。

## 5. AISS + LM Studio

想定経路:

```
Starfield
  -> AISS
  -> AISS backend
  -> LM Studio Local Server
  -> Local LLM
```

LM Studio側のローカルAPIはPhase 0で現行仕様を確認する。

AISS側では以下を監査する:
- provider/backend
- base URL
- model identifier
- API key要否
- 日本語出力設定
- NPC人格・記憶・コンテキスト
- 複数NPC会話
- 既知の不具合

テスト条件:
- 日本語質問（ゲーム内のAISS入力欄で日本語IMEが使えるか。使えない場合の代替手段: ボーダーレスウィンドウでの入力、貼り付け等）
- 日本語回答（AISSのUIで日本語の文字が表示されるか。文字化け・豆腐（□）がないか）
- NPC人格維持
- 過去会話の記憶
- クエスト/場所/船/装備等のコンテキスト認識
- 複数NPC会話時の日本語維持
- 日本語版ゲームのNPC名・地名・アイテム名がAISSのコンテキストに日本語で渡るか、英語の内部名が混ざるか

AISSの人格・ワールドプロファイル・システムプロンプトが英語の場合、日本語で返答させる指示を追加する。追加する設定値は `configs/AISS/` に記録する。

### LLMモデル方針（決定事項）

- 会話の質を落とさないことを優先する。**密な（Dense）12B級を標準とし、それより小さいモデルは採用しない**
- 標準モデル: **Gemma 4 12B（QAT版、Q4量子化、約8GB）**
- MoEモデルは採用しない。理由: モデル全体をRAMに載せるためRAM消費が大きい、CPU側の入力処理で返答開始が遅れる、推論負荷がCPUにかかりFHDでCPU律速になりやすいStarfieldと競合する
- 密な27B級以上をCPUへオフロードする構成も採用しない（応答が極端に遅くなるため）
- 比較対象: 日本語特化系の12B級前後のモデル（Swallow、ELYZA、LLM-jp、Sarashina等）をPhase 0で調査し、Gemma 4 12Bを上回るものがあれば比較テストする
- モデルはVRAMに全て載せる（GPUオフロード100%）
- モデル名・量子化・コンテキスト長・使用VRAM・生成速度を `configs/LMStudio/` に記録する

### 会話品質を上げるプロンプト調整

モデルと同等に会話の質を左右するため、AISSの人格・プロファイル設定で以下を行い、設定値を `configs/AISS/` に記録する。

- NPCの口調・性格を具体的に書く（一人称、語尾、話し方の癖）
- 「日本語のみで返答する」「AIアシスタントのように振る舞わない」「ゲーム世界の外の話をしない」を明記する
- 理想的な返答例を1〜2個入れる
- 返答の長さの目安を指定する（長すぎるとTTSの遅延も増える）
- 調整前後で同じNPC・同じ質問の返答を比較し、`docs/TEST_RESULTS.md` に記録する

### モデル比較の評価項目

同じNPC・同じ質問・同じ設定で比較する。
- 口調・人格の一貫性（複数往復）
- 状況（場所、船、燃料、クエスト等）の読み取り
- 日本語の崩れ（英語の混入、急な敬語化、不自然な表現）
- 存在しない設定の捏造
- 返答開始までの時間と生成速度
- ゲーム中のフレームレートへの影響

TTSは初期Phase（Phase 1）では導入しない。Phase 1でAISS + LM Studioの日本語テキスト会話が安定した後、5.1の無料TTS構成を「Phase 1.5 — AI Voice」として段階導入する。

## 5.1 AI音声（TTS）— 無料構成

### 前提（2026-10-03時点の確認事項）

- AISSが公式に対応しているTTSは **ElevenLabs** と **Fish Audio**（いずれもクラウド・APIキー・従量課金/クレジット制）。
- AISSのLLM側はLM Studio（ローカル・無料）に対応しているが、TTS側にローカル/無料エンジンの公式対応は確認できていない。
- AISSはTTS音声の長さに合わせた口パク（dialogue/lip system）を持つ。

### AISS側の確認済み事項（2026-10-03、Nexus説明文・ポスト欄より）

- 設定ファイル: `Data\AISS\config.json`。TTS有効化用のプリセットは `Data\AISS\config_presets` にあり、config.jsonへコピーして使う
- TTS設定として公開されている項目: プロバイダごとのAPIキー、NPCごとのボイスID（922件のNPC音声ルートが明示設定済み）、プロバイダの有効/無効
- TTSの送り先URL（base URL）を変更する項目は公開ドキュメントに記載なし → **方式Aは未確定**
- 設定ファイルに「xtts」用の枠があるとの報告あり（実装済みかは不明）。動作すればXTTS v2（ローカル）を直接接続できる可能性がある
- `AISS_Backend.exe`（ローカル常駐プロセス）がAI/TTSとの通信、音声キュー、再生、口パクのタイミングを担当する
- 生成音声のキャッシュ: `Data\SFSE\AISS\audio`（MP3）
- リクエスト/レスポンスのログ: `Data\SFSE\AISS\requests\latest_request.ini`、`Data\SFSE\AISS\responses\latest_response.ini` → **方式Dの入力として利用可能**
- LM Studioの接続はAPIキー不要（`provider: lmstudio`、`http://127.0.0.1:1234/v1`）

### 方針（ユーザー要件）

- **APIキー・アカウント登録を使わない。** 有料TTSの無料枠も使わない
- LLMはLM Studio（キー不要）を使う

したがって「無料のAI音声」は、次の2系統で実現する。
- 方式A/B: AISSの既存TTS経路にローカルTTSを接続する（口パク同期あり。可否はユーザー環境のconfig.jsonで判定）
- 方式D: AISSのレスポンスログを外部ツールが読み、ローカルTTSで読み上げる（口パク同期なし。公開情報の範囲で実現可能と判断）

Phase 0で方式Aの可否を判定し、不可なら方式Dを採用する。

### 要件

- 費用: 無料（サブスク・従量課金なし）
- 実行場所: ローカル優先（オフライン動作）
- 言語: 日本語音声（NPCのLLM回答が日本語のため）
- OS: Windows
- GPU: Radeon RX 9070 16GB（AMD）。CUDA専用エンジンは不可またはCPU実行扱い
- VRAM: Starfield + LM Studio（LLM）+ TTS の合計で16GBを超えないこと
- 権利: 音声モデル/キャラクターの利用規約（クレジット表記、商用/非商用、改変可否）を守る。音声モデル本体はリポジトリに含めない

### TTSエンジン候補

| エンジン | 種別 | 日本語 | AMD/Windows | 備考 |
|---|---|---|---|---|
| AivisSpeech Engine | ローカル・無料 | ◎ | 要確認（DirectML/CPU） | VOICEVOX互換API。Style-Bert-VITS2系。モデルごとのライセンス確認必須 |
| VOICEVOX Engine | ローカル・無料 | ◎ | 要確認（DirectML/CPU） | キャラクターごとの利用規約・クレジット表記（例: 「VOICEVOX:キャラ名」）が必要 |
| Style-Bert-VITS2 | ローカル・無料 | ◎ | 要確認（CUDA中心、CPU可） | 学習済みモデルのライセンス確認必須 |
| fish-speech / OpenAudio（OSS版） | ローカル・無料 | ○ | 要確認（CUDA中心） | Fish AudioのOSS版。AISSのFish Audio経路との互換性を確認する価値あり。重みのライセンス（非商用条件等）を確認 |
| XTTS v2（Coqui） | ローカル・無料 | ○ | 要確認（CUDA中心、CPU可だが低速） | AISSのconfigに「xtts」枠があるとの報告あり。方式Aで直接接続できる可能性。モデルライセンス（非商用条件）を確認 |
| Irodori-TTS | ローカル・無料 | ○ | 要確認 | MITライセンス、ボイスクローン・感情指定可。漢字の読みが弱いとの報告があり、かな変換の前処理が必要になる可能性。Experimental扱い |
| Windows標準音声（SAPI/OneCore: Haruka等） | ローカル・無料 | △ | ○ | キー・追加インストール不要。音質は機械的。方式Dの最終フォールバック |
| Edge-TTS | オンライン・無料 | ○ | ○ | Microsoftの非公式利用。規約・継続性リスクがあるため採用しない（比較記録のみ） |

初期第一候補: **AivisSpeech Engine**（日本語品質・Windows対応・VOICEVOX互換APIで扱いやすい）。比較対象: VOICEVOX Engine、XTTS v2（方式Aのxtts枠が使える場合）、fish-speech。

### 接続方式

AISS本体（DLL/Papyrus/ESP）は改変しない。以下の順に可否を判定する。

**方式A: AISSのTTS接続先をローカルに向ける（第一候補）**

```
Starfield
  -> AISS
  -> AISS backend（TTS: Fish Audio または ElevenLabs 設定）
  -> ローカルTTSブリッジ（http://127.0.0.1:<port>、Fish Audio/ElevenLabs互換APIを模倣）
  -> AivisSpeech Engine / VOICEVOX Engine / fish-speech
```

成立条件:
- AISSの設定ファイル/UIでTTSのbase URL（エンドポイント）を変更できること
- APIキーをダミー値で通せること（本物のキー・アカウントは使わない）
- ブリッジがAISSの期待する音声形式（コーデック、サンプルレート、レスポンス形式）を返せること
- 口パクが返却音声の長さと同期すること
- AISSがNPCごとに送るボイスID（922件のNPC音声ルート）を、ブリッジ側でローカルの話者（voice_map）に変換できること

fish-speech（OSS版）がAISSのFish Audio経路と直接互換であれば、ブリッジなしで接続できる可能性がある。Phase 0で確認する。

**方式B: AISS作者が無料/ローカルTTSの公式対応を提供している、または予定している場合**

公式対応を優先し、方式Aのブリッジは作らない。

**方式C: 接続先を変更できない場合**

AISS本体の改変・逆解析によるTTS差し替えは行わない（14章の禁止事項）。有料TTS（無料枠を含む）は使わない（APIキー不使用の要件）。この場合は方式Dへ移行する。並行してAISS作者へローカルTTS対応の要望を出すかはユーザー判断とする。

**方式D: レスポンスログの外部読み上げ（方式Aが不可の場合の採用方式）**

```
Starfield
  -> AISS
  -> AISS_Backend.exe（TTS無効、LLMはLM Studio）
  -> Data\SFSE\AISS\responses\latest_response.ini を書き出し
  -> 読み上げツール（本リポジトリ tools/tts-reader/ で管理）
       - ファイル変更を監視
       - NPC名・セリフを抽出（重複再生防止）
       - voice_mapでNPC→声を決定
  -> AivisSpeech Engine / VOICEVOX Engine（ローカルHTTP API）
  -> 再生
```

仕様:
- AISS本体・AISSのファイルには書き込まない（読み取り専用）
- AISSのTTSは無効のままにする（二重再生防止）
- latest_response.ini の形式（NPC識別子、本文、エンコーディング、書き込みタイミング）はPhase 0で実ファイルから確認する
- 書き込み途中の読み取りを避ける（更新後に短い待機、または内容が安定してから読む）
- 同一レスポンスを二度読まない（ハッシュ等で判定）
- 長文は文単位で分割し、先頭文から順次再生して体感遅延を減らす
- 読み上げ前に、英字固有名詞・数字の読み替え辞書を適用できるようにする（`configs/TTS/` で管理）
- 読み上げツールやTTSエンジンが停止しても、ゲームとAISSのテキスト会話には影響しない
- レスポンス内のセリフ以外（ト書き `*微笑む*` 等、アクション/感情タグ、JSON、メタ情報）は読み上げ前に除去する。除去ルールは実ファイル確認後に `configs/TTS/` で定義する
- MO2環境でのファイルの実際の場所を確認する（7.1参照）。読み上げツールは、MO2の仮想ファイルシステム経由のパスではなく、実際にファイルが書き出される場所（MO2のoverwriteフォルダ等）を監視する。パスは設定ファイルで指定できるようにする
- 再生音量・出力デバイスを設定できるようにする
- 読み上げツールのログを残す（検出時刻、NPC、本文の先頭、生成時間、再生時間、エラー）

制約:
- 口パクとは同期しない
- AISSの会話表示と音声にタイムラグが出る
- 音声はゲーム内の3D音響ではなくPC側の再生になる
- `latest_response.ini` は最新の1件だけを保持するため、短時間に複数のレスポンスが来ると、読み取る前に上書きされて取りこぼす可能性がある。取りこぼしはログに記録し、頻度を検証する

### 実行配置

- 標準: TTSエンジンをメインPC上でCPU実行し、VRAMをStarfieldとLLMに残す
- 代替: LAN内の別PC（Radeon RX 7600搭載のリビングPC等）でTTSエンジンを動かし、ブリッジから接続する。遅延とネットワーク到達性を検証する
- GPU実行はVRAM計測で余裕が確認できた場合のみ

### NPCと声の割り当て

- 少数の声（男声/女声/ロボット・ナレーション系など）をNPCの性別・種族・役割に割り当てる
- 割り当て表は `configs/TTS/voice_map` として管理する（音声モデル本体は含めない）
- 主要クルー/コンパニオンは固定の声にする

### 音声テスト条件

- 日本語の読み上げが破綻しない（漢字の読み、英字固有名詞、数字）
- LLM回答から音声再生開始までの遅延を計測する（目標: 体感で会話が途切れない範囲。実測値を記録）
- 口パクと音声長の同期
- 長文回答時の分割・途切れ
- 複数NPC会話時に声が混線しない
- VRAM/CPU使用率、フレームレート低下の計測
- TTSエンジン停止時にAISS会話（テキスト）が継続し、CTDしない
- 方式Dの場合: 重複再生がない、書き込み途中の読み取りがない、AISSのTTSが無効で二重再生しない
- 10回以上の連続会話とセーブ/ロード

## 5.2 VRAM・性能予算

RX 9070 16GBを、Starfield・LM Studio（LLM）・TTSで共有するため、VRAM不足が最大の性能リスクになる。

- 想定解像度はFHD。FHDのStarfieldは目安で7〜9GBのVRAMを使い、残りに12B級（約8GB）を載せる
- フレームレートに上限をかける（例: 60fps）。GPUに余力を残し、LLM生成中の落ち込みを抑える
- Phase 1でStarfield単体のVRAM使用量を計測し、12B級が載るかを確認する
- 載らない、またはフレームレートの落ち込みが許容できない場合は、以下の順で対処する（モデルを12B級未満に下げる対処は行わない）
  1. グラフィック設定（テクスチャ品質等）を下げてVRAMを空ける
  2. コンテキスト長を見直す
  3. LM StudioをLAN内の別PC（Radeon RX 7600搭載のリビングPC等）で動かし、AISSのLM Studio接続先URLをそのPCに向ける（RX 7600は8GBのため12B級Q4が収まるかを検証する。通信はテキストのみで、LANによる遅延は無視できる）
- TTSは原則CPUで動かす（5.1 実行配置）
- 計測項目: VRAM使用量、フレームレート（平均と最低）、LLMの応答時間、TTSの生成時間
- 結果は `docs/TEST_RESULTS.md` に記録する

## 6. 日本語化方針

### 優先度S
- クエスト
- NPC会話
- アイテム名
- 船パーツ
- 頻繁に見るUI
- 燃料・修理・船システム説明

### 優先度A
- MOD設定
- チュートリアル
- ヘルプ
- ゲームプレイ説明

### 優先度B
- 開発者向け設定
- デバッグ
- ログ
- 内部ID

SFSE/Address Library等の基盤MODや、新規プレイヤー向けテキストがほぼない機能MODは原則として日本語化対象外。
既存の日本語化パッチがある場合は優先する。ない場合は作者の許可条件を確認し、必要なら別パッチとして管理する。

## 7. MO2プロファイル

### Stable

Stableはフェーズの検証合格ごとに段階的に増やす。各MODを導入するフェーズは次のとおり。

| MOD | 導入フェーズ |
|---|---|
| SFSE | Phase 1 |
| Address Library for SFSE Plugins | Phase 1 |
| Cassiopeia Papyrus Extender | Phase 1 |
| Longer Names v2 | Phase 1 |
| AISS | Phase 1 |
| Absolute HOTAS | Phase 1 |
| Civil NPCs | Phase 2 |
| Ship Crew Assignments | Phase 2 |
| Real Fuel | Phase 2 |

TTS（Phase 1.5）はStableに含めず、Phase 1.5の検証合格後にStableへ追加するかをユーザーが判断する。検証中はStableプロファイル + TTS有効設定で試験する。

### 外部プロセス（MO2のMODではない）

以下はMO2のプロファイルに入れるMODではなく、ゲームと並行して起動する外部プログラムとして管理する。起動順と設定は `docs/CONFIG_GUIDE.md` に記録する。

```
LM Studio（Local Server）
AISS_Backend.exe
TTSエンジン（Phase 1.5以降）
読み上げツール または TTSブリッジ（Phase 1.5以降）
```

起動順の原則: LM Studio → TTSエンジン → 読み上げツール/ブリッジ → AISS_Backend.exe → SFSE経由でStarfield。

### Immersion-Test

Stable +

```
Grav Lanes
True Seamless Grav Jumps
Seamless Loading Screens
Seamless Neon
Spaceships Plus
```

### Experimental

Immersion-Test +

```
Seamless Planet Takeoffs
```

その他の大型航行MODは個別検証用プロファイルで扱う。

## 7.1 MO2運用上の注意

- MO2は仮想ファイルシステム（VFS）でMODをゲームフォルダに見せている。MO2の外から起動したプログラムには、MOD内のファイル（`Data\AISS\config.json` 等）が見えない
- `AISS_Backend.exe` は、MO2の実行ファイル登録から起動するか、作者の推奨手順に従う。どちらで動くかをPhase 0/1で確認する
- SFSEプラグインやAISSが書き出すファイル（ログ、`Data\SFSE\AISS\` 以下）は、MO2ではoverwriteフォルダに出力されることがある。実際の出力先を確認し、`docs/CONFIG_GUIDE.md` に記録する
- プロファイルごとにセーブを分ける（MO2のプロファイル別セーブ機能を使う）。Stable・Immersion-Test・Experimentalのセーブを混在させない
- プラグインの読み込み順はMO2で管理し、変更したら記録する
- Bethesda公式のCreations経由で導入したMODとNexus/MO2経由のMODを混在させる場合は、どちらで管理しているかを記録する。同じMODを両方から入れない

## 8. 競合監査

各MODについて次を記録する:
- ESP/ESM/ESL
- SFSE DLL
- Papyrus Script
- SWF/UI
- INI
- Mesh/Texture
- Worldspace
- Cell
- Quest
- Actor/NPC
- Ship system
- Input
- AI behavior

### 重大度

**CRITICAL:** 起動不能、セーブロード不能、CTD、永久ロード、操作不能、主要処理破綻  
**HIGH:** クエスト進行不能、NPC/クルー停止、船機能停止、Grav Jump不能、AISS会話不能  
**MEDIUM:** UI崩れ、テキスト欠落、一部アニメーション/ロード演出不良  
**LOW:** 表示順、翻訳漏れ、ログ警告のみ

CRITICAL/HIGHが解消できないMODはStableから除外する。

## 9. Phase 0 — READ-ONLY監査

AGYは変更を行わず、以下を調査する:
1. Starfield本体バージョン
2. SFSEバージョン
3. 各MOD最新版
4. 必須依存
5. 競合情報
6. 日本語化の有無
7. Nexus Permissions
8. Windows対応
9. AISS + LM Studio対応
10. 既知の問題
11. AISSのTTS接続先（base URL）変更可否、xtts枠の有無と動作可否、ダミーキーで通るか、期待される音声形式、`latest_response.ini` の形式（5.1 方式A/B/C/Dの判定。ユーザー環境の `Data\AISS\config.json` と `config_presets` を確認。APIキー欄は記録しない）
12. AISSの入力欄で日本語IMEが使えるか、AISSのUIで日本語が表示できるか（情報がなければPhase 1の実機テストで確認）
13. MO2環境での `AISS_Backend.exe` の起動方法と、AISSのログ・音声キャッシュの実際の出力先
14. 無料TTS候補（AivisSpeech Engine / VOICEVOX Engine / Style-Bert-VITS2 / fish-speech / XTTS v2 / Irodori-TTS）の最新版、Windows + AMD GPU対応、CPU実行時の速度、日本語品質、音声モデル/キャラクターの利用規約

成果物:
- `docs/MOD_AUDIT.md`
- `docs/MOD_COMPATIBILITY.md`
- `docs/MOD_JAPANESE.md`
- `docs/TTS_AUDIT.md`

**この監査が完了するまで実装を開始してはいけない。**

## 10. Phase 1 — Core

Stableプロファイルのうち、導入フェーズがPhase 1のMODだけで構築する（7章の表）。

導入:
- SFSE
- Address Library for SFSE Plugins
- Cassiopeia Papyrus Extender
- Longer Names v2
- AISS
- Absolute HOTAS
- 外部プロセス: LM Studio、AISS_Backend.exe

テスト:
- Starfield起動
- SFSE起動
- 新規ゲーム
- 既存セーブロード
- NPC会話
- AISS起動
- LM Studio接続
- 日本語AI会話（5章のテスト条件。日本語IME入力・日本語表示を含む）
- HOTAS入力
- VRAM・性能の計測（5.2）
- LLMモデル比較（5章の評価項目）

成果物: `docs/TEST_PHASE1.md`

## 10.5 Phase 1.5 — AI Voice（無料TTS）

前提:
- Phase 1の日本語AI会話テストに合格していること
- Phase 0の `docs/TTS_AUDIT.md` で方式A/B/Dのどれを採用するか判定されていること

追加:
- 無料TTSエンジン（初期第一候補: AivisSpeech Engine）
- 方式Aの場合: 必要な場合のみローカルTTSブリッジ（自作の場合は本リポジトリの `tools/tts-bridge/` で管理。AISS本体は改変しない）
- 方式Dの場合: 読み上げツール（本リポジトリの `tools/tts-reader/` で管理）
- `configs/TTS/`（エンジン設定、voice_map、AISSのTTS設定値の記録）

テスト: 5.1「音声テスト条件」の全項目

成果物: `docs/TEST_PHASE1_5.md`

## 11. Phase 2 — Ship Life

追加:
- Civil NPCs
- Ship Crew Assignments
- Real Fuel

テスト:
- NPCの挙動（Civil NPCs）とAISS会話が両立するか
- クルー配置
- クルー行動
- 船内移動
- 燃料消費
- 補給
- セーブ/ロード

## 12. Phase 3 — Seamless Travel

追加:
- Grav Lanes
- True Seamless Grav Jumps
- Seamless Loading Screens
- Seamless Neon

テスト:
- Grav Jump
- 航行時間
- 星系変更
- 都市移動
- ドア/エレベーター
- セーブ/ロード
- 10回以上の連続移動

## 13. Phase 4 — Experimental Takeoff

追加:
- Seamless Planet Takeoffs

複数惑星、天候、都市/基地、着陸地点、離陸、Cruise Modeを10回以上連続テストする。

CTDまたは操作不能が発生した場合はStable/Immersion-Testから除外する。

## 14. AGY禁止事項

AGYはユーザー承認なしに以下を行わない:
- MOD追加
- MOD削除
- MOD置換
- MOD本体改変
- MOD再配布可能な梱包
- 日本語化ファイルの無断公開
- NexusからのMOD再配布
- StableへのExperimental追加
- 競合を推測で無視
- ゲーム本体の自動更新
- セーブデータの上書き
- ロードオーダーの大幅変更
- AISS本体（DLL/Papyrus/ESP）の改変・逆解析によるTTS差し替え
- 有料TTS（ElevenLabs / Fish Audio等）の契約・アカウント作成・APIキー登録・課金の発生する設定（無料枠を含む）
- 音声モデル・音声データの再配布、リポジトリへの同梱

## 15. 成果物

```
docs/
├─ MOD_SPEC.md
├─ MOD_AUDIT.md
├─ MOD_COMPATIBILITY.md
├─ MOD_JAPANESE.md
├─ TTS_AUDIT.md
├─ INSTALL_GUIDE.md
├─ CONFIG_GUIDE.md
├─ TEST_PLAN.md
└─ TEST_RESULTS.md

profiles/
├─ Stable/
├─ Immersion-Test/
└─ Experimental/

configs/
├─ AISS/
├─ LMStudio/
├─ TTS/
└─ HOTAS/

tools/
├─ tts-bridge/（方式Aでブリッジが必要な場合のみ）
└─ tts-reader/（方式Dの場合のみ）
```

MOD本体・音声モデル本体はリポジトリに含めない。

## 16. Git運用

- `main`を正本とする。
- 実装前にREAD-ONLY監査を行う。
- 実装は作業ブランチで行う。
- 1フェーズごとにコミットする。
- テスト結果をコミットする。
- 無関係な変更を行わない。
- MOD構成変更時は仕様書も更新する。
- APIキー・トークン・個人のフォルダパス・ユーザー名をコミットしない。設定ファイルはプレースホルダー入りのテンプレート（例: `config.example.json`）として管理し、実際の設定ファイルは `.gitignore` で除外する。
- AISSの `config.json` を丸ごとコミットしない（MOD作者の配布物の再配布になるため）。変更した項目と値だけを記録する。

## 17. Phase 0の必須回答表

AGYは実装前に以下を埋める。

| MOD | 採用判定 | 最新版 | 必須依存 | 競合 | 日本語化 | 安定性 | 備考 |
|---|---|---|---|---|---|---|---|
| SFSE | 必須 | 調査 | 調査 | 調査 | 対象外 | 調査 | 本体バージョンとの対応 |
| Address Library for SFSE Plugins | 必須 | 調査 | 調査 | 調査 | 対象外 | 調査 | SFSE依存 |
| Cassiopeia Papyrus Extender | 必須候補 | 調査 | 調査 | 調査 | 対象外 | 調査 | AISS依存 |
| Longer Names v2 | 必須候補 | 調査 | 調査 | 調査 | 調査 | 調査 | AISS依存 |
| AISS | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | 中核 |
| Absolute HOTAS | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | X52 |
| Civil NPCs | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | NPC挙動。AISSとの干渉確認 |
| Ship Crew Assignments | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | クルー |
| Real Fuel | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | Ships Need Gasとの比較 |
| Grav Lanes | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | 実験 |
| True Seamless Grav Jumps | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | 実験 |
| Seamless Loading Screens | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | 視覚的シームレス |
| Seamless Neon | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | 大規模変更 |
| Spaceships Plus | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | 大規模変更 |
| Seamless Planet Takeoffs | Experimental | 調査 | 調査 | 調査 | 調査 | 調査 | 最後に導入 |
| AISS TTS接続先変更 | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | 方式A/B/C/D判定。xtts枠確認 |
| 方式D 読み上げツール | 方式A不可時に採用 | 調査 | 調査 | 調査 | 調査 | 調査 | latest_response.ini形式確認 |
| XTTS v2 | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | xtts枠が使える場合 |
| AivisSpeech Engine | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | 無料TTS第一候補 |
| VOICEVOX Engine | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | 比較対象 |
| fish-speech（OSS） | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | Fish Audio経路互換の確認 |

**AGYはこの表を完成させるまで実装を開始してはいけない。**
