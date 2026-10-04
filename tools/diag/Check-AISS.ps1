# Check-AISS.ps1 - AISS 稼働状態・会話ログ即時診断ツール
# Starfield Space Life JP Project

[CmdletBinding()]
param()

$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "         Starfield AISS 稼働状態・会話診断ツール          " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "診断時刻: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor DarkGray
Write-Host ""

$mo2Mods = "$env:LOCALAPPDATA\ModOrganizer\Starfield\mods"
$aissRoot = Join-Path $mo2Mods "AISS - AI Settled Systems\AISS"
$sfseAiss = Join-Path $mo2Mods "AISS - AI Settled Systems\SFSE\AISS"

# ------------------------------------------------------------
# 1. LM Studio サーバー状態
# ------------------------------------------------------------
Write-Host "[1/4] LM Studio サーバー状態" -ForegroundColor Cyan
$serverUrl = "http://127.0.0.1:1234"
try {
    $modelsResp = Invoke-RestMethod -Uri "$serverUrl/v1/models" -Method Get -TimeoutSec 3 -ErrorAction Stop
    $modelIds = $modelsResp.data | ForEach-Object { $_.id }
    
    # ロード中モデル確認
    $loadedModel = $null
    try {
        $lmsPs = & lms ps 2>$null
        if ($lmsPs -match "gemma-4-12b-it-qat") {
            $loadedModel = "gemma-4-12b-it-qat"
        }
    } catch {
        # lms コマンドが無い場合は無視
    }

    if ($loadedModel) {
        Write-Host "  [OK] LM Studio サーバー稼働中" -ForegroundColor Green
        Write-Host "       ロード中モデル: $loadedModel" -ForegroundColor Green
    } else {
        Write-Host "  [OK] LM Studio サーバー稼働中" -ForegroundColor Green
        Write-Host "       モデル状態: 未ロード（※初回会話時に JIT で自動ロードされます）" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  [NG] LM Studio サーバーに接続できません ($serverUrl)" -ForegroundColor Red
    Write-Host "       対処: LM Studio を起動し、Local Server（Developer タブ）を開始してください。" -ForegroundColor Yellow
}
Write-Host ""

# ------------------------------------------------------------
# 2. AISS Backend プロセス状態
# ------------------------------------------------------------
Write-Host "[2/4] AISS Backend プロセス状態" -ForegroundColor Cyan
$backendProc = Get-Process -Name "AISS_Backend" -ErrorAction SilentlyContinue

if ($backendProc) {
    Write-Host "  [OK] AISS Backend 稼働中 (PID: $($backendProc[0].Id), メモリ: $([math]::Round($backendProc[0].WS / 1MB, 1)) MB)" -ForegroundColor Green
} else {
    Write-Host "  [NG] AISS Backend が停止しています" -ForegroundColor Red
    Write-Host "       対処: デスクトップの「Starfield（MOD）」から起動するか、" -ForegroundColor Yellow
    Write-Host "             AISS_Backend.exe を直接ダブルクリックして起動してください。" -ForegroundColor Yellow
}
Write-Host ""

# ------------------------------------------------------------
# 3. 最新のリクエスト & 返事（会話状態）
# ------------------------------------------------------------
Write-Host "[3/4] 最新の会話状態" -ForegroundColor Cyan
$reqFile = Join-Path $sfseAiss "requests\latest_request.ini"
$respFile = Join-Path $sfseAiss "responses\latest_response.ini"

$reqTime = $null
$reqMsg = "(なし)"
$reqReady = $null
$reqId = ""
$npcName = ""

if (Test-Path $reqFile) {
    $reqItem = Get-Item $reqFile
    $reqTime = $reqItem.LastWriteTime
    $reqContent = Get-Content $reqFile -Encoding UTF8 -ErrorAction SilentlyContinue
    foreach ($line in $reqContent) {
        if ($line -match "^message=(.*)") {
            $reqMsg = $matches[1].Trim()
        } elseif ($line -match "^ready=(.*)") {
            $reqReady = $matches[1].Trim()
        } elseif ($line -match "^request_id=(.*)") {
            $reqId = $matches[1].Trim()
        } elseif ($line -match "^npc_name=(.*)") {
            $npcName = $matches[1].Trim()
        }
    }
}

$respTime = $null
$respText = "(なし)"
$respReady = $null
$respId = ""
$displayMode = ""

if (Test-Path $respFile) {
    $respItem = Get-Item $respFile
    $respTime = $respItem.LastWriteTime
    $respContent = Get-Content $respFile -Encoding UTF8 -ErrorAction SilentlyContinue
    foreach ($line in $respContent) {
        if ($line -match "^(display_text|text)=(.*)") {
            $respText = $matches[2].Trim()
        } elseif ($line -match "^ready=(.*)") {
            $respReady = $matches[1].Trim()
        } elseif ($line -match "^request_id=(.*)") {
            $respId = $matches[1].Trim()
        } elseif ($line -match "^display_mode=(.*)") {
            $displayMode = $matches[1].Trim()
        }
    }
}

$shortReq = if ($reqMsg.Length -gt 20) { $reqMsg.Substring(0, 20) + "..." } else { $reqMsg }
$shortResp = if ($respText.Length -gt 40) { $respText.Substring(0, 40) + "..." } else { $respText }

if ($reqTime) {
    Write-Host "  ・最新リクエスト時刻: $(Get-Date $reqTime -Format 'HH:mm:ss') [相手: $npcName]" -ForegroundColor DarkGray
    Write-Host "    送信内容: `"$shortReq`"" -ForegroundColor White
} else {
    Write-Host "  ・リクエスト履歴なし" -ForegroundColor DarkGray
}

if ($respTime) {
    Write-Host "  ・最新レスポンス時刻: $(Get-Date $respTime -Format 'HH:mm:ss')" -ForegroundColor DarkGray
    Write-Host "    返答内容: `"$shortResp`"" -ForegroundColor White
} else {
    Write-Host "  ・レスポンス履歴なし" -ForegroundColor DarkGray
}

Write-Host ""
# 状態判定
if ($reqTime -and $respTime) {
    if ($reqTime -gt $respTime -or ($reqReady -eq "1" -and $reqId -ne $respId)) {
        $diffSec = [math]::Round(((Get-Date) - $reqTime).TotalSeconds)
        Write-Host "  >> 判定: 【返事待ち（AI生成中）】（送信から $diffSec 秒経過）" -ForegroundColor Yellow
        Write-Host "     ※通常は 5〜10 秒程度で完了します。30 秒以上かかる場合は LM Studio の負荷を確認してください。" -ForegroundColor DarkGray
    } else {
        $elapsedSec = [math]::Round(($respTime - $reqTime).TotalSeconds, 1)
        Write-Host "  >> 判定: 【返事完了】（直近の処理時間: 約 $elapsedSec 秒）" -ForegroundColor Green
    }
}
Write-Host ""

# ------------------------------------------------------------
# 4. Backend ログ（直近の出力）
# ------------------------------------------------------------
Write-Host "[4/4] AISS Backend ログ（最新 8 行）" -ForegroundColor Cyan
$logFile = Join-Path $aissRoot "logs\aiss_rebuilt_backend.log"

if (Test-Path $logFile) {
    $tailLines = Get-Content $logFile -Tail 8 -Encoding UTF8 -ErrorAction SilentlyContinue
    if ($tailLines) {
        foreach ($line in $tailLines) {
            if ($line -match "error|fail|exception") {
                Write-Host "    $line" -ForegroundColor Red
            } elseif ($line -match "warn") {
                Write-Host "    $line" -ForegroundColor Yellow
            } else {
                Write-Host "    $line" -ForegroundColor DarkGray
            }
        }
    } else {
        Write-Host "    (ログファイルは空です)" -ForegroundColor DarkGray
    }
} else {
    Write-Host "    (ログファイルが見つかりません: $logFile)" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Enterキーを押して終了してください..." -ForegroundColor DarkGray
$null = Read-Host
