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

---

## 計画へのレビュー（Claude、2026-10-03）

agy が提示した作業計画（手順1の結果と手順3〜7の計画）は、以下の修正を加えたうえで承認する。修正を反映して手順3〜6を進め、手順7の前（ゲーム起動前）で `phase1-core-02.md` を push して止まること。

### 修正1: LM Studio のコンテキスト長（重要）

- AISS が1回の会話で約11,000〜13,000トークンを送ることを確認してくれたのは重要な発見。ただし 32K（32768）でいきなり始めない
- **16384 から開始する**（AISS 付属ドキュメントの最低値）
- KV キャッシュの量子化（Q8_0 等）が LM Studio + AMD GPU で使えるか確認し、使えるなら有効にする
- 16384 で読み込んだ状態の VRAM 使用量を記録する（Starfield 未起動の状態で）
- 32768 での VRAM 使用量の見積もり（`lms load --estimate-only` 等）も記録する
- 32K を常用するかは、Phase 1 の実機テストで Starfield と同時起動したときの VRAM・フレームレートを見て決める（仕様書5.2章）
- LM Studio でプロンプトキャッシュ（同じ前半部分の再利用）が有効かどうかも記録する。AISS は毎回長い文脈を送るため、返答開始までの時間に効く

### 修正2: MO2 プロファイル名

- プロファイル名は仕様書7章どおり **「Stable」** にする（「Phase1-Core」にしない）
- インスタンスは、既存の Mount & Blade II と同じ方式（グローバルインスタンス）で「Starfield」という名前で作る
- プロファイル別のセーブとプロファイル別の INI を有効にする
- nxm リンクの関連付けを Starfield インスタンスで有効にする（手順4の最後の項目）

### 修正3: バックアップ

