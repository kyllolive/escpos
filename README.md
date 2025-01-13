# Print Server Setup Instructions

1. Install Zadig (USB driver manager)
   - Download from https://zadig.akeo.ie/
   - Use it to install the correct USB drivers for your printer

2. Run setup.bat
   - This will install Chocolatey, Node.js, and other required dependencies
   - Follow the prompts and select "Y" when asked to setup the Node server

3. The server will be automatically configured by setup.bat
   - It will install dependencies
   - Build the project
   - Start PM2 with proper configuration

4. Setup auto-start (only needed once):
   - Copy `startup-print.bat` to your desktop
   - Create a shortcut of that file
   - Press Win+R, type `shell:startup` and press Enter
   - Move the shortcut to the startup folder

5. Verify installation:
   - Open a terminal and run: `pm2 list`
   - You should see "print-server" running
   - Run: `pm2 startup` and follow the instructions
   - Run: `pm2 save` to save the current process list
