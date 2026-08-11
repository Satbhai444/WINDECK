const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');
const dgram = require('dgram');
const os = require('os');
const Bonjour = require('bonjour-service');
const { startMediaMonitor } = require('./modules/mediaMonitor');
const { startWindowMonitor } = require('./modules/windowMonitor');
const systemControls = require('./modules/systemControls');
const appDiscovery = require('./modules/appDiscovery');
const path = require('path');
const fs = require('fs');
const multer = require('multer');
const { app: electronApp, clipboard, shell } = require('electron');


const logFile = path.join(os.homedir(), 'windeck_debug.log');
function logToFile(msg) {
    fs.appendFileSync(logFile, `[${new Date().toISOString()}] ${msg}\n`);
    // intentionally omitted console.log to avoid infinite recursion if replaced again
}

const app = express();
app.use(cors());
app.use(express.static(path.join(__dirname, 'public')));
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: '*' } });

const PORT = 3000;
const BROADCAST_PORT = 3001;
const serverName = os.hostname();
const SERVER_VERSION = '2.3.8';

// Network & Encoding logic
function getLocalIp() {
    const interfaces = os.networkInterfaces();
    for (const name of Object.keys(interfaces)) {
        const nameLower = name.toLowerCase();
        if (nameLower.includes('vethernet') || nameLower.includes('vmware') || nameLower.includes('virtualbox') || nameLower.includes('tailscale') || nameLower.includes('zerotier')) continue;
        for (const iface of interfaces[name]) {
            if (iface.family === 'IPv4' && !iface.internal) {
                return iface.address;
            }
        }
    }
    return '127.0.0.1';
}

function generateEncodedRoomId() {
    const ip = getLocalIp();
    const parts = ip.split('.');
    if (parts.length !== 4) return 'ERROR';
    const hex = parts.map(p => parseInt(p).toString(16).padStart(2, '0').toUpperCase()).join('');
    return `${hex.slice(0, 4)}-${hex.slice(4)}`; // e.g., C0A8-0064
}

// Connection Callbacks
// OTP and Room management
let currentOtp = '';
let currentRoomName = null;
let udpBroadcastInterval = null;
let otpCallback = null;
let connectionCallback = null;
let telemetryCallback = null;
let activeClientSocket = null;
let lastSetFromPhone = '';
let lastPolledClipboard = '';

function generateOTP() {
    currentOtp = Math.floor(100000 + Math.random() * 900000).toString();
    logToFile(`[OTP] Generated Pairing Code: ${currentOtp}`);
    
    if (otpCallback) {
        otpCallback(currentOtp);
    }
}

// UDP Broadcast for auto-discovery
const udpSocket = dgram.createSocket('udp4');
udpSocket.on('listening', () => {
    udpSocket.setBroadcast(true);
});
udpSocket.bind();

// mDNS/Bonjour discovery setup
const bonjour = new Bonjour.Bonjour();
let bonjourService = null;

// TODO (Future): Consider Bluetooth (RFCOMM/BLE) as a possible future no-WiFi fallback.

function getBroadcastAddresses() {
    const addresses = [];
    const interfaces = os.networkInterfaces();
    for (const name of Object.keys(interfaces)) {
        const nameLower = name.toLowerCase();
        if (nameLower.includes('vethernet') || nameLower.includes('vmware') || nameLower.includes('virtualbox') || nameLower.includes('tailscale') || nameLower.includes('zerotier')) continue;
        for (const iface of interfaces[name]) {
            if (iface.family === 'IPv4' && !iface.internal) {
                const ipParts = iface.address.split('.');
                const maskParts = iface.netmask.split('.');
                const broadcastParts = [];
                for(let i=0; i<4; i++) {
                    broadcastParts.push((parseInt(ipParts[i]) | (~parseInt(maskParts[i]) & 255)));
                }
                addresses.push(broadcastParts.join('.'));
                
                // Hotspot fallback: Directly target the phone's likely gateway IPs
                // in case the Android hotspot blocks subnet broadcasts.
                addresses.push(`${ipParts[0]}.${ipParts[1]}.${ipParts[2]}.1`);
                addresses.push(`${ipParts[0]}.${ipParts[1]}.${ipParts[2]}.254`);
                addresses.push(`${ipParts[0]}.${ipParts[1]}.${ipParts[2]}.43`); // Common Android hotspot IP
            }
        }
    }
    addresses.push('255.255.255.255'); // Standard global broadcast
    return [...new Set(addresses)];
}

