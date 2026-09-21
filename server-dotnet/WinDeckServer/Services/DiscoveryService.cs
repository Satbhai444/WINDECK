using System;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace WinDeckServer.Services
{
    public class DiscoveryService
    {
        private readonly string _roomId;
        private readonly int _serverPort;
        private UdpClient _udpListener;
        private CancellationTokenSource _cts;

        public DiscoveryService(string roomId, int serverPort)
        {
            _roomId = roomId;
            _serverPort = serverPort;
        }

        public void Start()
        {
            _cts = new CancellationTokenSource();
            StartUdpBroadcastListener();
        }

        public void Stop()
        {
            _cts?.Cancel();
            _udpListener?.Close();
        }

        private void StartUdpBroadcastListener()
        {
            _udpListener = new UdpClient(4444);
            Task.Run(() =>
            {
                while (!_cts.IsCancellationRequested)
                {
                    try
                    {
                        var endPoint = new IPEndPoint(IPAddress.Any, 4444);
                        var bytes = _udpListener.Receive(ref endPoint);
                        var message = Encoding.UTF8.GetString(bytes);

                        if (message == "WINDECK_DISCOVERY_PING")
                        {
                            var response = $"WINDECK_SERVER_INFO:{{\"hostname\":\"{Environment.MachineName}\",\"port\":{_serverPort},\"roomId\":\"{_roomId}\"}}";
                            var responseBytes = Encoding.UTF8.GetBytes(response);
                            _udpListener.Send(responseBytes, responseBytes.Length, endPoint);
                        }
                    }
                    catch (Exception) { /* Ignored on close */ }
                }
            });
        }
    }
}
