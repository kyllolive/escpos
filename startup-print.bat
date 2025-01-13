@echo off
:: Wait for network to be available
timeout /t 30 /nobreak
:: Change to the correct directory (replace with your actual path)
cd /d %~dp0
:: Start PM2 daemon if not running
pm2 ping || pm2 start
:: Resurrect previous processes
pm2 resurrect