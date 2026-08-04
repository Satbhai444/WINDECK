const { spawn, exec } = require('child_process');
const { shell } = require('electron');

// --- Persistent PowerShell Process for instant key sends ---
let psProcess = null;

function initPersistentShell() {
    if (psProcess) return;
    psProcess = spawn('powershell.exe', ['-NoProfile', '-NoLogo', '-NonInteractive', '-Command', '-'], {
        stdio: ['pipe', 'pipe', 'pipe'],
        windowsHide: true,
    });
    // Create the COM object once at startup
    psProcess.stdin.write('$wshell = New-Object -ComObject wscript.shell\n');
    
    // Inject C# class for native mouse control
    const mouseCode = `
$MouseCode = @'
using System;
using System.Runtime.InteropServices;
public class Mouse {
    [DllImport("user32.dll")]
    public static extern void mouse_event(uint dwFlags, int dx, int dy, uint dwData, int dwExtraInfo);
    [DllImport("user32.dll")]
    public static extern bool GetCursorPos(out POINT lpPoint);
    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int X, int Y);
    public struct POINT { public int X; public int Y; }
    public const uint LEFTDOWN = 0x02;
    public const uint LEFTUP = 0x04;
    public const uint RIGHTDOWN = 0x08;
    public const uint RIGHTUP = 0x10;
    public const uint WHEEL = 0x0800;
}
'@
Add-Type -TypeDefinition $MouseCode
`;
    psProcess.stdin.write(mouseCode + '\n');
    
    psProcess.on('error', (err) => {
        console.error('[SystemControls] PowerShell process error:', err);
        psProcess = null;
    });
    psProcess.on('exit', () => {
        console.log('[SystemControls] PowerShell process exited, will restart on next command');
        psProcess = null;
    });
    console.log('[SystemControls] Persistent PowerShell process started');
}

function sendKey(charCode) {
    if (!psProcess) initPersistentShell();
    if (psProcess && psProcess.stdin.writable) {
        psProcess.stdin.write(`$wshell.SendKeys([char]${charCode})\n`);
    }
}

function runPsCommand(cmd) {
    if (!psProcess) initPersistentShell();
    if (psProcess && psProcess.stdin.writable) {
        psProcess.stdin.write(`${cmd}\n`);
    }
}

// Start it immediately
initPersistentShell();

async function executeAction(action) {
    try {
        switch (action) {
            case 'volume-up':
                sendKey(175);
                break;
            case 'volume-down':
                sendKey(174);
                break;
            case 'mute':
                sendKey(173);
                break;
            case 'brightness-up':
                runPsCommand('(Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods).WmiSetBrightness(1, [Math]::Min(100, (Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightness).CurrentBrightness + 10))');
                break;
            case 'brightness-down':
                runPsCommand('(Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods).WmiSetBrightness(1, [Math]::Max(0, (Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightness).CurrentBrightness - 10))');
                break;
            case 'lock':
                exec('rundll32.exe user32.dll,LockWorkStation');
                break;
            case 'sleep':
                exec('rundll32.exe powrprof.dll,SetSuspendState 0,1,0');
                break;
            case 'restart':
                exec('shutdown /r /t 0');
                break;
            case 'shutdown':
                exec('shutdown /s /t 0');
                break;
            case 'screen-record':
                exec('start ms-screenclip:');
                break;
            case 'screenshot':
                exec('snippingtool');
                break;
            case 'show-desktop':
                runPsCommand('(New-Object -ComObject Shell.Application).ToggleDesktop()');
                break;
            case 'media-play-pause':
                sendKey(179);
                break;
            case 'media-next':
                sendKey(176);
                break;
            case 'media-prev':
                sendKey(177);
                break;
        }
    } catch (e) {
        console.error('System control error:', e);
    }
}

function executeMacro(macroScript) {
    // Macros also run through the persistent shell for speed
    if (!psProcess) initPersistentShell();
    if (psProcess && psProcess.stdin.writable) {
        psProcess.stdin.write(`${macroScript}\n`);
    }
}

function launchApp(exePath) {
    if (exePath.includes(':\\') || exePath.toLowerCase().endsWith('.exe')) {
        exec(`"${exePath}"`, (err) => {
            if (err) console.error('Launch app error:', err);
        });
    } else {
        exec(`explorer.exe shell:AppsFolder\\${exePath}`, (err) => {
            if (err) console.error('Launch AppID error:', err);
        });
    }
}

function openUrl(url) {
    shell.openExternal(url).catch(err => console.error('Open URL error:', err));
}

// Phase 5: Wireless Air Mouse & Presentation Pointer
function moveMouse(dx, dy) {
    if (!psProcess) initPersistentShell();
    if (psProcess && psProcess.stdin.writable) {
        const ix = Math.round(dx);
        const iy = Math.round(dy);
        // Optimize by reusing a global $_p variable to avoid object creation overhead on every frame
        psProcess.stdin.write(`if ($null -eq $global:_p) { $global:_p = New-Object Mouse+POINT }; [Mouse]::GetCursorPos([ref]$global:_p) | Out-Null; [Mouse]::SetCursorPos($global:_p.X + ${ix}, $global:_p.Y + ${iy}) | Out-Null\n`);
    }
}

function clickMouse(button = 'left') {
    if (!psProcess) initPersistentShell();
    if (psProcess && psProcess.stdin.writable) {
        if (button === 'left') {
            psProcess.stdin.write(`[Mouse]::mouse_event([Mouse]::LEFTDOWN, 0, 0, 0, 0); [Mouse]::mouse_event([Mouse]::LEFTUP, 0, 0, 0, 0)\n`);
        } else if (button === 'right') {
            psProcess.stdin.write(`[Mouse]::mouse_event([Mouse]::RIGHTDOWN, 0, 0, 0, 0); [Mouse]::mouse_event([Mouse]::RIGHTUP, 0, 0, 0, 0)\n`);
        }
    }
}

function scrollMouse(deltaY) {
    if (!psProcess) initPersistentShell();
    if (psProcess && psProcess.stdin.writable) {
        // MOUSEEVENTF_WHEEL = 0x0800, wheel delta is passed in dwData
        const delta = Math.round(deltaY);
        psProcess.stdin.write(`[Mouse]::mouse_event([Mouse]::WHEEL, 0, 0, ${delta}, 0)\n`);
    }
}

function presentationControl(action) {
    if (action === 'slide-next') sendKey('{PGDN}');
    else if (action === 'slide-prev') sendKey('{PGUP}');
    else if (action === 'presentation-start') sendKey('{F5}');
    else if (action === 'presentation-exit') sendKey('{ESC}');
    else if (action === 'blank-screen') sendKey('B');
}

module.exports = { executeAction, executeMacro, launchApp, openUrl, moveMouse, clickMouse, scrollMouse, presentationControl };
