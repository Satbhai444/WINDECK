filepath = r"D:\WINDECK\server\desktop_ui.html"

with open(filepath, "r", encoding="utf-8") as f:
    html = f.read()

old_code = """            if (savedRoomName) {
                document.getElementById('room-name-input').value = savedRoomName;
                // Auto-start server with saved room name - no button click needed on relaunch
                createRoom();
            } else {
                showView('view-create-room');
            }"""

new_code = """            if (savedRoomName) {
                document.getElementById('room-name-input').value = savedRoomName;
            }
            // Always require manual start to prevent auto-starting the server
            showView('view-create-room');"""

html = html.replace(old_code, new_code)

with open(filepath, "w", encoding="utf-8") as f:
    f.write(html)
