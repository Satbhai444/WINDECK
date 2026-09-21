# SUMMER INTERNSHIP REPORT
**Submitted in partial fulfillment of the requirements for the award of the degree of**
### INTEGRATED BSC AND MSC IT (IMSC-IT)

**Student Name:** Darshan Satbhai  
**Enrollment No:** 2402106047  
**Semester:** 4th  
**Faculty Guide:** Khushali Pansinia  
**Internship Organization:** Praxinfo Pvt. Ltd.  
**Project Title:** WinDeck – Wireless PC Remote Control Suite  
**Duration:** From 04 June 2026 To Ongoing  

**Submitted to:**  
Department of Computer Applications  
**[SHREYARTH UNIVERSITY]**  
Academic Year: 2026-27  

---

## CERTIFICATE

This is to certify that **Mr. Darshan Satbhai**, **2402106047**, student of IMSC (Integrated B.Sc. and M.Sc. IT), has successfully completed the Summer Internship at **Praxinfo Pvt. Ltd.** From 18 June 2026 To Present.

During the internship period, the student worked on the project titled **“WinDeck”** under the faculty guidance of **Khushali Pansinia** and completed the assigned tasks satisfactorily.

We wish him success in future endeavors.

**Company Mentor / Founder & CEO**  
Umang Kathiyara  
Founder & Director  
*Praxinfo Pvt. Ltd.*  

---

## ACKNOWLEDGEMENT

I express my sincere gratitude to **Praxinfo Pvt. Ltd.** for providing me the opportunity to undergo industrial internship training. I would like to express my deepest appreciation to company founders **Mr. Umang Kathiyara** (Founder & Director) and **Mr. Naitik Patel** (Co-Founder & Technical Lead), as well as my mentors and staff members for their continuous guidance, technical mentorship, and support throughout the project.

I am also thankful to the Principal, Head of Department, Internship Coordinator, and Faculty Guide **Ms. Khushali Pansinia** of SHREYARTH UNIVERSITY College for their continuous encouragement, valuable insights, and assistance throughout the internship period.

Finally, I thank my family and friends for their constant support and motivation.

**Student Signature**  
Darshan Satbhai  

---

## TABLE OF CONTENTS

- **Certificate** ........................................................................ i
- **Acknowledgement** ............................................................. ii
- **Table of Contents** ............................................................. ii
- **CHAPTER 1: COMPANY PROFILE** .................................... 2
  - 1.1 Introduction ............................................................... 2
  - 1.2 Company Details ....................................................... 3
  - 1.3 Organizational Structure ........................................... 3
  - 1.4 Objectives of the Company ...................................... 3
- **CHAPTER 2: INTERNSHIP WORK DETAILS / PROJECT DESCRIPTION** ................................................... 4
  - 2.1 Project Title ............................................................... 4
  - 2.2 Project Objective ....................................................... 4
  - 2.3 Technologies Used ................................................... 4
  - 2.4 Tasks Performed ....................................................... 4
  - 2.5 Project Modules ....................................................... 5
- **CHAPTER 3: LEARNING OUTCOMES** ............................... 5
- **CHAPTER 4: SCREENSHOTS / CODE SNIPPETS** ............. 6
- **CHAPTER 5: CONCLUSION** ............................................. 7
- **CHAPTER 6: FUTURE SCOPE** ........................................... 7
- **REFERENCES** ...................................................................... 8
- **STUDENT DECLARATION** ................................................ 8

---

# CHAPTER 1: COMPANY PROFILE

## 1.1 Introduction
Praxinfo Pvt. Ltd. is an established IT services, mobile app, and custom software development company based in Ahmedabad, Gujarat. Founded by **Mr. Umang Kathiyara** (Founder) and **Mr. Naitik Patel** (Co-Founder), Praxinfo specializes in providing end-to-end digital solutions, including mobile application development (Flutter, React Native, iOS, Android), modern web development, cloud software engineering, enterprise CRM solutions, and UI/UX design. With a client-first approach and experienced technical leadership, the company serves startups, growing businesses, and international enterprise clients. During my 45-day summer internship program, I had the opportunity to work under the direct mentorship of Praxinfo's senior development team and gain hands-on industrial experience on real-world cross-platform applications.

