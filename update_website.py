import os

with open(r"D:\WINDECK\website\index.html", "r", encoding="utf-8") as f:
    html = f.read()

# Remove the Star on GitHub button
html = html.replace(
    '''<a href="https://github.com/Satbhai444/WINDECK" target="_blank" class="inline-flex items-center h-[48px] px-8 rounded-full bg-black border border-white/[0.22] text-white text-[15px] font-semibold hover:border-white/40 transition-colors">
                        Star on GitHub ⭐
                    </a>''',
    ""
)

# Change download description text
html = html.replace(
    "Download the free PC Server and Android APK from GitHub.",
    "Download the free PC Server and Android APK securely."
)

with open(r"D:\WINDECK\website\index.html", "w", encoding="utf-8") as f:
    f.write(html)
