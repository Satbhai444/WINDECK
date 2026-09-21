filepath = r"C:\Users\Admin\.gemini\antigravity\brain\ece31fb5-5528-46a3-8517-0b1c17336848\task.md"
with open(filepath, "r", encoding="utf-8") as f:
    text = f.read()

text = text.replace("- [ ] **Task 3: Implement \"Grace Period / Standby Mode\"**", "- [x] **Task 3: Implement \"Grace Period / Standby Mode\"**")
text = text.replace("- [ ] **Task 4: Graceful Error Handling (Android)**", "- [x] **Task 4: Graceful Error Handling (Android)**")

with open(filepath, "w", encoding="utf-8") as f:
    f.write(text)
