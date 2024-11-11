@echo off
setlocal

REM Log file setup
set LOGFILE=install_log.txt
echo Installation Log - %DATE% %TIME% > %LOGFILE%

REM Function to log messages
set echo_log=echo %1 | tee -a %LOGFILE%

echo Checking if Node.js is installed... | tee -a %LOGFILE%
node -v >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Node.js is not installed. Attempting to install Node.js... | tee -a %LOGFILE%

    REM Check if PowerShell is available and its version
    echo Checking for PowerShell version... | tee -a %LOGFILE%
    powershell -Command "$psversion = $PSVersionTable.PSVersion; if ($psversion -and $psversion.Major -ge 3) { exit 0 } else { exit 1 }"
    IF %ERRORLEVEL% EQU 0 (
        echo PowerShell 3.0 or higher detected. Downloading Node.js installer... | tee -a %LOGFILE%
        powershell -Command "Invoke-WebRequest -Uri https://nodejs.org/dist/v18.17.1/node-v18.17.1-x64.msi -OutFile nodejs_installer.msi"
    ) ELSE (
        echo PowerShell 3.0 or higher is not available. Using bitsadmin for download... | tee -a %LOGFILE%
        bitsadmin /transfer "NodeJS Download" https://nodejs.org/dist/v18.17.1/node-v18.17.1-x64.msi %cd%\nodejs_installer.msi
    )

    REM Check if the installer was downloaded successfully
    if not exist "nodejs_installer.msi" (
        echo Node.js installer download failed. Exiting script. | tee -a %LOGFILE%
        pause
        exit /b 1
    )

    echo Installing Node.js... | tee -a %LOGFILE%
    msiexec /i nodejs_installer.msi /quiet /norestart

    echo Cleaning up Node.js installer file... | tee -a %LOGFILE%
    del nodejs_installer.msi

    echo Adding Node.js to PATH... | tee -a %LOGFILE%
    setx PATH "%PATH%;%ProgramFiles%\nodejs"
) ELSE (
    echo Node.js is already installed. | tee -a %LOGFILE%
)

REM Verify Node.js installation
echo Verifying Node.js installation... | tee -a %LOGFILE%
node -v >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Node.js installation failed. Exiting script. | tee -a %LOGFILE%
    pause
    exit /b 1
) ELSE (
    echo Node.js installation verified. | tee -a %LOGFILE%
)

REM Navigate to the app directory
echo Navigating to the application directory... | tee -a %LOGFILE%
cd /d %~dp0

REM Install dependencies
echo Installing application dependencies with npm... | tee -a %LOGFILE%
npm install >> %LOGFILE% 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to install dependencies. Exiting script. | tee -a %LOGFILE%
    pause
    exit /b 1
)

REM Build the application
echo Building the application... | tee -a %LOGFILE%
npm run build >> %LOGFILE% 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to build the application. Exiting script. | tee -a %LOGFILE%
    pause
    exit /b 1
)

REM Install pm2 globally
echo Installing pm2 globally... | tee -a %LOGFILE%
npm install -g pm2 >> %LOGFILE% 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to install PM2. Exiting script. | tee -a %LOGFILE%
    pause
    exit /b 1
)

REM Ensure PM2 is available in PATH for the current session
set PATH=%APPDATA%\npm;%PATH%

REM Start the app with PM2
echo Starting the printer-server with PM2... | tee -a %LOGFILE%
pm2 start dist/src/index.js --name "printer-server" >> %LOGFILE% 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to start printer-server with PM2. Exiting script. | tee -a %LOGFILE%
    pause
    exit /b 1
)

REM Save PM2 process list and set up startup
echo Saving PM2 process list... | tee -a %LOGFILE%
pm2 save >> %LOGFILE% 2>&1

echo Setting up PM2 to start on boot... | tee -a %LOGFILE%
FOR /F "tokens=*" %%i IN ('pm2 startup windows -u %USERNAME% --hp %USERPROFILE%') DO %%i >> %LOGFILE% 2>&1

REM Start the app immediately
echo Starting the app immediately... | tee -a %LOGFILE%
pm2 start printer-server >> %LOGFILE% 2>&1

echo Script execution completed successfully. Check %LOGFILE% for details. | tee -a %LOGFILE%

REM Keep the window open to view messages and log output
pause
