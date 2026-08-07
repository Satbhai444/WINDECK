# WinDeck User Guide

## Getting Started

### Step 1: Install WinDeck Server on your PC
1. Download `WinDeck_Server_Setup_x.x.x.exe` from the [Releases](https://github.com/Satbhai444/WINDECK/releases) page
2. Double-click the installer and follow the prompts
3. WinDeck Server will launch automatically after installation
4. You'll see the WinDeck dashboard with a "Create Room" button

### Step 2: Install WinDeck App on your Phone
1. Download `WinDeck_App_x.x.x.apk` from the [Releases](https://github.com/Satbhai444/WINDECK/releases) page
2. Transfer the APK to your phone (via USB, email, or cloud storage)
3. Open the APK file on your phone
4. If prompted, allow "Install from unknown sources"
5. Tap Install

### Step 3: Connect
1. Make sure your PC and phone are on the **same WiFi network**
2. On PC: Click "Create Room" → A 6-digit pairing code will appear
3. On Phone: Open WinDeck App → Your PC should appear automatically
4. Tap on your PC → Enter the 6-digit code shown on your PC
5. You're connected! 🎉

---

## Features Guide

### 🚀 App Launcher
Tap any app tile on the home screen to launch that application on your PC. The tile layout is configured from the PC's Editor page.

### 🎵 Media Hub
Access the Media Hub from the bottom navigation bar:
- See currently playing song/video info
- Play/Pause, Next Track, Previous Track
- Works with Spotify, YouTube, VLC, and any Windows media app

### 🖱️ Air Mouse
Access from the navigation bar:
- **Move cursor**: Slide your finger on the touchpad area
- **Left click**: Single tap
- **Right click**: Two-finger tap
- **Scroll**: Slide on the right edge area
- **Gyroscope mode**: Tilt your phone to move the cursor (toggle in settings)

### 📷 Camera Bridge
Stream your phone's camera to your PC:
1. Open Camera from the navigation bar
2. Your phone's camera feed will appear on PC at `http://localhost:3000/camera-view`
3. Use this with OBS Virtual Camera for video calls!

### 🔊 System Controls
Available through tiles or quick actions:
- Volume Up/Down/Mute
- Brightness Up/Down
- Lock, Sleep, Restart, Shutdown
- Screenshot, Screen Record
- Show Desktop

### 📋 Clipboard Sync
Copy text on your PC → It appears on your phone automatically (and vice versa)

### 📁 File Transfer
- **Phone → PC**: Use the DropZone feature. Files are saved to `Downloads/WinDeck/`
- **PC → Phone**: Drag a file onto the PC app to send it to your phone

### 🎯 Presentation Mode
Control your PowerPoint/Google Slides:
- Next Slide / Previous Slide
- Start Presentation (F5)
- End Presentation (Escape)
- Blank Screen

---

## Customizing Your Layout

### From PC Editor
1. Open WinDeck Server on PC
2. Go to the **Editor** tab
3. Click **Add Tile** to add apps, actions, or macros
4. Drag tiles to rearrange
5. Right-click a tile to edit or delete
6. Changes sync to your phone instantly

### Managing Pages
1. Go to **Settings** tab on PC
2. Under **Pages Management**:
   - Click **+ Add Page** to create new pages
   - Click the pencil icon to rename a page
   - Drag the handle to reorder pages
   - Click the trash icon to delete (minimum 1 page required)

---

## Updating the App

### Mobile App (OTA Update)
1. Open WinDeck App
2. Go to **Settings**
3. Tap **"Check for Updates"**
4. If an update is available, tap **"Update"** to download and install

### PC App (Auto Update)
The PC app checks for updates automatically on launch. If an update is found, you'll be prompted to install it.

---

## Troubleshooting

| Issue | Solution |
|---|---|
| Phone can't find PC | Make sure both are on the same WiFi network |
| "Version mismatch" error | Update both apps to the same version |
| Connection drops frequently | Check WiFi stability, move closer to router |
| Media controls not working | Make sure music/video is actually playing |
| App tiles show wrong icons | Restart the PC server to refresh icon cache |
| Air mouse is laggy | Reduce sensitivity in settings |

---

## Tips & Tricks

- 💡 **Minimize to tray**: Closing the PC app minimizes it to the system tray. Double-click the tray icon to restore.
- 💡 **Custom macros**: Create tiles that run PowerShell scripts for advanced automation.
- 💡 **Multiple pages**: Organize tiles into themed pages (e.g., "Work", "Gaming", "Media").
- 💡 **Camera as webcam**: Use the camera bridge with OBS for professional video calls.
