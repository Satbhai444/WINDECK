import os

files_to_update = [
    r"D:\WINDECK\.github\ISSUE_TEMPLATE\bug_report.md",
    r"D:\WINDECK\release\latest.yml",
    r"D:\WINDECK\server\desktop_ui.html",
    r"D:\WINDECK\website\index.html",
    r"D:\WINDECK\android\lib\screens\home_screen.dart"
]

replacements = {
    "v2.3.8": "v2.3.9",
    "v2.3.7": "v2.3.9",
    "2.3.8": "2.3.9",
    "2.3.7": "2.3.9"
}

for filepath in files_to_update:
    if not os.path.exists(filepath): continue
    with open(filepath, "r", encoding="utf-8") as f:
        text = f.read()
    
    for old, new in replacements.items():
        text = text.replace(old, new)
        
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(text)

# Now custom replace the "What's New" content in home_screen.dart
home_path = r"D:\WINDECK\android\lib\screens\home_screen.dart"
with open(home_path, "r", encoding="utf-8") as f:
    home_text = f.read()

old_whats_new = """Text("What's New in v2.3.9", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            const Text("• Added multi-page support\\n• New drag-and-drop editor\\n• Active window detection\\n• Custom page layouts\\n• Polished UI design", 
              style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),"""

new_whats_new = """Text("What's New in v2.3.9", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            const Text("🚀 What's New\\n• QR Code Pairing: Connect instantly without typing codes!\\n• Standby Mode: App waits 5 minutes before disconnecting when minimized.\\n\\n🛠️ What We Fixed\\n• Fixed 'Zombie Server' memory leak on Windows.\\n• Fixed infinite Notification Permission loop.\\n• Much smoother error messages.", 
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),"""

home_text = home_text.replace(old_whats_new, new_whats_new)
with open(home_path, "w", encoding="utf-8") as f:
    f.write(home_text)

# Also update desktop_ui.html's what's new
desktop_path = r"D:\WINDECK\server\desktop_ui.html"
with open(desktop_path, "r", encoding="utf-8") as f:
    desktop_text = f.read()

old_desktop_new = """const whatsNewItems = [
                'Added Multi-Page Support: Create and organize multiple dashboards!',
                'New Layout Editor: Drag & Drop tiles and pages effortlessly.',
                'Active Window Detection: See which app is running on PC from your phone.',
                'New Custom Page Type: Build any layout from scratch.',
                'Major UI Polish: Smoother animations and glassmorphism.'
            ];"""

new_desktop_new = """const whatsNewItems = [
                '🚀 QR Code Pairing: Generate QR to instantly pair with phone.',
                '🚀 Standby Mode: PC waits gracefully if phone connection drops.',
                '🛠️ Fixed Zombie Server: Processes correctly terminate on close.',
                '🛠️ Auto-Start Disabled: Server waits for manual start.'
            ];"""

desktop_text = desktop_text.replace(old_desktop_new, new_desktop_new)

with open(desktop_path, "w", encoding="utf-8") as f:
    f.write(desktop_text)

print("Versions updated successfully")
