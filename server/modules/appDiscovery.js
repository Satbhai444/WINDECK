const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');
const os = require('os');

async function getStartMenuApps() {
    return new Promise((resolve) => {
        const script = `
$apps = @()
$paths = @(
    "$env:ProgramData\\Microsoft\\Windows\\Start Menu\\Programs",
    "$env:APPDATA\\Microsoft\\Windows\\Start Menu\\Programs"
)
$sh = New-Object -ComObject WScript.Shell
foreach ($p in $paths) {
    Get-ChildItem -Path $p -Filter "*.lnk" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 200 | ForEach-Object {
        $lnk = $sh.CreateShortcut($_.FullName)
        $target = [System.Environment]::ExpandEnvironmentVariables($lnk.TargetPath)
        if ($target.EndsWith(".exe")) {
            $apps += @{ name = $_.BaseName; path = $target }
        }
    }
}
$apps | ConvertTo-Json
`;
        const buffer = Buffer.from(script, 'utf16le');
        const encoded = buffer.toString('base64');
        exec('powershell -NoProfile -EncodedCommand ' + encoded, { maxBuffer: 1024 * 1024 * 10 }, (err, stdout) => {
            if (err) return resolve([]);
            try {
                let list = JSON.parse(stdout);
                if (!Array.isArray(list)) list = [list];
                resolve(list.filter(a => a && a.name));
            } catch (e) {
                resolve([]);
            }
        });
    });
}

async function extractIcon(exePath) {
    return new Promise((resolve, reject) => {
        const outName = path.basename(exePath).replace('.exe', '.png');
        const outDir = path.join(os.tmpdir(), 'windeck_icons');
        if (!fs.existsSync(outDir)) fs.mkdirSync(outDir);
        const outPath = path.join(outDir, outName);
        
        if (fs.existsSync(outPath)) return resolve(outPath);

        const script = `
Add-Type -AssemblyName System.Drawing
$code = @"
using System;
using System.Runtime.InteropServices;
using System.Drawing;

public class IconExt {
    [DllImport("shell32.dll", CharSet = CharSet.Auto)]
    public static extern int SHDefExtractIcon(string pszIconFile, int iIndex, uint uFlags, out IntPtr phiconLarge, out IntPtr phiconSmall, uint nIconSize);
    
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool DestroyIcon(IntPtr hIcon);

    public static void Extract(string path, string outPath) {
        IntPtr hLarge, hSmall;
        // Request 256x256 (Jumbo) icon using MAKELONG(256, 256)
        int res = SHDefExtractIcon(path, 0, 0, out hLarge, out hSmall, 16777472);
        if (hLarge != IntPtr.Zero) {
            using (Icon icon = Icon.FromHandle(hLarge)) {
                using (Bitmap bmp = icon.ToBitmap()) {
                    bmp.Save(outPath, System.Drawing.Imaging.ImageFormat.Png);
                }
            }
            DestroyIcon(hLarge);
        } else {
            using (Icon icon = Icon.ExtractAssociatedIcon(path)) {
                using (Bitmap bmp = icon.ToBitmap()) {
                    bmp.Save(outPath, System.Drawing.Imaging.ImageFormat.Png);
                }
            }
        }
        if (hSmall != IntPtr.Zero) DestroyIcon(hSmall);
    }
}
"@
try {
    Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing -ErrorAction SilentlyContinue
} catch {}
try {
    [IconExt]::Extract('${exePath}', '${outPath}')
} catch {
    # Fallback to basic extraction
    try {
        $icon = [System.Drawing.Icon]::ExtractAssociatedIcon('${exePath}')
        if ($icon) {
            $bmp = $icon.ToBitmap()
            $bmp.Save('${outPath}', [System.Drawing.Imaging.ImageFormat]::Png)
            $bmp.Dispose()
            $icon.Dispose()
        }
    } catch {}
}
`;
        const buffer = Buffer.from(script, 'utf16le');
        const encoded = buffer.toString('base64');
        exec('powershell -NoProfile -EncodedCommand ' + encoded, (err) => {
            if (err) return reject(err);
            resolve(outPath);
        });
    });
}

module.exports = { getStartMenuApps, extractIcon };
