using System;
using System.Windows;
using Hardcodet.Wpf.TaskbarNotification;
using WinDeckServer.Services;

namespace WinDeckServer
{
    public partial class App : Application
    {
        private TaskbarIcon _notifyIcon;
        private DiscoveryService _discoveryService;
        private NetworkService _networkService;
        public static string CurrentRoomId { get; private set; }

        private void Application_Startup(object sender, StartupEventArgs e)
        {
            _notifyIcon = (TaskbarIcon)FindResource("NotifyIcon");
            
            // Initialize Core Services
            CurrentRoomId = GenerateRoomId();
            _networkService = new NetworkService(4445);
            _networkService.Start();
            
            _discoveryService = new DiscoveryService(CurrentRoomId, 4445);
            _discoveryService.Start();
        }

        private void Application_Exit(object sender, ExitEventArgs e)
        {
            _notifyIcon?.Dispose();
            _networkService?.Stop();
            _discoveryService?.Stop();
        }

        private string GenerateRoomId()
        {
            var rand = new Random();
            return rand.Next(100000, 999999).ToString();
        }

        private void ShowQR_Click(object sender, RoutedEventArgs e)
        {
            var qrWindow = new MainWindow();
            qrWindow.Show();
        }

        private void Exit_Click(object sender, RoutedEventArgs e)
        {
            Application.Current.Shutdown();
        }
    }
}
