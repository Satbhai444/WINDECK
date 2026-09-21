filepath = r"D:\WINDECK\server\server.js"

with open(filepath, "r", encoding="utf-8") as f:
    code = f.read()

# Add qrcode require
code = code.replace("const os = require('os');", "const os = require('os');\nconst qrcode = require('qrcode');")

# Modify generateOTP to also generate QR code and pass it to callback
old_generateOTP = """function generateOTP() {
    currentOtp = Math.floor(100000 + Math.random() * 900000).toString();
    logToFile(`[Core] Generated new OTP: ${currentOtp}`);
    if (otpCallback) otpCallback(currentOtp);
    return currentOtp;
}"""

new_generateOTP = """async function generateOTP() {
    currentOtp = Math.floor(100000 + Math.random() * 900000).toString();
    logToFile(`[Core] Generated new OTP: ${currentOtp}`);
    
    let qrDataUrl = null;
    try {
        const ip = getLocalIp();
        const payload = JSON.stringify({ ip: ip, port: PORT, otp: currentOtp, name: roomName || os.hostname() });
        qrDataUrl = await qrcode.toDataURL(payload, { 
            color: { dark: '#0078d4', light: '#00000000' },
            margin: 1,
            width: 200
        });
    } catch (e) {
        console.error('Failed to generate QR:', e);
    }

    if (otpCallback) otpCallback({ otp: currentOtp, qr: qrDataUrl });
    return currentOtp;
}"""
code = code.replace(old_generateOTP, new_generateOTP)

with open(filepath, "w", encoding="utf-8") as f:
    f.write(code)