## 1.2 Company Details
- **Company Name:** Praxinfo Pvt. Ltd.
- **Founders & Key Management:**
  - **Umang Kathiyara** — Founder & Director
  - **Naitik Patel** — Co-Founder & Technical Lead
- **Registered Office Address:** C-608, Titanium City Center, 100 Feet Anand Nagar Rd, Near Sachin Tower, Satellite, Ahmedabad, Gujarat – 380015, India.
- **Website:** www.praxinfo.com
- **Industry Type:** Information Technology (IT Services, Web & Mobile App Engineering)
- **Services Offered:**
  - Mobile App Development (Flutter, React Native, iOS, Android)
  - Custom Web & Desktop Software Development (Node.js, Express, PHP/Laravel, React)
  - Enterprise Software Consulting & CRM Development
  - UI/UX & Interaction Design
  - Cloud Computing, API Integration & DevOps
  - Digital Strategy & E-Commerce Solutions

## 1.3 Organizational Structure
Praxinfo Pvt. Ltd. follows a streamlined organizational hierarchy that fosters collaborative engineering and high-quality software delivery. Executive leadership is headed by Founder **Umang Kathiyara** and Co-Founder **Naitik Patel**, supported by project managers and technical leads who oversee dedicated software engineers, mobile app developers, UI/UX designers, and quality assurance engineers. During the internship, interns are assigned direct mentors who provide code reviews, technical guidance, and architecture supervision on production projects.

## 1.4 Objectives of the Company
The core objective of Praxinfo Pvt. Ltd. is to deliver scalable, robust, and cost-effective software solutions that drive business transformation for global clients. The company strives to provide high-quality applications through modern technological stacks, agile development sprint cycles, and continuous technical innovation while maintaining high standards of software quality, transparency, and client satisfaction.

---

# CHAPTER 2: INTERNSHIP WORK DETAILS / PROJECT DESCRIPTION

## 2.1 Project Title
**WinDeck – Wireless PC Remote Control Suite**

## 2.2 Project Objective
The objective of this project is to develop a modern, high-speed, and secure wireless control suite that transforms an Android smartphone into a versatile remote control for a Windows PC. Operating seamlessly over local network (WiFi/LAN), WinDeck enables real-time media and system volume/brightness control, launching PC applications, executing custom PowerShell macros, bidirectional clipboard synchronization, live PC system resource monitoring (CPU, RAM, GPU), an Air Mouse utilizing phone gyroscope sensors, and streaming the smartphone camera as a virtual webcam to the PC. The project aims to deliver ultra-low latency responsiveness, top-tier security with AES-256 encryption and OTP pairing, and an intuitive user experience.

## 2.3 Technologies Used
- **Mobile Application:** Flutter, Dart, Material 3 Design, Provider State Management, Gyroscope & Accelerometer Sensors, Network Service Discovery (NSD/mDNS).
- **Desktop Server:** Electron.js, Node.js, Express, Socket.IO, PowerShell IPC, SystemInformation, robotjs / nut.js, Bonjour Service.
- **Networking & Security:** Socket.IO (WebSockets), UDP Broadcast, AES-256-CBC Encryption, 6-digit OTP Authentication.
- **Web & Landing Page:** HTML5, CSS3, Tailwind CSS, JavaScript (ES6+), Vite.
- **Version Control & Tools:** Git, GitHub, VS Code, Android Studio, Electron Builder, GitHub Release Workflow.

