# Starfield AI ワンクリック統合ランチャー

Starfield Space Life JP プロジェクトにおける Phase 1 統合ランチャーです。
デスクトップのショートカットまたは `Start-StarfieldAI.bat` をダブルクリックするだけで、VRAM 解放の確認から LM Studio・AISS Backend・SFSE（Starfield）の起動までを全自動で実行します。

---

## 1. 構成ファイル

- `Start-StarfieldAI.bat`: ユーザー実行用バッチファイル（PowerShell の実行ポリシーを Bypass して起動）。
- `Start-StarfieldAI.ps1`: ランチャー本体（PowerShell スクリプト）。
- `launcher.config.example.json`: 設定ファイルのテンプレート（Git 管理）。
- `launcher.config.json`: 実環境用設定ファイル（ローカル固有、`.gitignore` で除外）。
- `README.md`: 本書。

---

## 2. 処理フロー

1. **VRAM 節約チェック**:
   - 設定ファイルで指定された常駐アプリ（`WardogsClient`、`msedge`、`Discord` 等）が起動している場合、一覧を表示して「閉じますか？ (Y/N)」と確認します。
   - Y を選択すると安全な通常終了（ウィンドウクローズ）を試みます（強制終了は行いません）。
2. **LM Studio サーバーの確認・起動**:
   - `http://127.0.0.1:1234` のローカルサーバーが停止している場合、自動で `lms server start` を実行します。
3. **モデル読み込み確認と API 疎通テスト**:
   - `gemma-4-12b-it-qat` がロードされているか確認し、未ロードの場合は自動でロードします（コンテキスト長 16384、Q8_0 KV キャッシュ、Flash Attention、思考オフが自動適用されます）。
   - 短いテストプロンプトを送信し、API が正常に応答するか検証します。
4. **AISS Backend の起動**:
   - MO2 のショートカット機構（`moshortcut://Starfield:AISS Backend`）を呼び出し、バックエンドを起動・常駐させます。
5. **SFSE（Starfield）の起動**:
   - MO2 のショートカット機構（`moshortcut://Starfield:SFSE`）を呼び出し、MOD が有効化された状態で Starfield を起動します。

---

## 3. 設定ファイル（launcher.config.json）の仕様

```json
{
  "mo2ExecutablePath": "C:\\Modding\\MO2\\ModOrganizer.exe",
  "mo2InstanceName": "Starfield",
  "aissExecutableTitle": "AISS Backend",
  "sfseExecutableTitle": "SFSE",
  "openMo2Only": false,
  "vramHeavyProcesses": [
    "WardogsClient-Win64-Shipping",
    "msedge",
    "Discord"
  ],
  "lmStudio": {
    "serverUrl": "http://127.0.0.1:1234",
    "modelIdentifier": "gemma-4-12b-it-qat",
    "testTimeoutSeconds": 15
  }
}
```

### 設定項目の説明
- `mo2ExecutablePath`: MO2 の実行ファイル（`ModOrganizer.exe`）の絶対パス。
- `mo2InstanceName`: MO2 のインスタンス名（通常は `"Starfield"`）。
- `aissExecutableTitle`: MO2 の Executable 一覧に登録された AISS Backend のタイトル名。
- `sfseExecutableTitle`: MO2 の Executable 一覧に登録された SFSE のタイトル名。
- `openMo2Only`:
  - `false`（既定）: AISS Backend および SFSE を完全自動起動します。
  - `true`（予備手段）: MO2 の GUI を開くだけにし、ゲーム起動を手動で行う安全モードです。
- `vramHeavyProcesses`: 起動時に終了確認を行うプロセス名の配列。
- `lmStudio.serverUrl`: LM Studio ローカルサーバーの URL。
- `lmStudio.modelIdentifier`: ロード対象のモデル識別子。

---

## 4. デスクトップショートカットの作成方法

ランチャーから自動作成されるショートカット、または以下の手順でデスクトップに配置可能です：
- リンク先: `<リポジトリパス>\tools\launcher\Start-StarfieldAI.bat`
- アイコンの変更: `<MO2インストール先>\ModOrganizer.exe` を指定
- ショートカット名: `Starfield（MOD）`
