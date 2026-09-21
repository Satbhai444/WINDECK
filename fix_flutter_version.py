filepath = r"D:\WINDECK\.github\workflows\release.yml"
with open(filepath, "r", encoding="utf-8") as f:
    text = f.read()

old_flutter = """      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.0'
          channel: 'stable'
          cache: true"""

new_flutter = """      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          cache: true"""

text = text.replace(old_flutter, new_flutter)

with open(filepath, "w", encoding="utf-8") as f:
    f.write(text)
