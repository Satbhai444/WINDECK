import os

with open(r"D:\WINDECK\VibeCodeDetector\popup.html", "r", encoding="utf-8") as html_file:
    html = html_file.read()

# Add roast box below verdict
html = html.replace(
    '<div id="verdict" class="verdict">Analyzing...</div>',
    '<div id="verdict" class="verdict">Analyzing...</div>\n      <div id="roast-box" style="font-style: italic; font-size: 13px; margin: 10px 0; padding: 8px; background: rgba(0,0,0,0.2); border-radius: 8px; color: #d4d4d8;"></div>'
)

# Add Download Report button next to the copy prompt button
html = html.replace(
    '<button id="copy-prompt-btn" class="copy-btn">Copy Prompt</button>',
    '<button id="download-report-btn" class="copy-btn" style="margin-right: 8px; background: #3b82f6; border-color: #2563eb; color: white;">📄 Download Report</button>\n        <button id="copy-prompt-btn" class="copy-btn">Copy Prompt</button>'
)

with open(r"D:\WINDECK\VibeCodeDetector\popup.html", "w", encoding="utf-8") as html_file:
    html_file.write(html)