function startBroadcasting(roomName) {
    if (udpBroadcastInterval) clearInterval(udpBroadcastInterval);
    currentRoomName = roomName;
    logToFile(`[UDP] Broadcasting room '${currentRoomName}' on port ${BROADCAST_PORT}`);
    
    // Start mDNS advertisement
    if (bonjourService) {
        bonjourService.stop();
        bonjourService = null;
    }
    bonjourService = bonjour.publish({ name: currentRoomName, type: 'windeck', protocol: 'tcp', port: PORT });
    logToFile(`[mDNS] Advertising service _windeck._tcp on port ${PORT}`);

    udpBroadcastInterval = setInterval(() => {
        const message = Buffer.from(JSON.stringify({
            name: currentRoomName, // Broadcast the chosen room name
            port: PORT,
            type: 'windeck-server'
        }));
        
        const targetIps = getBroadcastAddresses();
        targetIps.forEach(ip => {
            try {
                udpSocket.send(message, 0, message.length, BROADCAST_PORT, ip);
            } catch (err) {
                // Ignore send errors for specific IPs
            }
        });
    }, 2000);
}

function stopBroadcasting() {
    if (udpBroadcastInterval) {
        clearInterval(udpBroadcastInterval);
        udpBroadcastInterval = null;
    }
    if (bonjourService) {
        bonjourService.stop();
        bonjourService = null;
    }
}

// Setup Multer for DropZone Uploads
const downloadsFolder = path.join(os.homedir(), 'Downloads', 'WinDeck');
if (!fs.existsSync(downloadsFolder)) {
    fs.mkdirSync(downloadsFolder, { recursive: true });
}

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, downloadsFolder)
    },
    filename: function (req, file, cb) {
        cb(null, Date.now() + '-' + file.originalname)
    }
});
const upload = multer({ storage: storage });

// DropZone file upload endpoint
app.post('/upload', upload.single('file'), (req, res) => {
    const authHeader = req.headers['x-windeck-auth'];
    const cleanAuthHeader = String(authHeader || '').trim();
    const cleanCurrent = String(currentOtp || '').trim();
    
    if (cleanAuthHeader !== cleanCurrent || !cleanCurrent) {
        if (req.file && fs.existsSync(req.file.path)) {
            fs.unlinkSync(req.file.path);
        }
        return res.status(401).send('Unauthorized');
    }

    if (!req.file) {
        return res.status(400).send('No file uploaded');
    }

    logToFile(`[DropZone] File received: ${req.file.originalname}`);
    io.emit('file-received', { filename: req.file.originalname, path: req.file.path });
    
    // Reveal in Windows Explorer
    shell.showItemInFolder(req.file.path);
    
    res.status(200).json({ success: true, path: req.file.path });
});

// PC to Phone File Download Endpoint
app.get('/download-file', (req, res) => {
    const filePath = req.query.path;
    if (!filePath || !fs.existsSync(filePath)) {
        return res.status(404).send('File not found');
    }
    res.download(filePath);
});

