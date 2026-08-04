
        const { ipcRenderer } = require('electron');
        const os = require('os');
        
        let serverStarted = false;

        function showView(id) {
            document.querySelectorAll('.view-section').forEach(el => el.classList.remove('active'));
            document.getElementById(id).classList.add('active');
            
            // Update nav styling
            document.querySelectorAll('.nav-btn').forEach(el => {
                el.classList.remove('bg-[#0078d4]/10', 'text-[#0078d4]');
                el.classList.add('text-white/40');
            });
            const activeNav = document.getElementById('nav-' + id.replace('view-', ''));
            if(activeNav) {
                activeNav.classList.remove('text-white/40');
                activeNav.classList.add('bg-[#0078d4]/10', 'text-[#0078d4]');
            }

            if(id === 'view-settings') {
                const nets = os.networkInterfaces();
                for (const name of Object.keys(nets)) {
                    for (const net of nets[name]) {
                        if (net.family === 'IPv4' && !net.internal) {
                            document.getElementById('settings-local-ip').innerText = net.address;
                            break;
                        }
                    }
                }
            }
        }

        function showSettings() { showView('view-settings'); }

        function initApp() {
            document.getElementById('room-name-input').value = os.hostname();
            showView('view-create-room');
            loadNotifPrefs();
            
            // Check and show What's New modal for v1.1.0
            if (localStorage.getItem('shown_v1_1_whatsnew') !== 'true') {
                document.getElementById('whats-new-modal').classList.remove('hidden');
            }
        }

        function closeWhatsNewModal() {
            document.getElementById('whats-new-modal').classList.add('hidden');
            localStorage.setItem('shown_v1_1_whatsnew', 'true');
        }

        // Window Controls
        function closeApp() { ipcRenderer.send('close-app'); }
        function minimizeApp() { ipcRenderer.send('minimize-app'); }
        function maximizeApp() { ipcRenderer.send('maximize-app'); }

        
        function renameDevice() {
            const currentName = document.getElementById('dev-name').innerText;
            // Create inline modal (prompt() doesn't work in Electron)
            const overlay = document.createElement('div');
            overlay.style.cssText = 'position:fixed;inset:0;z-index:9999;background:rgba(0,0,0,0.7);display:flex;align-items:center;justify-content:center;backdrop-filter:blur(4px)';
            overlay.innerHTML = `
              <div style="background:#161622;border:1px solid rgba(255,255,255,0.1);border-radius:20px;padding:28px;width:320px;box-shadow:0 20px 60px rgba(0,0,0,0.5)">
                <div style="font-size:16px;font-weight:700;color:#fff;margin-bottom:4px">Rename Device</div>
                <div style="font-size:12px;color:rgba(255,255,255,0.4);margin-bottom:16px">Give your phone a custom label</div>
                <input id="rename-input" type="text" value="${currentName}" 
                  style="width:100%;box-sizing:border-box;background:rgba(255,255,255,0.05);border:1px solid rgba(255,255,255,0.15);border-radius:10px;padding:10px 14px;color:#fff;font-size:14px;outline:none;margin-bottom:16px"
                  placeholder="e.g. My OnePlus" />
                <div style="display:flex;gap:8px;justify-content:flex-end">
                  <button id="rename-cancel" style="padding:8px 16px;border-radius:10px;background:rgba(255,255,255,0.05);color:rgba(255,255,255,0.6);border:none;cursor:pointer;font-size:13px">Cancel</button>
                  <button id="rename-save" style="padding:8px 20px;border-radius:10px;background:#0078d4;color:#fff;border:none;cursor:pointer;font-size:13px;font-weight:600">Save</button>
                </div>
              </div>`;
            document.body.appendChild(overlay);
            const input = document.getElementById('rename-input');
            input.focus(); input.select();
            const close = () => document.body.removeChild(overlay);
            document.getElementById('rename-cancel').onclick = close;
            document.getElementById('rename-save').onclick = () => {
                const newName = input.value.trim();
                if (newName) {
                    document.getElementById('dev-name').innerText = newName;
                    localStorage.setItem('windeck_custom_device_name', newName);
                }
                close();
            };
            input.onkeydown = (e) => { if (e.key === 'Enter') document.getElementById('rename-save').click(); if (e.key === 'Escape') close(); };
            overlay.onclick = (e) => { if (e.target === overlay) close(); };
        }

        function saveNotifPref(key, value) {
            localStorage.setItem('windeck_notif_' + key, value ? 'true' : 'false');
        }

        function loadNotifPrefs() {
            ['notif-connect', 'notif-disconnect', 'notif-file'].forEach(key => {
                const saved = localStorage.getItem('windeck_notif_' + key);
                const isOn = saved === null ? (key === 'notif-connect') : saved === 'true';
                const el = document.getElementById(key);
                if (el) el.checked = isOn;
            });
        }


        // Override the connection status to use local storage name
        const originalStatusHandler = (event, status) => { /* handled by replacing the ipc listener body below */ };


        // Server Actions
        function createRoom() {
            const name = document.getElementById('room-name-input').value.trim() || os.hostname();
            ipcRenderer.send('create-room', name);
            serverStarted = true;
            showView('view-dashboard');
        }

        function disconnectDevice() {
            ipcRenderer.send('disconnect-client');
        }

        function cancelRoom() {
            ipcRenderer.send('disconnect-client');
            serverStarted = false;
            showView('view-create-room');
        }

        // IPC Listeners
        ipcRenderer.on('room-created', (event, roomId) => {
            document.getElementById('encoded-room-id').innerText = roomId;
        });

        ipcRenderer.on('otp-update', (event, otp) => {
            document.getElementById('otp-display').innerText = otp.slice(0, 3) + ' ' + otp.slice(3);
        });

        ipcRenderer.on('connection-status', (event, status) => {
            const info = document.getElementById('connection-info');
            const btnDis = document.getElementById('btn-disconnect');
            const btnCancel = document.getElementById('btn-cancel-room');
            
            const devNone = document.getElementById('device-none');
            const devActive = document.getElementById('device-active');
            
            if (status.connected) {
                info.innerText = `Connected`;
                info.classList.add('text-green-400');
                info.classList.remove('text-white/70');
                btnDis.classList.remove('hidden');
                btnCancel.classList.add('hidden');
                
                devNone.classList.add('hidden');
                devActive.classList.remove('hidden');
                devActive.classList.add('flex');
                const savedName = localStorage.getItem('windeck_custom_device_name');
                document.getElementById('dev-name').innerText = savedName || status.deviceName;
            } else {
                info.innerText = 'Waiting for device...';
                info.classList.remove('text-green-400');
                info.classList.add('text-white/70');
                btnDis.classList.add('hidden');
                btnCancel.classList.remove('hidden');

                devNone.classList.remove('hidden');
                devActive.classList.add('hidden');
                devActive.classList.remove('flex');
            }
        });

        ipcRenderer.on('telemetry-update', (event, data) => {
            if(!serverStarted) return;
            document.getElementById('stat-cpu').innerText = data.cpuUsage;
            document.getElementById('bar-cpu').style.width = data.cpuUsage + '%';
            
            document.getElementById('stat-ram').innerText = data.ramUsage;
            document.getElementById('bar-ram').style.width = data.ramUsage + '%';
        });

        // -----------------------------------------
        // Editor Logic
        // -----------------------------------------
        // SVG Icon Generator for PC Editor UI
        function getSvgIcon(iconKey) {
            const svgs = {
                'lock': '<svg class="w-6 h-6 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>',
                'sleep': '<svg class="w-6 h-6 text-yellow-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"/></svg>',
                'restart': '<svg class="w-6 h-6 text-cyan-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>',
                'shutdown': '<svg class="w-6 h-6 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/></svg>',
                'screen-record': '<svg class="w-6 h-6 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><circle cx="12" cy="12" r="9" stroke-width="2"/><circle cx="12" cy="12" r="4" fill="currentColor"/></svg>',
                'screenshot': '<svg class="w-6 h-6 text-teal-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z"/><circle cx="12" cy="13" r="3" stroke-width="2"/></svg>',
                'show-desktop': '<svg class="w-6 h-6 text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/></svg>',
                'mute': '<svg class="w-6 h-6 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2"/></svg>',
                'volume-down': '<svg class="w-6 h-6 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.536 8.464a5 5 0 010 7.072M12 6l-4.707 4.707H4v4h3.293L12 19V6z"/></svg>',
                'volume-up': '<svg class="w-6 h-6 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.536 8.464a5 5 0 010 7.072M17.95 6.05a8 8 0 010 11.9M12 6l-4.707 4.707H4v4h3.293L12 19V6z"/></svg>',
                'media-play-pause': '<svg class="w-6 h-6 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>',
                'media-prev': '<svg class="w-6 h-6 text-cyan-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 19l-7-7 7-7m8 14l-7-7 7-7"/></svg>',
                'media-next': '<svg class="w-6 h-6 text-cyan-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5l7 7-7 7M5 5l7 7-7 7"/></svg>',
                'brightness-down': '<svg class="w-6 h-6 text-orange-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"/></svg>',
                'brightness-up': '<svg class="w-6 h-6 text-amber-300" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"/></svg>',
                'mic': '<svg class="w-6 h-6 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z"/></svg>',
                'video': '<svg class="w-6 h-6 text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"/></svg>',
                'hand': '<svg class="w-6 h-6 text-yellow-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 11.5V14m0-2.5v-6a1.5 1.5 0 113 0m-3 6a1.5 1.5 0 00-3 0v2a7.5 7.5 0 0015 0v-5a1.5 1.5 0 00-3 0m-6-3V11m0-5.5a1.5 1.5 0 013 0v4.5M13 11V5.5a1.5 1.5 0 013 0V11"/></svg>',
                'chat': '<svg class="w-6 h-6 text-teal-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/></svg>',
                'captions': '<svg class="w-6 h-6 text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z"/></svg>',
                'phone-off': '<svg class="w-6 h-6 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 8l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2M5 3a2 2 0 00-2 2v1c0 8.284 6.716 15 15 15h1a2 2 0 002-2v-3.28a1 1 0 00-.684-.948l-4.493-1.498a1 1 0 00-1.21.502l-1.13 2.257a11.042 11.042 0 01-5.516-5.517l2.257-1.128a1 1 0 00.502-1.21L9.228 3.684A1 1 0 008.279 3H5z"/></svg>',
                'smartphone': '<svg class="w-6 h-6 text-pink-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z"/></svg>',
                'globe': '<svg class="w-6 h-6 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"/></svg>',
                'upload': '<svg class="w-6 h-6 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12"/></svg>',
                'mouse-pointer': '<svg class="w-6 h-6 text-pink-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 15l-2 5L9 9l11 4-5 2zm0 0l5 5M7.188 2.239l.777 2.897M5.136 7.965l-2.898-.777M13.95 4.05l-2.122 2.122m-5.657 5.656l-2.12 2.122"/></svg>',
                'timer': '<svg class="w-6 h-6 text-yellow-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>'
            };
            return svgs[iconKey] || svgs[iconKey.toLowerCase()] || `<svg class="w-6 h-6 text-white/60" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/></svg>`;
        }

        let layoutData = [];
        let currentPageIndex = 0;
        let systemApps = [];

        const systemControls = [
            { id: 'lock', title: 'Lock PC', icon: 'lock', payload: 'lock' },
            { id: 'sleep', title: 'Sleep', icon: 'sleep', payload: 'sleep' },
            { id: 'restart', title: 'Restart', icon: 'restart', payload: 'restart' },
            { id: 'shutdown', title: 'Shutdown', icon: 'shutdown', payload: 'shutdown' },
            { id: 'screen_record', title: 'Record Screen', icon: 'screen-record', payload: 'screen-record' },
            { id: 'screenshot', title: 'Screenshot', icon: 'screenshot', payload: 'screenshot' },
            { id: 'show_desktop', title: 'Show Desktop', icon: 'show-desktop', payload: 'show-desktop' },
            { id: 'mute', title: 'Mute', icon: 'mute', payload: 'mute' },
            { id: 'vol_down', title: 'Vol Down', icon: 'volume-down', payload: 'volume-down' },
            { id: 'vol_up', title: 'Vol Up', icon: 'volume-up', payload: 'volume-up' },
            { id: 'play_pause', title: 'Play/Pause', icon: 'media-play-pause', payload: 'media-play-pause' },
            { id: 'prev', title: 'Previous', icon: 'media-prev', payload: 'media-prev' },
            { id: 'next', title: 'Next', icon: 'media-next', payload: 'media-next' },
            { id: 'bright_down', title: 'Dim Screen', icon: 'brightness-down', payload: 'brightness-down' },
            { id: 'bright_up', title: 'Brighten', icon: 'brightness-up', payload: 'brightness-up' },
            { id: 'dropzone', type: 'dropzone', title: 'DropZone', icon: 'upload', payload: 'dropzone' },
            { id: 'airmouse', type: 'airmouse', title: 'AirMouse', icon: 'mouse-pointer', payload: 'airmouse' },
            { id: 'webcam', type: 'webcam', title: 'Webcam', icon: 'video', payload: 'webcam' },
            { id: 'timer_25', type: 'timer', title: 'Timer 25m', icon: 'timer', payload: '25' }
        ];

        function createDefaultPage(name, type, linkedExe, titlePattern) {
            return {
                id: 'page_' + Math.random().toString(36).substr(2, 9),
                name: name,
                type: type,
                linkedExe: linkedExe || null,
                titlePattern: titlePattern || null,
                tiles: Array(8).fill(null).map((_, i) => ({
                    id: 'empty_' + Math.random().toString(36).substr(2, 9),
                    type: 'empty',
                    title: '',
                    iconValue: '',
                    payload: ''
                }))
            };
        }

        function createContextPage(name, type, linkedExe, titlePattern, tiles) {
            return {
                id: 'page_' + Math.random().toString(36).substr(2, 9),
                name: name,
                type: type,
                linkedExe: linkedExe || null,
                titlePattern: titlePattern || null,
                tiles: tiles
            };
        }

        function renderEditor() {
            if (layoutData.length === 0) {
                layoutData.push(createDefaultPage("Apps", "apps"));
                layoutData.push(createDefaultPage("System", "system"));

                // Pre-configured Google Meet page
                layoutData.push(createContextPage("Google Meet", "custom", "chrome.exe", "Meet", [
                    { id: 'meet_1', type: 'macro', title: 'Toggle Mic', iconValue: 'mic', payload: '$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys("^d")' },
                    { id: 'meet_2', type: 'macro', title: 'Toggle Video', iconValue: 'video', payload: '$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys("^e")' },
                    { id: 'meet_3', type: 'macro', title: 'Raise Hand', iconValue: 'hand', payload: '$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys("^%h")' },
                    { id: 'meet_4', type: 'macro', title: 'Chat', iconValue: 'chat', payload: '$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys("^%c")' },
                    { id: 'meet_5', type: 'macro', title: 'Captions', iconValue: 'captions', payload: '$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys("c")' },
                    { id: 'meet_6', type: 'macro', title: 'End Call', iconValue: 'phone-off', payload: '$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys("^w")' },
                    { id: 'meet_7', type: 'empty', title: '', iconValue: '', payload: '' },
                    { id: 'meet_8', type: 'empty', title: '', iconValue: '', payload: '' },
                ]));

                // Pre-configured YouTube page
                layoutData.push(createContextPage("YouTube", "custom", "chrome.exe", "YouTube", [
                    { id: 'yt_1', type: 'macro', title: 'Play/Pause', iconValue: 'media-play-pause', payload: '$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys(" ")' },
                    { id: 'yt_2', type: 'macro', title: 'Fullscreen', iconValue: 'show-desktop', payload: '$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys("f")' },
                    { id: 'yt_3', type: 'macro', title: 'Mute', iconValue: 'mute', payload: '$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys("m")' },
                    { id: 'yt_4', type: 'macro', title: 'Captions', iconValue: 'captions', payload: '$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys("c")' },
                    { id: 'yt_5', type: 'macro', title: 'Skip 10s', iconValue: 'media-next', payload: '$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys("l")' },
                    { id: 'yt_6', type: 'macro', title: 'Rewind 10s', iconValue: 'media-prev', payload: '$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys("j")' },
                    { id: 'yt_7', type: 'macro', title: 'Next Video', iconValue: 'media-next', payload: '$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys("+n")' },
                    { id: 'yt_8', type: 'macro', title: 'Miniplayer', iconValue: 'smartphone', payload: '$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys("i")' },
                ]));
            }
            
            // Backward compatibility migration for missing types
            layoutData.forEach(page => {
                if (!page.type) {
                    const lower = (page.name || '').toLowerCase();
                    if (lower.includes('system')) page.type = 'system';
                    else if (lower.includes('apps')) page.type = 'apps';
                    else if (lower.includes('website') || lower.includes('web')) page.type = 'websites';
                    else page.type = 'custom';
                }
            });
            
            // Ensure Websites page exists
            if (!layoutData.find(p => p.type === 'websites')) {
                layoutData.push(createDefaultPage("Websites", "websites"));
            }

            if (currentPageIndex >= layoutData.length) currentPageIndex = layoutData.length - 1;
            if (currentPageIndex < 0) currentPageIndex = 0;

            const page = layoutData[currentPageIndex];
            document.getElementById('page-name-input').value = page.name;

            const grid = document.getElementById('phone-grid');
            grid.innerHTML = '';
            
            page.tiles.forEach((tile, index) => {
                const slot = document.createElement('div');
                slot.className = 'w-full aspect-square rounded-2xl border-2 border-dashed border-white/20 flex flex-col items-center justify-center p-2 relative transition-all cursor-pointer hover:bg-white/5';
                slot.dataset.index = index;
                
                // Dropzone handlers
                slot.ondragover = (e) => { e.preventDefault(); slot.classList.add('border-[#0078d4]', 'bg-[#0078d4]/10'); };
                slot.ondragleave = (e) => { slot.classList.remove('border-[#0078d4]', 'bg-[#0078d4]/10'); };
                slot.ondrop = (e) => onDropTile(e, index);

                // Click handler for URL Editor
                slot.onclick = (e) => {
                    if (e.target.tagName === 'BUTTON' || e.target.closest('button')) return;
                    
                    if (tile && tile.type === 'url') {
                        openUrlModal(index, tile.title, tile.payload);
                    } else if (!tile || tile.type === 'empty') {
                        if (page.type === 'websites') {
                            openUrlModal(index, '', '');
                        }
                    }
                };

                if (tile && tile.type !== 'empty') {
                    slot.classList.remove('border-dashed', 'border-white/20');
                    slot.classList.add('border-white/10', 'bg-white/5');
                    
                    let iconHtml = '';
                    if (tile.type === 'app') {
                        iconHtml = `<img src="http://localhost:3000/icon?path=${encodeURIComponent(tile.payload)}" class="w-10 h-10 mb-2 object-contain" onerror="this.outerHTML='<div class=\\'w-10 h-10 mb-2 flex items-center justify-center bg-white/10 rounded-xl\\'>⚙️</div>'">`;
                    } else {
                        iconHtml = `<div class="mb-1">${getSvgIcon(tile.iconValue || tile.payload)}</div>`;
                    }

                    slot.innerHTML = `
                        ${iconHtml}
                        <span class="text-[10px] font-medium text-white/80 text-center w-full truncate px-1">${tile.title}</span>
                        <button onclick="removeTile(${index})" class="absolute -top-2 -right-2 w-6 h-6 bg-red-500 rounded-full text-white text-xs flex items-center justify-center opacity-0 hover:opacity-100 transition-opacity z-10">&times;</button>
                    `;
                    // Make existing tiles hoverable to show remove button
                    slot.onmouseenter = () => { const b = slot.querySelector('button'); if(b) b.style.opacity = '1'; };
                    slot.onmouseleave = () => { const b = slot.querySelector('button'); if(b) b.style.opacity = '0'; };
                } else {
                    slot.innerHTML = `<span class="text-white/10 text-xl">+</span>`;
                }
                
                grid.appendChild(slot);
            });
        }

        function removeTile(index) {
            layoutData[currentPageIndex].tiles[index] = {
                id: 'empty_' + Math.random().toString(36).substr(2, 9),
                type: 'empty',
                title: '', iconValue: '', payload: ''
            };
            renderEditor();
        }

        // URL Modal Logic
        function openUrlModal(index, title, url) {
            document.getElementById('url-modal-slot-index').value = index;
            document.getElementById('url-modal-title-input').value = title;
            document.getElementById('url-modal-url-input').value = url;
            
            const isEdit = title !== '' || url !== '';
            document.getElementById('url-modal-title').innerText = isEdit ? 'Edit Website' : 'Add Website';
            document.getElementById('url-modal-delete-btn').style.display = isEdit ? 'block' : 'none';
            
            document.getElementById('url-modal').classList.remove('hidden');
        }

        function closeUrlModal() {
            document.getElementById('url-modal').classList.add('hidden');
        }

        function saveUrlModal() {
            const index = parseInt(document.getElementById('url-modal-slot-index').value);
            let title = document.getElementById('url-modal-title-input').value.trim();
            let url = document.getElementById('url-modal-url-input').value.trim();
            
            if (!title || !url) {
                alert('Title and URL are required.');
                return;
            }
            if (!url.startsWith('http://') && !url.startsWith('https://')) {
                url = 'https://' + url;
            }
            
            layoutData[currentPageIndex].tiles[index] = {
                id: 'tile_' + Math.random().toString(36).substr(2, 9),
                type: 'url',
                title: title,
                iconValue: '🌐',
                payload: url
            };
            closeUrlModal();
            renderEditor();
            saveLayout();
        }

        function deleteUrlModal() {
            const index = parseInt(document.getElementById('url-modal-slot-index').value);
            removeTile(index);
            closeUrlModal();
            saveLayout();
        }

        function onDropTile(e, targetIndex) {
            e.preventDefault();
            const slot = document.querySelector(`[data-index="${targetIndex}"]`);
            if(slot) slot.classList.remove('border-[#0078d4]', 'bg-[#0078d4]/10');
            
            const dataStr = e.dataTransfer.getData("application/json");
            if (!dataStr) return;
            try {
                const data = JSON.parse(dataStr);
                let tile = {
                    id: 'tile_' + Math.random().toString(36).substr(2, 9),
                    type: data.type,
                    title: data.title,
                    iconType: data.type === 'app' ? 'exe' : (data.iconValue ? 'emoji' : 'icon'),
                    iconValue: data.type === 'app' ? data.payload : (data.iconValue || ''),
                    payload: data.payload
                };
                layoutData[currentPageIndex].tiles[targetIndex] = tile;
                renderEditor();
                saveLayout();
            } catch(err) { console.error(err); }
        }

        function setAssetTab(tab) {
            document.querySelectorAll('.asset-tab').forEach(el => {
                el.classList.remove('text-[#0078d4]', 'border-[#0078d4]');
                el.classList.add('text-white/40', 'border-transparent');
            });
            const activeTab = document.getElementById('tab-' + tab);
            activeTab.classList.remove('text-white/40', 'border-transparent');
            activeTab.classList.add('text-[#0078d4]', 'border-[#0078d4]');

            document.querySelectorAll('.asset-list').forEach(el => el.classList.add('hidden'));
            document.getElementById('asset-list-' + tab).classList.remove('hidden');

            if (tab === 'apps' && systemApps.length === 0) {
                ipcRenderer.send('request-apps');
            }
        }

        function onDragStartApp(e, index) {
            const app = systemApps[index];
            e.dataTransfer.setData("application/json", JSON.stringify({
                type: 'app', title: app.name, payload: app.path
            }));
        }

        function onDragStartSystem(e, index) {
            const sys = systemControls[index];
            e.dataTransfer.setData("application/json", JSON.stringify({
                type: sys.type || 'system', title: sys.title, iconType: 'emoji', iconValue: sys.icon, payload: sys.payload
            }));
        }

        function onDragStartWeb(e) {
            const title = document.getElementById('web-title').value || 'Website';
            const url = document.getElementById('web-url').value || 'https://google.com';
            e.dataTransfer.setData("application/json", JSON.stringify({
                type: 'url', title: title, iconType: 'emoji', iconValue: 'globe', payload: url
            }));
        }

        function renderSystemControls() {
            const container = document.getElementById('asset-list-system');
            container.innerHTML = '';
            systemControls.forEach((sys, i) => {
                const div = document.createElement('div');
                div.className = 'cursor-grab bg-white/5 border border-white/10 rounded-xl p-3 flex flex-col items-center justify-center text-center transition-all hover:bg-white/10 hover:-translate-y-1';
                div.draggable = true;
                div.ondragstart = (e) => onDragStartSystem(e, i);
                div.innerHTML = `<div class="mb-1">${getSvgIcon(sys.icon)}</div><span class="text-[10px] font-semibold text-white/80 truncate w-full px-1">${sys.title}</span>`;
                container.appendChild(div);
            });
        }

        ipcRenderer.on('system-apps-data', (event, apps) => {
            systemApps = apps || [];
            const container = document.getElementById('asset-list-apps');
            container.innerHTML = '';

            if (systemApps.length === 0) {
                container.innerHTML = '<div class="col-span-3 text-center text-white/40 text-sm py-4">No apps found</div>';
                return;
            }

            systemApps.forEach((app, i) => {
                const div = document.createElement('div');
                div.className = 'cursor-grab bg-white/5 border border-white/10 rounded-xl p-3 flex flex-col items-center justify-center text-center transition-all hover:bg-white/10 hover:-translate-y-1';
                div.draggable = true;
                div.ondragstart = (e) => onDragStartApp(e, i);
                div.innerHTML = `
                    <img src="http://localhost:3000/icon?path=${encodeURIComponent(app.path)}" class="w-8 h-8 mb-2 object-contain pointer-events-none" onerror="this.style.display='none'">
                    <span class="text-[10px] font-semibold text-white/80 truncate w-full px-1 pointer-events-none">${app.name}</span>
                `;
                container.appendChild(div);
            });

            // Auto-populate Apps page if it has only empty tiles
            if (apps && apps.length > 0 && layoutData && layoutData.length > 0) {
                const appsPage = layoutData.find(p => p.type === 'apps');
                if (appsPage) {
                    const allEmpty = appsPage.tiles.every(t => !t || t.type === 'empty');
                    if (allEmpty) {
                        apps.slice(0, 8).forEach((app, i) => {
                            appsPage.tiles[i] = {
                                id: 'tile_auto_' + Math.random().toString(36).substr(2, 9),
                                type: 'app',
                                title: app.name,
                                iconType: 'exe',
                                iconValue: app.path,
                                payload: app.path
                            };
                        });
                        renderEditor();
                        saveLayout();
                    }
                }
            }
        });

        ipcRenderer.on('layout-data', (event, data) => {
            if (data && data.length > 0) {
                layoutData = data;
            }
            renderEditor();
        });

        function prevPage() { if(currentPageIndex > 0) { currentPageIndex--; renderEditor(); } }
        function nextPage() { if(currentPageIndex < layoutData.length - 1) { currentPageIndex++; renderEditor(); } }
        function addNewPage() {
            layoutData.push(createDefaultPage("New Page", "custom"));
            currentPageIndex = layoutData.length - 1;
            renderEditor();
        }
        function deleteCurrentPage() {
            if(layoutData.length <= 1) return alert('Cannot delete the last page.');
            if(confirm('Are you sure you want to delete this page?')) {
                layoutData.splice(currentPageIndex, 1);
                if(currentPageIndex >= layoutData.length) currentPageIndex = layoutData.length - 1;
                renderEditor();
            }
        }
        function updatePageName() {
            layoutData[currentPageIndex].name = document.getElementById('page-name-input').value;
        }

        function saveLayout() {
            ipcRenderer.send('save-layout', layoutData);
            // visual feedback
            const btn = document.querySelector('button[onclick="saveLayout()"]');
            const oldText = btn.innerText;
            btn.innerText = 'Saved!';
            btn.classList.add('bg-green-500');
            setTimeout(() => {
                btn.innerText = oldText;
                btn.classList.remove('bg-green-500');
            }, 1000);
        }

        const systemControlsMod = require('./modules/systemControls');

        // Mock Phone UI Logic
        let mockPhoneScreenOn = true;
        function toggleMockPhoneScreen() {
            mockPhoneScreenOn = !mockPhoneScreenOn;
            const overlay = document.getElementById('mock-screen-overlay');
            if (mockPhoneScreenOn) {
                overlay.classList.add('opacity-0', 'pointer-events-none');
                overlay.classList.remove('opacity-100', 'pointer-events-auto');
            } else {
                updateMockClock();
                overlay.classList.remove('opacity-0', 'pointer-events-none');
                overlay.classList.add('opacity-100', 'pointer-events-auto');
            }
        }

        let mockVolume = 50;
        let mockVolumeTimeout;
        function triggerMockVolume(up) {
            if (!mockPhoneScreenOn) toggleMockPhoneScreen(); // Wake screen if volume is pressed
            
            if (up) {
                mockVolume = Math.min(100, mockVolume + 10);
                systemControlsMod.executeAction('volume-up');
            } else {
                mockVolume = Math.max(0, mockVolume - 10);
                systemControlsMod.executeAction('volume-down');
            }
            
            const slider = document.getElementById('mock-volume-slider');
            const fill = document.getElementById('mock-volume-fill');
            
            fill.style.height = mockVolume + '%';
            slider.classList.remove('opacity-0', '-translate-x-4');
            slider.classList.add('opacity-100', 'translate-x-0');
            
            clearTimeout(mockVolumeTimeout);
            mockVolumeTimeout = setTimeout(() => {
                slider.classList.remove('opacity-100', 'translate-x-0');
                slider.classList.add('opacity-0', '-translate-x-4');
            }, 2000);
        }

        // Real-time Clock and Battery for mock status bar
        function updateMockClock() {
            const now = new Date();
            const timeStr = now.getHours().toString().padStart(2, '0') + ':' + now.getMinutes().toString().padStart(2, '0');
            document.querySelectorAll('.mock-time').forEach(el => el.innerText = timeStr);
            document.getElementById('mock-screen-time').innerText = timeStr;
        }

        async function updateMockBattery() {
            try {
                if (navigator.getBattery) {
                    const battery = await navigator.getBattery();
                    const level = Math.round(battery.level * 100);
                    const charging = battery.charging;
                    
                    const batteryIconHTML = charging ? 
                        `<svg width="10" height="10" viewBox="0 0 24 24" fill="#34d399"><path d="M20 18V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2h12a2 2 0 002-2z"></path><path fill="#050507" d="M11 16l-3-5h3V6l3 5h-3v5z"></path></svg>` : 
                        `<svg width="10" height="10" viewBox="0 0 24 24" fill="white"><path d="M20 18V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2h12a2 2 0 002-2z"></path><rect x="6" y="8" width="${(level/100)*12}" height="10" fill="#050507"></rect></svg>`;
                    
                    document.getElementById('mock-battery-icon').innerHTML = batteryIconHTML;
                }
            } catch (e) {
                console.error("Battery API error", e);
            }
        }

        setInterval(updateMockClock, 60000);
        updateMockClock();
        updateMockBattery();
        if (navigator.getBattery) {
            navigator.getBattery().then(b => {
                b.addEventListener('levelchange', updateMockBattery);
                b.addEventListener('chargingchange', updateMockBattery);
            });
        }

        // Fetch initial data
        ipcRenderer.send('get-layout');
        ipcRenderer.send('request-apps');
        renderSystemControls();

        initApp();
    
        function handlePcFileSelect(event) {
            const file = event.target.files[0];
            if (file) {
                console.log("Sending file to phone: " + file.path);
                ipcRenderer.send('send-file-to-phone', file.path);
                
                // Show temporary success feedback
                const dropzone = event.target.parentElement;
                const originalHTML = dropzone.innerHTML;
                dropzone.innerHTML = '<div class="text-green-400 font-bold text-sm">Sent!</div>';
                setTimeout(() => {
                    dropzone.innerHTML = originalHTML;
                }, 2000);
            }
        }
        
        // OTA Update Listeners
        ipcRenderer.on('update-available', (event, info) => {
            const banner = document.getElementById('update-banner');
            const text = document.getElementById('update-text');
            banner.classList.remove('hidden');
            text.innerText = `A new version (${info.version || ''}) is downloading...`;
        });
        
        ipcRenderer.on('update-downloaded', (event, info) => {
            const btn = document.getElementById('update-btn');
            const text = document.getElementById('update-text');
            text.innerText = 'Update ready to install!';
            btn.classList.remove('hidden');
        });
        
        function installUpdate() {
            ipcRenderer.send('trigger-update');
        }