## 2.4 Tasks Performed
- Requirement analysis, software architecture design, and protocol specification for local network remote control.
- Development of the Electron.js desktop server GUI and background service daemon.
- Designing responsive Flutter Android app interface following Material 3 guidelines.
- Implementing high-speed Socket.IO real-time bi-directional messaging with AES-256 payload encryption.
- Building mDNS and UDP Broadcast services for zero-configuration PC auto-discovery on local networks.
- Implementing an Air Mouse feature utilizing smartphone gyroscope and accelerometer sensors for wireless cursor positioning.
- Developing a custom macro execution pipeline capable of invoking PowerShell IPC scripts with parameters.
- Implementing a dynamic App Launcher that discovers installed Windows apps and extracts high-resolution icons.
- Building active window tracking and real-time PC clipboard synchronization modules.
- Creating a Camera Bridge module to stream Android camera video feed directly to PC as a virtual webcam over WebSockets.
- Integrating live system monitoring for PC CPU, RAM, and GPU resource utilization.
- Configuring cross-platform packaging, installer generation (`.exe` setup and `.apk`), and GitHub Releases update channel.

## 2.5 Project Modules
- **Module 1: Server Room & Security Pairing:** Handles room creation, 6-digit OTP generation, mDNS/UDP auto-discovery, and AES-256 encrypted session handshake.
- **Module 2: System & Media Controller:** Provides remote controls for system volume, screen brightness, media playback (play/pause/skip), power options (sleep/shutdown), and Air Mouse gyroscope controller.
- **Module 3: App Launcher & Window Tracker:** Discovers installed Windows applications, displays indexed icons, triggers application launches, and tracks the currently active window on the PC.
- **Module 4: Custom Macros & Action Deck:** Allows users to build custom action pages, map buttons to PowerShell scripts, hotkeys, or web shortcuts, and manage customized deck layouts.
- **Module 5: Productivity & System Monitor:** Provides live clipboard text synchronization between PC and phone, performance monitoring metrics (CPU/RAM/GPU usage), and wireless file transfers.
- **Module 6: Camera Bridge & Virtual Webcam:** Streams low-latency video feed from phone camera to PC for use as a virtual webcam.

---

# CHAPTER 3: LEARNING OUTCOMES

During the 45-day industrial internship at Praxinfo Pvt. Ltd., I learned:
- **Desktop Application Architecture:** Gained hands-on experience building Electron.js desktop applications with IPC separation between main and renderer processes.
- **Cross-Platform Mobile Development:** Mastered building responsive mobile UIs and managing state using Flutter, Dart, and Provider under the guidance of Praxinfo mentors and faculty guide **Khushali Pansinia**.
- **Real-Time Network Protocols:** Understood socket-based bi-directional communication using Socket.IO, UDP broadcasting, and mDNS service discovery.
- **Hardware & Sensor Integration:** Learned how to process motion sensor data (gyroscope and accelerometer) from mobile hardware to control desktop mouse cursors.
- **Windows System Automation:** Gained expertise in invoking PowerShell scripts and native OS commands safely via Node.js IPC handlers.
- **Security Implementation:** Understood cryptographic standards including AES-256 payload encryption and OTP device pairing mechanisms.
- **DevOps & Build Distribution:** Learned build packaging using Electron Builder, APK compilation, and automated release deployment on GitHub.

---

# CHAPTER 4: SCREENSHOTS / CODE SNIPPETS

## Application Screenshots

- **1. Connect to PC / Device Pairing:** Displays network scanning, auto-discovered PC list, and 6-digit OTP authentication screen (`screenshots/1_connect_pc.png`).
- **2. App Launcher Interface:** Shows indexed PC applications with extracted icons ready for one-tap execution (`screenshots/2_launch_apps.png`).
- **3. System & Media Control Deck:** Interface for volume, brightness, media player controls, and air mouse pad (`screenshots/3_system_control.png`).
- **4. Website Access & Web Shortcuts:** Quick access deck for launching favorite web destinations directly in default PC browser (`screenshots/4_website_access.png`).
- **5. Custom App Controls & Macro Deck:** Custom user pages with PowerShell macro actions for app-specific workflows (`screenshots/5_app_specific_controls.png`).

