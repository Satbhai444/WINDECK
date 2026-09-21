filepath = r"C:\Users\Admin\.gemini\antigravity\brain\ece31fb5-5528-46a3-8517-0b1c17336848\task.md"
with open(filepath, "r", encoding="utf-8") as f:
    text = f.read()

text = text.replace("- [ ] **Task 6: System Tray Background Service (Windows PC)**", "- [x] **Task 6: System Tray Background Service (Windows PC)** (Cancelled per user request - True Kill instead)")
text = text.replace("- [ ] **Task 7: Auto-App Fetching (PC -> Android)**", "- [x] **Task 7: Auto-App Fetching (PC -> Android)**")
text = text.replace("- [ ] **Task 8: Smart Media Page**", "- [x] **Task 8: Smart Media Page**")

with open(filepath, "w", encoding="utf-8") as f:
    f.write(text)
