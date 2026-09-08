@echo off
title Career Compass AI - Setup
color 0A
echo.
echo  ============================================
echo    Career Compass AI
echo    Navigate Your Future with Success
echo    One-Time Setup
echo  ============================================
echo.
echo  This script will:
echo    1. Find Python on this laptop and add it to PATH
echo    2. Install required Python packages (Flask etc.)
echo    3. Download and install Ollama AI engine
echo    4. Download the AI model (~2GB, one time only)
echo.
echo  Internet connection is required for this setup.
echo  After setup the app runs 100 percent offline.
echo.
pause

:: ── Step 1: Find Python and fix PATH ─────────────────────────
echo.
echo  ============================================
echo  [STEP 1 of 5]  Locating Python installation...
echo  ============================================
echo.

set PYTHON_EXE=
set PYTHON_DIR=

:: First check if python is already reachable in PATH
python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo  Python is already available in PATH:
    python --version
    for /f "tokens=*" %%i in ('where python') do set PYTHON_EXE=%%i
    echo  Location: %PYTHON_EXE%
    goto :python_ready
)

echo  Python not found in PATH. Searching common install locations...
echo.

:: Search all known Python install locations
set SEARCH_DIRS=^
    "%LOCALAPPDATA%\Programs\Python\Python313" ^
    "%LOCALAPPDATA%\Programs\Python\Python312" ^
    "%LOCALAPPDATA%\Programs\Python\Python311" ^
    "%LOCALAPPDATA%\Programs\Python\Python310" ^
    "%LOCALAPPDATA%\Programs\Python\Python39" ^
    "%LOCALAPPDATA%\Programs\Python\Python38" ^
    "C:\Python313" ^
    "C:\Python312" ^
    "C:\Python311" ^
    "C:\Python310" ^
    "C:\Python39" ^
    "C:\Python38" ^
    "%PROGRAMFILES%\Python313" ^
    "%PROGRAMFILES%\Python312" ^
    "%PROGRAMFILES%\Python311" ^
    "%PROGRAMFILES%\Python310" ^
    "%PROGRAMFILES(X86)%\Python313" ^
    "%PROGRAMFILES(X86)%\Python312" ^
    "%PROGRAMFILES(X86)%\Python311" ^
    "%APPDATA%\Programs\Python\Python313" ^
    "%APPDATA%\Programs\Python\Python312" ^
    "%APPDATA%\Programs\Python\Python311"

for %%d in (%SEARCH_DIRS%) do (
    if exist "%%~d\python.exe" (
        set PYTHON_DIR=%%~d
        set PYTHON_EXE=%%~d\python.exe
        echo  Found Python at: %%~d
        goto :found_python
    )
)

:: Try registry lookup as fallback
echo  Checking Windows registry for Python...
for /f "tokens=2*" %%a in ('reg query "HKCU\SOFTWARE\Python\PythonCore" /s /v InstallPath 2^>nul') do (
    if exist "%%b\python.exe" (
        set PYTHON_DIR=%%b
        set PYTHON_EXE=%%b\python.exe
        echo  Found via registry: %%b
        goto :found_python
    )
)
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Python\PythonCore" /s /v InstallPath 2^>nul') do (
    if exist "%%b\python.exe" (
        set PYTHON_DIR=%%b
        set PYTHON_EXE=%%b\python.exe
        echo  Found via registry: %%b
        goto :found_python
    )
)

:: Last resort — search user profile and C drive top-level folders
echo  Scanning user profile for python.exe...
for /f "tokens=*" %%f in ('dir /s /b "%USERPROFILE%\python.exe" 2^>nul') do (
    set PYTHON_EXE=%%f
    for %%i in ("%%f") do set PYTHON_DIR=%%~dpi
    echo  Found at: %%f
    goto :found_python
)

:: Nothing found — download Python
echo.
echo  Python not found on this laptop.
echo  Downloading Python 3.11.9 installer...
echo.
powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe' -OutFile '%TEMP%\python_installer.exe'" 2>&1
if exist "%TEMP%\python_installer.exe" (
    echo  Download complete. Launching Python installer...
    echo.
    echo  IMPORTANT: In the installer window that opens:
    echo  -----------------------------------------------
    echo   CHECK the box: "Add Python to PATH"  (bottom)
    echo   Then click:    "Install Now"
    echo  -----------------------------------------------
    echo.
    pause
    "%TEMP%\python_installer.exe"
    echo.
    echo  Press any key once Python installation is finished.
    pause
    :: Re-check after install
    python --version >nul 2>&1
    if %errorlevel% equ 0 (
        for /f "tokens=*" %%i in ('where python') do set PYTHON_EXE=%%i
        goto :python_ready
    )
    echo  ERROR: Python still not found. Please restart and run setup.bat again.
    pause
    exit /b 1
) else (
    echo  ERROR: Could not download Python automatically.
    echo  Please install from https://www.python.org/downloads/
    echo  Then run setup.bat again.
    pause
    exit /b 1
)