// Camera View Endpoint for OBS Virtual Camera
app.get('/camera-view', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>WinDeck Camera Bridge</title>
            <style>
                body, html { margin: 0; padding: 0; width: 100%; height: 100%; background: black; overflow: hidden; display: flex; justify-content: center; align-items: center; }
                img { max-width: 100%; max-height: 100%; object-fit: contain; }
                .waiting { color: white; font-family: sans-serif; opacity: 0.5; }
            </style>
        </head>
        <body>
            <div id="status" class="waiting">Waiting for camera stream...</div>
            <img id="cam" src="" style="display:none;" />
            <script src="/socket.io/socket.io.js"></script>
            <script>
                const socket = io();
                const img = document.getElementById('cam');
                const status = document.getElementById('status');
                
                socket.on('broadcast-camera-frame', (base64Frame) => {
                    if (img.style.display === 'none') {
                        img.style.display = 'block';
                        status.style.display = 'none';
                    }
                    img.src = 'data:image/jpeg;base64,' + base64Frame;
                });
            </script>
        </body>
        </html>
    `);
});

// Icon endpoint
app.get('/icon', async (req, res) => {
    const exePath = req.query.path;
    const name = req.query.name || 'App';
    if (!exePath) return res.status(400).send('Path required');
    
    // Allow extractIcon to handle UWP app IDs (which are not valid physical paths)
    try {
        const iconPath = await appDiscovery.extractIcon(exePath);
        if (fs.existsSync(iconPath)) {
            res.sendFile(iconPath);
        } else {
            throw new Error("Icon extraction failed");
        }
    } catch (e) {
        // Fallback to SVG if extraction fails
        const letter = name.charAt(0).toUpperCase();
        const color = '#0078d4';
        const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64"><rect width="64" height="64" rx="12" fill="${color}"/><text x="50%" y="50%" dominant-baseline="central" text-anchor="middle" font-family="Arial, sans-serif" font-size="32" font-weight="bold" fill="#ffffff">${letter}</text></svg>`;
        res.setHeader('Content-Type', 'image/svg+xml');
        res.send(svg);
    }
});

