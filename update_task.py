filepath = r"C:\Users\Admin\.gemini\antigravity\brain\ece31fb5-5528-46a3-8517-0b1c17336848\task.md"
with open(filepath, "r", encoding="utf-8") as f:
    text = f.read()

text = text.replace("- [ ] **Task 1: Fix Notification Permission Loop (Android)**", "- [x] **Task 1: Fix Notification Permission Loop (Android)**")

with open(filepath, "w", encoding="utf-8") as f:
    f.write(text)
