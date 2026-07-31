const { app, BrowserWindow, ipcMain, Tray, Menu } = require('electron');
const path = require('path');
const { autoUpdater } = require('electron-updater');

let mainWindow;
let serverInstance;
let tray = null;

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 1000,
        height: 700,
        minWidth: 800,
        minHeight: 600,
        frame: false,
        resizable: true,
        backgroundColor: '#0c0c0e',
        icon: path.join(__dirname, 'icon.png'),
        webPreferences: {
            nodeIntegration: true,
            contextIsolation: false
        }
    });

    mainWindow.loadFile('desktop_ui.html');

    mainWindow.on('close', function (event) {
        if (!app.isQuitting) {
            event.preventDefault();
            mainWindow.hide();
        }
    });

    mainWindow.on('closed', function () {
        mainWindow = null;
    });

    // Start the WinDeck Server once the window is ready
    mainWindow.webContents.once('did-finish-load', () => {
        // Start the server and register event callbacks
        serverInstance = require('./server.js');
        
        // Register connection changes and OTP updates
        serverInstance.onOtp((otp) => {
            if (mainWindow) mainWindow.webContents.send('otp-update', otp);
        });

        serverInstance.onClientConnection((connected, deviceName) => {
            if (mainWindow) mainWindow.webContents.send('connection-status', { connected, deviceName });
        });

        serverInstance.onTelemetry((data) => {
            if (mainWindow) mainWindow.webContents.send('telemetry-update', data);
        });
        
        // Auto Updater Events
        autoUpdater.on('update-available', (info) => {
            if (mainWindow) mainWindow.webContents.send('update-available', info);
        });
        autoUpdater.on('update-downloaded', (info) => {
            if (mainWindow) mainWindow.webContents.send('update-downloaded', info);
        });
        autoUpdater.on('error', (err) => {
            if (mainWindow) mainWindow.webContents.send('update-error', err.message);
        });
        
        // Check for updates
        autoUpdater.checkForUpdatesAndNotify();
    });
}

app.on('ready', () => {
    app.setAppUserModelId("com.windeck.app"); // Required for Windows Notifications
    createWindow();
    
    tray = new Tray(path.join(__dirname, 'icon.png')); // use the existing icon.png
    const contextMenu = Menu.buildFromTemplate([
        { label: 'Show', click: () => { if (mainWindow) mainWindow.show(); } },
        { label: 'Quit', click: () => { app.isQuitting = true; app.quit(); } }
    ]);
    tray.setToolTip('WinDeck Server');
    tray.setContextMenu(contextMenu);
    
    tray.on('double-click', () => {
        if (mainWindow) mainWindow.show();
    });
});

app.on('window-all-closed', function () {
    if (process.platform !== 'darwin') app.quit();
});

app.on('activate', function () {
    if (mainWindow === null) createWindow();
});

// IPC handlers
ipcMain.on('close-app', () => {
    if (mainWindow) {
        mainWindow.hide();
    }
});

ipcMain.on('minimize-app', () => {
    if (mainWindow) {
        mainWindow.hide();
    }
});

ipcMain.on('maximize-app', () => {
    if (mainWindow) {
        if (mainWindow.isMaximized()) {
            mainWindow.unmaximize();
        } else {
            mainWindow.maximize();
        }
    }
});

ipcMain.on('regenerate-otp', () => {
    if (serverInstance) {
        serverInstance.regenerateOTP();
    }
});

ipcMain.on('create-room', (event, roomName) => {
    if (serverInstance) {
        serverInstance.createRoom(roomName);
        event.reply('room-created', serverInstance.getEncodedRoomId());
    }
});

ipcMain.on('disconnect-client', () => {
    if (serverInstance) {
        serverInstance.disconnectClient();
    }
});

const fs = require('fs');
const layoutPath = path.join(app.getPath('userData'), 'layout.json');

ipcMain.on('get-layout', (event) => {
    if (fs.existsSync(layoutPath)) {
        try {
            const data = fs.readFileSync(layoutPath, 'utf8');
            event.reply('layout-data', JSON.parse(data));
        } catch (err) {
            console.error('Failed to read layout:', err);
            event.reply('layout-data', []);
        }
    } else {
        event.reply('layout-data', []);
    }
});

ipcMain.on('save-layout', (event, layout) => {
    try {
        fs.writeFileSync(layoutPath, JSON.stringify(layout));
        if (serverInstance) {
            serverInstance.broadcastLayout(layout);
        }
    } catch (err) {
        console.error('Failed to save layout:', err);
    }
});

ipcMain.on('request-apps', async (event) => {
    try {
        if (!serverInstance) {
            serverInstance = require('./server.js');
        }
        const apps = await serverInstance.getAppList();
        event.reply('system-apps-data', apps || []);
    } catch (err) {
        console.error('Error fetching apps for Electron UI:', err);
        event.reply('system-apps-data', []);
    }
});

ipcMain.on('send-file-to-phone', (event, filePath) => {
    if (serverInstance) {
        serverInstance.sendFileToPhone(filePath);
    }
});
ipcMain.on('trigger-update', () => {
    autoUpdater.quitAndInstall();
});
