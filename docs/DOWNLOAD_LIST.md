# ダウンロード一覧（Phase 2 以降）

Phase 1 のMODは `D:\StarfieldMODs\Phase1` に配置済み。ここでは、それ以降のフェーズで必要になるものをまとめる。

## ダウンロードの方法

- Phase 1 で MO2 の Starfield 用インスタンスを作り、nxm リンクの関連付けを有効にした後は、Nexus の **「Mod Manager Download」** ボタンを押すだけで MO2 に直接ダウンロードされる。フォルダの管理は不要
- MO2 に入れたアーカイブは、該当フェーズまで**インストールしない**（ダウンロードだけしておく）
- Nexus のダウンロードはユーザー本人のログインが必要。agy・Claude は代行しない
- バージョンは、ダウンロード時点の最新版でよい。導入時に agy が対応状況を確認する

## Phase 1 仕上げ

2026-10-09 の事前監査（`docs/MOD_COMPATIBILITY.md` 7章）に基づくダウンロード一覧。ゲーム本体 1.16.244.0 / SFSE 0.2.21 環境を対象とする。

| グループ | MOD | 入手先 | ダウンロード対象ファイル | 区分 | 備考 |
|---|---|---|---|---|---|
| 1. 安定化 | **Starfield Engine Fixes - SFSE** | [Nexus 10457](https://www.nexusmods.com/starfield/mods/10457) | `Starfield Engine Fixes - Game version 1.16.244` (v21.2) | Main | SFSE 0.2.21 必須。INI 調整で任意機能は必要最小限に運用 |
| 1. 安定化 | **Orbit Traffic Fix** | [Nexus 18325](https://www.nexusmods.com/starfield/mods/18325) | `OrbitTrafficFix 1.0.0` または `OrbitTrafficFix 1.0.0 ESM` | Main | MO2 での競合検知が容易なルーズ版（`OrbitTrafficFix 1.0.0`）を推奨（どちらか片方のみ） |
| 2. 表示/QoL | **StarUI HUD** | [Nexus 3444](https://www.nexusmods.com/starfield/mods/3444) | `StarUI HUD` (v1.4) | Main | ルーズ UI ファイル。日本語ソート用 swf 同梱 |
| 2. 表示/QoL | **Decal Fix** | [Nexus 17576](https://www.nexusmods.com/starfield/mods/17576) | `DecalFix-PackagedVersion-esm` (v2) または `DecalFix-LooseFiles` (v2.1) | Main / Optional | BA2 パッケージ版（Main）またはルーズ版（Optional）のどちらか片方 |
| 2. 表示/QoL | **Neutral LUTs - No Color Filters** | [Nexus 323](https://www.nexusmods.com/starfield/mods/323) | `Neutral LUTs - No Color Filters v1-5` (v1.5) | Main | ルーズ DDS テクスチャ。他 LUT MOD とは併用不可 |
| 2. 表示/QoL | **Easy Digipick (Lockpick)** | [Nexus 451](https://www.nexusmods.com/starfield/mods/451) | `Easy Digipick` (v1.4) | Main | `Easy Digipick.esm`（または好みに応じて Immersive Digipick） |
| 2. 表示/QoL | **Shades Glowy Stuff Terran Armada Fix** | [Nexus 17615](https://www.nexusmods.com/starfield/mods/17615) | Main 版（v1.0.2。Legendary/Exotic のみ光る Optional 版とは片方のみ） | Main | 導入済み Shades Glowy Stuff 1.5.2 用の修正。Anchorpoint（Terran Armada）で光らない問題、Astra・X-Tech・宇宙服等の発光を修正。ESM 追加と `_sgb_objectgloweffectscript.pex` の上書きあり。日本語化MODとの上書き関係は導入時に確認 |
| 3. 武器 | ~~Weapon Mod Fixes - WMF~~ | [Nexus 9091](https://www.nexusmods.com/starfield/mods/9091) | （ダウンロード保留） | - | **採用見送り**: Nexus 最新版が pre-Free Lanes（v1.10）。1.16.244 未対応のため保留 |
| 3. 武器 | **Weapon Quality Diversity** | [Nexus 17044](https://www.nexusmods.com/starfield/mods/17044) | `Weapon Quality Diversity` (v1.0) | Main | **採用**: `Shattered Space` と `Terran Armada` の両DLCが必須前提。ユーザーは両方所持（2026-10-09 確認） |
| 2. 表示/QoL（マップ） | **Slightly Better Map Icons** | [Nexus 4813](https://www.nexusmods.com/starfield/mods/4813) | `XVII` (v17) | Main | **採用**: ルーズ UI ファイル（`mapicons.gfx`/`swf`）。StarUI HUD 併用可、テキストなし、セーブ汚染なし。※City Interior Map Markers（12719）は先祖返り・クエスト破壊リスクで見送り、Remove Overlapping Markers（15633）は不可逆なセーブ改変のため不採用 |

## Phase 2 — Ship Life

| MOD | 入手先 | 備考 |
|---|---|---|
| Civil NPCs | [Nexus 17292](https://www.nexusmods.com/starfield/mods/17292) | |
| Ship Crew Assignments | [Nexus 12744](https://www.nexusmods.com/starfield/mods/12744) | |
| Real Fuel | [Nexus 13306](https://www.nexusmods.com/starfield/mods/13306) | Cassiopeia が前提（Phase 1 で導入済み） |
| Real Fuel 日本語化パッチ | 2game.info（docs/MOD_JAPANESE.md 参照） | Real Fuel と同じバージョン対応のもの |

## Phase 2.5 — Ship Systems

| MOD | 入手先 | 備考 |
|---|---|---|
| Spaceships Plus | [Nexus 17034](https://www.nexusmods.com/starfield/mods/17034) | |

## Phase 3 — Seamless Travel

| MOD / ツール | 入手先 | 備考 |
|---|---|---|
| Grav Lanes | [Nexus 16438](https://www.nexusmods.com/starfield/mods/16438) | |
| True Seamless Grav Jumps SFSE | [Nexus 17159](https://www.nexusmods.com/starfield/mods/17159) | |
| Seamless Loading Screens | [Nexus 18239](https://www.nexusmods.com/starfield/mods/18239) | ReShade が前提 |
| ReShade 6.8.0 以上（アドオン対応版） | [reshade.me](https://reshade.me/) | 「with full add-on support」版。ゲームフォルダに直接導入するため MO2 では管理しない |
| Seamless Neon | [Nexus 17340](https://www.nexusmods.com/starfield/mods/17340) | 新規ゲームまたは NG+ 前提 |

## Phase 4 — Experimental Takeoff

| MOD | 入手先 | 備考 |
|---|---|---|
| Seamless Planet Takeoffs SFSE | [Nexus 17719](https://www.nexusmods.com/starfield/mods/17719) | Beta |

## Phase 1.5 — AI Voice（MOD ではない）

| ツール | 入手先 | 備考 |
|---|---|---|
| AivisSpeech Engine | [GitHub Aivis-Project/AivisSpeech-Engine](https://github.com/Aivis-Project/AivisSpeech-Engine) | Nexus ではないため、Phase 1.5 で agy にダウンロードを許可してよい。音声モデルはモデルごとに利用規約を確認 |
