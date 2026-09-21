filepath = r"D:\WINDECK\server\server.js"

with open(filepath, "r", encoding="utf-8") as f:
    code = f.read()

# We need a global variable to hold the standby timeout
code = code.replace("let activeClientSocket = null;", "let activeClientSocket = null;\nlet standbyTimeout = null;\nlet currentConnectedDevice = null;")

# Update authentication success to clear standby timeout
auth_success_old = """        if (cleanSubmitted === cleanCurrent) {
            failedAttempts = 0;
            socket.authenticated = true;
            activeClientSocket = socket;
            
            logToFile(`[Socket] Client authenticated successfully: ${deviceName}`);
            socket.emit('authenticated', { success: true });

            if (connectionCallback) connectionCallback(true, deviceName);
        } else {"""

auth_success_new = """        if (cleanSubmitted === cleanCurrent) {
            failedAttempts = 0;
            socket.authenticated = true;
            activeClientSocket = socket;
            currentConnectedDevice = deviceName;
            
            // Clear any existing standby timeout
            if (standbyTimeout) {
                clearTimeout(standbyTimeout);
                standbyTimeout = null;
                logToFile(`[Socket] Standby timeout cleared. Client reconnected.`);
            }
            
            logToFile(`[Socket] Client authenticated successfully: ${deviceName}`);
            socket.emit('authenticated', { success: true });

            if (connectionCallback) connectionCallback(true, deviceName);
        } else {"""
code = code.replace(auth_success_old, auth_success_new)

# Update disconnect event to use standby timeout
disconnect_old = """    socket.on('disconnect', () => {
        logToFile('[Socket] Client disconnected');
        if (socket === activeClientSocket) {
            activeClientSocket = null;
            if (connectionCallback) connectionCallback(false, null);
        }
    });"""

disconnect_new = """    socket.on('disconnect', () => {
        logToFile('[Socket] Client disconnected (entering standby)');
        if (socket === activeClientSocket) {
            activeClientSocket = null;
            
            // Notify UI that we are in standby (grace period)
            if (connectionCallback) connectionCallback('standby', currentConnectedDevice);
            
            // Wait 5 minutes (300,000 ms) before fully disconnecting
            standbyTimeout = setTimeout(() => {
                logToFile('[Socket] Standby timeout expired. Fully disconnecting client.');
                currentConnectedDevice = null;
                if (connectionCallback) connectionCallback(false, null);
                standbyTimeout = null;
            }, 5 * 60 * 1000);
        }
    });"""
code = code.replace(disconnect_old, disconnect_new)

# Update explicit disconnectClient to clear timeout
disconnectClient_old = """    disconnectClient: () => {
        if (activeClientSocket) {
            activeClientSocket.emit('force-disconnect');
            activeClientSocket.disconnect(true);
            activeClientSocket = null;
        }
        if (connectionCallback) connectionCallback(false, null);
    },"""

disconnectClient_new = """    disconnectClient: () => {
        if (standbyTimeout) {
            clearTimeout(standbyTimeout);
            standbyTimeout = null;
        }
        currentConnectedDevice = null;
        if (activeClientSocket) {
            activeClientSocket.emit('force-disconnect');
            activeClientSocket.disconnect(true);
            activeClientSocket = null;
        }
        if (connectionCallback) connectionCallback(false, null);
    },"""
code = code.replace(disconnectClient_old, disconnectClient_new)

with open(filepath, "w", encoding="utf-8") as f:
    f.write(code)
