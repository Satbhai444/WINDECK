import os

with open(r"D:\WINDECK\VibeCodeDetector\popup.js", "r", encoding="utf-8") as f:
    js = f.read()

# Replace alert with injecting into DOM
js = js.replace(
    '''alert("Error: " + chrome.runtime.lastError.message + "\\n\\nMake sure you are on a standard webpage (not chrome:// settings). Refresh the page and try again.");''',
    '''document.getElementById('verdict').textContent = "Connection Error"; document.getElementById('verdict').style.color = "red"; document.getElementById('loading').innerHTML = "<p style='color:red; font-size:12px; margin-top:10px;'>Please REFRESH the webpage you are trying to scan, then click scan again.</p>"; loadingDiv.style.display = "block";'''
)

js = js.replace(
    '''alert("Scan failed: " + response.error);''',
    '''document.getElementById('verdict').textContent = "Scan Failed"; loadingDiv.innerHTML = "<p style='color:red; font-size:12px; margin-top:10px;'>" + response.error + "</p>"; loadingDiv.style.display = "block";'''
)

with open(r"D:\WINDECK\VibeCodeDetector\popup.js", "w", encoding="utf-8") as f:
    f.write(js)
