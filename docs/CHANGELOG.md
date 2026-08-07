# Changelog

All notable changes to the WinDeck project are documented here.

## [2.3.6] - 2026-08-07

### Added
- QR Code pairing (upcoming)
- Professional project documentation

### Changed
- Version bumped to 2.3.6 across PC and Mobile apps

---

## [2.2.0] - 2026-08-06

### Added
- **Pages Management**: Add, rename, delete, and reorder pages via drag-and-drop
- **Settings Page Management**: Manage pages from the Settings tab with inline rename and drag-drop reorder
- **Real App Icons**: Native icon extraction using C# extractor (`icon_extractor.exe`) for Win32 apps and PowerShell for UWP apps
- **OTA Update System**: Mobile app checks GitHub Releases API for updates; download and install from within the app
- **GitHub Release Pipeline**: Automated release creation with APK upload via Node.js script

### Changed
- Version synchronized to 2.2.0 across PC server and Mobile app
- Build output directory changed to `dist-final` to avoid OneDrive conflicts

### Fixed
- OneDrive file locking issues during builds (moved builds outside OneDrive)
- Icon display for UWP/Store apps (WhatsApp, Instagram, etc.)
- Version mismatch causing connection rejection

---

## [1.2.0] - 2026-08-03

### Added
- **End-to-End Encryption**: AES-256-CBC encryption for all Socket.IO messages
- **File Transfer**: Phone → PC upload via DropZone, PC → Phone via download endpoint
- **Camera Bridge**: Stream phone camera to PC, accessible at `/camera-view`
- **Air Mouse**: Wireless mouse control with gyroscope support
- **Presentation Control**: Slide navigation (next, prev, start, exit, blank)
- **Clipboard Sync**: Bidirectional clipboard sharing between PC and phone
- **Custom Macros**: Execute PowerShell scripts from phone tiles
- **System Tray**: Minimize to tray with double-click to restore
- **mDNS Discovery**: Bonjour/NSD service advertisement alongside UDP broadcast
- **Active Window Tracking**: Monitor which application is in focus on PC

---

## [1.0.0] - 2026-07-07

### Added
- Initial release
- PC server with Electron desktop UI
- Mobile app with Flutter
- App launcher with Start Menu scanning
- Media controls (play/pause, next, prev)
- Volume and brightness control
- System actions (lock, sleep, restart, shutdown)
- OTP-based authentication
- UDP broadcast auto-discovery
- Live CPU/RAM monitoring
- Custom tile layout editor
