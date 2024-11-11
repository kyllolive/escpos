@echo off

REM Check if Node.js is installed
node -v >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Node.js is not installed. Installing Node.js...
    REM Download and install Node.js (replace with the correct version and URL)
    powershell -Command "Start-Process 'https://nodejs.org/dist/v18.17.1/node-v18.17.1-x64.msi' -Wait -NoNewWindow"
)

REM Navigate to the app directory
cd /d %~dp0


echo Installing dependencies...
npm install

echo Building the application...
npm run build

echo Installing pm2...
npm install -g pm2

echo Starting the printer-server with pm2...
pm2 start dist/src/index.js --name "printer-server"

pm2 save
pm2 startup

REM Run the pm2 startup command
FOR /F "tokens=*" %%i IN ('pm2 startup windows -u %USERNAME% --hp %USERPROFILE%') DO %%i


echo Starting the app immediately...
pm2 start my-app