filepath = r"D:\WINDECK\server\desktop_ui.html"
with open(filepath, "r", encoding="utf-8") as f:
    html = f.read()

# Add an image tag for the QR code above or below the OTP
old_otp_ui = """                <div class="mt-8">
                    <p class="text-white/40 text-xs tracking-[0.2em] font-medium mb-3 uppercase">Pairing Code</p>
                    <div id="otp-display" class="font-mono text-5xl tracking-widest text-[#0078d4] font-bold">--- ---</div>
                </div>"""

new_otp_ui = """                <div class="mt-8 flex flex-col items-center">
                    <div id="qr-container" class="bg-white p-2 rounded-2xl mb-4 hidden shadow-[0_0_20px_rgba(0,120,212,0.3)]">
                        <img id="qr-display" src="" alt="QR Code" class="w-40 h-40 object-contain rounded-xl" />
                    </div>
                    <p class="text-white/40 text-xs tracking-[0.2em] font-medium mb-3 uppercase">Pairing Code</p>
                    <div id="otp-display" class="font-mono text-5xl tracking-widest text-[#0078d4] font-bold">--- ---</div>
                </div>"""
html = html.replace(old_otp_ui, new_otp_ui)

# Update the IPC listener for otp-update to also set the QR image
old_otp_listener = """        ipcRenderer.on('otp-update', (event, otpData) => {
            let otpStr = typeof otpData === 'string' ? otpData : (otpData.otp || otpData);
            document.getElementById('otp-display').innerText = otpStr.slice(0, 3) + ' ' + otpStr.slice(3);
        });"""

new_otp_listener = """        ipcRenderer.on('otp-update', (event, otpData) => {
            let otpStr = typeof otpData === 'string' ? otpData : (otpData.otp || otpData);
            document.getElementById('otp-display').innerText = otpStr.slice(0, 3) + ' ' + otpStr.slice(3);
            
            if (otpData && otpData.qr) {
                const qrContainer = document.getElementById('qr-container');
                const qrImg = document.getElementById('qr-display');
                qrImg.src = otpData.qr;
                qrContainer.classList.remove('hidden');
            }
        });"""
html = html.replace(old_otp_listener, new_otp_listener)

with open(filepath, "w", encoding="utf-8") as f:
    f.write(html)
