filepath = r"D:\WINDECK\server\main.js"
with open(filepath, "r", encoding="utf-8") as f:
    code = f.read()

# Fix window close behavior
old_close = """    mainWindow.on('close', function (event) {
        if (!app.isQuitting) {
            event.preventDefault();
            mainWindow.hide();
        }
    });"""

new_close = """    mainWindow.on('close', function (event) {
        // Kill the app entirely for now (until we build proper System Tray logic in Task 6)
        app.isQuitting = true;
        app.quit();
    });"""

code = code.replace(old_close, new_close)

# Stop the server properly before quit
old_quit = """app.on('window-all-closed', function () {
    if (process.platform !== 'darwin') app.quit();
});"""

new_quit = """app.on('before-quit', () => {
    if (serverInstance && serverInstance.stopServer) {
        serverInstance.stopServer();
    }
});

app.on('window-all-closed', function () {
    if (process.platform !== 'darwin') app.quit();
});"""

code = code.replace(old_quit, new_quit)

with open(filepath, "w", encoding="utf-8") as f:
    f.write(code)
