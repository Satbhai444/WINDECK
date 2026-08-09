# WinDeck - Wireless PC Control Suite

<p align="center">
  <strong>Control your Windows PC from your Android phone - wirelessly.</strong>
</p>

<p align="center">
  <a href="https://github.com/Satbhai444/WINDECK/releases/latest"><img src="https://img.shields.io/github/v/release/Satbhai444/WINDECK?style=for-the-badge&color=blue" alt="Latest Release"></a>
  <a href="https://github.com/Satbhai444/WINDECK/blob/master/LICENSE"><img src="https://img.shields.io/github/license/Satbhai444/WINDECK?style=for-the-badge&color=green" alt="License"></a>
  <a href="https://website-fawn-nine-99.vercel.app/"><img src="https://img.shields.io/badge/Website-Live-brightgreen?style=for-the-badge" alt="Website"></a>
  <a href="https://github.com/Satbhai444/WINDECK/stargazers"><img src="https://img.shields.io/github/stars/Satbhai444/WINDECK?style=for-the-badge&color=yellow" alt="Stars"></a>
</p>

---

## Overview

WinDeck is a two-part application suite that transforms your Android smartphone into a powerful wireless control panel for your Windows PC. It consists of:

- **WinDeck Server** (Windows) — An Electron-based desktop application that runs on your PC
- **WinDeck App** (Android) — A Flutter-based mobile application that connects to your PC

⭐ **If you find this project useful, please consider giving it a star on GitHub! It helps a lot!** ⭐

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

```text
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
3. Install `windeck-vx.x.x.apk` on your phone
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
| Updates | electron-updater (PC), GitHub Actions CI/CD |

## Project Structure

```text
WINDECK/
├── server/                    # PC Application (Electron)
│   ├── main.js                # Electron main process
│   ├── preload.js             # Context bridge (IPC)
│   ├── server.js              # Express + Socket.IO server
│   ├── desktop_ui.html        # Desktop UI (single-page app)
│   ├── modules/               # Native integrations (Media, WinAPI)
│   ├── icon_extractor.exe     # C# native icon extractor
│   └── package.json
│
├── android/                   # Mobile Application (Flutter)
│   ├── lib/                   # Dart source code
│   └── pubspec.yaml
│
├── docs/                      # Documentation
├── .github/                   # CI/CD Workflows & Templates
└── website/                   # Landing page source
```

## Documentation

- [Architecture Guide](./docs/ARCHITECTURE.md)
- [API Reference](./docs/API_REFERENCE.md)
- [Setup Guide](./docs/SETUP_GUIDE.md)
- [User Guide](./docs/USER_GUIDE.md)
- [Changelog](./docs/CHANGELOG.md)
- [Contributing](./CONTRIBUTING.md)
- [Code of Conduct](./CODE_OF_CONDUCT.md)
- [Security Policy](./.github/SECURITY.md)

## License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Connect With Me

Developed with ❤️ by **Darshan Satbhai**

[![Portfolio](https://img.shields.io/badge/Portfolio-darshansatbhai.in-blue?style=for-the-badge&logo=google-chrome)](https://website-fawn-nine-99.vercel.app/)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=for-the-badge&logo=linkedin)](https://www.linkedin.com/in/darshan-satbhai-212600423)
[![Instagram](https://img.shields.io/badge/Instagram-Follow-E4405F?style=for-the-badge&logo=instagram)](https://www.instagram.com/darshaan_satbhai)
[![Email](https://img.shields.io/badge/Email-Contact_Me-red?style=for-the-badge&logo=gmail)](mailto:darshan.satbhai@gmail.com)
