const { createSessionManager } = require('windows-media-sessions');
const sessionManager = createSessionManager();
sessionManager.onSessionsChanged((sessions) => {
    if (sessions && sessions.length > 0) {
        console.log(sessions[0].mediaProperties);
        process.exit(0);
    }
});
