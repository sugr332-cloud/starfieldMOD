# 指示書: Phase 1（Core）構築

- 作成: Claude（2026-10-03）
- 運用ルール: docs/agy/README.md に従うこと（止まる場面は3つだけ、報告はファイルで push）
- 正本の仕様: docs/MOD_SPEC.md（v0.6）。作業前に全文を読むこと
- 参照: docs/MOD_AUDIT.md、docs/MOD_COMPATIBILITY.md、docs/MOD_JAPANESE.md、docs/TTS_AUDIT.md

## これまでの状況（確認済み）

- Starfield: 1.16.244.0（インストール完了）
- LM Studio: gemma-4-12b-it-qat（unsloth/gemma-4-12B-it-qat-GGUF、量子化 UD-Q4_K_XL、6.72GB）ダウンロード済み。画像入力用の mmproj-F32.gguf は残すが使わない
- Phase 1 の MOD アーカイブ: `D:\StarfieldMODs\Phase1` に配置済み（ユーザー申告）
- 作業ブランチ: phase1-core（agy のローカルに作成済み）

## 0. リポジトリの準備

- main を pull し、phase1-core ブランチに main の最新を取り込む（この指示書と docs/agy/README.md を含む）
- 以後、報告ファイルは phase1-core ブランチに commit・push する

## 導入範囲

導入するのは仕様書7章で導入フェーズが Phase 1 のMODだけ:
SFSE、Address Library for SFSE Plugins、Cassiopeia Papyrus Extender、Longer Names v2、AISS、Absolute HOTAS

## 1. 前提の確認（止まらずに進めてよい）

- `D:\StarfieldMODs\Phase1` の6アーカイブのファイル名・バージョン・サイズを一覧にする
- SFSE がゲーム 1.16.244 に対応していることを確認する
- Address Library が 1.16.244 に対応していることを確認する
- アーカイブ内のファイルは、7-Zip 等で一覧・表示するか、リポジトリ・ゲームフォルダ・MO2 フォルダの外にある一時フォルダに展開して読む
- AISS 付属のドキュメント（LMSTUDIO_SETUP_GUIDE.txt 等）を読み、導入手順・AISS_Backend.exe の起動方法・MO2 での使い方について作者の指示を確認する
- 前提が満たされていなければ、報告して止まる（止まる場面3）

## 2. 作業計画の報告（ここで1回止まる）

手順1の結果と、手順3〜6の具体的な計画（バックアップの保存先、作成する MO2 インスタンスの場所、変更する INI と内容、ゲームフォルダ直下に置くファイル）を報告ファイル `phase1-core-01.md` に書いて push し、ユーザーの OK を待つ。

OK が出たら、手順3〜6は止まらずに続けてよい（計画どおりである限り）。計画と違うことが必要になったら、報告して止まる。

## 3. バックアップ

保存先はリポジトリの外。場所を報告に書く。
- セーブデータのフォルダ（<Documents>\My Games\Starfield\Saves）
- <Documents>\My Games\Starfield の INI ファイル（存在するもの）
- <Starfield> 直下のファイル一覧（SFSE 導入前の状態の記録）

## 4. MO2 の準備

- Starfield 用の新しいインスタンスを作成する。既存の Mount & Blade II 用インスタンスには触れない
- プロファイル「Stable」を作成し、プロファイル別のセーブとプロファイル別の INI を有効にする
- Starfield でルーズファイルを読み込むための INI 設定（StarfieldCustom.ini の [Archive] セクション等）が必要か確認し、必要なら MO2 のプロファイル別 INI 側で設定する
- MO2 の nxm リンクの関連付け（Nexus の「Mod Manager Download」ボタンで MO2 に直接ダウンロードできる設定）を Starfield インスタンスで有効にする。以後のフェーズのダウンロードを簡単にするため

## 5. MOD の導入

