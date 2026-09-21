import json
import re

# server/package.json
with open(r"D:\WINDECK\server\package.json", "r", encoding="utf-8") as f:
    server_pkg = json.load(f)
server_pkg["version"] = "2.3.10"
with open(r"D:\WINDECK\server\package.json", "w", encoding="utf-8") as f:
    json.dump(server_pkg, f, indent=2)

# android/pubspec.yaml
with open(r"D:\WINDECK\android\pubspec.yaml", "r", encoding="utf-8") as f:
    pubspec = f.read()
pubspec = re.sub(r"version: 2\.3\.9\+1", "version: 2.3.10+1", pubspec)
with open(r"D:\WINDECK\android\pubspec.yaml", "w", encoding="utf-8") as f:
    f.write(pubspec)

# server/desktop_ui.html
with open(r"D:\WINDECK\server\desktop_ui.html", "r", encoding="utf-8") as f:
    html = f.read()
html = html.replace("v2.3.9", "v2.3.10")
with open(r"D:\WINDECK\server\desktop_ui.html", "w", encoding="utf-8") as f:
    f.write(html)

# website/index.html
with open(r"D:\WINDECK\website\index.html", "r", encoding="utf-8") as f:
    web = f.read()
web = web.replace("v2.3.9", "v2.3.10")
with open(r"D:\WINDECK\website\index.html", "w", encoding="utf-8") as f:
    f.write(web)
    
# android/lib/screens/home_screen.dart
with open(r"D:\WINDECK\android\lib\screens\home_screen.dart", "r", encoding="utf-8") as f:
    dart = f.read()
dart = dart.replace("v2.3.9", "v2.3.10")
with open(r"D:\WINDECK\android\lib\screens\home_screen.dart", "w", encoding="utf-8") as f:
    f.write(dart)
