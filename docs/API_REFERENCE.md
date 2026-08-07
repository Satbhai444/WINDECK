# WinDeck API Reference

## Socket.IO Events

All events (except authentication) are encrypted with AES-256-CBC after successful pairing.

### Authentication

| Event | Direction | Data | Description |
|---|---|---|---|
| `authenticate` | Client → Server | `{ otp: string, deviceName: string, version: string }` | Client sends OTP to authenticate |
| `authenticated` | Server → Client | `{ success: boolean, error?: string }` | Authentication result |
| `force-disconnect` | Server → Client | — | Server forces client to disconnect |

### App Management

| Event | Direction | Data | Description |
|---|---|---|---|
| `get-apps` | Client → Server | — | Request list of installed applications |
| `app-list` | Server → Client | `Array<{ name: string, path: string }>` | List of installed apps |
| `launch-app` | Client → Server | `string` (exe path or AppID) | Launch an application |

### Layout & Pages

| Event | Direction | Data | Description |
|---|---|---|---|
| `get-layout` | Client → Server | — | Request current tile layout |
| `sync-layout` | Server → Client | `Array<Page>` | Tile layout data |

### System Controls

| Event | Direction | Data | Description |
|---|---|---|---|
| `system-action` | Client → Server | `string` | Execute a system action |
| `custom-macro` | Client → Server | `string` | Execute a PowerShell macro script |
| `open-url` | Client → Server | `string` | Open a URL in default browser |

#### Available System Actions
| Action String | Effect |
|---|---|
| `volume-up` | Increase volume |
| `volume-down` | Decrease volume |
| `mute` | Toggle mute |
| `brightness-up` | Increase brightness by 10% |
| `brightness-down` | Decrease brightness by 10% |
| `lock` | Lock workstation |
| `sleep` | Put PC to sleep |
| `restart` | Restart PC |
| `shutdown` | Shutdown PC |
| `screen-record` | Open screen clip tool |
| `screenshot` | Open snipping tool |
| `show-desktop` | Toggle show desktop |
| `media-play-pause` | Play/pause media |
| `media-next` | Next track |
| `media-prev` | Previous track |

### Air Mouse

| Event | Direction | Data | Description |
|---|---|---|---|
| `mouse-move` | Client → Server | `{ dx: number, dy: number }` | Move mouse cursor by delta |
| `mouse-click` | Client → Server | `{ button: 'left' \| 'right' }` | Click mouse button |
| `mouse-scroll` | Client → Server | `{ deltaY: number }` | Scroll mouse wheel |

### Presentation Control

| Event | Direction | Data | Description |
|---|---|---|---|
| `presentation-control` | Client → Server | `string` | Control presentation slides |

#### Available Presentation Actions
| Action | Effect |
|---|---|
| `slide-next` | Next slide (Page Down) |
| `slide-prev` | Previous slide (Page Up) |
| `presentation-start` | Start slideshow (F5) |
| `presentation-exit` | Exit slideshow (Escape) |
| `blank-screen` | Blank screen (B key) |

### Media Monitoring

| Event | Direction | Data | Description |
|---|---|---|---|
| `media-update` | Server → Client | `{ title, artist, albumTitle, sourceApp, playbackStatus }` | Currently playing media info |

#### Playback Status Values
| Value | Meaning |
|---|---|
| `4` | Playing |
| `5` | Paused |
| `0` | Unknown/Stopped |

### Clipboard

| Event | Direction | Data | Description |
|---|---|---|---|
| `send-clipboard` | Client → Server | `string` | Set PC clipboard text |
| `clipboard-update` | Server → Client | `string` | PC clipboard changed |

### Camera Bridge

| Event | Direction | Data | Description |
|---|---|---|---|
| `camera-frame` | Client → Server | `string` (base64 JPEG) | Camera frame from phone |
| `broadcast-camera-frame` | Server → All | `string` (base64 JPEG) | Broadcast frame to viewers |

### File Transfer

| Event | Direction | Data | Description |
|---|---|---|---|
| `file-received` | Server → Client | `{ filename, path }` | File upload notification |
| `file-offer` | Server → Client | `string` (download URL) | PC offers file to phone |

### System Status

| Event | Direction | Data | Description |
|---|---|---|---|
| `status` | Server → Client | `{ serverName, cpuUsage, ramUsage }` | System telemetry (every 2s) |
| `foreground-app-changed` | Server → Client | `{ exe, title }` | Active window changed |

---

## HTTP Endpoints

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/upload` | `X-WinDeck-Auth` header (OTP) | Upload file from phone to PC |
| `GET` | `/download-file?path=...` | None | Download file from PC |
| `GET` | `/camera-view` | None | Camera stream viewer page |
| `GET` | `/icon?path=...&name=...` | None | Get app icon (PNG or SVG fallback) |

---

## IPC Events (Electron Internal)

| Event | Direction | Data | Description |
|---|---|---|---|
| `close-app` | Renderer → Main | — | Hide window |
| `minimize-app` | Renderer → Main | — | Minimize to tray |
| `maximize-app` | Renderer → Main | — | Toggle maximize |
| `create-room` | Renderer → Main | `string` (room name) | Create room & start broadcasting |
| `room-created` | Main → Renderer | `string` (encoded room ID) | Room created confirmation |
| `regenerate-otp` | Renderer → Main | — | Generate new OTP |
| `disconnect-client` | Renderer → Main | — | Disconnect mobile client |
| `otp-update` | Main → Renderer | `string` | New OTP generated |
| `connection-status` | Main → Renderer | `{ connected, deviceName }` | Client connection change |
| `telemetry-update` | Main → Renderer | `{ serverName, cpuUsage, ramUsage }` | System stats |
| `get-layout` | Renderer → Main | — | Request saved layout |
| `layout-data` | Main → Renderer | `Array<Page>` | Layout data |
| `save-layout` | Renderer → Main | `Array<Page>` | Save layout to disk |
| `request-apps` | Renderer → Main | — | Request installed apps |
| `system-apps-data` | Main → Renderer | `Array<App>` | List of apps |
| `send-file-to-phone` | Renderer → Main | `string` (file path) | Send file to phone |
| `trigger-update` | Renderer → Main | — | Install downloaded update |