:found_python
echo.
echo  Adding Python to PATH for this session and permanently...

:: Add to PATH for current session immediately
set "PATH=%PYTHON_DIR%;%PYTHON_DIR%\Scripts;%PATH%"

:: Add to user PATH permanently via registry (no admin needed)
powershell -Command ^
  "$currentPath = [Environment]::GetEnvironmentVariable('Path','User');" ^
  "$pythonDir = '%PYTHON_DIR%';" ^
  "$scriptsDir = '%PYTHON_DIR%\Scripts';" ^
  "if ($currentPath -notlike '*' + $pythonDir + '*') {" ^
  "  $newPath = $pythonDir + ';' + $scriptsDir + ';' + $currentPath;" ^
  "  [Environment]::SetEnvironmentVariable('Path', $newPath, 'User');" ^
  "  Write-Host '  PATH updated permanently for user account.'" ^
  "} else {" ^
  "  Write-Host '  Python path already in user PATH.'" ^
  "}"

echo.
echo  Verifying Python...
"%PYTHON_EXE%" --version
if %errorlevel% neq 0 (
    echo  ERROR: Python found but failed to run. Please restart and try again.
    pause
    exit /b 1
)

:python_ready
echo.
echo  Python is ready!
echo.

:: ── Step 2: Upgrade pip ───────────────────────────────────────
echo  ============================================
echo  [STEP 2 of 5]  Upgrading pip...
echo  ============================================
echo.
python -m pip install --upgrade pip --quiet
echo  pip is ready.
echo.

:: ── Step 3: Install Python packages ──────────────────────────
echo  ============================================
echo  [STEP 3 of 5]  Installing Python packages...
echo  (Flask, Flask-Session, Requests)
echo  ============================================
echo.
cd /d "%~dp0"
python -m pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo.
    echo  Retrying with trusted hosts (for corporate networks)...
    python -m pip install -r requirements.txt ^
        --trusted-host pypi.org ^
        --trusted-host files.pythonhosted.org
    if %errorlevel% neq 0 (
        echo.
        echo  ERROR: Could not install packages.
        echo  Try running manually:
        echo    python -m pip install flask flask-session requests
        pause
        exit /b 1
    )
)
echo.
echo  All Python packages installed!
echo.

:: ── Step 4: Install Ollama ────────────────────────────────────
echo  ============================================
echo  [STEP 4 of 5]  Setting up Ollama AI engine...
echo  ============================================
echo.
echo  Ollama is the engine that runs the AI model
echo  locally on your laptop without the internet.
echo.

:: Check if ollama.exe is reachable in PATH
ollama --version >nul 2>&1
if %errorlevel% equ 0 (
    echo  [OK] Ollama is already installed:
    ollama --version
    echo.
    goto :pull_model
)

:: Check known install location even if not in PATH
if exist "%LOCALAPPDATA%\Programs\Ollama\ollama.exe" (
    echo  [OK] Ollama found at: %LOCALAPPDATA%\Programs\Ollama
    set "PATH=%PATH%;%LOCALAPPDATA%\Programs\Ollama"
    echo      Added to PATH for this session.
    powershell -Command ^
      "$p=[Environment]::GetEnvironmentVariable('Path','User');" ^
      "$d=$env:LOCALAPPDATA+'\Programs\Ollama';" ^
      "if($p -notlike '*Ollama*'){[Environment]::SetEnvironmentVariable('Path',$d+';'+$p,'User');Write-Host '      PATH updated permanently.'}"
    echo.
    goto :pull_model
)

:: Ollama not found — download and install
echo  Ollama not found. Downloading installer...
echo  (File size: ~100 MB, please wait)
echo.
powershell -NoProfile -Command ^
  "try { $ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri 'https://ollama.com/download/OllamaSetup.exe' -OutFile '$env:TEMP\OllamaSetup.exe' -UseBasicParsing; Write-Host '  Download complete.' } catch { Write-Host '  DOWNLOAD FAILED: ' $_.Exception.Message }"

