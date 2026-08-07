const fs = require('fs');
const path = require('path');
const { exec, execFile } = require('child_process');
const os = require('os');

function getStartMenuApps() {
    return new Promise((resolve, reject) => {
        const script = `
$paths = @(
    "$env:ProgramData\\Microsoft\\Windows\\Start Menu\\Programs",
    "$env:APPDATA\\Microsoft\\Windows\\Start Menu\\Programs"
)
$apps = @()
foreach ($p in $paths) {
    if (Test-Path $p) {
        $apps += Get-ChildItem -Path $p -Filter "*.lnk" -Recurse | Where-Object { 
            $_.Name -notmatch "Uninstall" -and $_.Name -notmatch "Help"
        } | Select-Object -Property @{Name="name";Expression={$_.BaseName}}, @{Name="path";Expression={$_.FullName}}
    }
}
$uwp = Get-StartApps | Select-Object -Property @{Name="name";Expression={$_.Name}}, @{Name="path";Expression={$_.AppID}}
$all = $apps + $uwp | Sort-Object -Property name -Unique
$all | ConvertTo-Json
`;
        const buffer = Buffer.from(script, 'utf16le');
        const encoded = buffer.toString('base64');
        exec('powershell -NoProfile -EncodedCommand ' + encoded, { maxBuffer: 1024 * 1024 * 10 }, (error, stdout) => {
            if (error) {
                console.error("Error fetching apps:", error);
                return resolve([]);
            }
            try {
                const parsed = JSON.parse(stdout);
                resolve(Array.isArray(parsed) ? parsed : [parsed]);
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

        // UWP App (has '!' in AppID)
        if (exePath.includes('!')) {
            const script = `
$appId = '${exePath}'
try {
    $baseId = $appId.Split('_')[0]
    $searchName = $baseId.Split('.')[-1]
    $pkg = Get-AppxPackage -Name "*$searchName*" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($pkg) {
        $manifestPath = Join-Path $pkg.InstallLocation "AppxManifest.xml"
        if (Test-Path $manifestPath) {
            [xml]$manifest = Get-Content $manifestPath -ErrorAction SilentlyContinue
            $logo = $manifest.Package.Properties.Logo
            if ($logo) {
                $logoPath = Join-Path $pkg.InstallLocation $logo
                if (Test-Path $logoPath) {
                    Copy-Item $logoPath -Destination '${outPath}' -Force
                    return
                }
                $logoBase = [System.IO.Path]::GetFileNameWithoutExtension($logo)
                $logoDir = [System.IO.Path]::GetDirectoryName((Join-Path $pkg.InstallLocation $logo))
                if (Test-Path $logoDir) {
                    $matches = Get-ChildItem -Path $logoDir -Filter "$logoBase*.png" | Select-Object -First 1
                    if ($matches) {
                        Copy-Item $matches.FullName -Destination '${outPath}' -Force
                        return
                    }
                }
            }
        }
    }
} catch {}
`;
            const buffer = Buffer.from(script, 'utf16le');
            const encoded = buffer.toString('base64');
            exec('powershell -NoProfile -EncodedCommand ' + encoded, (err) => {
                if (err) return reject(err);
                resolve(outPath);
            });
            return;
        }

        // Win32 App (using our fast C# extractor)
        const extractorPath = path.join(__dirname, '..', 'icon_extractor.exe');
        if (fs.existsSync(extractorPath)) {
            execFile(extractorPath, [exePath, outPath], (err) => {
                if (err) return reject(err);
                resolve(outPath);
            });
        } else {
            // Fallback if extractor doesn't exist
            reject(new Error("icon_extractor.exe not found"));
        }
    });
}

module.exports = { getStartMenuApps, extractIcon };
