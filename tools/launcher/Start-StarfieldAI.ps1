# Start-StarfieldAI.ps1 - Starfield AI ワンクリック統合ランチャー
# Starfield Space Life JP Project

[CmdletBinding()]
param(
    [switch]$TestOnly,
    [switch]$NonInteractive
)

$ErrorActionPreference = "Stop"

# コンソール文字コードを UTF-8 に設定
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Starfield Space Life JP - ワンクリック統合ランチャー" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# 1. 設定ファイルの読み込み
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configPath = Join-Path $scriptDir "launcher.config.json"

if (-not (Test-Path $configPath)) {
    $examplePath = Join-Path $scriptDir "launcher.config.example.json"
    Write-Host "[エラー] 設定ファイルが見つかりません: $configPath" -ForegroundColor Red
    Write-Host "        $examplePath をコピーして launcher.config.json を作成してください。" -ForegroundColor Yellow
    if (-not $NonInteractive) {
        Read-Host "Enterキーを押して終了してください..."
    }
    exit 1
}

$config = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json

# 2. VRAM 節約チェック（常駐プロセスの確認）
Write-Host "[ステップ 1/5] VRAM 常駐アプリのチェック中..." -ForegroundColor Green
$heavyProcesses = $config.vramHeavyProcesses
$foundProcesses = @()

foreach ($procName in $heavyProcesses) {
    $running = Get-Process -Name $procName -ErrorAction SilentlyContinue
    if ($running) {
        $foundProcesses += $running
    }
}

if ($foundProcesses.Count -gt 0) {
    Write-Host "  以下の VRAM 消費アプリが起動しています:" -ForegroundColor Yellow
    $uniqueNames = $foundProcesses | Select-Object -ExpandProperty ProcessName -Unique
    foreach ($name in $uniqueNames) {
        $count = ($foundProcesses | Where-Object { $_.ProcessName -eq $name }).Count
        Write-Host "    - $name ($count 個のプロセス)" -ForegroundColor Yellow
    }
    Write-Host "  ※これらを終了すると約 2〜3 GB 以上の VRAM が解放され、ゲームが安定します。" -ForegroundColor DarkGray

    $shouldClose = $false
    if ($NonInteractive) {
        Write-Host "  (非対話モード: アプリ終了確認をスキップします)" -ForegroundColor DarkGray
    } else {
        $answer = Read-Host "  これらのアプリを終了しますか？ (Y/N) [初期値: Y]"
        if ([string]::IsNullOrWhiteSpace($answer) -or $answer.Trim().ToUpper() -eq "Y") {
            $shouldClose = $true
        }
    }

    if ($shouldClose) {
        Write-Host "  アプリの正常終了を試行中..." -ForegroundColor Cyan
        foreach ($p in $foundProcesses) {
            try {
                $p.CloseMainWindow() | Out-Null
            } catch {
                # ウィンドウを持たない場合は無視
            }
        }
        Start-Sleep -Seconds 2
        Write-Host "  終了処理完了。" -ForegroundColor Green
    } else {
        Write-Host "  アプリの終了をスキップしました。" -ForegroundColor DarkGray
    }
} else {
    Write-Host "  VRAM 消費の大きな常駐アプリは検出されませんでした。" -ForegroundColor Green
}
Write-Host ""

# 3. LM Studio サーバーの確認・起動
Write-Host "[ステップ 2/5] LM Studio サーバーの確認中..." -ForegroundColor Green
$serverUrl = $config.lmStudio.serverUrl
$serverRunning = $false

try {
    $null = Invoke-RestMethod -Uri "$serverUrl/v1/models" -Method Get -TimeoutSec 3 -ErrorAction Stop
    $serverRunning = $true
    Write-Host "  LM Studio サーバーは稼働中です ($serverUrl)。" -ForegroundColor Green
} catch {
    Write-Host "  LM Studio サーバーが未起動です。起動を試行中..." -ForegroundColor Yellow
    try {
        & lms server start | Out-Null
        Start-Sleep -Seconds 3
        $null = Invoke-RestMethod -Uri "$serverUrl/v1/models" -Method Get -TimeoutSec 5 -ErrorAction Stop
        $serverRunning = $true
        Write-Host "  LM Studio サーバーを正常に起動しました。" -ForegroundColor Green
    } catch {
        Write-Host "[エラー] LM Studio サーバーの自動起動に失敗しました。" -ForegroundColor Red
        Write-Host "        LM Studio アプリを手動で開き、ポート 1234 でサーバーを開始してください。" -ForegroundColor Yellow
        if (-not $NonInteractive) {
            Read-Host "Enterキーを押して終了してください..."
        }
        exit 1
    }
}
Write-Host ""

