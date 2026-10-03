@echo off
chcp 65001 > nul
setlocal

:: カレントディレクトリをスクリプトの配置場所に移動
cd /d "%~dp0"

:: PowerShell を実行ポリシー Bypass で呼び出し
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Start-StarfieldAI.ps1"

endlocal
