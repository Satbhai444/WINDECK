Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$screen = [System.Windows.Forms.Screen]::PrimaryScreen
$bounds = $screen.Bounds
$bitmap = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)

$graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)

$outputDir = "C:\Users\Admin\OneDrive\Desktop\WINDECK\website\images"
if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Force -Path $outputDir
}

$outputPath = Join-Path $outputDir "pc-app-screenshot.png"
$bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)

$graphics.Dispose()
$bitmap.Dispose()

Write-Host "Screenshot captured successfully at $outputPath"