// Socket.io
io.on('connection', (socket) => {
    logToFile('[Socket] Client connected, awaiting authentication:', socket.id);
    socket.authenticated = false;

    // Handle authentication using OTP    // End-to-End Encryption Setup
    const crypto = require('crypto');
    const algorithm = 'aes-256-cbc';
    const getEncryptionKey = () => crypto.createHash('sha256').update(currentOtp + 'windeck_salt').digest();

    function encrypt(text) {
        const iv = crypto.randomBytes(16);
        const cipher = crypto.createCipheriv(algorithm, getEncryptionKey(), iv);
        let encrypted = cipher.update(JSON.stringify(text), 'utf8', 'hex');
        encrypted += cipher.final('hex');
        return iv.toString('hex') + ':' + encrypted;
    }

    function decrypt(text) {
        let textParts = text.split(':');
        let iv = Buffer.from(textParts.shift(), 'hex');
        let encryptedText = Buffer.from(textParts.join(':'), 'hex');
        const decipher = crypto.createDecipheriv(algorithm, getEncryptionKey(), iv);
        let decrypted = decipher.update(encryptedText, 'hex', 'utf8');
        decrypted += decipher.final('utf8');
        return JSON.parse(decrypted);
    }

    const originalEmit = socket.emit;
    socket.emit = function(eventName, ...args) {
        if (eventName === 'authenticated' || eventName === 'auth_error' || eventName === 'unauthorized') {
            return originalEmit.apply(this, [eventName, ...args]);
        }
        const encryptedArgs = args.map(arg => encrypt(arg));
        return originalEmit.apply(this, [eventName, ...encryptedArgs]);
    };

    socket.use((packet, next) => {
        const eventName = packet[0];
        if (eventName === 'authenticate') return next();
        
        try {
            for (let i = 1; i < packet.length; i++) {
                if (typeof packet[i] === 'string' && packet[i].includes(':')) {
                    packet[i] = decrypt(packet[i]);
                }
            }
            next();
        } catch (e) {
            logToFile('Decryption failed for event:', eventName, e);
            next(new Error('Decryption failed'));
        }
    });

    let failedAttempts = 0;
    let lockoutUntil = 0;

    socket.on('authenticate', (data) => {
        if (Date.now() < lockoutUntil) {
            const remaining = Math.ceil((lockoutUntil - Date.now()) / 1000);
            socket.emit('authenticated', { success: false, error: `Too many failed attempts. PC locked down. Try again in ${remaining}s.` });
            socket.disconnect();
            return;
        }

        const submittedOtp = typeof data === 'object' ? data.otp : data;
        const deviceName = typeof data === 'object' ? data.deviceName : 'Mobile Device';
        const clientVersion = typeof data === 'object' ? data.version : '1.0.0';

        if (clientVersion !== SERVER_VERSION) {
            socket.emit('authenticated', { success: false, error: `Version mismatch. Server is ${SERVER_VERSION}, Client is ${clientVersion}. Please update.` });
            logToFile(`[Socket] Authentication failed for ${deviceName} (Version mismatch)`);
            socket.disconnect();
            return;
        }

        const cleanSubmitted = String(submittedOtp || '').trim();
        const cleanCurrent = String(currentOtp || '').trim();

        if (cleanSubmitted === cleanCurrent) {
            failedAttempts = 0;
            socket.authenticated = true;
            activeClientSocket = socket;
            socket.deviceName = deviceName;
            
            socket.emit('authenticated', { success: true });
            logToFile(`[Socket] Client authenticated successfully: ${deviceName}`);
            
            if (connectionCallback) connectionCallback(true, deviceName);
            
            // Automatically send app list upon successful authentication
            sendAppList(socket);
            sendLayout(socket);
        } else {
            failedAttempts++;
            if (failedAttempts >= 5) {
                logToFile(`[SECURITY] 5 consecutive failed attempts from socket ${socket.id}. Engaging Anti-Brute Force lockout.`);
                systemControls.executeAction('lock');
                lockoutUntil = Date.now() + (5 * 60 * 1000);
                socket.emit('authenticated', { success: false, error: 'Anti-Brute Force triggered. PC is now locked. Try again in 5 minutes.' });
            } else {
                socket.emit('authenticated', { success: false, error: `Incorrect pairing code. (${5 - failedAttempts} attempts remaining)` });
                logToFile(`[Socket] Authentication failed for socket ${socket.id} (Attempt ${failedAttempts}/5)`);
            }
            socket.disconnect();
        }
    });

    socket.on('get-apps', async () => {
        if (!socket.authenticated) return;
        sendAppList(socket);
    });

    socket.on('get-layout', () => {
        if (!socket.authenticated) return;
        sendLayout(socket);
    });

    socket.on('launch-app', (exePath) => {
        if (!socket.authenticated) return;
        systemControls.launchApp(exePath);
    });

    socket.on('system-action', (action) => {
        if (!socket.authenticated) return;
        systemControls.executeAction(action);
    });

    socket.on('custom-macro', (macro) => {
        if (!socket.authenticated) return;
        systemControls.executeMacro(macro);
    });

    socket.on('open-url', (url) => {
        if (!socket.authenticated) return;
        systemControls.openUrl(url);
    });

    socket.on('send-clipboard', (text) => {
        if (!socket.authenticated) return;
        lastSetFromPhone = text;
        lastPolledClipboard = text;
        clipboard.writeText(text);
    });

    // Phase 5: Wireless Air Mouse & Presentation Pointer Events
    socket.on('mouse-move', (data) => {
        if (!socket.authenticated || !data) return;
        systemControls.moveMouse(data.dx, data.dy);
    });

    socket.on('mouse-click', (data) => {
        if (!socket.authenticated || !data) return;
        systemControls.clickMouse(data.button);
    });

    socket.on('mouse-scroll', (data) => {
        if (!socket.authenticated || !data) return;
        systemControls.scrollMouse(data.deltaY);
    });

    socket.on('presentation-control', (action) => {
        if (!socket.authenticated) return;
        systemControls.presentationControl(action);
    });

    // Phase 6: Webcam Bridge Frame Receiver
    socket.on('camera-frame', (base64Frame) => {
        if (!socket.authenticated) return;
        // Broadcast to all clients (including the /camera-view page)
        io.emit('broadcast-camera-frame', base64Frame);
    });

    socket.on('disconnect', () => {
        logToFile('[Socket] Client disconnected');
        if (socket === activeClientSocket) {
            activeClientSocket = null;
            if (connectionCallback) connectionCallback(false, null);
        }
    });
});

