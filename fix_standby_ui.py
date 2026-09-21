filepath = r"D:\WINDECK\server\desktop_ui.html"

with open(filepath, "r", encoding="utf-8") as f:
    html = f.read()

old_status_check = """            if (status.connected) {
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
            } else {"""

new_status_check = """            if (status.connected === 'standby') {
                info.innerText = `Standby / Away 🟡`;
                info.classList.remove('text-green-400', 'text-white/70');
                info.classList.add('text-yellow-400');
                
                // Keep the device shown, just change the status text
                const savedName = localStorage.getItem('windeck_custom_device_name');
                document.getElementById('dev-name').innerText = savedName || status.deviceName;
            } else if (status.connected) {
                info.innerText = `Connected`;
                info.classList.add('text-green-400');
                info.classList.remove('text-white/70', 'text-yellow-400');
                btnDis.classList.remove('hidden');
                btnCancel.classList.add('hidden');

                devNone.classList.add('hidden');
                devActive.classList.remove('hidden');
                devActive.classList.add('flex');
                const savedName = localStorage.getItem('windeck_custom_device_name');
                document.getElementById('dev-name').innerText = savedName || status.deviceName;
            } else {"""

html = html.replace(old_status_check, new_status_check)

# Need to ensure that the else block clears the yellow color
old_else = """            } else {
                info.innerText = `Waiting for connection...`;
                info.classList.add('text-white/70');
                info.classList.remove('text-green-400');"""

new_else = """            } else {
                info.innerText = `Waiting for connection...`;
                info.classList.add('text-white/70');
                info.classList.remove('text-green-400', 'text-yellow-400');"""
html = html.replace(old_else, new_else)

with open(filepath, "w", encoding="utf-8") as f:
    f.write(html)