if not exist "%TEMP%\OllamaSetup.exe" (
    echo.
    echo  ERROR: Could not download Ollama automatically.
    echo.
    echo  Please do this manually:
    echo    1. Open browser, go to: https://ollama.com/download
    echo    2. Click "Download for Windows"
    echo    3. Run OllamaSetup.exe
    echo    4. Run setup.bat again
    echo.
    pause
    exit /b 1
)

echo.
echo  Installing Ollama — a Windows installer window will open.
echo  Click through the installer (just click Next / Install).
echo  Come back to this window when it is done.
echo.
echo  Press any key to start the Ollama installer...
pause

:: Run installer and wait for it to finish
start /wait "" "%TEMP%\OllamaSetup.exe"

echo.
echo  Ollama installer finished.
echo.

:: Give Windows a moment to register the install
timeout /t 3 /nobreak >nul

:: Add to PATH for this session
set "PATH=%PATH%;%LOCALAPPDATA%\Programs\Ollama"

:: Persist Ollama path permanently to user account
powershell -NoProfile -Command ^
  "$p=[Environment]::GetEnvironmentVariable('Path','User');" ^
  "$d=$env:LOCALAPPDATA+'\Programs\Ollama';" ^
  "if($p -notlike '*Ollama*'){[Environment]::SetEnvironmentVariable('Path',$d+';'+$p,'User');Write-Host '  Ollama PATH saved permanently.'} else {Write-Host '  Ollama PATH already set.'}"

:: Verify
ollama --version >nul 2>&1
if %errorlevel% equ 0 (
    echo  [OK] Ollama installed and working:
    ollama --version
) else (
    :: Try direct path as fallback
    if exist "%LOCALAPPDATA%\Programs\Ollama\ollama.exe" (
        echo  [OK] Ollama installed at %LOCALAPPDATA%\Programs\Ollama
        echo      (Will be fully active after restarting Command Prompt)
    ) else (
        echo.
        echo  WARNING: Ollama installation could not be verified.
        echo  Please restart your laptop and run setup.bat again.
        echo.
        pause
        exit /b 1
    )
)
echo.

:: ── Step 5: Download AI Model ─────────────────────────────────
:pull_model
echo  ============================================
echo  [STEP 5 of 5]  Downloading AI model...
echo  Model  : llama3.2:3b  (Meta AI, 2024)
echo  Size   : ~2 GB download
echo  Purpose: The AI brain of Career Compass AI
echo  ============================================
echo.
echo  This model will be stored on your laptop and
echo  used completely OFFLINE after this download.
echo.
echo  Estimated time: 5-20 minutes depending on
echo  your internet speed.
echo.
echo  DO NOT close this window during download.
echo.

:: Start Ollama service if not already running
tasklist /fi "imagename eq ollama.exe" | find /i "ollama.exe" >nul 2>&1
if %errorlevel% neq 0 (
    echo  Starting Ollama background service...
    start /min "" "%LOCALAPPDATA%\Programs\Ollama\ollama.exe" serve
    timeout /t 6 /nobreak >nul
    echo  Ollama service started.
    echo.
)

:: Check if model is already present (skip re-download)
ollama list 2>nul | find /i "llama3.2" >nul 2>&1
if %errorlevel% equ 0 (
    echo  [OK] llama3.2:3b is already downloaded on this laptop.
    echo      Skipping download.
    goto :setup_done
)

echo  Starting model download now...
echo  (You will see download progress below)
echo.
ollama pull llama3.2:3b

if %errorlevel% neq 0 (
    echo.
    echo  -----------------------------------------------
    echo  WARNING: Model download did not complete fully.
    echo  -----------------------------------------------
    echo.
    echo  To finish the download, open Command Prompt and run:
    echo    ollama pull llama3.2:3b
    echo.
    echo  The app will show "AI Offline" until the model
    echo  is successfully downloaded.
    echo.
    pause
) else (
    echo.
    echo  [OK] AI model downloaded and ready!
    echo.
    :: Confirm model is listed
    echo  Installed models on this laptop:
    ollama list
)

:: ── Done ──────────────────────────────────────────────────────
:setup_done
echo.
echo  ============================================
echo    SETUP COMPLETE!
echo  ============================================
echo.
echo  Installed and configured:
echo    [OK] Python (with PATH configured)
echo    [OK] Flask + Python packages
echo    [OK] Ollama AI engine (with PATH configured)
echo    [OK] Llama 3.2 AI model
echo.
echo  NOTE: If you see PATH errors after restart,
echo  close and reopen Command Prompt or restart
echo  your laptop once.
echo.
echo  To launch Career Compass AI anytime:
echo    Double-click run.bat
echo.
echo  Press any key to launch the app now...
pause
call "%~dp0run.bat"
