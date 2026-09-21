using System;
using System.IO;
using System.Threading.Tasks;
using Windows.Media.Control;

namespace WinDeckServer.Native
{
    public class MediaMonitor
    {
        public delegate void MediaUpdateHandler(object mediaData);
        public event MediaUpdateHandler OnMediaUpdate;

        private GlobalSystemMediaTransportControlsSessionManager _sessionManager;

        public async Task StartAsync()
        {
            _sessionManager = await GlobalSystemMediaTransportControlsSessionManager.RequestAsync();
            if (_sessionManager != null)
            {
                _sessionManager.CurrentSessionChanged += SessionManager_CurrentSessionChanged;
                UpdateCurrentSession();
            }
        }

        private void SessionManager_CurrentSessionChanged(GlobalSystemMediaTransportControlsSessionManager sender, CurrentSessionChangedEventArgs args)
        {
            UpdateCurrentSession();
        }

        private async void UpdateCurrentSession()
        {
            var session = _sessionManager.GetCurrentSession();
            if (session != null)
            {
                session.MediaPropertiesChanged += Session_MediaPropertiesChanged;
                session.PlaybackInfoChanged += Session_PlaybackInfoChanged;
                await NotifyUpdateAsync(session);
            }
        }

        private async void Session_PlaybackInfoChanged(GlobalSystemMediaTransportControlsSession sender, PlaybackInfoChangedEventArgs args)
        {
            await NotifyUpdateAsync(sender);
        }

        private async void Session_MediaPropertiesChanged(GlobalSystemMediaTransportControlsSession sender, MediaPropertiesChangedEventArgs args)
        {
            await NotifyUpdateAsync(sender);
        }

        private async Task NotifyUpdateAsync(GlobalSystemMediaTransportControlsSession session)
        {
            try
            {
                var props = await session.TryGetMediaPropertiesAsync();
                var playbackInfo = session.GetPlaybackInfo();
                
                string base64Thumb = null;
                if (props.Thumbnail != null)
                {
                    using (var stream = await props.Thumbnail.OpenReadAsync())
                    {
                        var bytes = new byte[stream.Size];
                        using (var dataReader = new Windows.Storage.Streams.DataReader(stream))
                        {
                            await dataReader.LoadAsync((uint)stream.Size);
                            dataReader.ReadBytes(bytes);
                        }
                        base64Thumb = "data:image/png;base64," + Convert.ToBase64String(bytes);
                    }
                }

                var data = new
                {
                    title = props.Title,
                    artist = props.Artist,
                    isPlaying = playbackInfo.PlaybackStatus == GlobalSystemMediaTransportControlsSessionPlaybackStatus.Playing,
                    thumbnail = base64Thumb
                };

                OnMediaUpdate?.Invoke(data);
            }
            catch (Exception ex)
            {
                Console.WriteLine("MediaMonitor Error: " + ex.Message);
            }
        }
    }
}
