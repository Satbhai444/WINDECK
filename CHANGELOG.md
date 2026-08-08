# WinDeck - Feature History & Roadmap

This document outlines the version-wise progression of features implemented in WinDeck, along with detailed descriptions of upcoming features in the next release.

---

## 🚀 Upcoming Update - v2.3.7

*The following features are planned for the upcoming v2.3.7 release based on user feedback and internal testing.*

### 1. Manual App Addition from Windows Server
**Details:** Currently, apps are either auto-fetched from the Start Menu/UWP or managed via the mobile app. In this update, a new "Add App Manually" interface will be introduced directly in the PC's Electron Desktop UI. Users will be able to browse their file system and select specific `.exe` files or shortcuts to add them to their WinDeck app grid instantly.

### 2. Landscape Mode Support for Android
**Details:** The mobile application will receive full responsive support for Landscape Mode. When users rotate their devices horizontally, the app grid, media controls, and custom pages will dynamically adjust to utilize the wider screen space, providing a tablet-like, dashboard experience.

### 3. Real-time App Sync Fix
**Details:** Addressed a critical synchronization bug. Previously, editing app details or layouts on the PC server sometimes failed to update on the mobile app even after triggering a sync, requiring a full app restart or manual reconnection. The state management and Socket.IO events have been refactored to ensure that the moment a change is made on the server, it instantly forces a UI refresh on the connected mobile client without dropping the connection.

### 4. Two-Way Clipboard Synchronization
**Details:** The clipboard feature has been upgraded from unidirectional (PC → Phone) to fully bidirectional (PC ↔ Phone). Users can now copy text or links on their Android device, and WinDeck will instantly push that clipboard data to the PC, allowing for seamless pasting directly onto the Windows desktop. 

### 5. Bulk File Transfer (Enhanced Drop Zone)
**Details:** The Drop Zone feature is being overhauled. Previously restricted to sending one file or photo at a time, the new system will introduce a batch processing queue. Users will now be able to select and send up to 10 photos or files simultaneously in a single action, similar to modern messaging platforms like WhatsApp, significantly speeding up workflow and data sharing.

---

## 📜 Version History (Past Implementation)

### v2.3.6 (Current Release)
- **Website Overhaul:** Completely redesigned the official landing page (`index.html`) with a modern, storytelling approach, scroll animations (AOS), and dynamic UI components.
- **Web3Forms Integration:** Added a "Notify Me" newsletter subscription and a dedicated Contact page without needing a backend.
- **Automated Deployments:** Configured Vercel for seamless production deployments of the web presence.
- **Git Optimization:** Cleaned up the repository by ignoring large binaries (`.exe`, `.apk`) to maintain a lightweight codebase.

### v2.3.0
- **Clipboard Sync (PC to Phone):** Introduced the ability to copy text on Windows and have it available on the Android clipboard.
- **File Transfer Drop Zone (v1):** Added the foundational ability to transfer single files wirelessly over the local network.
- **System Monitoring:** Implemented live CPU and RAM usage tracking visible directly on the mobile app dashboard.

### v2.2.0
- **Air Mouse:** Added gyroscope-based mouse control, allowing users to move the PC cursor by moving their phone.
- **Custom Pages:** Users can now create, rename, and reorder custom grids/pages to organize their macros and apps.
- **Active Window Tracking:** The app now detects and displays which window is currently active on the PC.

### v2.1.0
- **Media Controls:** Full support for Play/Pause, Next Track, and Previous Track with live media session monitoring.
- **System Controls:** Added quick toggles for adjusting Windows System Volume and Screen Brightness.
- **Macro Support:** Introduced the ability to execute custom PowerShell scripts via a single tap.

### v1.0.0 - v2.0.0 (The Foundation)
- **Core Architecture:** Established the Electron (Node.js) Server on Windows and the Flutter application on Android.
- **Socket.IO Communication:** Built the local Wi-Fi, zero-latency communication layer.
- **App Launcher Core:** Implemented automated fetching of Start Menu programs and UWP apps, alongside custom icon extraction (via C# utility).
- **Encrypted Connection:** Secured local communication using AES-256-CBC encryption.
