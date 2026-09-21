import os

filepath = r"D:\WINDECK\android\android\app\src\main\AndroidManifest.xml"
with open(filepath, "r", encoding="utf-8") as f:
    xml = f.read()

if "<uses-permission android:name=\"android.permission.CAMERA\" />" not in xml:
    xml = xml.replace("<application", "<uses-permission android:name=\"android.permission.CAMERA\" />\n    <application")
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(xml)
