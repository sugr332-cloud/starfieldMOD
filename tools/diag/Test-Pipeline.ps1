# Test-Pipeline.ps1 - AISS 全経路疎通テスト ラッパー
param(
    [int]$Iterations = 3
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$pyScript = Join-Path $scriptDir "test_pipeline.py"

python $pyScript $Iterations
