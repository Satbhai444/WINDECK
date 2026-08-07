# WinDeck Development Setup Guide

## Prerequisites

### For PC Server Development
- **Node.js** v18+ ([Download](https://nodejs.org/))
- **npm** v9+ (comes with Node.js)
- **Git** ([Download](https://git-scm.com/))
- **Windows 10/11** (required for PowerShell system controls)
- **Visual Studio Build Tools** (for native modules like `loudness`)

### For Mobile App Development
- **Flutter SDK** 3.12+ ([Download](https://flutter.dev/docs/get-started/install))
- **Android Studio** with Android SDK 21+
- **Java JDK 17** (required by Gradle)

---

## Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/Satbhai444/WINDECK.git
cd WINDECK
```

### 2. Setup PC Server
```bash
cd server
npm install
npm start
```
This will launch the Electron app with the WinDeck Server.

### 3. Setup Mobile App
```bash
cd android
flutter pub get
flutter run
```
This will build and launch the Flutter app on your connected Android device or emulator.

---

## Building for Production

### Build PC Installer (.exe)
```bash
cd server
npm run build
```
Output: `server/dist-final/WinDeck Server Setup x.x.x.exe`

> **Important**: Do NOT build from a OneDrive-synced directory. OneDrive locks files during sync and causes `EBUSY`/`EPERM` errors. Copy the project to a non-synced directory (e.g., `D:\WINDECK`) before building.

### Build Android APK
```bash
cd android
flutter build apk --release
```
Output: `android/build/app/outputs/flutter-apk/app-release.apk`

> **Tip**: Run `flutter clean` before building if you encounter `AccessDeniedException` errors.

---

## Version Management

Version must be updated in **3 places** when releasing a new version:

| File | Field | Example |
|---|---|---|
| `server/package.json` | `"version"` | `"2.3.6"` |
| `server/server.js` | `SERVER_VERSION` | `'2.3.6'` |
| `android/pubspec.yaml` | `version` | `2.3.6+1` |

> **Critical**: PC server and mobile app versions MUST match. The server rejects connections from clients with mismatched versions.

---

## Creating a Release

1. Update version numbers in all 3 files listed above
2. Build both applications
3. Create a GitHub Release with tag `vX.X.X`
4. Attach the `.apk` file to the release
5. The PC auto-updater uses `electron-updater` with GitHub as the provider
6. The mobile app checks GitHub Releases API for OTA updates

---

## Project Configuration

### Electron Builder Config (in `package.json`)
```json
{
  "build": {
    "appId": "com.windeck.server",
    "productName": "WinDeck Server",
    "directories": { "output": "dist-final" },
    "win": { "target": "nsis" },
    "publish": [{ "provider": "github", "owner": "Satbhai444", "repo": "WINDECK" }]
  }
}
```

### Network Ports
| Port | Protocol | Purpose |
|---|---|---|
| `3000` | TCP (HTTP/WS) | Main server (Express + Socket.IO) |
| `3001` | UDP | Auto-discovery broadcast |

### Key Paths
| Path | Purpose |
|---|---|
| `%APPDATA%/server/layout.json` | Saved tile layout |
| `%TEMP%/windeck_icons/` | Cached app icon PNGs |
| `%USERPROFILE%/Downloads/WinDeck/` | Received files from phone |
| `%USERPROFILE%/windeck_debug.log` | Server debug log |

---

## Troubleshooting

| Problem | Solution |
|---|---|
| `EADDRINUSE` on port 3000 | Another WinDeck instance is running. Kill it or restart PC |
| `Lock file cannot be created` | Close all WinDeck/Electron processes first |
| `EBUSY` during build | Move project out of OneDrive, kill lingering processes |
| `AccessDeniedException` (Flutter) | Run `flutter clean`, kill `java.exe`, then rebuild |
| Phone can't find PC | Ensure both on same WiFi, check firewall allows port 3000/3001 |
| Version mismatch error | Update version in all 3 files to match |
