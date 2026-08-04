const { contextBridge, ipcRenderer } = require('electron');
const os = require('os');

contextBridge.exposeInMainWorld('electronAPI', {
    send: (channel, data) => {
        let validChannels = ['close-app', 'minimize-app', 'maximize-app', 'create-room', 'disconnect-client', 'get-layout', 'request-apps', 'send-file-to-phone', 'save-layout', 'trigger-update', 'execute-system-action'];
        if (validChannels.includes(channel)) {
            ipcRenderer.send(channel, data);
        }
    },
    on: (channel, func) => {
        let validChannels = ['room-created', 'otp-update', 'connection-status', 'telemetry-update', 'update-available', 'update-downloaded', 'update-error', 'layout-data', 'system-apps-data'];
        if (validChannels.includes(channel)) {
            // Pass a dummy event object as the first parameter so the frontend callbacks (event, arg) don't get shifted arguments.
            ipcRenderer.on(channel, (event, ...args) => func({}, ...args));
        }
    },
    openExternal: (url) => require('electron').shell.openExternal(url),
    getHostname: () => os.hostname(),
    getLocalIPs: () => {
        const nets = os.networkInterfaces();
        let ips = [];
        for (const name of Object.keys(nets)) {
            for (const net of nets[name]) {
                if (net.family === 'IPv4' && !net.internal) {
                    ips.push(net.address);
                }
            }
        }
        return ips;
    }
});
