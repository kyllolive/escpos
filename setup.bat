@echo off
setlocal

echo Checking if Node.js is installed...
node -v >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Node.js is not installed. Attempting to install Node.js...

    REM Check if PowerShell is available and its version
    echo Checking for PowerShell version...
    powershell -Command "$psversion = $PSVersionTable.PSVersion; if ($psversion -and $psversion.Major -ge 3) { exit 0 } else { exit 1 }"
    IF %ERRORLEVEL% EQU 0 (
        echo PowerShell 3.0 or higher detected. Downloading Node.js installer...
        powershell -Command "Invoke-WebRequest -Uri https://nodejs.org/dist/v18.17.1/node-v18.17.1-x64.msi -OutFile nodejs_installer.msi"
    ) ELSE (
        echo PowerShell 3.0 or higher is not available. Using bitsadmin for download...
        bitsadmin /transfer "NodeJS Download" https://nodejs.org/dist/v18.17.1/node-v18.17.1-x64.msi %cd%\nodejs_installer.msi
    )

    echo Installing Node.js...
    msiexec /i nodejs_installer.msi /quiet /norestart

    echo Cleaning up Node.js installer file...
    del nodejs_installer.msi

    echo Adding Node.js to PATH...
    setx PATH "%PATH%;%ProgramFiles%\nodejs"
) ELSE (
    echo Node.js is already installed.
)

REM Verify Node.js installation
echo Verifying Node.js installation...
node -v >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Node.js installation failed. Exiting script.
    pause
    exit /b 1
)

REM Navigate to the app directory
echo Navigating to the application directory...
cd /d %~dp0

echo Installing application dependencies with npm...
npm install

echo Building the application...
npm run build

echo Installing pm2 globally...
npm install -g pm2

REM Ensure PM2 is available in PATH for the current session
set PATH=%APPDATA%\npm;%PATH%

echo Starting the printer-server with pm2...
pm2 start dist/src/index.js --name "printer-server"

echo Saving pm2 process list...
pm2 save

echo Setting up pm2 to start on boot...
FOR /F "tokens=*" %%i IN ('pm2 startup windows -u %USERNAME% --hp %USERPROFILE%') DO %%i

echo Starting the app immediately...
pm2 start printer-server

echo Script execution completed successfully.

REM Keep the window open to view messages
pause
