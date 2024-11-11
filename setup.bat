@REM @echo off
@REM setlocal

@REM echo Checking if Node.js is installed...
@REM node -v >nul 2>&1
@REM IF %ERRORLEVEL% NEQ 0 (
@REM     echo Node.js is not installed. Attempting to install Node.js...

@REM     REM Check if PowerShell is available and its version
@REM     echo Checking for PowerShell version...
@REM     powershell -Command "$psversion = $PSVersionTable.PSVersion; if ($psversion -and $psversion.Major -ge 3) { exit 0 } else { exit 1 }"
@REM     IF %ERRORLEVEL% EQU 0 (
@REM         echo PowerShell 3.0 or higher detected. Downloading Node.js installer...
@REM         powershell -Command "Invoke-WebRequest -Uri https://nodejs.org/dist/v18.17.1/node-v18.17.1-x64.msi -OutFile nodejs_installer.msi"
@REM     ) ELSE (
@REM         echo PowerShell 3.0 or higher is not available. Using bitsadmin for download...
@REM         bitsadmin /transfer "NodeJS Download" https://nodejs.org/dist/v18.17.1/node-v18.17.1-x64.msi %cd%\nodejs_installer.msi
@REM     )

@REM     echo Installing Node.js...
@REM     msiexec /i nodejs_installer.msi /quiet /norestart

@REM     echo Cleaning up Node.js installer file...
@REM     del nodejs_installer.msi

@REM     echo Adding Node.js to PATH...
@REM     setx PATH "%PATH%;%ProgramFiles%\nodejs"
@REM ) ELSE (
@REM     echo Node.js is already installed.
@REM )

@REM REM Verify Node.js installation
@REM echo Verifying Node.js installation...
@REM node -v >nul 2>&1
@REM IF %ERRORLEVEL% NEQ 0 (
@REM     echo Node.js installation failed. Exiting script.
@REM     pause
@REM     exit /b 1
@REM )

@REM REM Navigate to the app directory
@REM echo Navigating to the application directory...
@REM cd /d %~dp0

@REM echo Installing application dependencies with npm...
@REM npm install

@REM echo Building the application...
@REM npm run build

@REM echo Installing pm2 globally...
@REM npm install -g pm2

@REM REM Ensure PM2 is available in PATH for the current session
@REM set PATH=%APPDATA%\npm;%PATH%

@REM echo Starting the printer-server with pm2...
@REM pm2 start dist/src/index.js --name "printer-server"

@REM echo Saving pm2 process list...
@REM pm2 save

@REM echo Setting up pm2 to start on boot...
@REM FOR /F "tokens=*" %%i IN ('pm2 startup windows -u %USERNAME% --hp %USERPROFILE%') DO %%i

@REM echo Starting the app immediately...
@REM pm2 start printer-server

@REM echo Script execution completed successfully.

@REM REM Keep the window open to view messages
@REM pause


set NULL_VAL=null
set NODE_VER=%NULL_VAL%
set NODE_EXEC=node-v18.17.1-x64.msi

node -v >.tmp_nodever
set /p NODE_VER=<.tmp_nodever
del .tmp_nodever

IF "%NODE_VER%"=="%NULL_VAL%" (
	echo.
	echo Node.js is not installed! Please press a key to download and install it from the website that will open.
	PAUSE
	start "" http://nodejs.org/dist/v10.15.3/%NODE_EXEC%
	echo.
	echo.
	echo After you have installed Node.js, press a key to shut down this process. Please restart it again afterwards.
	PAUSE
	EXIT
) ELSE (
	echo A version of Node.js ^(%NODE_VER%^) is installed. Proceeding...
)