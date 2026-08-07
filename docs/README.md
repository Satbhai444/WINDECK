# WinDeck - Wireless PC Control Suite

<p align="center">
  <strong>Control your Windows PC from your Android phone - wirelessly.</strong>
</p>

---

## Overview

WinDeck is a two-part application suite that transforms your Android smartphone into a powerful wireless control panel for your Windows PC. It consists of:

- **WinDeck Server** (Windows) — An Electron-based desktop application that runs on your PC
- **WinDeck App** (Android) — A Flutter-based mobile application that connects to your PC

## Key Features

| Feature | Description |
|---|---|
| 🚀 **App Launcher** | Launch any installed PC application from your phone |
| 🎵 **Media Control** | Play/pause, next, previous track with live media info |
| 🖱️ **Air Mouse** | Use your phone as a wireless mouse with gyroscope support |
| 🔊 **Volume & Brightness** | Control system volume and screen brightness |
| ⌨️ **Custom Macros** | Execute PowerShell scripts with a single tap |
| 📋 **Clipboard Sync** | Seamlessly share clipboard between PC and phone |
| 📷 **Camera Bridge** | Stream your phone camera to PC as a virtual webcam |
| 📁 **File Transfer** | Send files between PC and phone wirelessly |
| 🎯 **Presentation Control** | Navigate slides during presentations |
| 🔒 **Encrypted Connection** | AES-256-CBC encrypted communication |
| 📱 **OTA Updates** | Auto-update via GitHub Releases |
| 🎨 **Custom Pages** | Create, rename, reorder, and manage control pages |
| 📊 **System Monitor** | Live CPU & RAM usage on your phone |
| 🖥️ **Active Window Tracking** | See which app is currently active on PC |

## Architecture

```
┌─────────────────────┐          WiFi / LAN          ┌──────────────────────┐
│   WinDeck Server    │◄────── Socket.IO + HTTP ──────►│    WinDeck App       │
│   (Electron/Node)   │          (Encrypted)          │    (Flutter/Dart)    │
│                     │                               │                     │
│  • Express HTTP     │    ◄── UDP Broadcast ──►      │  • Auto Discovery    │
│  • Socket.IO        │    ◄── mDNS/Bonjour ──►       │  • NSD/mDNS          │
│  • PowerShell IPC   │                               │  • Provider State    │
│  • Media Sessions   │                               │  • Material Design   │
│  • Icon Extraction  │                               │  • Sensors/Gyro      │
└─────────────────────┘                               └──────────────────────┘
```

## Quick Start

### Prerequisites
- Windows 10/11 PC
- Android 6.0+ phone
- Both devices on the same WiFi network

### Installation
1. Download the latest release from [GitHub Releases](https://github.com/Satbhai444/WINDECK/releases)
2. Install `WinDeck_Server_Setup_x.x.x.exe` on your PC
3. Install `WinDeck_App_x.x.x.apk` on your phone
4. Launch WinDeck Server on PC → Create a Room
5. Open WinDeck App on phone → Find your PC → Enter the pairing code
6. Done! Start controlling your PC!

## Tech Stack

| Component | Technology |
|---|---|
| PC App | Electron 43, Node.js, Express, Socket.IO, TailwindCSS |
| Mobile App | Flutter 3.x, Dart, Provider, Socket.IO Client |
| Communication | WebSocket (Socket.IO), UDP Broadcast, mDNS/Bonjour |
| Security | AES-256-CBC Encryption, OTP Authentication |
| Build | electron-builder (PC), Gradle (Android) |
| Updates | electron-updater (PC), GitHub Releases API (Android) |

## Project Structure

```
WINDECK/
├── server/                    # PC Application (Electron)
│   ├── main.js                # Electron main process
│   ├── preload.js             # Context bridge (IPC)
│   ├── server.js              # Express + Socket.IO server
│   ├── desktop_ui.html        # Desktop UI (single-page app)
│   ├── modules/
│   │   ├── appDiscovery.js    # Start Menu & UWP app scanner
│   │   ├── systemControls.js  # Volume, brightness, mouse, keyboard
│   │   ├── mediaMonitor.js    # Windows Media Session listener
│   │   └── windowMonitor.js   # Active window tracker
│   ├── icon_extractor.exe     # C# native icon extractor
│   └── package.json
│
├── android/                   # Mobile Application (Flutter)
│   ├── lib/
│   │   ├── main.dart          # App entry point & theme
│   │   ├── models/            # Data models (Page, Tile)
│   │   ├── providers/         # State management (Connection, Pages)
│   │   ├── screens/           # UI screens
│   │   ├── services/          # Network & update services
│   │   └── widgets/           # Reusable UI components
│   └── pubspec.yaml
│
├── docs/                      # Documentation
├── Releases/                  # Built artifacts
└── website/                   # Landing page
```

## Documentation

- [Architecture Guide](./docs/ARCHITECTURE.md)
- [API Reference](./docs/API_REFERENCE.md)
- [Setup Guide](./docs/SETUP_GUIDE.md)
- [User Guide](./docs/USER_GUIDE.md)
- [Changelog](./docs/CHANGELOG.md)
- [Contributing](./docs/CONTRIBUTING.md)

## Version

Current: **v2.3.6**

## License

This project is private and not open-source.

## Author

Developed by **Darshan Satbhai** ([@Satbhai444](https://github.com/Satbhai444))
