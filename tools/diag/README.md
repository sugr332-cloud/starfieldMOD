# AISS 稼働状態・会話診断ツール (Check-AISS)

Starfield の AI 会話 MOD（AISS - AI Settled Systems）が正常に通信できているか、返答が遅れている原因が何かをワンクリックで即座に確認・診断するためのツールです。

---

## 1. 使い方

### 方法 A: デスクトップショートカット（推奨）
- デスクトップの「**AISS 状態確認**」ショートカットをダブルクリックします。

### 方法 B: バッチファイルから起動
- `tools/diag/Check-AISS.bat` をダブルクリックします。

### 方法 C: PowerShell から起動
```powershell
powershell -ExecutionPolicy Bypass -File tools/diag/Check-AISS.ps1
```

---

## 2. 診断項目と見方

| 項目 | 正常な表示 (OK) | 異常時の表示 (NG) と対処 |
|---|---|---|
| **1. LM Studio サーバー** | `[OK] LM Studio サーバー稼働中`<br>（モデル名が表示されます） | `[NG] LM Studio サーバーに接続できません`<br>→ LM Studio を起動し、Developer タブから「Start Server」を押してください。 |
| **2. AISS Backend プロセス** | `[OK] AISS Backend 稼働中 (PID: xxx)` | `[NG] AISS Backend が停止しています`<br>→ デスクトップの「Starfield（MOD）」から起動するか、`AISS_Backend.exe` を直接起動してください。 |
| **3. 会話状態と判定** | `【返事完了】（直近の処理時間: 約 x 秒）` | `【返事待ち（AI生成中）】（送信から x 秒経過）`<br>→ リクエストが LM Studio で生成処理中であることを示します。30 秒以上かかる場合はモデルの負荷やログを確認してください。 |
| **4. Backend 最新ログ** | 直近の生成時間（`llm=...ms`）やログ | `error` や `fail` が含まれる行が赤色で強調表示されます。 |

---

## 3. ファイル構成

- `Check-AISS.ps1`: 診断処理の本体スクリプト（PowerShell）
- `Check-AISS.bat`: ダブルクリック用の起動バッチ（UTF-8 出力・ウィンドウ保持対応）
- `README.md`: 本説明ドキュメント
