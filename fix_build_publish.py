filepath = r"D:\WINDECK\server\package.json"
with open(filepath, "r", encoding="utf-8") as f:
    text = f.read()

text = text.replace('"build": "npm run build:css && electron-builder --win"', '"build": "npm run build:css && electron-builder --win -p never"')

with open(filepath, "w", encoding="utf-8") as f:
    f.write(text)
