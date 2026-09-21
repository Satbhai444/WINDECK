filepath = r"D:\WINDECK\server\desktop_ui.html"
with open(filepath, "r", encoding="utf-8") as f:
    text = f.read()

old_otp = """                          <div class="flex flex-col items-center justify-center py-6 mb-2">
                              <span class="text-[10px] uppercase tracking-widest text-white/40 font-bold block mb-2">Pairing Code</span>
                              <div class="relative">
                                  <div class="absolute inset-0 bg-[#0078d4] opacity-20 blur-2xl rounded-full"></div>
                                  <span id="otp-display" class="relative z-10 text-5xl font-bold tracking-[0.2em] mono text-white leading-none pl-[0.2em] drop-shadow-[0_0_15px_rgba(0,120,212,0.5)]">------</span>
                              </div>
                          </div>"""

new_otp = """                          <div class="flex flex-col items-center justify-center py-4 mb-2">
                              <div id="qr-container" class="hidden mb-4 p-2 bg-white rounded-lg shadow-lg">
                                  <img id="qr-display" class="w-32 h-32" />
                              </div>
                              <span class="text-[10px] uppercase tracking-widest text-white/40 font-bold block mb-2">Pairing Code</span>
                              <div class="relative">
                                  <div class="absolute inset-0 bg-[#0078d4] opacity-20 blur-2xl rounded-full"></div>
                                  <span id="otp-display" class="relative z-10 text-5xl font-bold tracking-[0.2em] mono text-white leading-none pl-[0.2em] drop-shadow-[0_0_15px_rgba(0,120,212,0.5)]">------</span>
                              </div>
                          </div>"""

text = text.replace(old_otp, new_otp)

with open(filepath, "w", encoding="utf-8") as f:
    f.write(text)
