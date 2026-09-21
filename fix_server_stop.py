filepath = r"D:\WINDECK\server\server.js"

with open(filepath, "r", encoding="utf-8") as f:
    code = f.read()

# Make the server export a stop method
old_exports = """module.exports = {
    onOtp,
    onClientConnection,
    onTelemetry,
    regenerateOTP,
    createRoom,
    getEncodedRoomId,
    disconnectClient,
    getAppList,
    sendFileToPhone,
    broadcastLayout
};"""

new_exports = """function stopServer() {
    if (io) {
        io.close();
    }
    if (server) {
        server.close();
    }
    logToFile('[HTTP] Server stopped.');
}

module.exports = {
    onOtp,
    onClientConnection,
    onTelemetry,
    regenerateOTP,
    createRoom,
    getEncodedRoomId,
    disconnectClient,
    getAppList,
    sendFileToPhone,
    broadcastLayout,
    stopServer
};"""

code = code.replace(old_exports, new_exports)

with open(filepath, "w", encoding="utf-8") as f:
    f.write(code)
