# Start-StarfieldAI.ps1 - Starfield AI ワンクリック統合ランチャー
# Starfield Space Life JP Project

[CmdletBinding()]
param(
    [switch]$NoAI,
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

    # モード判定と MO2 プロファイル名の決定
    if ($NoAI) {
        $NoLLM = $true
        $mo2Profile = "Stable-NoAI"
        Write-Host "  >>> 起動モード: [AIなし] (バニラ会話 / AISS・LLM完全停止 / プロファイル: $mo2Profile) <<<" -ForegroundColor Yellow
    } else {
        $mo2Profile = if ($config.mo2Profile) { $config.mo2Profile } else { "Stable" }
        Write-Host "  >>> 起動モード: [AIあり] (AISS / LM Studio 連携 / プロファイル: $mo2Profile) <<<" -ForegroundColor Green
    }

    # AISS Backend 実行ファイルの決定
    $aissExePath = if ($config.aissExecutablePath -and (Test-Path $config.aissExecutablePath)) {
        $config.aissExecutablePath
    } else {
        $defaultAiss = Join-Path $env:LOCALAPPDATA "ModOrganizer\$($config.mo2InstanceName)\mods\AISS - AI Settled Systems\AISS\AISS_Backend.exe"
        if (Test-Path $defaultAiss) { $defaultAiss } else { $null }
    }

    # MO2 の ModOrganizer.ini を検査し、selected_profile を指定プロファイルに固定
    $mo2IniPath = Join-Path $env:LOCALAPPDATA "ModOrganizer\$($config.mo2InstanceName)\ModOrganizer.ini"
    if (Test-Path $mo2IniPath) {
        try {
            $mo2IniRaw = Get-Content $mo2IniPath -Raw -Encoding UTF8
            if ($mo2IniRaw -match "selected_profile=@ByteArray\((.*?)\)") {
                $curProfile = $matches[1]
                if ($curProfile -ne $mo2Profile) {
                    Write-Host "  MO2 の選択プロファイル ($curProfile) を '$mo2Profile' に切り替えます..." -ForegroundColor Cyan
                    $updatedIni = $mo2IniRaw -replace "selected_profile=@ByteArray\(.*?\)", "selected_profile=@ByteArray($mo2Profile)"
                    [System.IO.File]::WriteAllText($mo2IniPath, $updatedIni, [System.Text.Encoding]::UTF8)
                }
            }
        } catch {
            Write-Host "  [情報] ModOrganizer.ini の確認をスキップしました: $_" -ForegroundColor DarkGray
        }
    }
    # AISS 日本語アドオンの同期（AIあり時のみ実施）
    if (-not $NoAI) {
        $jpAddonSrc = Join-Path $env:LOCALAPPDATA "ModOrganizer\$($config.mo2InstanceName)\mods\AISS - Japanese Language Addon\AISS\addons\jp_prompt_pack"
        $jpAddonDst = Join-Path $env:LOCALAPPDATA "ModOrganizer\$($config.mo2InstanceName)\mods\AISS - AI Settled Systems\AISS\addons\jp_prompt_pack"
        if (Test-Path $jpAddonSrc) {
            try {
                if (-not (Test-Path $jpAddonDst)) {
                    Copy-Item -Path $jpAddonSrc -Destination $jpAddonDst -Recurse -Force | Out-Null
                    Write-Host "  日本語アドオン (jp_prompt_pack) を AISS 本体に配備しました。" -ForegroundColor Green
                }
            } catch {
                Write-Host "  [警告] 日本語アドオンの同期に失敗しました: $_" -ForegroundColor Yellow
            }
        }
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
        Write-Host "  Mod Organizer 2 をプロファイル '$mo2Profile' で起動します..." -ForegroundColor Cyan
        Start-Process -FilePath $config.mo2ExecutablePath -ArgumentList "-i $($config.mo2InstanceName) -p `"$mo2Profile`""
        Write-Host "  MO2 の GUI から手動で「AISS Backend」と「SFSE」を実行してください。" -ForegroundColor Green
        Exit-Launcher 0
    }

    if ($NoAI) {
        $currentStep = "ステップ 4/5: AISS Backend スキップ (-NoAI)"
        Write-Host "[$currentStep] AIなしモードのため、AISS Backend の起動をスキップします。" -ForegroundColor Yellow
        $runningAiss = Get-Process -Name "AISS_Backend" -ErrorAction SilentlyContinue
        if ($runningAiss) {
            Write-Host "  [情報] バックグラウンドで稼働中の AISS Backend を停止します..." -ForegroundColor DarkGray
            $runningAiss | Stop-Process -Force -ErrorAction SilentlyContinue
        }
        Write-Host ""
    } else {
    $currentStep = "ステップ 4/5: AISS Backend 起動"
    $runningAiss = Get-Process -Name "AISS_Backend" -ErrorAction SilentlyContinue

    if ($runningAiss) {
        Write-Host "[$currentStep] AISS Backend はすでに起動しています (PID: $($runningAiss[0].Id))。" -ForegroundColor Green
    } elseif ($DryRun) {
        Write-Host "[$currentStep] (ドライラン)" -ForegroundColor Magenta
        if ($aissExePath) {
            Write-Host "  [DryRun] AISS Backend 直接起動予定: $aissExePath" -ForegroundColor Cyan
        } else {
            Write-Host "  [DryRun] AISS Backend MO2 経由起動予定: moshortcut://$($config.mo2InstanceName):$($config.aissExecutableTitle)" -ForegroundColor Cyan
        }
    } else {
        Write-Host "[$currentStep] AISS Backend を起動中..." -ForegroundColor Green
        try {
            if ($aissExePath) {
                $aissDir = Split-Path -Parent $aissExePath
                Start-Process -FilePath $aissExePath -WorkingDirectory $aissDir
                Write-Host "  AISS Backend を直接起動しました。" -ForegroundColor Cyan
            } else {
                $aissShortcut = "moshortcut://$($config.mo2InstanceName):$($config.aissExecutableTitle)"
                Start-Process -FilePath $config.mo2ExecutablePath -ArgumentList "`"$aissShortcut`""
                Write-Host "  AISS Backend を MO2 ショートカット経由で起動しました。" -ForegroundColor Cyan
            }
        } catch {
            throw "AISS Backend の起動に失敗しました: $_"
        }
        Write-Host "  AISS Backend の初期化を待機中（3秒）..." -ForegroundColor DarkGray
        Start-Sleep -Seconds 3

        $checkAiss = Get-Process -Name "AISS_Backend" -ErrorAction SilentlyContinue
        if ($checkAiss) {
            Write-Host "  AISS Backend 正常稼働確認 (PID: $($checkAiss[0].Id))" -ForegroundColor Green
        } else {
            Write-Host "  [情報] AISS Backend プロセスの初期化が進行中です。" -ForegroundColor DarkGray
        }
    }
    Write-Host ""
    }

    $currentStep = "ステップ 5/5: SFSE（Starfield）起動"
    $sfseShortcut = "moshortcut://$($config.mo2InstanceName):$($config.sfseExecutableTitle)"

    if ($DryRun) {
        Write-Host "[$currentStep] (ドライラン)" -ForegroundColor Magenta
        Write-Host "  [DryRun] 実行予定コマンド:" -ForegroundColor Cyan
        Write-Host "    実行ファイル: $($config.mo2ExecutablePath)" -ForegroundColor Cyan
        Write-Host "    引数        : `"$sfseShortcut`" -p `"$mo2Profile`"" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "==========================================================" -ForegroundColor Magenta
        Write-Host "   [ドライラン完了] コマンド検証が正常に完了しました。" -ForegroundColor Magenta
        Write-Host "   実際のプロセス起動は行っていません。" -ForegroundColor Magenta
        Write-Host "==========================================================" -ForegroundColor Magenta
        Exit-Launcher 0
    } else {
        Write-Host "[$currentStep] SFSE（Starfield）をプロファイル '$mo2Profile' で MO2 経由で起動中..." -ForegroundColor Green
        try {
            Start-Process -FilePath $config.mo2ExecutablePath -ArgumentList "`"$sfseShortcut`" -p `"$mo2Profile`""
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
