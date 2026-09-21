import os
import sys
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.units import inch
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, Image, HRFlowable, KeepTogether
)
from reportlab.pdfgen import canvas

class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super(NumberedCanvas, self).__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_number(num_pages)
            canvas.Canvas.showPage(self)
        canvas.Canvas.save(self)

    def draw_page_number(self, page_count):
        if self._pageNumber == 1:
            return  # Skip header/footer on cover page
        self.saveState()
        self.setFont("Helvetica", 9)
        self.setFillColor(colors.HexColor("#555555"))
        
        # Header line & text
        self.drawString(54, 11 * inch - 36, "WinDeck – Summer Internship Report | Darshan Satbhai")
        self.setStrokeColor(colors.HexColor("#D0D0D0"))
        self.setLineWidth(0.5)
        self.line(54, 11 * inch - 42, 8.5 * inch - 54, 11 * inch - 42)
        
        # Footer line & page number
        page_str = f"{self._pageNumber}"
        self.drawRightString(8.5 * inch - 54, 36, page_str)
        self.drawString(54, 36, "Department of Computer Applications, Shreyarth University")
        self.line(54, 48, 8.5 * inch - 54, 48)
        self.restoreState()

def build_pdf(filename="D:/WINDECK/WinDeck_Summer_Internship_Report.pdf"):
    doc = SimpleDocTemplate(
        filename,
        pagesize=letter,
        leftMargin=54,
        rightMargin=54,
        topMargin=54,
        bottomMargin=54
    )
    
    styles = getSampleStyleSheet()
    
    # Custom styles
    title_style = ParagraphStyle(
        'CoverTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=22,
        leading=26,
        alignment=0, # Left-aligned beside logo
        textColor=colors.HexColor("#1A202C")
    )

    cert_title_style = ParagraphStyle(
        'CertTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=20,
        leading=24,
        alignment=1, # Center
        textColor=colors.HexColor("#1A202C")
    )
    
    subtitle_style = ParagraphStyle(
        'CoverSubtitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=22,
        alignment=0,
        textColor=colors.HexColor("#38A169")
    )
    
    h1_style = ParagraphStyle(
        'Header1',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=16,
        leading=20,
        spaceBefore=14,
        spaceAfter=8,
        textColor=colors.HexColor("#1A365D")
    )

    h2_style = ParagraphStyle(
        'Header2',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=12,
        leading=16,
        spaceBefore=10,
        spaceAfter=6,
        textColor=colors.HexColor("#2C5282")
    )
    
    body_style = ParagraphStyle(
        'BodyTextCustom',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=10,
        leading=14,
        spaceAfter=6,
        textColor=colors.HexColor("#2D3748")
    )

    bullet_style = ParagraphStyle(
        'BulletCustom',
        parent=body_style,
        leftIndent=15,
        firstLineIndent=-10,
        spaceAfter=4
    )

    code_style = ParagraphStyle(
        'CodeStyle',
        parent=styles['Normal'],
        fontName='Courier',
        fontSize=8.5,
        leading=11,
        textColor=colors.HexColor("#1A202C")
    )

    story = []

    # ================= PAGE 1: TITLE PAGE & CERTIFICATE =================
    logo_path = "D:/WINDECK/shreyarth_logo_0.png"
    
    header_title_cell = [
        Paragraph("<b>SUMMER INTERNSHIP</b>", title_style),
        Spacer(1, 4),
        Paragraph("<b>REPORT</b>", subtitle_style)
    ]

    if os.path.exists(logo_path):
        logo_img = Image(logo_path, width=1.1*inch, height=1.2*inch)
        header_table_data = [[logo_img, header_title_cell]]
        t_header = Table(header_table_data, colWidths=[1.4*inch, 5.3*inch])
        t_header.setStyle(TableStyle([
            ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
            ('ALIGN', (0,0), (0,0), 'LEFT'),
            ('LEFTPADDING', (1,0), (1,0), 10),
        ]))
        story.append(t_header)
    else:
        story.append(Paragraph("SUMMER INTERNSHIP REPORT", cert_title_style))

    story.append(Spacer(1, 8))
    intro_p = Paragraph("Submitted in partial fulfillment of the requirements for the award of the degree of<br/><b>INTEGRATED BSC AND MSC IT (IMSC-IT)</b>", ParagraphStyle('LeftSmall', parent=body_style, alignment=0))
    story.append(intro_p)
    story.append(Spacer(1, 8))

    meta_table_data = [
        [Paragraph("<b>Student Name:</b>", body_style), Paragraph("Darshan Satbhai", body_style)],
        [Paragraph("<b>Enrollment No:</b>", body_style), Paragraph("2402106047", body_style)],
        [Paragraph("<b>Semester:</b>", body_style), Paragraph("4th", body_style)],
        [Paragraph("<b>Faculty Guide:</b>", body_style), Paragraph("Khushali Pansinia", body_style)],
        [Paragraph("<b>Internship Organization:</b>", body_style), Paragraph("Praxinfo Pvt. Ltd.", body_style)],
        [Paragraph("<b>Project Title:</b>", body_style), Paragraph("WinDeck – Wireless PC Remote Control Suite", body_style)],
        [Paragraph("<b>Duration:</b>", body_style), Paragraph("From 04 June 2026 To Ongoing", body_style)],
        [Paragraph("<b>Submitted to:</b>", body_style), Paragraph("Department of Computer Applications [SHREYARTH UNIVERSITY]", body_style)],
        [Paragraph("<b>Academic Year:</b>", body_style), Paragraph("2026-27", body_style)],
    ]
    t_meta = Table(meta_table_data, colWidths=[2.2*inch, 4.5*inch])
    t_meta.setStyle(TableStyle([
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('BOTTOMPADDING', (0,0), (-1,-1), 1.5),
        ('TOPPADDING', (0,0), (-1,-1), 1.5),
    ]))
    story.append(t_meta)
    
    story.append(Spacer(1, 10))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor("#CBD5E0"), spaceAfter=10))
    
    story.append(Paragraph("CERTIFICATE", cert_title_style))
    story.append(Spacer(1, 6))
    
    cert_text = "This is to certify that <b>Mr. Darshan Satbhai</b>, <b>2402106047</b>, student of IMSC (Integrated B.Sc. and M.Sc. IT), has successfully completed the Summer Internship at <i>Praxinfo Pvt. Ltd.</i> From 18 June 2026 To Present.<br/><br/>During the internship period, the student worked on the project titled <b>“WinDeck”</b> under the guidance of Faculty Guide <b>Khushali Pansinia</b> and completed the assigned tasks satisfactorily.<br/><br/>We wish him success in future endeavors."
    story.append(Paragraph(cert_text, body_style))
    story.append(Spacer(1, 12))
    
    cert_sig_data = [
        [Paragraph("<b>Company Mentor / Founder & CEO</b>", body_style)],
        [Paragraph("Umang Kathiyara<br/>Founder & Director<br/><i>Praxinfo Pvt. Ltd.</i>", body_style)]
    ]
    t_sig = Table(cert_sig_data, colWidths=[3.5*inch])
    t_sig.setStyle(TableStyle([('VALIGN', (0,0), (-1,-1), 'TOP')]))
    story.append(t_sig)
    
    story.append(PageBreak())

    # ================= PAGE 2: ACKNOWLEDGEMENT & TOC & CH1 START =================
    story.append(Paragraph("ACKNOWLEDGEMENT", cert_title_style))
    story.append(Spacer(1, 8))
    ack_text = "I express my sincere gratitude to <b>Praxinfo Pvt. Ltd.</b> for providing me the opportunity to undergo industrial internship training. I would like to express my deepest appreciation to company founders <b>Mr. Umang Kathiyara</b> (Founder & Director) and <b>Mr. Naitik Patel</b> (Co-Founder & Technical Lead), as well as my mentors and staff members for their continuous guidance, technical mentorship, and support throughout the project.<br/><br/>I am also thankful to the Principal, Head of Department, Internship Coordinator, and Faculty Guide <b>Ms. Khushali Pansinia</b> of SHREYARTH UNIVERSITY College for their continuous encouragement, guidance, and assistance throughout the internship period.<br/><br/>Finally, I thank my family and friends for their support and motivation."
    story.append(Paragraph(ack_text, body_style))
    story.append(Spacer(1, 8))
    story.append(Paragraph("<b>Student Signature</b><br/>Darshan Satbhai", body_style))
    
    story.append(Spacer(1, 12))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor("#CBD5E0"), spaceAfter=10))
    
    story.append(Paragraph("TABLE OF CONTENTS", cert_title_style))
    story.append(Spacer(1, 6))
    
    toc_data = [
        [Paragraph("Certificate", body_style), Paragraph("i", body_style)],
        [Paragraph("Acknowledgement", body_style), Paragraph("ii", body_style)],
        [Paragraph("Table of Contents", body_style), Paragraph("ii", body_style)],
        [Paragraph("<b>CHAPTER 1: COMPANY PROFILE</b>", body_style), Paragraph("2", body_style)],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;1.1 Introduction", body_style), Paragraph("2", body_style)],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;1.2 Company Details", body_style), Paragraph("3", body_style)],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;1.3 Organizational Structure", body_style), Paragraph("3", body_style)],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;1.4 Objectives of the Company", body_style), Paragraph("3", body_style)],
        [Paragraph("<b>CHAPTER 2: INTERNSHIP WORK DETAILS / PROJECT DESCRIPTION</b>", body_style), Paragraph("4", body_style)],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;2.1 Project Title", body_style), Paragraph("4", body_style)],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;2.2 Project Objective", body_style), Paragraph("4", body_style)],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;2.3 Technologies Used", body_style), Paragraph("4", body_style)],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;2.4 Tasks Performed", body_style), Paragraph("4", body_style)],
        [Paragraph("&nbsp;&nbsp;&nbsp;&nbsp;2.5 Project Modules", body_style), Paragraph("5", body_style)],
        [Paragraph("<b>CHAPTER 3: LEARNING OUTCOMES</b>", body_style), Paragraph("5", body_style)],
        [Paragraph("<b>CHAPTER 4: SCREENSHOTS / CODE SNIPPETS</b>", body_style), Paragraph("6", body_style)],
        [Paragraph("<b>CHAPTER 5: CONCLUSION</b>", body_style), Paragraph("7", body_style)],
        [Paragraph("<b>CHAPTER 6: FUTURE SCOPE</b>", body_style), Paragraph("7", body_style)],
        [Paragraph("<b>REFERENCES</b>", body_style), Paragraph("8", body_style)],
    ]
    t_toc = Table(toc_data, colWidths=[5.5*inch, 1*inch])
    t_toc.setStyle(TableStyle([
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('BOTTOMPADDING', (0,0), (-1,-1), 1),
        ('TOPPADDING', (0,0), (-1,-1), 1),
    ]))
    story.append(t_toc)
    
    story.append(PageBreak())

    # ================= CHAPTER 1: COMPANY PROFILE =================
    story.append(Paragraph("CHAPTER 1: COMPANY PROFILE", h1_style))
    story.append(Paragraph("1.1 Introduction", h2_style))
    ch1_intro = "Praxinfo Pvt. Ltd. is an established IT services, mobile app, and custom software development company based in Ahmedabad, Gujarat. Founded by <b>Mr. Umang Kathiyara</b> (Founder) and <b>Mr. Naitik Patel</b> (Co-Founder), Praxinfo specializes in providing end-to-end digital solutions, including mobile application development (Flutter, React Native, iOS, Android), modern web development, cloud software engineering, enterprise CRM solutions, and UI/UX design. With a client-first approach and experienced technical leadership, the company serves startups, growing businesses, and international enterprise clients. During my 45-day summer internship program, I had the opportunity to work under the direct mentorship of Praxinfo's senior development team and gain hands-on industrial experience on real-world cross-platform applications."
    story.append(Paragraph(ch1_intro, body_style))
    
    story.append(Paragraph("1.2 Company Details", h2_style))
    comp_details = """
    <b>Company Name:</b> Praxinfo Pvt. Ltd.<br/>
    <b>Founders & Key Management:</b> Umang Kathiyara (Founder & Director), Naitik Patel (Co-Founder & Technical Lead)<br/>
    <b>Registered Address:</b> C-608, Titanium City Center, 100 Feet Anand Nagar Rd, Near Sachin Tower, Satellite, Ahmedabad, Gujarat – 380015, India.<br/>
    <b>Website:</b> www.praxinfo.com<br/>
    <b>Industry Type:</b> Information Technology (IT Services, Web & Mobile App Engineering)<br/>
    <b>Services Offered:</b>
    """
    story.append(Paragraph(comp_details, body_style))
    services = [
        "• Mobile Application Development (Flutter, React Native, iOS, Android)",
        "• Custom Web & Desktop Software Development (Node.js, Express, PHP/Laravel, React)",
        "• Enterprise Software Consulting & CRM Development",
        "• UI/UX Design & Interactive Prototyping",
        "• Cloud Computing, API Integration & DevOps Services",
        "• Digital Strategy & E-Commerce Engineering"
    ]
    for s in services:
        story.append(Paragraph(s, bullet_style))
        
    story.append(Paragraph("1.3 Organizational Structure", h2_style))
    org_text = "Praxinfo Pvt. Ltd. follows a streamlined organizational hierarchy that fosters collaborative engineering and high-quality software delivery. Executive leadership is headed by Founder <b>Umang Kathiyara</b> and Co-Founder <b>Naitik Patel</b>, supported by project managers and technical leads who oversee dedicated software engineers, mobile app developers, UI/UX designers, and quality assurance engineers. During the internship, interns are assigned direct mentors who provide code reviews, technical guidance, and architecture supervision on production projects."
    story.append(Paragraph(org_text, body_style))
    
    story.append(Paragraph("1.4 Objectives of the Company", h2_style))
    obj_text = "The core objective of Praxinfo Pvt. Ltd. is to deliver scalable, robust, and cost-effective software solutions that drive business transformation for global clients. The company strives to provide high-quality applications through modern technological stacks, agile development sprint cycles, and continuous technical innovation while maintaining high standards of software quality, transparency, and client satisfaction."
    story.append(Paragraph(obj_text, body_style))
    
    story.append(PageBreak())

    # ================= CHAPTER 2: INTERNSHIP WORK DETAILS =================
    story.append(Paragraph("CHAPTER 2: INTERNSHIP WORK DETAILS / PROJECT DESCRIPTION", h1_style))
    
    story.append(Paragraph("2.1 Project Title", h2_style))
    story.append(Paragraph("<b>WinDeck – Wireless PC Remote Control Suite</b>", body_style))
    
    story.append(Paragraph("2.2 Project Objective", h2_style))
    proj_obj = "The objective of this project is to develop a modern, high-speed, and responsive wireless control suite that transforms an Android smartphone into a remote control for a Windows PC. Operating over a local WiFi/LAN network using WebSockets, WinDeck enables real-time media and system volume/brightness control, launching PC applications, executing custom PowerShell macros, bidirectional clipboard synchronization, live PC system resource monitoring (CPU, RAM, GPU), an Air Mouse utilizing phone gyroscope sensors, and streaming the smartphone camera as a virtual webcam to the PC. The project aims to provide ultra-low latency, fast performance, top-tier security (AES-256 encryption & OTP pairing), and an intuitive touch deck interface."
    story.append(Paragraph(proj_obj, body_style))
    
    story.append(Paragraph("2.3 Technologies Used", h2_style))
    tech_list = [
        "• <b>Mobile Client:</b> Flutter, Dart, Material Design, Provider State Management, Hardware Sensors (Gyroscope/Accelerometer), mDNS/NSD.",
        "• <b>Desktop Server:</b> Electron.js, Node.js, Express, Socket.IO, PowerShell IPC, SystemInformation, robotjs / nut.js, Bonjour Service.",
        "• <b>Networking & Security:</b> Socket.IO (WebSockets), UDP Broadcast, AES-256-CBC Payload Encryption, 6-digit OTP Pairing.",
        "• <b>Landing Page & Tools:</b> HTML5, CSS3, Tailwind CSS, JavaScript, Vite, Git & GitHub."
    ]
    for t in tech_list:
        story.append(Paragraph(t, bullet_style))
        
    story.append(Paragraph("2.4 Tasks Performed", h2_style))
    tasks = [
        "• Requirement analysis and architecture planning for local network PC control.",
        "• Development of Electron-based desktop server GUI and background service daemon.",
        "• Responsive front-end UI implementation in Flutter following Material 3 guidelines.",
        "• High-speed Socket.IO real-time bi-directional messaging with AES-256 encryption setup.",
        "• UDP Broadcast and mDNS service discovery for zero-configuration PC pairing.",
        "• Air Mouse feature implementation utilizing smartphone motion sensors.",
        "• Custom macro execution engine capable of invoking PowerShell IPC scripts.",
        "• Dynamic App Launcher indexing installed PC apps and extracting icons.",
        "• Active window tracking and real-time PC clipboard synchronization.",
        "• Camera Bridge module development to stream mobile feed as virtual PC webcam.",
        "• System performance monitor integration (CPU, RAM, GPU statistics).",
        "• Build packaging, installer generation, and GitHub release pipeline deployment."
    ]
    for task in tasks:
        story.append(Paragraph(task, bullet_style))
        
    story.append(Paragraph("2.5 Project Modules", h2_style))
    modules = [
        "<b>Module 1: Server Room & Security Pairing</b> — Handles room creation, 6-digit OTP generation, mDNS/UDP auto-discovery, and AES-256 encrypted session handshake.",
        "<b>Module 2: System & Media Controller</b> — Provides remote controls for system volume, screen brightness, media playback, power options, and Air Mouse gyroscope controller.",
        "<b>Module 3: App Launcher & Window Tracker</b> — Discovers installed Windows applications, displays indexed icons, triggers app launches, and tracks the currently active PC window.",
        "<b>Module 4: Custom Macros & Action Deck</b> — Allows users to build custom action pages, map buttons to PowerShell scripts or shortcuts, and manage deck layouts.",
        "<b>Module 5: Productivity & System Monitor</b> — Provides live clipboard text synchronization, performance monitoring metrics (CPU/RAM/GPU), and wireless file transfers.",
        "<b>Module 6: Camera Bridge</b> — Streams low-latency video feed from phone camera to PC for use as a virtual webcam."
    ]
    for mod in modules:
        story.append(Paragraph(f"• {mod}", bullet_style))

    story.append(PageBreak())

    # ================= CHAPTER 3: LEARNING OUTCOMES =================
    story.append(Paragraph("CHAPTER 3: LEARNING OUTCOMES", h1_style))
    story.append(Paragraph("During the 45-day industrial internship at Praxinfo Pvt. Ltd., I learned:", body_style))
    outcomes = [
        "• Gained experience in building modern desktop applications using <b>Electron.js</b> and Node.js.",
        "• Mastered cross-platform mobile UI development and state management with <b>Flutter and Dart</b> under Praxinfo mentorship.",
        "• Developed deep understanding of real-time socket communication using <b>Socket.IO</b>, mDNS, and UDP broadcasting.",
        "• Learned hardware sensor integration (Gyroscope/Accelerometer) for motion-controlled input.",
        "• Understood low-level system automation via <b>PowerShell IPC</b> and native OS commands.",
        "• Gained knowledge in implementing cryptographic security using <b>AES-256</b> payload encryption and OTP pairing.",
        "• Enhanced project management, version control (Git/GitHub), and build release workflows under guidance of faculty guide <b>Khushali Pansinia</b>."
    ]
    for o in outcomes:
        story.append(Paragraph(o, bullet_style))
        
    story.append(Spacer(1, 15))

    # ================= CHAPTER 4: SCREENSHOTS / CODE SNIPPETS =================
    story.append(Paragraph("CHAPTER 4: SCREENSHOTS / CODE SNIPPETS", h1_style))
    
    # Screenshots Grid / Table
    img_dir = "D:/WINDECK/screenshots"
    img_files = ["1_connect_pc.png", "2_launch_apps.png", "3_system_control.png", "4_website_access.png", "5_app_specific_controls.png"]
    
    story.append(Paragraph("Application Interface Screenshots:", h2_style))
    
    img_table_data = []
    row = []
    for idx, fname in enumerate(img_files):
        fpath = os.path.join(img_dir, fname)
        if os.path.exists(fpath):
            img = Image(fpath, width=2.0*inch, height=3.5*inch)
            caption = Paragraph(f"<b>Fig {idx+1}:</b> {fname.replace('.png','').replace('_',' ').title()}", ParagraphStyle('Cap', parent=body_style, fontSize=8, alignment=1))
            cell = [img, Spacer(1, 2), caption]
            row.append(cell)
            if len(row) == 3 or idx == len(img_files) - 1:
                while len(row) < 3:
                    row.append("")
                img_table_data.append(row)
                row = []

    if img_table_data:
        t_imgs = Table(img_table_data, colWidths=[2.2*inch, 2.2*inch, 2.2*inch])
        t_imgs.setStyle(TableStyle([
            ('ALIGN', (0,0), (-1,-1), 'CENTER'),
            ('VALIGN', (0,0), (-1,-1), 'TOP'),
            ('BOTTOMPADDING', (0,0), (-1,-1), 8),
        ]))
        story.append(t_imgs)

    story.append(PageBreak())
    
    story.append(Paragraph("Sample Code Snippets", h2_style))
    story.append(Paragraph("<b>1. Server Initialization & Socket.IO Setup (server.js)</b>", body_style))
    
    code_1 = """const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const os = require('os');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: '*' } });

// Generate Room ID from Local IP
function generateEncodedRoomId() {
    const interfaces = os.networkInterfaces();
    for (const name of Object.keys(interfaces)) {
        for (const iface of interfaces[name]) {
            if (iface.family === 'IPv4' && !iface.internal) {
                const hex = iface.address.split('.')
                    .map(p => parseInt(p).toString(16).padStart(2, '0').toUpperCase()).join('');
                return `${hex.slice(0, 4)}-${hex.slice(4)}`;
            }
        }
    }
    return 'WINDECK-ROOM';
}"""

    t_code1 = Table([[Paragraph(code_1.replace('\n', '<br/>').replace(' ', '&nbsp;'), code_style)]], colWidths=[6.5*inch])
    t_code1.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#F7FAFC")),
        ('BOX', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('PADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_code1)
    story.append(Spacer(1, 10))

    story.append(Paragraph("<b>2. PowerShell Macro Execution Engine (systemControls.js)</b>", body_style))
    code_2 = """const { exec } = require('child_process');

function executePowerShellMacro(scriptContent) {
    return new Promise((resolve, reject) => {
        const encoded = Buffer.from(scriptContent, 'utf16le').toString('base64');
        const cmd = `powershell.exe -NoProfile -NonInteractive -EncodedCommand ${encoded}`;
        
        exec(cmd, (error, stdout, stderr) => {
            if (error) reject(stderr || error.message);
            else resolve(stdout.trim());
        });
    });
}"""
    t_code2 = Table([[Paragraph(code_2.replace('\n', '<br/>').replace(' ', '&nbsp;'), code_style)]], colWidths=[6.5*inch])
    t_code2.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#F7FAFC")),
        ('BOX', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('PADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_code2)

    story.append(Spacer(1, 14))

    # ================= CHAPTER 5: CONCLUSION =================
    story.append(Paragraph("CHAPTER 5: CONCLUSION", h1_style))
    conclusion_text = "The 45-day industrial internship at Praxinfo Pvt. Ltd. provided practical experience in developing a modern cross-platform software suite using industry-standard technologies. Under the mentorship of <b>Mr. Umang Kathiyara</b> and <b>Mr. Naitik Patel</b>, and faculty guidance of <b>Khushali Pansinia</b>, I learned how to build high-performance Electron desktop servers, responsive Flutter mobile interfaces, real-time encrypted WebSocket communication channels, and low-level system automation tools. Developing the <b>WinDeck</b> application improved my technical knowledge, debugging abilities, and problem-solving skills while giving me valuable exposure to real-world software engineering practices."
    story.append(Paragraph(conclusion_text, body_style))

    story.append(Spacer(1, 10))

    # ================= CHAPTER 6: FUTURE SCOPE =================
    story.append(Paragraph("CHAPTER 6: FUTURE SCOPE", h1_style))
    future_items = [
        "• <b>Cloud Remote Access:</b> Internet-wide connectivity via WebRTC relay servers for remote access outside local WiFi.",
        "• <b>Cross-Platform Desktop Support:</b> Porting server backend to macOS and Linux operating systems.",
        "• <b>Biometric Authentication:</b> Fingerprint and Face ID integration for secure PC authorization.",
        "• <b>Community Macro Deck Marketplace:</b> Online platform to share and download customized action decks.",
        "• <b>Advanced Widget Customization:</b> Drag-and-drop mobile UI layout builder with dynamic PC telemetry."
    ]
    for f in future_items:
        story.append(Paragraph(f, bullet_style))

    story.append(Spacer(1, 10))

    # ================= REFERENCES =================
    story.append(Paragraph("REFERENCES", h1_style))
    refs = [
        "1. Electron.js Official Documentation: https://www.electronjs.org/docs",
        "2. Flutter & Dart Developer Guides: https://flutter.dev/docs",
        "3. Socket.IO Real-time WebSockets: https://socket.io/docs/v4/",
        "4. Node.js SystemInformation Module: https://systeminformation.io/",
        "5. Microsoft PowerShell Automation: https://learn.microsoft.com/en-us/powershell/",
        "6. Praxinfo Official Website: https://www.praxinfo.com"
    ]
    for r in refs:
        story.append(Paragraph(r, body_style))

    story.append(Spacer(1, 15))

    # ================= STUDENT DECLARATION =================
    story.append(Paragraph("STUDENT DECLARATION", h1_style))
    dec_text = "I hereby declare that this internship report is my original work and has been prepared based on the internship completed by me at the above-mentioned organization."
    story.append(Paragraph(dec_text, body_style))
    story.append(Spacer(1, 12))
    story.append(Paragraph("<b>Date:</b> 29 June 2026<br/><b>Place:</b> Ahmedabad, Gujarat", body_style))
    story.append(Spacer(1, 20))
    story.append(Paragraph("______________________________<br/><b>Student Signature</b><br/>(Darshan Satbhai)", body_style))

    # Build PDF
    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"Successfully generated PDF report at: {filename}")

if __name__ == '__main__':
    build_pdf()
