using System;
using System.Net;
using System.Net.WebSockets;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Concurrent;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using WinDeckServer.Native;

namespace WinDeckServer.Services
{
    public class NetworkService
    {
        private readonly int _port;
        private HttpListener _listener;
        private CancellationTokenSource _cts;
        private ConcurrentDictionary<string, WebSocket> _clients = new ConcurrentDictionary<string, WebSocket>();
        private MediaMonitor _mediaMonitor;

        public NetworkService(int port)
        {
            _port = port;
        }

        public void Start()
        {
            _cts = new CancellationTokenSource();
            _listener = new HttpListener();
            _listener.Prefixes.Add($"http://*:{_port}/ws/");
            _listener.Start();
            
            _mediaMonitor = new MediaMonitor();
            _mediaMonitor.OnMediaUpdate += (data) => BroadcastAll("media-update", data);
            _ = _mediaMonitor.StartAsync();

            Task.Run(() => AcceptConnectionsAsync(_cts.Token));
        }

        public void Stop()
        {
            _cts?.Cancel();
            _listener?.Stop();
        }

        private async Task AcceptConnectionsAsync(CancellationToken token)
        {
            while (!token.IsCancellationRequested)
            {
                try
                {
                    var context = await _listener.GetContextAsync();
                    if (context.Request.IsWebSocketRequest)
                    {
                        var wsContext = await context.AcceptWebSocketAsync(null);
                        var socket = wsContext.WebSocket;
                        string clientId = Guid.NewGuid().ToString();
                        _clients.TryAdd(clientId, socket);
                        
                        _ = Task.Run(() => HandleClientAsync(clientId, socket, token));
                    }
                    else
                    {
                        context.Response.StatusCode = 400;
                        context.Response.Close();
                    }
                }
                catch (Exception) when (token.IsCancellationRequested) { break; }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error accepting connection: {ex.Message}");
                }
            }
        }

        private async Task HandleClientAsync(string clientId, WebSocket socket, CancellationToken token)
        {
            var buffer = new byte[1024 * 64]; 
            try
            {
                while (socket.State == WebSocketState.Open && !token.IsCancellationRequested)
                {
                    var result = await socket.ReceiveAsync(new ArraySegment<byte>(buffer), token);
                    if (result.MessageType == WebSocketMessageType.Close)
                    {
                        await socket.CloseAsync(WebSocketCloseStatus.NormalClosure, "Closed", token);
                        break;
                    }
                    
                    var message = Encoding.UTF8.GetString(buffer, 0, result.Count);
                    ProcessMessage(clientId, message);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Client disconnected: {ex.Message}");
            }
            finally
            {
                _clients.TryRemove(clientId, out _);
                socket.Dispose();
            }
        }

        private void ProcessMessage(string clientId, string rawMessage)
        {
            try
            {
                var map = JsonConvert.DeserializeObject<JObject>(rawMessage);
                if (map == null) return;
                
                string eventName = map["event"]?.ToString();
                var data = map["data"];

                if (eventName == "authenticate")
                {
                    BroadcastToClient(clientId, "authenticated", new { success = true });
                }
                else if (eventName == "mouse-move")
                {
                    int dx = data?["dx"]?.ToObject<int>() ?? 0;
                    int dy = data?["dy"]?.ToObject<int>() ?? 0;
                    SystemControls.MoveMouse(dx, dy);
                }
                else if (eventName == "mouse-click")
                {
                    string button = data?["button"]?.ToString() ?? "left";
                    SystemControls.ClickMouse(button);
                }
                else if (eventName == "mouse-scroll")
                {
                    int deltaY = data?["deltaY"]?.ToObject<int>() ?? 0;
                    SystemControls.ScrollMouse(deltaY);
                }
                else if (eventName == "system-control")
                {
                    string action = data?["action"]?.ToString();
                    if (!string.IsNullOrEmpty(action))
                        SystemControls.ExecuteAction(action);
                }
                else if (eventName == "fetch-apps")
                {
                    var apps = AppDiscovery.GetStartMenuApps();
                    BroadcastToClient(clientId, "app-list", apps);
                }
                else if (eventName == "launch-app")
                {
                    string path = data?["path"]?.ToString();
                    if (!string.IsNullOrEmpty(path))
                    {
                        try { System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo { FileName = path, UseShellExecute = true }); } catch { }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Process message error: {ex.Message}");
            }
        }

        public void BroadcastToClient(string clientId, string eventName, object data)
        {
            if (_clients.TryGetValue(clientId, out var socket) && socket.State == WebSocketState.Open)
            {
                var payload = new { @event = eventName, data = data };
                var json = JsonConvert.SerializeObject(payload);
                var bytes = Encoding.UTF8.GetBytes(json);
                socket.SendAsync(new ArraySegment<byte>(bytes), WebSocketMessageType.Text, true, CancellationToken.None).Wait();
            }
        }
        
        public void BroadcastAll(string eventName, object data)
        {
            var payload = new { @event = eventName, data = data };
            var json = JsonConvert.SerializeObject(payload);
            var bytes = Encoding.UTF8.GetBytes(json);
            
            foreach (var kvp in _clients)
            {
                if (kvp.Value.State == WebSocketState.Open)
                {
                    kvp.Value.SendAsync(new ArraySegment<byte>(bytes), WebSocketMessageType.Text, true, CancellationToken.None).Wait();
                }
            }
        }
    }
}
