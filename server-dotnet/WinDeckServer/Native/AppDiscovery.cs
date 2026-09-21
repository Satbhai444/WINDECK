using System;
using System.IO;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Linq;

namespace WinDeckServer.Native
{
    public static class AppDiscovery
    {
        public static List<object> GetStartMenuApps()
        {
            var apps = new List<object>();
            var paths = new[]
            {
                Environment.GetFolderPath(Environment.SpecialFolder.CommonPrograms),
                Environment.GetFolderPath(Environment.SpecialFolder.Programs)
            };

            foreach (var path in paths)
            {
                if (Directory.Exists(path))
                {
                    var files = Directory.GetFiles(path, "*.lnk", SearchOption.AllDirectories)
                                         .Where(f => !f.Contains("Uninstall") && !f.Contains("Help"));
                    
                    foreach (var file in files)
                    {
                        apps.Add(new { name = Path.GetFileNameWithoutExtension(file), path = file });
                    }
                }
            }
            return apps;
        }

        public static string ExtractIconBase64(string path)
        {
            try
            {
                using (var icon = Icon.ExtractAssociatedIcon(path))
                {
                    if (icon != null)
                    {
                        using (var bmp = icon.ToBitmap())
                        {
                            using (var ms = new MemoryStream())
                            {
                                bmp.Save(ms, ImageFormat.Png);
                                return "data:image/png;base64," + Convert.ToBase64String(ms.ToArray());
                            }
                        }
                    }
                }
            }
            catch { }
            return null;
        }
    }
}
