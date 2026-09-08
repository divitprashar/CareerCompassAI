@echo off
title Career Compass AI
color 0B
echo.
echo  ============================================
echo    Career Compass AI - Navigate Your Future with Success
echo  ============================================
echo.

cd /d "%~dp0"

:: ── Start Ollama (if not running) ─────────────────────────────
echo  Starting Ollama AI engine...
tasklist /fi "imagename eq ollama.exe" | find /i "ollama.exe" >nul 2>&1
if %errorlevel% neq 0 (
    start /min "" ollama serve
    echo  Waiting for Ollama to start...
    timeout /t 4 /nobreak >nul
) else (
    echo  Ollama is already running.
)

:: ── Start Flask App ───────────────────────────────────────────
echo  Starting Career Compass AI web server...
echo.
echo  ============================================
echo    App running at: http://localhost:5000
echo  ============================================
echo.
echo  Opening browser...
timeout /t 2 /nobreak >nul
start http://localhost:5000

echo  Press Ctrl+C to stop the server.
echo.
python app.py

pause
