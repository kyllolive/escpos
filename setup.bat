@echo off
setlocal

REM Check if Node.js is installed
node -v >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Node.js is not installed. Installing Node.js...
    
    REM Download Node.js installer (replace URL with the desired Node.js version)
    powershell -Command "Invoke-WebRequest -Uri https://nodejs.org/dist/v18.17.1/node-v18.17.1-x64.msi -OutFile nodejs_installer.msi"
    
    REM Install Node.js silently
    msiexec /i nodejs_installer.msi /quiet /norestart

    REM Clean up the installer
    del nodejs_installer.msi

    REM Add Node.js to PATH (may require restart to take effect)
    setx PATH "%PATH%;%ProgramFiles%\nodejs"
)

REM Verify Node.js installation
node -v >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Node.js installation failed. Exiting script.
    exit /b 1
)

REM Navigate to the app directory
cd /d %~dp0

echo Installing dependencies...
npm install

echo Building the application...
npm run build

echo Installing pm2 globally...
npm install -g pm2

REM Ensure PM2 is available in PATH for the current session
set PATH=%APPDATA%\npm;%PATH%

echo Starting the printer-server with pm2...
pm2 start dist/src/index.js --name "printer-server"

pm2 save

echo Setting up pm2 to start on boot...
FOR /F "tokens=*" %%i IN ('pm2 startup windows -u %USERNAME% --hp %USERPROFILE%') DO %%i

echo Starting the app immediately...
pm2 start printer-server

echo Script execution completed successfully.
