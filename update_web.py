filepath = r"D:\WINDECK\website\index.html"
with open(filepath, "r", encoding="utf-8") as f:
    text = f.read()

old_web = """<ul class="space-y-4 text-left">
                                <li class="flex items-start text-white/70">
                                    <div class="mt-1 mr-3 shrink-0 text-[#818cf8]"><i class="fas fa-check-circle"></i></div>
                                    <span class="text-[15px] leading-relaxed"><strong>Multi-Page Support:</strong> Create, name, and organize infinite custom dashboards.</span>
                                </li>
                                <li class="flex items-start text-white/70">
                                    <div class="mt-1 mr-3 shrink-0 text-[#818cf8]"><i class="fas fa-check-circle"></i></div>
                                    <span class="text-[15px] leading-relaxed"><strong>Drag-and-Drop Editor:</strong> Easily rearrange tiles and pages on your PC, syncing instantly to your phone.</span>
                                </li>
                                <li class="flex items-start text-white/70">
                                    <div class="mt-1 mr-3 shrink-0 text-[#818cf8]"><i class="fas fa-check-circle"></i></div>
                                    <span class="text-[15px] leading-relaxed"><strong>Active Window Detection:</strong> See exactly which app is currently active on your PC right from your phone.</span>
                                </li>
                            </ul>"""

new_web = """<ul class="space-y-4 text-left">
                                <li class="flex items-start text-white/70">
                                    <div class="mt-1 mr-3 shrink-0 text-[#818cf8]"><i class="fas fa-check-circle"></i></div>
                                    <span class="text-[15px] leading-relaxed"><strong>🚀 QR Code Pairing:</strong> Scan the QR code on your PC screen to instantly pair without typing.</span>
                                </li>
                                <li class="flex items-start text-white/70">
                                    <div class="mt-1 mr-3 shrink-0 text-[#818cf8]"><i class="fas fa-check-circle"></i></div>
                                    <span class="text-[15px] leading-relaxed"><strong>🚀 Standby Mode:</strong> App won't instantly disconnect when minimized, ensuring a stable connection.</span>
                                </li>
                                <li class="flex items-start text-white/70">
                                    <div class="mt-1 mr-3 shrink-0 text-[#818cf8]"><i class="fas fa-check-circle"></i></div>
                                    <span class="text-[15px] leading-relaxed"><strong>🛠️ Bug Fixes:</strong> Fixed Zombie Server memory leak and Notification Permission loops!</span>
                                </li>
                            </ul>"""
text = text.replace(old_web, new_web)
with open(filepath, "w", encoding="utf-8") as f:
    f.write(text)
