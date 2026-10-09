# Starfield Space Life JP — Phase 0 MOD監査レポート

- 調査日: 2026-10-03
- 調査対象リポジトリ: `https://github.com/sugr332-cloud/starfieldMOD` (ブランチ: `phase0-audit`)
- 調査ステータス: 完了 (READ-ONLY)

---

## 1. ローカル環境調査結果（読み取り専用）

ローカル環境のシステムおよびゲーム関連ソフトウェアの実機調査結果（ファイルのダウンロード、変更、インストール等は一切行っていません）。
※個人情報保護およびセキュリティのため、ファイルパスは `<Steam>`、`<Starfield>` 等の基点を伏せた形式で記録しています。

| 項目 | 状態 / 検出値 | 備考 |
|---|---|---|
| **OS** | Windows 11 (64-bit) | |
| **CPU** | AMD Ryzen 7 7800X3D 8-Core Processor (8コア / 16スレッド) | |
| **RAM容量** | 32 GB (16GB × 2枚) | |
| **GPU** | AMD Radeon RX 9070 (VRAM 16GB) | |
| **GPUドライバ** | バージョン 32.0.31041.1004 (AMD Software) | |
| **Starfield本体** | **ダウンロード中（未完了 / 暫定値: 1.16.244.0）**<br>ストア: Steam (AppID: 1716740) | `<Steam>\steamapps\common\Starfield` は現在空フォルダ。<br>`<Steam>\steamapps\downloading\1716740\Starfield.exe` のファイルバージョンが `1.16.244.0` (TargetBuildID: 23518663) であることを確認。<br>**※本バージョンはダウンロード中の一時ファイルから取得した暫定値であり、インストール完了後に再確認が必要です。** |
| **SFSE** | **なし** | 未導入（未ダウンロード） |
| **Mod Organizer 2** | **あり** (バージョン 2.5.2) | 実行ファイル: `<MO2>\ModOrganizer.exe`<br>Starfield用インスタンスは未作成（Mount & Blade II のみ構成済み） |
| **LM Studio** | **あり** (バージョン 0.4.25.0) | 実行ファイル: `<Programs>\LM Studio\LM Studio.exe` |
| **ダウンロード済み LM モデル一覧** | 1. `gemma-4-E4B-it-Q4_K_M.gguf`<br>   - 量子化: Q4_K_M<br>   - サイズ: 約 5.34 GB (5,335,291,936 bytes)<br>2. `mmproj-gemma-4-E4B-it-BF16.gguf`<br>   - 量子化: BF16 (マルチモーダルプロジェクタ)<br>   - サイズ: 約 991 MB (991,551,840 bytes)<br>3. `gpt-oss-20b-MXFP4.gguf`<br>   - 量子化: MXFP4<br>   - サイズ: 約 12.1 GB (12,109,565,632 bytes) | **Gemma 4 12B は未ダウンロード（なし）**。<br>現在保持されているのは Gemma 4 の 4B クラス（E4B-it）および GPT-OSS 20B のみであることを確認。 |
| **AISS手元配置状況** | **AISS未入手のため未確認** | ローカルストレージ上に AISS のアーカイブ、設定ファイル（`<Starfield>\Data\AISS\config.json` 等）、レスポンスログ（`latest_response.ini`）は存在せず。<br>READ-ONLY 制約に従い、ダウンロードは行わず「AISS未入手のため未確認」と記録。**Phase 1 導入時に実ファイルを確認**します。 |

---

## 2. 仕様書17章 必須回答表

