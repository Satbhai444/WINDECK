using System.Windows;
using System.Windows.Media.Imaging;
using System.IO;
using QRCoder;
using System.Drawing;

namespace WinDeckServer
{
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
            LoadQrCode();
        }

        private void LoadQrCode()
        {
            string roomId = App.CurrentRoomId;
            RoomIdText.Text = $"Room ID: {roomId}";

            using (var qrGenerator = new QRCodeGenerator())
            {
                var qrCodeData = qrGenerator.CreateQrCode($"WINDECK:{roomId}", QRCodeGenerator.ECCLevel.Q);
                using (var qrCode = new QRCode(qrCodeData))
                {
                    using (var qrBitmap = qrCode.GetGraphic(20))
                    {
                        using (var ms = new MemoryStream())
                        {
                            qrBitmap.Save(ms, System.Drawing.Imaging.ImageFormat.Png);
                            ms.Position = 0;
                            var bitmapImage = new BitmapImage();
                            bitmapImage.BeginInit();
                            bitmapImage.StreamSource = ms;
                            bitmapImage.CacheOption = BitmapCacheOption.OnLoad;
                            bitmapImage.EndInit();
                            QrImage.Source = bitmapImage;
                        }
                    }
                }
            }
        }
    }
}
