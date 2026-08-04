const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');
const os = require('os');

async function getStartMenuApps() {
    return new Promise((resolve) => {
        const script = `
            $apps = @{}
            $shell = New-Object -COM WScript.Shell
            
            # 1. Resolve Start Menu shortcuts (.lnk files) to get real .exe paths
            $folders = @(
                [Environment]::GetFolderPath('StartMenu'),
                [Environment]::GetFolderPath('CommonStartMenu')
            )
            foreach ($f in $folders) {
                if (Test-Path $f) {
                    Get-ChildItem -Path $f -Filter *.lnk -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                        $name = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
                        try {
                            $shortcut = $shell.CreateShortcut($_.FullName)
                            $target = $shortcut.TargetPath
                            if ($target -and (Test-Path $target) -and ($target.EndsWith('.exe'))) {
                                $apps[$name] = @{
                                    name = $name
                                    path = $target
                                    iconPath = $target
                                }
                            }
                        } catch {}
                    }
                }
            }

            # 2. Get UWP & Store apps from Get-StartApps
            Get-StartApps | ForEach-Object {
                if (-not $apps.ContainsKey($_.Name)) {
                    $apps[$_.Name] = @{
                        name = $_.Name
                        path = $_.AppID
                        iconPath = $_.AppID
                    }
                }
            }

            $result = @()
            foreach ($key in $apps.Keys) {
                $result += [PSCustomObject]@{
                    name = $apps[$key].name
                    path = $apps[$key].path
                    iconPath = $apps[$key].iconPath
                }
            }
            $result | ConvertTo-Json -Compress
        `;
        const buffer = Buffer.from(script, 'utf16le');
        const encoded = buffer.toString('base64');
        exec('powershell -NoProfile -EncodedCommand ' + encoded, { maxBuffer: 1024 * 1024 * 20 }, (err, stdout) => {
            if (err) return resolve([]);
            try {
                let list = JSON.parse(stdout);
                if (!Array.isArray(list)) list = [list];
                const formatted = list
                    .filter(a => a && a.name && a.path && !a.name.startsWith('ms-resource:'))
                    .sort((a, b) => a.name.localeCompare(b.name));
                resolve(formatted);
            } catch (e) {
                resolve([]);
            }
        });
    });
}

async function extractIcon(exePath) {
    return new Promise((resolve, reject) => {
        const ext = path.extname(exePath);
        const outName = path.basename(exePath, ext) + '.png';
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
