using System;
using System.Drawing;
using System.Runtime.InteropServices;

namespace IconExtractor {
    class Program {
        [DllImport("shell32.dll", CharSet = CharSet.Auto)]
        public static extern int SHDefExtractIcon(string pszIconFile, int iIndex, uint uFlags, out IntPtr phiconLarge, out IntPtr phiconSmall, uint nIconSize);
        
        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool DestroyIcon(IntPtr hIcon);

        static void Main(string[] args) {
            if (args.Length < 2) return;
            string path = args[0];
            string outPath = args[1];

            // Resolve .lnk
            if (path.EndsWith(".lnk", StringComparison.OrdinalIgnoreCase)) {
                Type shellType = Type.GetTypeFromProgID("WScript.Shell");
                dynamic shell = Activator.CreateInstance(shellType);
                var shortcut = shell.CreateShortcut(path);
                if (shortcut != null) {
                    string iconLoc = shortcut.IconLocation;
                    bool iconLocUsed = false;
                    if (!string.IsNullOrEmpty(iconLoc)) {
                        string[] parts = iconLoc.Split(',');
                        string iconPath = parts[0].Trim();
                        if (System.IO.File.Exists(iconPath)) {
                            path = iconPath;
                            iconLocUsed = true;
                        }
                    }
                    if (!iconLocUsed && !string.IsNullOrEmpty(shortcut.TargetPath)) {
                        path = shortcut.TargetPath;
                    }
                }
            }

            IntPtr hLarge, hSmall;
            // nIconSize = (256 << 16) | 256
            int res = SHDefExtractIcon(path, 0, 0, out hLarge, out hSmall, 16777472);
            if (hLarge != IntPtr.Zero) {
                using (Icon icon = Icon.FromHandle(hLarge)) {
                    using (Bitmap bmp = icon.ToBitmap()) {
                        bmp.Save(outPath, System.Drawing.Imaging.ImageFormat.Png);
                    }
                }
                DestroyIcon(hLarge);
                if (hSmall != IntPtr.Zero) DestroyIcon(hSmall);
                return;
            }

            // Fallback
            try {
                using (Icon icon = Icon.ExtractAssociatedIcon(path)) {
                    using (Bitmap bmp = icon.ToBitmap()) {
                        bmp.Save(outPath, System.Drawing.Imaging.ImageFormat.Png);
                    }
                }
            } catch {}
        }
    }
}
