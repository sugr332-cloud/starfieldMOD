# Start-StarfieldAI.ps1 - Starfield AI ワンクリック統合ランチャー
# Starfield Space Life JP Project

[CmdletBinding()]
param(
    [switch]$NoLLM,
    [switch]$TestOnly,
    [switch]$DryRun,
    [switch]$NonInteractive
)

$ErrorActionPreference = "Stop"

# コンソール文字コードを UTF-8 に設定
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$logDir = Join-Path $scriptDir "logs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logPath = Join-Path $logDir "launcher-$timestamp.log"

try {
    Start-Transcript -Path $logPath -Force | Out-Null
} catch {
    Write-Host "[警告] ログ記録 (Transcript) を開始できませんでした: $_" -ForegroundColor Yellow
}

function Exit-Launcher([int]$exitCode) {
    try {
        Stop-Transcript | Out-Null
    } catch {
        $null = $_
    }
    exit $exitCode
}

$currentStep = "初期化"

try {
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "   Starfield Space Life JP - ワンクリック統合ランチャー" -ForegroundColor Cyan
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "ログ記録先: $logPath" -ForegroundColor DarkGray
    Write-Host ""

    # 1. 設定ファイルの読み込み
    $currentStep = "設定ファイル読み込み"
    $configPath = Join-Path $scriptDir "launcher.config.json"

    if (-not (Test-Path $configPath)) {
        $examplePath = Join-Path $scriptDir "launcher.config.example.json"
        throw "設定ファイルが見つかりません: $configPath`n       $examplePath をコピーして launcher.config.json を作成してください。"
    }

    $config = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json

    # MO2 実行ファイルの存在確認
    if (-not (Test-Path $config.mo2ExecutablePath)) {
        throw "設定された MO2 実行ファイルが見つかりません: $($config.mo2ExecutablePath)`n       launcher.config.json の mo2ExecutablePath を確認してください。"
    }

    # 2. VRAM 節約チェック（常駐プロセスの確認）
    $currentStep = "ステップ 1/5: VRAM 常駐アプリのチェック"
    Write-Host "[$currentStep] 実行中..." -ForegroundColor Green
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

    if ($NoLLM) {
        $currentStep = "ステップ 2/5 & 3/5: LLM スキップ処理 (-NoLLM)"
        Write-Host "[$currentStep] NoLLM モードで実行中..." -ForegroundColor Yellow
        Write-Host "  LM Studio モデルの読み込みをスキップします。" -ForegroundColor Cyan

        try {
            $loadedModels = & lms ps 2>$null
            if ($loadedModels -and ($loadedModels -notmatch "No models")) {
                Write-Host "  ロード中の LM Studio モデルを検出しました。VRAM 解放のためアンロードします..." -ForegroundColor Yellow
                & lms unload --all 2>$null | Out-Null
                Write-Host "  すべてのモデルをアンロードしました。" -ForegroundColor Green
            } else {
                Write-Host "  ロード中のモデルはありません。" -ForegroundColor Green
            }
        } catch {
            Write-Host "  (LM Studio CLI の確認はスキップされました: $_)" -ForegroundColor DarkGray
        }
        Write-Host ""
    } else {
    # 3. LM Studio サーバーの確認・起動
    $currentStep = "ステップ 2/5: LM Studio サーバーの確認"
    Write-Host "[$currentStep] 実行中..." -ForegroundColor Green
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
            throw "LM Studio サーバーの自動起動に失敗しました。`n       LM Studio アプリを手動で開き、ポート 1234 でサーバーを開始してください。"
        }
    }
    Write-Host ""

    # 4. モデル読み込み確認と API 疎通テスト
    $currentStep = "ステップ 3/5: モデル読み込み確認・API 疎通テスト"
    Write-Host "[$currentStep] 実行中..." -ForegroundColor Green
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
        throw "LM Studio API への疎通テストに失敗しました: $_"
    }
    Write-Host ""

    }

    if ($TestOnly) {
        Write-Host "[テスト完了] ステップ 1〜3 が正常に確認されました。MO2 / ゲーム起動はスキップします。" -ForegroundColor Yellow
        Exit-Launcher 0
    }

    # 5. MO2 / AISS Backend / Starfield の起動
    if ($config.openMo2Only) {
        $currentStep = "MO2 単独起動"
        Write-Host "[ステップ 4/5] MO2 を開くだけのモード（openMo2Only = true）です。" -ForegroundColor Yellow
        Write-Host "  Mod Organizer 2 を起動します..." -ForegroundColor Cyan
        Start-Process -FilePath $config.mo2ExecutablePath -ArgumentList "-i $($config.mo2InstanceName)"
        Write-Host "  MO2 の GUI から手動で「AISS Backend」と「SFSE」を実行してください。" -ForegroundColor Green
        Exit-Launcher 0
    }

    $currentStep = "ステップ 4/5: AISS Backend 起動"
    $aissShortcut = "moshortcut://$($config.mo2InstanceName):$($config.aissExecutableTitle)"

    if ($DryRun) {
        Write-Host "[$currentStep] (ドライラン)" -ForegroundColor Magenta
        Write-Host "  [DryRun] 実行予定コマンド:" -ForegroundColor Cyan
        Write-Host "    実行ファイル: $($config.mo2ExecutablePath)" -ForegroundColor Cyan
        Write-Host "    引数        : `"$aissShortcut`"" -ForegroundColor Cyan
    } else {
        Write-Host "[$currentStep] MO2 経由で起動中..." -ForegroundColor Green
        try {
            Start-Process -FilePath $config.mo2ExecutablePath -ArgumentList "`"$aissShortcut`""
            Write-Host "  AISS Backend 起動コマンドを発行しました。" -ForegroundColor Cyan
        } catch {
            throw "AISS Backend の起動に失敗しました: $_"
        }
        Write-Host "  AISS Backend の初期化を待機中（3秒）..." -ForegroundColor DarkGray
        Start-Sleep -Seconds 3
    }
    Write-Host ""

    $currentStep = "ステップ 5/5: SFSE（Starfield）起動"
    $sfseShortcut = "moshortcut://$($config.mo2InstanceName):$($config.sfseExecutableTitle)"

    if ($DryRun) {
        Write-Host "[$currentStep] (ドライラン)" -ForegroundColor Magenta
        Write-Host "  [DryRun] 実行予定コマンド:" -ForegroundColor Cyan
        Write-Host "    実行ファイル: $($config.mo2ExecutablePath)" -ForegroundColor Cyan
        Write-Host "    引数        : `"$sfseShortcut`"" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "==========================================================" -ForegroundColor Magenta
        Write-Host "   [ドライラン完了] コマンド検証が正常に完了しました。" -ForegroundColor Magenta
        Write-Host "   実際のプロセス起動は行っていません。" -ForegroundColor Magenta
        Write-Host "==========================================================" -ForegroundColor Magenta
        Exit-Launcher 0
    } else {
        Write-Host "[$currentStep] SFSE（Starfield）を MO2 経由で起動中..." -ForegroundColor Green
        try {
            Start-Process -FilePath $config.mo2ExecutablePath -ArgumentList "`"$sfseShortcut`""
            Write-Host "  SFSE 起動コマンドを発行しました。Starfield が起動します！" -ForegroundColor Green
        } catch {
            throw "SFSE の起動に失敗しました: $_"
        }

        Write-Host ""
        Write-Host "==========================================================" -ForegroundColor Green
        Write-Host "   すべての起動シーケンスが完了しました！ よい宇宙の旅を！" -ForegroundColor Green
        Write-Host "   (このウィンドウは 5 秒後に自動で閉じます)" -ForegroundColor DarkGray
        Write-Host "==========================================================" -ForegroundColor Green
        Start-Sleep -Seconds 5
        Exit-Launcher 0
    }

} catch {
    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Red
    Write-Host " [エラー] ランチャーの実行中にエラーが発生しました" -ForegroundColor Red
    Write-Host " 発生フェーズ: $currentStep" -ForegroundColor Red
    Write-Host " エラー詳細: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host " ログファイル: $logPath" -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Red
    Write-Host ""
    if (-not $NonInteractive) {
        Read-Host "Enterキーを押して終了してください..."
    }
    Exit-Launcher 1
}