# 4. モデル読み込み確認と API 疎通テスト
Write-Host "[ステップ 3/5] モデルの読み込み状態・API 疎通テスト中..." -ForegroundColor Green
$modelId = $config.lmStudio.modelIdentifier

$loadedModels = & lms ps
$isLoaded = $loadedModels -match $modelId

if (-not $isLoaded) {
    Write-Host "  モデル $modelId を読み込み中（既定設定が自動適用されます）..." -ForegroundColor Cyan
    & lms load $modelId -y | Out-Null
    Start-Sleep -Seconds 3
} else {
    Write-Host "  モデル $modelId はすでに読み込まれています。" -ForegroundColor Green
}

Write-Host "  API 応答テストを送信中..." -ForegroundColor Cyan
try {
    $testBody = @{
        model = $modelId
        messages = @(
            @{ role = "user"; content = "疎通確認" }
        )
        reasoning_effort = "none"
        max_tokens = 10
    } | ConvertTo-Json -Compress

    $testBytes = [System.Text.Encoding]::UTF8.GetBytes($testBody)
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $testResp = Invoke-RestMethod -Uri "$serverUrl/v1/chat/completions" -Method Post -ContentType "application/json; charset=utf-8" -Body $testBytes -TimeoutSec $config.lmStudio.testTimeoutSeconds
    $sw.Stop()
    Write-Host "  API 疎通確認成功！（応答速度: $($sw.ElapsedMilliseconds) ms）" -ForegroundColor Green
} catch {
    Write-Host "[エラー] LM Studio API への疎通テストに失敗しました: $_" -ForegroundColor Red
    if (-not $NonInteractive) {
        Read-Host "Enterキーを押して終了してください..."
    }
    exit 1
}
Write-Host ""

if ($TestOnly) {
    Write-Host "[テスト完了] ステップ 1〜3 が正常に確認されました。MO2 / ゲーム起動はスキップします。" -ForegroundColor Yellow
    exit 0
}

# 5. MO2 / AISS Backend / Starfield の起動
if ($config.openMo2Only) {
    Write-Host "[ステップ 4/5] MO2 を開くだけのモード（openMo2Only = true）です。" -ForegroundColor Yellow
    Write-Host "  Mod Organizer 2 を起動します..." -ForegroundColor Cyan
    Start-Process -FilePath $config.mo2ExecutablePath -ArgumentList "-i $($config.mo2InstanceName)"
    Write-Host "  MO2 の GUI から手動で「AISS Backend」と「SFSE」を実行してください。" -ForegroundColor Green
    exit 0
}

Write-Host "[ステップ 4/5] AISS Backend を MO2 経由で起動中..." -ForegroundColor Green
$aissShortcut = "moshortcut://$($config.mo2InstanceName):$($config.aissExecutableTitle)"

try {
    Start-Process -FilePath $config.mo2ExecutablePath -ArgumentList "`"$aissShortcut`""
    Write-Host "  AISS Backend 起動コマンドを発行しました。" -ForegroundColor Cyan
} catch {
    Write-Host "[エラー] AISS Backend の起動に失敗しました: $_" -ForegroundColor Red
    exit 1
}

Write-Host "  AISS Backend の初期化を待機中（3秒）..." -ForegroundColor DarkGray
Start-Sleep -Seconds 3

Write-Host "[ステップ 5/5] SFSE（Starfield）を MO2 経由で起動中..." -ForegroundColor Green
$sfseShortcut = "moshortcut://$($config.mo2InstanceName):$($config.sfseExecutableTitle)"

try {
    Start-Process -FilePath $config.mo2ExecutablePath -ArgumentList "`"$sfseShortcut`""
    Write-Host "  SFSE 起動コマンドを発行しました。Starfield が起動します！" -ForegroundColor Green
} catch {
    Write-Host "[エラー] SFSE の起動に失敗しました: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "   すべての起動シーケンスが完了しました！ よい宇宙の旅を！" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Start-Sleep -Seconds 3