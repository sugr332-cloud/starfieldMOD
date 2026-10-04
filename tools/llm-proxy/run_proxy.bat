@echo off
setlocal
cd /d "%~dp0"
echo [LLM Proxy] Starting LLM Proxy on port 1235...
python llm_proxy.py --port 1235 --upstream http://127.0.0.1:1234
pause
