import re
filepath = r"D:\WINDECK\server\desktop_ui.html"
with open(filepath, "r", encoding="utf-8") as f:
    text = f.read()

m = re.search(r"function renderSystemAppsList\(\) \{.*?\n        \}", text, re.DOTALL)
if m:
    with open("D:\\WINDECK\\temp.txt", "w", encoding="utf-8") as f2:
        f2.write(m.group(0))
