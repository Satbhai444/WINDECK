const activeWin = require('active-win');

let previousApp = '';

function startWindowMonitor(io) {
    setInterval(async () => {
        try {
            const win = await activeWin();
            if (win && win.owner && win.owner.name) {
                const currentApp = win.owner.name.toLowerCase();
                if (currentApp !== previousApp) {
                    previousApp = currentApp;
                    io.emit('foreground-app-changed', { exe: currentApp, title: win.title });
                }
            }
        } catch (error) {
            console.error('[WindowMonitor] Error getting active window:', error.message);
        }
    }, 2000); // Check every 2 seconds

    console.log('[WindowMonitor] Active window polling started');
}

module.exports = { startWindowMonitor };