async function sendAppList(socket) {
    try {
        const apps = await appDiscovery.getStartMenuApps();
        socket.emit('app-list', apps);
    } catch (e) {
        logToFile('Error fetching apps:', e);
    }
}

function sendLayout(socket) {
    try {
        const layoutPath = path.join(electronApp.getPath('userData'), 'layout.json');
        if (fs.existsSync(layoutPath)) {
            const data = fs.readFileSync(layoutPath, 'utf8');
            socket.emit('sync-layout', JSON.parse(data));
        } else {
            socket.emit('sync-layout', []);
        }
    } catch (err) {
        logToFile('Error reading layout for socket:', err);
    }
}

// Start Monitors
startMediaMonitor(io);
startWindowMonitor(io);

// System Telemetry loop
setInterval(() => {
    const cpus = os.cpus();
    let user = 0, nice = 0, sys = 0, idle = 0, irq = 0;
    for (let cpu in cpus) {
        user += cpus[cpu].times.user;
        nice += cpus[cpu].times.nice;
        sys += cpus[cpu].times.sys;
        irq += cpus[cpu].times.irq;
        idle += cpus[cpu].times.idle;
    }
    const total = user + nice + sys + idle + irq;
    const cpuUsage = Math.round(((total - idle) / total) * 100);
    const ramUsage = Math.round((1 - (os.freemem() / os.totalmem())) * 100);

    const data = {
        serverName,
        cpuUsage: cpuUsage,
        ramUsage: ramUsage
    };

    if (activeClientSocket && activeClientSocket.authenticated) {
        io.emit('status', data);
        
        try {
            const currentClipboard = clipboard.readText();
            if (currentClipboard !== lastPolledClipboard && currentClipboard !== lastSetFromPhone) {
                lastPolledClipboard = currentClipboard;
                io.emit('clipboard-update', currentClipboard);
            }
        } catch (e) { }
    }
    
    if (telemetryCallback) {
        telemetryCallback(data);
    }
}, 2000);

server.on('error', (err) => {
    if (err.code === 'EADDRINUSE') {
        logToFile(`[HTTP] Port ${PORT} is already in use. WinDeck server is already running.`);
    } else {
        logToFile('[HTTP] Server error:', err);
    }
});

server.listen(PORT, '0.0.0.0', () => {
    logToFile(`[HTTP] WinDeck Server listening on port ${PORT}`);
});

// Exports for Electron integration
module.exports = {
    createRoom: (name) => {
        startBroadcasting(name);
        generateOTP();
    },
    getEncodedRoomId: () => generateEncodedRoomId(),
    disconnectClient: () => {
        if (activeClientSocket) {
            activeClientSocket.emit('force-disconnect');
            activeClientSocket.disconnect(true);
            activeClientSocket = null;
        }
        if (connectionCallback) connectionCallback(false, null);
    },
    regenerateOTP: () => generateOTP(),
    onOtp: (cb) => { otpCallback = cb; },
    onClientConnection: (cb) => { connectionCallback = cb; },
    onTelemetry: (cb) => { telemetryCallback = cb; },
    getAppList: async () => {
        return await appDiscovery.getStartMenuApps();
    },
    broadcastLayout: (layout) => {
        io.sockets.sockets.forEach((socket) => {
            if (socket.authenticated) {
                socket.emit('sync-layout', layout);
            }
        });
    },
    sendFileToPhone: (filePath) => {
        if (activeClientSocket && activeClientSocket.authenticated) {
            const ip = getLocalIp();
            const downloadUrl = `http://${ip}:${PORT}/download-file?path=${encodeURIComponent(filePath)}`;
            activeClientSocket.emit('file-offer', downloadUrl);
            logToFile(`[DropZone] Sent file-offer to phone: ${downloadUrl}`);
        } else {
            logToFile(`[DropZone] Cannot send file, no authenticated client connected.`);
        }
    }
};
