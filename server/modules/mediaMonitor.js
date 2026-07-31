const { createSessionManager } = require('windows-media-sessions');

function startMediaMonitor(io) {
    const sessionManager = createSessionManager();
    
    sessionManager.onSessionsChanged((sessions) => {
        if (sessions && sessions.length > 0) {
            // Find an active session (e.g., Spotify, Chrome/YouTube)
            const activeSession = sessions.find(s => s.playbackInfo && s.playbackInfo.playbackStatus === 4) || sessions[0];
            
            const mediaData = {
                title: activeSession.mediaProperties?.title || 'Unknown Title',
                artist: activeSession.mediaProperties?.artist || 'Unknown Artist',
                albumTitle: activeSession.mediaProperties?.albumTitle || '',
                sourceApp: activeSession.sourceAppUserModelId || 'Unknown App',
                playbackStatus: activeSession.playbackInfo?.playbackStatus || 0, // 4 = playing, 5 = paused
            };
            
            io.emit('media-update', mediaData);
        }
    });

    console.log('[Media] Monitor started');
}

module.exports = { startMediaMonitor };
