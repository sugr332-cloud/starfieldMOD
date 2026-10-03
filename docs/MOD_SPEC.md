# Starfield Space Life JP — MODパッケージ実装仕様書

**Status:** READ-ONLY / Implementation Specification Draft  
**Target:** Windows / Starfield / RX 9070 16GB / X52 HOTAS / LM Studio local LLM  
**Version:** 0.1  
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

## 3. 採用候補

### Core / 優先候補

| MOD/ソフト | 役割 | 初期方針 |
|---|---|---|
| SFSE | スクリプト/プラグイン基盤 | 必須 |
| Address Library for SFSE Plugins | SFSE依存 | 必須 |
| Cassiopeia Papyrus Extender | AISS依存 | 必須候補 |
| Longer Names v2 | AISS依存 | 必須候補 |
| AISS - AI Settled Systems | AI NPC | 中核候補 |
| LM Studio | ローカルLLM | 中核 |
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
- 日本語質問
- 日本語回答
- NPC人格維持
- 過去会話の記憶
- クエスト/場所/船/装備等のコンテキスト認識
- 複数NPC会話時の日本語維持

TTSは初期Phaseでは導入しない。

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

```
SFSE
Address Library
AISS + dependencies
LM Studio
Absolute HOTAS
Civil NPCs
Ship Crew Assignments
Real Fuel
```

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

成果物:
- `docs/MOD_AUDIT.md`
- `docs/MOD_COMPATIBILITY.md`
- `docs/MOD_JAPANESE.md`

**この監査が完了するまで実装を開始してはいけない。**

## 10. Phase 1 — Core

Stableプロファイルのみ構築。

テスト:
- Starfield起動
- SFSE起動
- 新規ゲーム
- 既存セーブロード
- NPC会話
- AISS起動
- LM Studio接続
- 日本語AI会話
- HOTAS入力

成果物: `docs/TEST_PHASE1.md`

## 11. Phase 2 — Ship Life

追加:
- Ship Crew Assignments
- Real Fuel

テスト:
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

## 15. 成果物

```
docs/
├─ MOD_SPEC.md
├─ MOD_AUDIT.md
├─ MOD_COMPATIBILITY.md
├─ MOD_JAPANESE.md
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
└─ HOTAS/
```

MOD本体はリポジトリに含めない。

## 16. Git運用

- `main`を正本とする。
- 実装前にREAD-ONLY監査を行う。
- 実装は作業ブランチで行う。
- 1フェーズごとにコミットする。
- テスト結果をコミットする。
- 無関係な変更を行わない。
- MOD構成変更時は仕様書も更新する。

## 17. Phase 0の必須回答表

AGYは実装前に以下を埋める。

| MOD | 採用判定 | 最新版 | 必須依存 | 競合 | 日本語化 | 安定性 | 備考 |
|---|---|---|---|---|---|---|---|
| AISS | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | 中核 |
| Absolute HOTAS | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | X52 |
| Ship Crew Assignments | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | クルー |
| Real Fuel | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | Ships Need Gasとの比較 |
| Grav Lanes | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | 実験 |
| True Seamless Grav Jumps | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | 実験 |
| Seamless Loading Screens | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | 視覚的シームレス |
| Seamless Neon | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | 大規模変更 |
| Spaceships Plus | 未確定→監査 | 調査 | 調査 | 調査 | 調査 | 調査 | 大規模変更 |
| Seamless Planet Takeoffs | Experimental | 調査 | 調査 | 調査 | 調査 | 調査 | 最後に導入 |

**AGYはこの表を完成させるまで実装を開始してはいけない。**