| MOD / 項目 | 採用判定 | 最新版 (確認日: 2026-10-03) | 必須依存 | 競合 | 日本語化 | 安定性 | 備考 |
|---|---|---|---|---|---|---|---|
| **SFSE** | 必須 | 0.2.21 | Starfield本体 (Steam版) | 他スクリプト拡張ツール（重複時） | 対象外 | Stable | 暫定バージョン 1.16.244 に対応。<br>出典: [sfse.silverlock.org](https://sfse.silverlock.org/) |
| **Address Library for SFSE Plugins** | 必須 | v16 | SFSE | なし（バイナリDB） | 対象外 | Stable | 1.16.244 対応DBを含む。<br>出典: [Nexus Mods ID: 3256](https://www.nexusmods.com/starfield/mods/3256) |
| **Cassiopeia Papyrus Extender** | 必須候補 | 最新版 (Nexus ID: 10896) | SFSE, Address Library | なし | 対象外 | Stable | AISS、Real Fuel 等が依存するスクリプト拡張DLL。約430関数追加。<br>出典: [Nexus Mods ID: 10896](https://www.nexusmods.com/starfield/mods/10896) |
| **Longer Names v2** | 必須候補 | 最新版 (Nexus ID: 5046) | SFSE または ASI Loader | 旧版 Longer Names (ID: 1635) | 対象外 (設定INIのみ) | Stable | 船・拠点・アイテムの名前文字数制限を最大255文字へ拡張。<br>出典: [Nexus Mods ID: 5046](https://www.nexusmods.com/starfield/mods/5046) |
| **AISS - AI Settled Systems** | 中核候補 | 最新版 (Nexus ID: 17392) | SFSE, Address Library, Cassiopeia, Longer Names v2, LM Studio | 他AI会話MOD | プロンプト調整で対応（UI表示は未確認） | Stable (外部プロセス依存) | 中核AI MOD。`AISS_Backend.exe` が常駐し、LM Studio と通信。<br>出典: [Nexus Mods ID: 17392](https://www.nexusmods.com/starfield/mods/17392) |
| **Absolute HOTAS** | 採用候補 | 最新版 (Nexus ID: 16668) | SFSE, Address Library | XInputエミュレータ系ツール | 対象外 (設定UIのみ) | Stable | X52 HOTAS によるダイレクト操縦入力。ゲーム内ウィザード搭載。<br>出典: [Nexus Mods ID: 16668](https://www.nexusmods.com/starfield/mods/16668) |
| **Civil NPCs** | 採用候補 | 最新版 (Nexus ID: 17292) | なし (バニラ対応) | NPCのGMST変更MOD | 対象外 (テキストなし) | Stable | 視線距離短縮、挨拶間隔延長。スクリプトなしGMST変更のみで安全。<br>出典: [Nexus Mods ID: 17292](https://www.nexusmods.com/starfield/mods/17292) |
| **Ship Crew Assignments** | 採用候補 | 最新版 (Nexus ID: 12744) | なし (Creations / Nexus) | 船内家具・NavMesh変更MOD | 翻訳対象（短文UI） | Stable | クルーの配置・就寝・勤務シフト指定（アニメーションマーカー80種以上）。<br>出典: [Nexus Mods ID: 12744](https://www.nexusmods.com/starfield/mods/12744) |
| **Real Fuel** | 採用候補 | v2.01 (2026-08-30) | Cassiopeia Papyrus Extender | Ships Need Gas, Starvival | **既存パッチあり (v2.01)** | Stable | 恒星間ジャンプ時の He-3 消費と補給。2gameに日本語化パッチあり。<br>出典: [Nexus Mods ID: 13306](https://www.nexusmods.com/starfield/mods/13306) |
| **Grav Lanes** | 実機検証後 | 最新版 (Nexus ID: 16438) | なし (単一スクリプト) | Immersive Grav Jumps (作者明記の非互換) | 翻訳対象（設定メニュー） | Stable | ジャンプ到着地点を恒星に変更、ジャンプ中船内歩行可能化。単一スクリプト。<br>※True Seamless Grav Jumps は作者併用推奨。実機での動作は Phase 3 で検証。<br>出典: [Nexus Mods ID: 16438](https://www.nexusmods.com/starfield/mods/16438) |
| **True Seamless Grav Jumps** | 実機検証後 | 最新版 (Nexus ID: 17159) | SFSE, Address Library | 未確認 | 対象外 (演出のみ) | Stable (SFSEフック) | Grav Jumpのロード画面を排除し、コックピットからシームレスジャンプ。<br>※Grav Lanes との併用動作は Phase 3 で検証。<br>出典: [Nexus Mods ID: 17159](https://www.nexusmods.com/starfield/mods/17159) |
| **Seamless Loading Screens** | 採用候補 | 最新版 (Nexus ID: 18239) | SFSE, Address Library, **ReShade 6.8.0+** | 他のロード画面書き換えMOD | 対象外 (視覚演出) | Stable (ReShade依存) | ドア・エレベーター等のロード暗転を最終フレーム維持で視覚的隠蔽。<br>※ReShade 6.8.0以上（Addon有効）必須。<br>出典: [Nexus Mods ID: 18239](https://www.nexusmods.com/starfield/mods/18239) |
| **Seamless Neon** | 実機検証後 | 最新版 (Nexus ID: 17340) | Starfield Free Lanes update plugin（SFBGS00D.esm、2026年4月以降のゲームバージョン） | 大型のNeon改変MOD（Seamless City Interiors、Neon Core Disguised Seamless Project、Neon Core Apartment、Kansha - Neon Apartment、The Dark Side of Neon 等） | 翻訳不要（配置変更） | Caution (要NG+/新規セーブ) | ネオン全区画を外部ワールドスペースに統合。<br>※作者明記: **New Game または NG+ が必須**。<br>出典: [Nexus Mods ID: 17340](https://www.nexusmods.com/starfield/mods/17340) |
| **Spaceships Plus** | 実機検証後 | 最新版 (Nexus ID: 17034) | なし (単体動作) | 未確認（Real Fuel連携機能あり） | 翻訳対象（船警告・設定） | Stable (多機能) | 船システム・燃料スクープ・EVA修理・減圧。Phase 2 (Ship Life) での検証推奨。<br>出典: [Nexus Mods ID: 17034](https://www.nexusmods.com/starfield/mods/17034) |
| **Seamless Planet Takeoffs** | Experimental | 最新版 (Nexus ID: 17719) | SFSE, Address Library | 離陸アニメーション変更MOD | 対象外 (演出のみ) | Beta (慎重検証) | 離陸ロードを排除し大気圏突破を演出。仕様書通り最後に導入。<br>出典: [Nexus Mods ID: 17719](https://www.nexusmods.com/starfield/mods/17719) |
| **AISS TTS接続先変更** | 未確定 (保留) | AISS 最新版 | AISS Backend | クラウドTTS (ElevenLabs/Fish Audio) | 対象外 | 未確認 (公開情報なし) | 公開設定項目にbase URL指定なし。実ファイル未入手のため方式Aは保留。 |
| **方式D 読み上げツール** | **暫定採用** | 仕様書準拠設計 (自作) | Python / .NET / Node 等 | なし (外部監視プロセス) | 日本語音声出力 | Stable | `latest_response.ini` を監視し、AivisSpeech等へテキスト送出（形式・出力先は実機で確認）。 |
| **XTTS v2** | 採用見送り | 最新版 (Coqui CPML) | Python / PyTorch | なし | 日本語品質に難あり | 不安定 (CPU極低速) | AMD GPU未対応、CPU推論がリアルタイム未満。ライセンス非商用。<br>出典: [HuggingFace Coqui XTTS-v2](https://huggingface.co/coqui/XTTS-v2) |
| **AivisSpeech Engine** | **第一候補** | 最新版 (LGPL-3.0) | ONNX Runtime (CPU/DirectML) | なし | 日本語ネイティブ | Stable | 高品質、VOICEVOX互換API、CPU最適化。モデル規約はモデルごとに確認必要。<br>出典: [GitHub AivisSpeech-Engine](https://github.com/Aivis-Project/AivisSpeech-Engine) |
| **VOICEVOX Engine** | 第二候補 (比較) | 最新版 (LGPL-3.0) | DirectML / CPU | なし | 日本語ネイティブ | Stable | DirectML/CPU対応。キャラごとのクレジット表記義務あり。<br>出典: [GitHub voicevox_engine](https://github.com/VOICEVOX/voicevox_engine) |
| **fish-speech (OSS)** | 採用見送り | 最新版 (OpenAudio) | Python / WSL2 (Linux環境) | なし | 日本語対応 | 不安定 (Windows環境) | Windowsネイティブ非推奨、CUDA中心（AMD不可）。重み非商用。<br>出典: [GitHub fish-speech](https://github.com/fishaudio/fish-speech) |

---

## 3. 候補MOD詳細監査（出典明記）

### 3.1 SFSE (Starfield Script Extender)
- **最新版**: 0.2.21 (確認日: 2026-10-03)
- **対応ゲームバージョン**: 1.16.244
- **SFSE DLL**: 実行ファイル本体 (`sfse_loader.exe`) およびコアDLL (`sfse_1_16_244.dll`)
- **出典**: [sfse.silverlock.org](https://sfse.silverlock.org/)
- **Permissions**: オープンソース / クレジット表記
- **既知の不具合**: ゲーム本体のバージョンと不一致の場合に起動不可。

### 3.2 Address Library for SFSE Plugins
- **最新版**: v16 (Nexus ID: 3256, 作者: meh321, 確認日: 2026-10-03)
- **対応ゲームバージョン**: 1.16.244
- **SFSE DLL**: DLLなし（データベース `.bin` ファイルを `<Starfield>\Data\SFSE\Plugins\` に配置）
- **出典**: [Nexus Mods ID: 3256](https://www.nexusmods.com/starfield/mods/3256)
- **Permissions**: フリー利用、再配布条件遵守

### 3.3 Cassiopeia Papyrus Extender
- **最新版**: Nexus ID: 10896 (確認日: 2026-10-03)
- **対応バージョン**: 1.16.244 (Address Library 経由で動作)
- **SFSE DLL**: あり (`<Starfield>\Data\SFSE\Plugins\Cassiopeia.dll`)
- **必須依存**: SFSE, Address Library
- **出典**: [Nexus Mods ID: 10896](https://www.nexusmods.com/starfield/mods/10896)
- **機能**: 約430のネイティブ関数と60以上のイベントを追加。AISS、Real Fuel の必須前提。

### 3.4 Longer Names v2 (Outpost Ship Item)
- **最新版**: Nexus ID: 5046 (確認日: 2026-10-03)
- **SFSE DLL**: あり (または ASI)
- **必須依存**: SFSE
- **出典**: [Nexus Mods ID: 5046](https://www.nexusmods.com/starfield/mods/5046)
- **機能**: 名前の最大長を14文字から最大255文字へ拡張。INI設定ファイル付属。

### 3.5 AISS - AI Settled Systems
- **最新版**: Nexus ID: 17392 (作者: X2357, 確認日: 2026-10-03)
- **対応バージョン**: 1.16.244
- **必須依存**: SFSE, Address Library, Cassiopeia Papyrus Extender, Longer Names v2, LM Studio
- **外部プロセス**: `AISS_Backend.exe`（常駐してLM Studioおよびゲームと通信）
- **出典**: [Nexus Mods ID: 17392](https://www.nexusmods.com/starfield/mods/17392)
- **Permissions**: 個人利用フリー、改変・無断再配布禁止

### 3.6 Absolute HOTAS
- **最新版**: Nexus ID: 16668 (確認日: 2026-10-03)
- **SFSE DLL**: あり (`<Starfield>\Data\SFSE\Plugins\AbsoluteHOTAS.dll`)
- **必須依存**: SFSE, Address Library
- **出典**: [Nexus Mods ID: 16668](https://www.nexusmods.com/starfield/mods/16668)
- **機能**: X52 HOTAS等の入力をゲーム内フライトモデルへダイレクトバインド。ゲーム内UIウィザード（`Ctrl+Alt+B`）でキャリブレーション可能。

### 3.7 Civil NPCs
- **最新版**: Nexus ID: 17292 (確認日: 2026-10-03)
- **SFSE DLL**: なし (ESMのみ)
- **必須依存**: なし
- **出典**: [Nexus Mods ID: 17292](https://www.nexusmods.com/starfield/mods/17292)
- **機能**: NPCの視線ロック距離を30m→2.5mに短縮、挨拶間隔を15秒→5分に延長。GMST 8項目のみの軽量変更でスクリプトなし。

### 3.8 Ship Crew Assignments
- **最新版**: Nexus ID: 12744 (作者: LarannKiar, 確認日: 2026-10-03)
- **Bethesda Creations版**: あり (PC & Xbox)
- **SFSE DLL**: なし（コア機能はESM/Papyrusスクリプト）
- **出典**: [Nexus Mods ID: 12744](https://www.nexusmods.com/starfield/mods/12744)
- **機能**: 船内に不可視のアニメーションマーカーを配置し、クルーを特定位置・シフトに割り当て。

### 3.9 Real Fuel - Immersive Exploration
- **最新版**: v2.01 (2026-08-30更新, Nexus ID: 13306, 確認日: 2026-10-03)
- **Bethesda Creations版**: あり
- **必須依存**: Cassiopeia Papyrus Extender
- **日本語化**: **既存パッチあり (v2.01対応, xTranslator形式)**
- **出典**: [Nexus Mods ID: 13306](https://www.nexusmods.com/starfield/mods/13306)
- **機能**: 恒星間ジャンプ時の He-3 燃料消費、補給ステーションでの給油。

### 3.10 Grav Lanes
- **最新版**: Nexus ID: 16438 (作者: slamanna, 確認日: 2026-10-03)
- **Bethesda Creations版**: あり
- **SFSE DLL**: なし (単一Papyrusスクリプト)
- **出典**: [Nexus Mods ID: 16438](https://www.nexusmods.com/starfield/mods/16438)
- **機能**: ジャンプ到着点を恒星付近に変更し、ジャンプ中に船内を歩けるようにする。
- **互換性（作者明記）**:
  - 作者は **True Seamless Grav Jumps との併用を推奨（Recommended）** として挙げている。
  - 作者が非互換（Incompatible）として挙げているのは **Immersive Grav Jumps** である。
  - また、両者の併用を前提とした MOD（例: Nexus Mods ID: 17417 "Alien Juggernaut Jump Sound Replacer"）が存在する。
  - **実機での動作・視覚演出の調和は Phase 3 で検証**する。

### 3.11 True Seamless Grav Jumps (SFSE)
- **最新版**: Nexus ID: 17159 (作者: 0xBobby, 確認日: 2026-10-03)
- **SFSE DLL**: あり (`<Starfield>\Data\SFSE\Plugins\TrueSeamlessGravJumps.dll`)
- **必須依存**: SFSE, Address Library
- **出典**: [Nexus Mods ID: 17159](https://www.nexusmods.com/starfield/mods/17159)
- **機能**: コックピット視点を維持したままロード画面なしでGrav Jumpを完了。

### 3.12 Seamless Loading Screens
- **最新版**: Nexus ID: 18239 (確認日: 2026-10-03)
- **SFSE DLL**: あり (`<Starfield>\Data\SFSE\Plugins\LastFrameTransitionObserver.dll`)
- **必須依存**: SFSE, Address Library, **ReShade 6.8.0以上 (DX12 + Add-on support有効版)**
  - ReShade アドオンファイル: `<Starfield>\LastFrameTransition.addon64`
- **出典**: [Nexus Mods ID: 18239](https://www.nexusmods.com/starfield/mods/18239)
- **機能**: ドア・エレベーター等の暗転をフレームバッファ保持でマスク。

### 3.13 Seamless Neon
- **最新版**: Nexus ID: 17340 (確認日: 2026-10-03)
- **SFSE DLL**: なし (マスターESM / Worldspace改変)
- **出典**: [Nexus Mods ID: 17340](https://www.nexusmods.com/starfield/mods/17340)
- **要件（作者明記）**: **New Game または NG+ (Unity jump) が必須**。
  - 作者は、途中導入も技術的には可能だが一部のクエストが壊れると警告し、セーブのバックアップを推奨している。
- **必須依存（作者明記）**: Starfield Free Lanes update plugin（SFBGS00D.esm）。2026年4月以降のゲームバージョンが必要。
- **非互換（作者明記）**: Seamless City Interiors、Neon Core Disguised Seamless Project、Neon Core Apartment、Kansha - Neon Apartment、The Dark Side of Neon - An Ebbside Overhaul、その他大型のNeon改変MOD。
- **互換パッチ（作者提供）**: Terran Armada DLC、Trackers Alliance ほか。
- 〔2026-10-03 Claudeレビューで修正: 旧記載の「Neon Expanded等」は作者の非互換リストに見当たらないため削除〕

### 3.14 Spaceships Plus
- **最新版**: Nexus ID: 17034 (作者: Flashy(JoeR), 確認日: 2026-10-03)
- **SFSE DLL**: なし (ESM / スクリプト)
- **出典**: [Nexus Mods ID: 17034](https://www.nexusmods.com/starfield/mods/17034)
- **機能**: 燃料スクープ、EVA修理、船体減圧/無重力、サブシステム手動修理、離陸許可申請。ゲーム内設定で機能のON/OFFが可能。
- **Real Fuelとの関係**: コミュニティおよび作者説明において「works with or without Real Fuel（Real Fuel の有無にかかわらず動作可能）」と記載されている。
- **導入フェーズに関する意見**:
  - 船内生活・サバイバル・クルー連携に直結しているため、**Phase 2（Ship Life）の直後、または Phase 2 の検証項目として組み込むのが最適**と判断する。

### 3.15 Seamless Planet Takeoffs (SFSE)
- **最新版**: Nexus ID: 17719 (作者: 0xBobby, 確認日: 2026-10-03)
- **ステータス**: Beta
- **SFSE DLL**: あり
- **必須依存**: SFSE, Address Library
- **出典**: [Nexus Mods ID: 17719](https://www.nexusmods.com/starfield/mods/17719)
- **方針**: 仕様書通り、Phase 4 (Experimental) で最後に単体検証を行う。

---

## 4. LLM調査結果

### 4.1 Gemma 4 12B (QAT版) GGUF
- **入手先**: Hugging Face (`unsloth/gemma-4-12B-it-qat-GGUF` 等)
- **出典**: [Hugging Face: unsloth/gemma-4-12B-it-qat-GGUF](https://huggingface.co/unsloth/gemma-4-12B-it-qat-GGUF) (確認日: 2026-10-03)
- **量子化形式**: Q4_K_M (QAT最適化)
- **VRAM使用目安 (出典に基づく数値)**:
  - Unsloth公式ドキュメントにおける4-bit量子化モデルの実行メモリ目安: **約 8 GB**（固定の重みファイルサイズ約 7.5〜8.0 GB ＋ 基本バッファ）。
  - 会話のコンテキスト長（Context Size）を拡張するにつれて KV キャッシュメモリが比例して増加する。
- **ハードウェア適合性**:
  - RX 9070 (VRAM 16GB) において、Starfield (FHD想定: 6〜7GB) と同時に起動した場合、コンテキスト長を適切に制御（4K〜8K目安）することで、合計 15GB 前後に収まる見込み。
  - LM Studio (v0.4.25) の Vulkan / ROCm バックエンドによる 100% GPU オフロードを想定。

### 4.2 日本語特化系12B級モデルの現状
- **Sarashina2-13B (SB Intuitions)**:
  - ライセンス: MIT
  - 出典: [Hugging Face: sbintuitions/sarashina2-13b](https://huggingface.co/sbintuitions/sarashina2-13b)
  - **ベース（事前学習）モデルであり、指示追従の調整はされていない**（モデルカードに明記）。そのままではチャット・ロールプレイに使えない。比較対象にする場合は、指示調整済みの派生モデル（ファインチューン版）を別途調査する。
  - 〔2026-10-03 Claudeレビューで修正: 旧記載の「ロールプレイ適性あり」は誤り〕
- **LLM-jp-3-13B-instruct (国立情報学研究所)**:
  - ライセンス: Apache-2.0
  - 出典: [Hugging Face: llm-jp/llm-jp-3-13b-instruct](https://huggingface.co/llm-jp/llm-jp-3-13b-instruct)
  - 特徴: 指示追従性に優れる。
- **Swallow (東工大等)** / **ELYZA**: 12B級の密な現行モデルは提供されていない（8Bまたは70Bクラスが中心）。
- **結論**: 標準モデルとして決定されている **Gemma 4 12B (QAT版)** を第1選択とし、比較テスト対象としては指示調整済みの **LLM-jp-3-13B-instruct** を第一候補とする。Sarashina2系は指示調整版が見つかった場合のみ比較する。
- **注意**: Gemma 4 12B はローカル未ダウンロードのため、Phase 1 で入手が必要。

---

## 6. 追加MOD監査（Phase 1 Extras: 光る・実績解除・家具）

- 調査日: 2026-10-04
- 調査対象: `docs/agy/phase1-extras.md` 作業B に基づく追加候補MOD

### 6.1 Shades Glowy Stuff (光るMOD)
- **最新版**: Nexus ID: 11818 (作者: ShadeComplete / TheShade)
- **URL**: `https://www.nexusmods.com/starfield/mods/11818`
- **ゲームバージョン互換性**: 1.16.244 対応済 (Stable)
- **必須依存**: なし (SFSE 不要、バニラ・Creations 対応)
- **特徴・仕組み**:
  - 未読スキルブック、マガジン、弾薬、回復アイテム、収集素材、コンテナ等に一時的なシェーダーハイライト（パルス発光）を付与するQoL MOD。
  - ハンドスキャナーを開かなくてもアイテムの視認性が向上。
  - ゲーム内アセットやフォームレコードを直接改変せず、近接オブジェクトに動的シェーダー効果を付与する非破壊設計のため、他MODとの競合が極めて起きにくい。
- **Terran Armada DLC 関連**:
  - 指示書にあった「Shades Glowy Stuff Terran Armada Fix」（Nexus 17615）は、Terran Armada DLC (ESM) が必須前提。
  - ローカルの Starfield Data フォルダを点検した結果、Terran Armada の ESM は未所持であることを確認済み。
  - したがって、通常版 `Shades Glowy Stuff` のみを導入対象とし、Fix版は除外する。
  - **〔2026-10-09 訂正〕ユーザーは Terran Armada を所持している**（ユーザー確認）。Data の `SFBGS050.esm` / `BlueprintShips-SFBGS050.esm` が該当すると見られる。上記の「未所持」判定は誤り。Fix版（v1.0.2）は Phase 1 仕上げで導入を検討する（`docs/DOWNLOAD_LIST.md`）
- **日本語化**: 設定メニューや説明文にテキストがある場合、xTranslator で翻訳対応。

### 6.2 Baka Achievement Enabler (SFSE) (実績解除MOD)
- **最新版**: Nexus ID: 658 (作者: shad0wshayd3 / shademe, バージョン: 7.0.0)
- **URL**: `https://www.nexusmods.com/starfield/mods/658`
- **ゲームバージョン互換性**: **1.16.244 正式対応済** (Stable)
  - ※Nexus Posts タブにおける作者（shad0wshayd3）の固定投稿（Pinned Post）にて、「バージョン 7.0.0 はゲームバージョン 1.16.236、1.16.242、1.16.244 をサポートしています」と明記されていることを確認済み。
- **必須依存**: SFSE (0.2.21), Address Library for SFSE Plugins (v16, All in one)
- **特徴・仕組み**:
  - MODやコンソールコマンド使用時でも、Steam 実績（Achievements）の解除を有効に保つ SFSE DLL プラグイン。
  - 初回コンソール起動時の実績無効化警告メッセージを非表示化し、セーブデータへの「Modded」フラグ付与をブロックする。
  - 古い ASI Loader 版（Nexus 252「Achievement Enabler」、2023年）とは異なり、最新の SFSE / Address Library ネイティブで動作し、安定性が高い。
- **注意点**:
  - 導入以降のセーブデータを保護するものであり、既に「Modded」フラグが付与されてしまった既存セーブデータを遡及してクリーンに戻す機能はない。
- **日本語化**: 不要（DLL によるバイナリフックのため、ゲーム内文字列なし）。

### 6.3 Furnish Your Fleet (家具MOD - 船内特化)
- **最新版**: Nexus ID: 12202 (作者: Gothik17)
- **URL**: `https://www.nexusmods.com/starfield/mods/12202`
- **ゲームバージョン互換性**: 1.16.244 対応済 (Creation Kit 製)
- **必須依存**: なし
- **特徴・仕組み**:
  - 船内居住区（Hab）の内装カスタマイズに特化した家具拡張MOD。
  - 各造船メーカー（Nova Galactic, Deimos, Stroud-Eklund, HopeTech, Taiyo）の意匠に合わせた二段ベッド、ベッド、バスルーム/シャワー、ギャレー（調理場）、カーブ壁対応家具、間接照明付き家具などを多数追加。
  - クルーが実際にベッドで就寝したり、ギャレーで料理を行える実用的なアニメーションマーカーを内包。
- **日本語化**: 要（家具名・装飾名・ビルドメニュー名の翻訳）。

### 6.4 Better Living - Outpost Decor (家具MOD - 拠点/生活装飾)
- **最新版**: Nexus ID: 10290 (作者: StackGX)
- **URL**: `https://www.nexusmods.com/starfield/mods/10290`
- **ゲームバージョン互換性**: 1.16.244 対応済 (Creation Kit 製)
- **必須依存**: なし
- **特徴・仕組み**:
  - アウトポストおよびプレイヤーホーム向けの内装・家具・生活装飾を大幅に追加する総合パック。
  - キッチンユニット、観葉植物、医療器具、ポスター、機能性調理ストーブ、貿易公社キオスク、ミッションボード、音楽再生可能なラジカセ、大容量コンテナ等を追加。
- **日本語化**: 要（家具名・装飾名・アイテム名・ビルドメニュー名の翻訳）。

### 6.5 Betamax's Functional Decor (家具MOD - 機能性装飾)
- **最新版**: Nexus ID: 10789 (作者: Betamax76)
- **URL**: `https://www.nexusmods.com/starfield/mods/10789`
- **ゲームバージョン互換性**: 1.16.244 対応済 (Creation Kit 製)
- **必須依存**: なし
- **特徴・仕組み**:
  - 船内およびアウトポストに配置可能な機能的装飾アイテム（洗面台、TerraBrew自動販売機、オートドック、照明、生活家具等、300点以上）を追加。
  - メニューの重複を避け、整理されたカテゴリ構成で軽量・安全に動作する。
- **日本語化**: 要（自販機・家具名・メニュー名の翻訳）。