- SFSE: 作者の手順どおりに導入する。ゲームフォルダ直下に置いたファイルの一覧を記録する。sfse_loader.exe を MO2 の実行ファイルに登録する
- Address Library、Cassiopeia Papyrus Extender、Longer Names v2、AISS、Absolute HOTAS: MO2 経由で導入する
- MO2 の競合表示でファイルの上書きを確認する（仕様書8章のチェック手順1）
- プラグインの読み込み順を記録する

## 6. LM Studio と AISS の設定

- LM Studio: gemma-4-12b-it-qat を読み込み、GPU オフロード 100%、コンテキスト長 8192 から開始。画像入力（Vision）は使わない設定にする。ローカルサーバーを起動し、API のモデル識別子を確認する
- AISS の config.json:
  - provider を lmstudio、接続先を http://127.0.0.1:1234/v1、model を LM Studio のモデル識別子に設定する
  - TTS は無効にする
  - TTS 関連の項目の構造を確認し、TTS の送り先 URL（base URL / endpoint）を指定する項目があるか、xtts に関する項目があるかを記録する（値・APIキー欄は記録しない）
  - 日本語で返答させる指示を、仕様書5章「会話品質を上げるプロンプト調整」に沿って追加する
- AISS_Backend.exe の起動方法を作者の指示に沿って決め、記録する
- 起動順（LM Studio → AISS_Backend.exe → MO2 経由で sfse_loader.exe）を記録する

## 7. ゲーム起動（ここでもう1回止まる）

手順3〜6の結果を報告ファイル `phase1-core-02.md` に書いて push し、ユーザーの OK を待つ（止まる場面2）。OK が出たら:
- MO2 の Stable プロファイルから sfse_loader.exe でゲームを起動し、メインメニューが表示されたら終了する（新規ゲーム・ロードはしない）
- sfse.log で全 SFSE プラグインの読み込みとバージョン対応を確認する
- sfse.log と AISS のログ・出力ファイルが実際にどのフォルダに出力されたか（ゲームフォルダ / MO2 の overwrite）を記録する

## 8. ドキュメントの作成（止まらずに進めてよい。commit はまだしない）

- docs/INSTALL_GUIDE.md: 導入した MOD・バージョン・導入方法・ゲームフォルダ直下に置いたファイル・ロード順
- docs/CONFIG_GUIDE.md: MO2 インスタンスとプロファイルの設定、INI 設定、LM Studio の設定、AISS の設定（変更した項目と値のみ）、外部プロセスの起動順
- configs/LMStudio/gemma-4-12b.md: モデル名・取得元・量子化（UD-Q4_K_XL。仕様書の想定 Q4_K_M から変更した旨）・コンテキスト長・GPU オフロード
- configs/AISS/settings.md: AISS で変更した項目と値、追加した日本語指示の全文（config.json そのものは入れない）
- docs/TTS_AUDIT.md: 方式A の判定に必要な事実（送り先 URL の項目の有無、xtts 項目の有無）を追記。判定は書かない
- docs/TEST_PHASE1.md: 仕様書10章のテスト項目を、ユーザーが実機で記入するチェックリストにする。agy が確認済みの項目は結果を記入し、ユーザーが行う項目（新規ゲーム、既存セーブのロード、AISS との日本語会話、日本語 IME 入力、日本語表示、HOTAS 入力、VRAM・フレームレート計測、LLM の応答時間）は空欄にする。会話後に latest_response.ini の場所と中身の構造を記録する手順も含める

## 9. 完了報告

報告ファイル `phase1-core-03.md` に以下を書いて push し、止まる（状態: 完了）。
- 実施した作業と、変更・作成したファイルの一覧（リポジトリ内・外）
- バックアップの保存先
- sfse.log の結果
- AISS の TTS 送り先 URL 項目・xtts 項目の有無
- AISS のログ・出力ファイルの実際の出力先
- 問題・仕様との食い違い

手順8で作成したドキュメントの commit・push は、Claude の確認後に別途指示する。

---

これから何をするかを説明し、許可を得てから作業を開始すること。
