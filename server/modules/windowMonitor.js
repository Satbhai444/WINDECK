const { exec } = require('child_process');

let previousApp = '';

// We use a persistent PowerShell process to avoid spawning a new one every 2 seconds, saving CPU.
let psProcess = null;

function startWindowMonitor(io) {
    const psScript = `
        Add-Type @"
          using System;
          using System.Runtime.InteropServices;
          public class Window {
            [DllImport("user32.dll")]
            public static extern IntPtr GetForegroundWindow();
            [DllImport("user32.dll", CharSet=CharSet.Auto)]
            public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder text, int count);
            [DllImport("user32.dll")]
            public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
          }
"@;
        while($true) {
            $hwnd = [Window]::GetForegroundWindow();
            if ($hwnd -ne 0) {
                $text = New-Object System.Text.StringBuilder 256;
                if ([Window]::GetWindowText($hwnd, $text, 256) -gt 0) {
                    $title = $text.ToString();
                    $pid = 0;
                    [Window]::GetWindowThreadProcessId($hwnd, [ref]$pid);
                    $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue;
                    if ($proc) {
                        $name = $proc.Name + ".exe";
                        Write-Output "$name|$title";
                    }
                }
            }
            Start-Sleep -Seconds 2
        }
    `;

    psProcess = exec(`powershell -NoProfile -Command "${psScript.replace(/\n/g, ' ')}"`);
    console.log('[WindowMonitor] Active window polling started via PowerShell');

    psProcess.stdout.on('data', (data) => {
        try {
            const parts = data.trim().split('\n');
            const latest = parts[parts.length - 1]; // Get most recent if buffered
            if (!latest || !latest.includes('|')) return;

            const [currentApp, title] = latest.split('|', 2);
            if (currentApp && currentApp.toLowerCase() !== previousApp) {
                previousApp = currentApp.toLowerCase();
                io.emit('foreground-app-changed', { exe: previousApp, title: title });
            }
        } catch (error) {
            console.error('[WindowMonitor] Parse error:', error.message);
        }
    });

    psProcess.stderr.on('data', (data) => {
        // Ignore minor PS errors
    });
}

module.exports = { startWindowMonitor };