---

## Sample Code Snippets

### 1. Desktop Server Initialization & Socket.IO Setup (`server/server.js`)
```javascript
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const os = require('os');
const Bonjour = require('bonjour-service');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: '*' } });
const PORT = 3000;

// Generate Room ID from Local IP
function generateEncodedRoomId() {
    const interfaces = os.networkInterfaces();
    for (const name of Object.keys(interfaces)) {
        for (const iface of interfaces[name]) {
            if (iface.family === 'IPv4' && !iface.internal) {
                const hex = iface.address.split('.')
                    .map(p => parseInt(p).toString(16).padStart(2, '0').toUpperCase())
                    .join('');
                return `${hex.slice(0, 4)}-${hex.slice(4)}`;
            }
        }
    }
    return 'WINDECK-ROOM';
}

io.on('connection', (socket) => {
    console.log('Mobile client connected:', socket.id);
    
    socket.on('pair-device', ({ otp }) => {
        if (otp === currentOtp) {
            socket.emit('pair-success', { token: 'AUTH_GRANTED' });
        } else {
            socket.emit('pair-failed', { message: 'Invalid OTP' });
        }
    });
});
```

### 2. PowerShell Macro Execution Engine (`server/modules/systemControls.js`)
```javascript
const { exec } = require('child_process');

function executePowerShellMacro(scriptContent) {
    return new Promise((resolve, reject) => {
        const encodedCommand = Buffer.from(scriptContent, 'utf16le').toString('base64');
        const cmd = `powershell.exe -NoProfile -NonInteractive -EncodedCommand ${encodedCommand}`;
        
        exec(cmd, (error, stdout, stderr) => {
            if (error) {
                reject(stderr || error.message);
            } else {
                resolve(stdout.trim());
            }
        });
    });
}

module.exports = { executePowerShellMacro };
```

---

# CHAPTER 5: CONCLUSION

The 45-day industrial internship at Praxinfo Pvt. Ltd. provided valuable practical experience in developing a modern cross-platform software suite using industry-standard technologies. Under the mentorship of **Mr. Umang Kathiyara** and **Mr. Naitik Patel**, and academic guidance of faculty guide **Khushali Pansinia**, I learned how to build high-performance Electron desktop servers, responsive Flutter mobile interfaces, real-time encrypted WebSocket communication channels, and low-level system automation tools. Developing the **WinDeck** application significantly enhanced my technical expertise, problem-solving skills, and understanding of full-stack software development practices.

---

# CHAPTER 6: FUTURE SCOPE

- **Cloud Remote Access:** Internet-wide connectivity via WebRTC relay servers for remote access outside local WiFi networks.
- **Cross-Platform Server Support:** Expanding desktop server support to macOS and Linux operating systems.
- **Biometric Security:** Integration of mobile fingerprint / Face ID for secure PC unlocking and sudo privileges.
- **Community Macro Marketplace:** An online hub for users to share and download customized action decks and PowerShell automation scripts.
- **Advanced Widget Builder:** Drag-and-drop customization of mobile control layouts with dynamic PC telemetry widgets.

---

# REFERENCES

1. Electron.js Documentation: https://www.electronjs.org/docs
2. Flutter & Dart Developer Guides: https://flutter.dev/docs
3. Socket.IO Real-time Framework: https://socket.io/docs/v4/
4. Node.js SystemInformation API: https://systeminformation.io/
5. Microsoft PowerShell Automation: https://learn.microsoft.com/en-us/powershell/
6. Praxinfo Official Site: https://www.praxinfo.com

---

# STUDENT DECLARATION

I hereby declare that this internship report is my original work and has been prepared based on the internship completed by me at the above-mentioned organization.

**Date:** 29 June 2026  
**Place:** Ahmedabad, Gujarat  

<br/><br/>
______________________________  
**Student Signature**  
(Darshan Satbhai)  