- 「有無を確認」ではなく、実際にコピーしてバックアップを取る
- 保存先: リポジトリ・ゲームフォルダ・MO2 フォルダのいずれでもない場所（例: `D:\StarfieldMODs\Backup\2026-10-03\`）
- 対象: セーブデータのフォルダ、<Documents>\My Games\Starfield の INI ファイル、<Starfield> 直下のファイル一覧
- セーブデータが存在しない場合は「なし」と記録する

### 修正4: AISS の日本語指示

- 「適用確認」ではなく、仕様書5章「会話品質を上げるプロンプト調整」に沿った日本語指示を実際に追加する
- 追加先（人格・ワールドプロファイル・システムプロンプト等）と、追加した全文を configs/AISS/settings.md に記録する
- 内容の最低限: 日本語のみで返答する／AIアシスタントのように振る舞わない／ゲーム世界の外の話をしない／返答は短めにする（目安を書く）

### 修正5: AISS_Backend.exe のヘルスチェック

- `--health-check` は、AISS 付属ドキュメントに記載がある場合のみ実行する。記載がなければ実行せず、その旨を記録する

### 修正6: latest_response.ini の出力先

- 付属ドキュメント上の出力先は `<Starfield>\Data\SFSE\AISS\responses\` だが、MO2 環境では overwrite フォルダに出ることがある。手順7でゲームを起動した後に、実際の出力先を確認して記録する（仕様書7.1章）

---

## phase1-core-02 へのレビュー（Claude、2026-10-03）

手順3〜6の結果を確認した。**手順7（ゲーム起動）を承認する。** 以下の追加作業を含めて手順7〜9を進め、完了したら `phase1-core-03.md` を push して止まること。

### 重要な発見（記録のみ）

- AISS の config.json に `tts.local`（`tts_url`、`body_style: openai / fish`）があることを確認してくれたのは重要。仕様書5.1の方式A が成立する可能性が高い。判定と実装は Phase 1.5 で行うので、Phase 1 では TTS は無効のまま触らないこと
- docs/TTS_AUDIT.md には、`tts.local` ブロックの項目名・取りうる値（body_style の選択肢）・付属ドキュメントの該当記述（OpenAI 互換ラッパー経由で XTTS-v2 を使える旨など）を、事実として追記すること。APIキー欄・値は書かない

### 追加1: VRAM の確認（重要。修正1で依頼した項目の残り）

Starfield 未起動で VRAM 使用量が約11.8GB と報告されている。FHD の Starfield（目安7〜9GB）を足すと16GB を超えるおそれがあるため、以下を確認・記録する。

1. LM Studio を終了した状態の VRAM 使用量（デスクトップ・常駐アプリ分）
2. gemma-4-12b-it-qat を 16384 で読み込んだときの VRAM 使用量（モデル本体と KV キャッシュの内訳がわかれば内訳も）
3. **KV キャッシュの量子化**（K と V を Q8_0 にする設定。LM Studio の読み込み設定、または lms load のオプション）と **Flash Attention** が、この環境（LM Studio 0.4.25 + RX 9070、Vulkan / ROCm）で使えるか。使える場合は有効にして、2 と同じ条件の VRAM 使用量を記録する
4. 3 で使えた設定の 32768 での見積もり
5. 手順7でゲームをメインメニューまで起動している間の VRAM 使用量（LM Studio を読み込んだまま）。メインメニュー時点の値なので参考値として記録する

これらの結果は configs/LMStudio/gemma-4-12b.md に記録する。KV キャッシュの量子化が使える場合は、それを Phase 1 の標準設定とする。

### 追加2: AISS の日本語指示ファイルの扱い

- 日本語指示を追記した `AISS\profiles\vanilla_starfield\system_preface.txt` は MOD 内のファイルで、MOD を更新すると上書きされる
- 追記前の元ファイルを、`D:\StarfieldMODs\Backup\2026-10-03\` に保存しているか確認する。していなければ、追記部分を取り除いた状態を復元できるよう、追記した内容と追記位置を記録する
- AISS に、MOD フォルダの外（MO2 の別MOD や overwrite、ユーザー設定フォルダ等）でプロファイル文を上書きできる仕組みがあるかを付属ドキュメントで確認する。あれば、そちらに移すことを提案として報告に書く（移すかは Claude が判断する）
- configs/AISS/settings.md に、追記先のパスと追記した全文を記録する

### 手順7の補足

- AISS_Backend.exe の起動方法（MO2 経由かどうか）は、ヘルスチェックで Install mode: mo2 が検出されたことを踏まえ、MO2 の実行ファイルから起動する
- メインメニュー表示後に終了したら、sfse.log と AISS のログ・出力フォルダの実際の場所（ゲームフォルダ / MO2 の overwrite）を記録する

---

## phase1-core-03 へのレビュー（Claude、2026-10-03）

完了報告を確認した。TTS の `tts.local` の確認、AISS のアドオン機能の発見、VRAM の実測はどれも重要な成果。以下の作業1〜6を行い、`phase1-core-04.md` を push して止まること。作業1〜6はすべて「止まらずに進めてよい」範囲とする（作業2のファイル復元を含む）。

### 作業1: 日本語指示をアドオン方式に移す（承認）

- 提案どおり、MO2 の別MOD「AISS - Japanese Language Addon」を作り、`AISS\addons\<pack_name>\profiles\vanilla_starfield\system_preface_append.txt` に日本語指示を入れる。MO2 の左ペインで AISS より下（優先度が高い側）に置く
- AISS 本体の `system_preface.txt` は、バックアップ（`AISS_original_system_preface.txt`）から元に戻す。元に戻した後、バックアップと内容が一致することを確認する
- AISS_Backend.exe を再起動し、アドオンが読み込まれたことをログまたはヘルスチェックで確認する
- configs/AISS/settings.md を、アドオン方式に合わせて書き直す（アドオンの構成と全文を記録。本体ファイルの直接編集はやめた旨も記録）

### 作業2: KV キャッシュ量子化を標準設定にする

- 16K・f16 でモデル本体＋コンテキストが 9.84GB、メインメニューの時点で VRAM が 15.34GiB（96%）。実際のプレイではこれより増えるため、余裕がない
- LM Studio で gemma-4-12b-it-qat の読み込み設定を、**K キャッシュ Q8_0・V キャッシュ Q8_0・Flash Attention オン・コンテキスト長 16384** にする。CLI で指定できなければ、LM Studio のモデル別の既定読み込み設定（GUI で保存される設定ファイル）で指定する
- その設定で読み込み直し、VRAM の内訳（モデル本体・コンテキスト）を記録する
- 読み込み後に簡単な日本語のテストプロンプトを送り、正常に応答することを確認する
- configs/LMStudio/gemma-4-12b.md を更新する（標準設定: Q8_0 KV キャッシュ＋Flash Attention、16K。32K は使わない）

### 作業3: デスクトップ常駐の VRAM（5.54GiB）の確認

- LM Studio 終了時点で 5.54GiB は多い。GPU メモリを使っているプロセス名と使用量の上位を一覧にする（プロセス名と数値のみ。ウィンドウタイトルや開いている内容は記録しない）
- ゲームプレイ時に閉じておくべきアプリがあれば、CONFIG_GUIDE.md の起動手順に「プレイ前に閉じるもの」として記録する

### 作業4: ModOrganizer.ini の steamAppID を空にした理由

- 報告に「1\steamAppID 空化」とあるが、指示にない変更。空にした理由を報告する
- 必要がない変更なら元の値に戻す。必要なら理由を CONFIG_GUIDE.md に記録する

### 作業5: SFSE のファイルサイズの食い違い

- `sfse_loader.exe` と `sfse_1_16_244.dll` のサイズが、報告02（68,600 / 116,216 bytes）と報告03（190,464 / 496,128 bytes）で違う
- 現在ゲームフォルダにあるファイルと、`D:\StarfieldMODs\Phase1` の SFSE アーカイブ内のファイルのハッシュ（SHA-256）を比較し、一致するか報告する。どちらかの報告の数値が誤記ならその旨を書く

### 作業6: ドキュメントの commit・push（承認）

- 作業1〜5を反映したうえで、以下を **phase1-core ブランチ**に commit・push する（main へのマージはしない。Claude が確認してマージする）
  - docs/INSTALL_GUIDE.md、docs/CONFIG_GUIDE.md、docs/TEST_PHASE1.md、docs/TTS_AUDIT.md
  - configs/LMStudio/gemma-4-12b.md、configs/AISS/settings.md
  - docs/agy/reports/phase1-core-04.md
- commit 前に、実際のユーザー名を含むパス・APIキーらしき文字列が含まれていないことを確認する
- CONFIG_GUIDE.md と TEST_PHASE1.md には、**ゲームは必ず MO2 の GUI から「SFSE」を実行して起動する**こと（sfse_loader.exe を直接起動すると MO2 の MOD が読み込まれない）を目立つ形で書く

### 次の段階（参考）

作業1〜6の後、ユーザーが docs/TEST_PHASE1.md に沿って実機テストを行う。MO2 の GUI から起動して、SFSE プラグインと AISS が実際に読み込まれるか、日本語会話ができるかを確認するのはその段階。
