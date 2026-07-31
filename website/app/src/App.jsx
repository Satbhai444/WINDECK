import React from 'react';
import { motion } from 'framer-motion';
import { 
  Zap, 
  Smartphone, 
  Monitor, 
  ShieldCheck, 
  Copy, 
  Music, 
  Layers, 
  ArrowRight,
  Sliders,
  CheckCircle2,
  AlertTriangle
} from 'lucide-react';

export default function App() {
  return (
    <div className="min-h-screen bg-black text-[#f5f5f7] font-sans antialiased selection:bg-[#505be1] selection:text-white">
      
      {/* Top Navigation Bar */}
      <header className="fixed left-0 right-0 top-0 z-50 flex items-center justify-between px-6 sm:px-8 h-14 border-b border-white/[0.06] bg-black/60 backdrop-blur-xl">
        <a href="#" className="shrink-0 text-[17px] font-bold tracking-tight text-white hover:opacity-90 transition-opacity">
          win<span className="text-[#505be1]">deck</span>
        </a>
        
        <nav className="hidden md:flex items-center gap-8 text-[13px]">
          <a href="#pc-app" class="text-white/40 hover:text-white/80 transition-colors">Apps</a>
          <a href="#features" class="text-white/40 hover:text-white/80 transition-colors">Features</a>
          <a href="#who-its-for" class="text-white/40 hover:text-white/80 transition-colors">Built for</a>
          <a href="#how-it-works" class="text-white/40 hover:text-white/80 transition-colors">How it works</a>
        </nav>

        <a href="#download" className="shrink-0 text-[13px] font-semibold px-5 py-2 rounded-full bg-white text-black hover:bg-white/90 transition-colors">
          Download
        </a>
      </header>

      <main>
        {/* Hero Section */}
        <section className="relative min-h-screen flex flex-col items-center justify-center text-center px-6 pt-24 pb-16 overflow-hidden grid-pattern">
          {/* Radial Glow Effect */}
          <div className="absolute bottom-1/3 left-1/2 -translate-x-1/2 w-[700px] h-[400px] rounded-full bg-[#505be1] opacity-10 blur-[140px] pointer-events-none" />

          <div className="relative z-10 flex flex-col items-center w-full max-w-5xl">
            
            {/* Version Badge */}
            <motion.div 
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
              className="mb-7 inline-flex items-center gap-2.5 px-4 py-1.5 rounded-full border border-[#505be1]/40 bg-[#505be1]/10 text-[11px] text-indigo-300 tracking-widest uppercase shadow-[0_0_20px_rgba(80,91,225,0.2)]"
            >
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[#505be1] opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-[#505be1]"></span>
              </span>
              <span>v1.2 — Context Auto-Switch & 2-Way Clipboard</span>
              <span className="text-[14px] text-indigo-300">✦</span>
            </motion.div>

            {/* Headline */}
            <motion.h1 
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.1 }}
              className="text-[52px] sm:text-[76px] md:text-[92px] font-bold tracking-[-0.04em] leading-[1.02] max-w-3xl mb-6"
            >
              The controller<br/>
              <span className="text-[#505be1]">you already own.</span>
            </motion.h1>

            {/* Subtitle */}
            <motion.p 
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.2 }}
              className="text-[17px] sm:text-[19px] text-white/45 max-w-md leading-relaxed font-light mb-10"
            >
              Your Android phone is already a controller. WinDeck just turns it on. One tap. Free, forever.
            </motion.p>

            {/* Buttons */}
            <motion.div 
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.3 }}
              className="flex flex-col sm:flex-row items-center gap-4 mb-14"
            >
              <a href="#download" className="inline-flex items-center h-[46px] px-8 rounded-full bg-[#505be1] text-white text-[15px] font-semibold hover:bg-[#3b43c6] transition-colors btn-glow">
                Get WinDeck Free
              </a>
              <a href="#features" className="inline-flex items-center h-[46px] px-8 rounded-full bg-black border border-white/[0.22] text-white text-[15px] font-semibold hover:border-white/40 transition-colors">
                Explore Features
              </a>
            </motion.div>

            {/* Real App Screenshot Showcase Frame */}
            <motion.div 
              initial={{ opacity: 0, scale: 0.95, y: 30 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              transition={{ duration: 0.7, delay: 0.4 }}
              className="w-full max-w-4xl relative p-3 rounded-[32px] bg-gradient-to-b from-white/10 to-white/0 border border-white/10 shadow-2xl overflow-hidden"
            >
              <div className="rounded-[24px] overflow-hidden bg-black border border-white/5">
                <img src="/images/showcase.jpg" alt="WinDeck Showcase" className="w-full h-auto object-cover rounded-2xl" />
              </div>
            </motion.div>

          </div>
        </section>

        {/* WinDeck in Action Section */}
        <section id="pc-app" className="bg-black py-32 overflow-hidden border-t border-white/[0.04]">
          <div className="relative max-w-6xl mx-auto px-6 text-center md:text-left">
            <motion.div 
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6 }}
              className="mb-12 max-w-2xl"
            >
              <p className="text-[11px] font-semibold uppercase tracking-[0.18em] text-[#505be1] mb-3">WinDeck in action</p>
              <h2 className="text-[36px] sm:text-[48px] font-bold tracking-[-0.03em] leading-[1.06]">
                Your PC. Your Phone.<br/>
                <span className="text-white/30">One seamless workflow.</span>
              </h2>
              <p className="mt-4 text-[16px] text-white/45 max-w-lg leading-relaxed">
                The Windows PC app organizes your apps into pages. Your phone shows the tiles. Tap one — the app opens instantly on your PC.
              </p>
            </motion.div>

            <motion.div 
              initial={{ opacity: 0, y: 40 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.7, delay: 0.2 }}
              className="rounded-3xl border border-white/10 overflow-hidden shadow-2xl bg-[#080808]"
            >
              <img src="/images/desktop-app.jpg" alt="WinDeck Windows App Command Center" className="w-full h-auto object-cover" />
            </motion.div>
            <p className="mt-4 text-[12px] text-white/20 text-center">Real WinDeck PC Desktop Interface • 100% Wireless</p>
          </div>
        </section>

        {/* Core Features Section */}
        <section id="features" className="py-32 bg-[#050508] border-t border-white/[0.04]">
          <div className="max-w-6xl mx-auto px-6">
            <div className="text-center max-w-3xl mx-auto mb-16">
              <p className="text-[11px] font-semibold uppercase tracking-[0.18em] text-[#505be1] mb-3">Core Features</p>
              <h2 className="text-[36px] sm:text-[48px] font-bold tracking-[-0.03em] text-white">
                Built to supercharge your PC productivity.
              </h2>
            </div>

            <div className="grid md:grid-cols-3 gap-6">
              
              <motion.div 
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: 0.1 }}
                className="pd-card p-8 flex flex-col justify-between"
              >
                <div className="w-12 h-12 rounded-2xl bg-[#505be1]/15 border border-[#505be1]/30 flex items-center justify-center text-[#505be1] mb-6">
                  <Layers className="w-6 h-6" />
                </div>
                <h3 className="text-xl font-bold text-white mb-2">Context Auto-Switching</h3>
                <p className="text-white/45 text-sm leading-relaxed">
                  Automatically switches phone decks based on active PC window (e.g. Google Meet, YouTube, Spotify, VS Code).
                </p>
              </motion.div>

              <motion.div 
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: 0.2 }}
                className="pd-card p-8 flex flex-col justify-between"
              >
                <div className="w-12 h-12 rounded-2xl bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 mb-6">
                  <Copy className="w-6 h-6" />
                </div>
                <h3 className="text-xl font-bold text-white mb-2">2-Way Clipboard Sync</h3>
                <p class="text-white/45 text-sm leading-relaxed">
                  Copy text on PC (Ctrl+C) ➔ Paste on Phone. Copy text on Phone ➔ Paste on PC (Ctrl+V) instantly with loop guards.
                </p>
              </motion.div>

              <motion.div 
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: 0.3 }}
                className="pd-card p-8 flex flex-col justify-between"
              >
                <div className="w-12 h-12 rounded-2xl bg-purple-500/10 border border-purple-500/30 flex items-center justify-center text-purple-400 mb-6">
                  <Music className="w-6 h-6" />
                </div>
                <h3 className="text-xl font-bold text-white mb-2">Live Media Header Card</h3>
                <p className="text-white/45 text-sm leading-relaxed">
                  Displays real-time song title, artist, playback timeline, and album art from Spotify, YouTube & Windows Media.
                </p>
              </motion.div>

            </div>
          </div>
        </section>

        {/* Download Section */}
        <section id="download" className="relative bg-black py-32 px-6 border-t border-white/[0.04]">
          <div className="relative max-w-5xl mx-auto">
            <div className="text-center mb-12">
              <h2 className="text-[40px] sm:text-[56px] font-bold tracking-[-0.03em] leading-tight mb-4">
                Get WinDeck.
              </h2>
              <p className="text-[17px] text-white/45 leading-relaxed">
                Two apps. One seamless experience. Free, forever.
              </p>
            </div>

            {/* Version Warning Banner */}
            <div className="mb-10 flex flex-col items-center text-center gap-1.5 rounded-2xl border border-amber-500/25 bg-amber-500/[0.06] px-6 py-4">
              <AlertTriangle className="w-6 h-6 text-amber-400 mb-1" />
              <p className="text-[14px] font-semibold text-amber-300">Both apps must be on v1.2 to work.</p>
              <p className="text-[13px] text-amber-400/60">Update both PC Server and Android App to v1.2 before using — one without the other won't connect.</p>
            </div>

            {/* 2 Download Cards */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              
              {/* Android Card */}
              <div className="pd-card p-6 flex flex-col overflow-hidden">
                <div className="h-64 rounded-2xl overflow-hidden mb-6 bg-[#0a0a0a] border border-white/10 flex items-center justify-center p-2">
                  <img src="/images/phone-app.jpg" alt="WinDeck Android App" className="h-full w-auto object-contain rounded-xl" />
                </div>
                <p className="text-[11px] font-semibold uppercase tracking-[0.18em] text-[#505be1] mb-1">Android App</p>
                <h3 className="text-[22px] font-bold tracking-[-0.02em] mb-2">Your Mobile Controller</h3>
                <p className="text-[14px] text-white/45 leading-relaxed mb-6 flex-1">
                  Swipe between custom decks. Tap any tile to trigger macros, control volume, or switch apps on your Windows PC instantly.
                </p>
                <div className="mt-auto flex flex-col items-center gap-3">
                  <div className="px-3 py-1 rounded-full border border-[#505be1]/35 bg-[#505be1]/10 text-[11px] font-semibold text-indigo-300">
                    v1.2 · Latest Release
                  </div>
                  <button onClick={() => alert('Starting WinDeck Android APK Download...')} className="w-full py-3.5 rounded-xl bg-[#505be1] text-white font-bold text-center hover:bg-[#3b43c6] transition-colors btn-glow text-sm cursor-pointer">
                    Download APK for Android
                  </button>
                </div>
              </div>

              {/* Windows PC Server Card */}
              <div className="pd-card p-6 flex flex-col overflow-hidden">
                <div className="h-64 rounded-2xl overflow-hidden mb-6 bg-[#0a0a0a] border border-white/10 flex items-center justify-center p-2">
                  <img src="/images/desktop-app.jpg" alt="WinDeck PC App" className="w-full h-full object-cover rounded-xl" />
                </div>
                <p className="text-[11px] font-semibold uppercase tracking-[0.18em] text-[#505be1] mb-1">Windows 10 / 11</p>
                <h3 className="text-[22px] font-bold tracking-[-0.02em] mb-2">Your PC Command Center</h3>
                <p className="text-[14px] text-white/45 leading-relaxed mb-6 flex-1">
                  Visual Layout Editor. Manage pages, app shortcuts, and system controls. Persistent fast shell execution with zero delay.
                </p>
                <div className="mt-auto flex flex-col items-center gap-3">
                  <div className="px-3 py-1 rounded-full border border-[#505be1]/35 bg-[#505be1]/10 text-[11px] font-semibold text-indigo-300">
                    v1.2 · Latest Release
                  </div>
                  <button onClick={() => alert('Starting WinDeck Windows Server .exe Download...')} className="w-full py-3.5 rounded-xl bg-[#505be1] text-white font-bold text-center hover:bg-[#3b43c6] transition-colors btn-glow text-sm cursor-pointer">
                    Download WinDeck Server (.exe)
                  </button>
                </div>
              </div>

            </div>
          </div>
        </section>

        {/* Framer Motion StreamDeck Price Comparison Section */}
        <section id="comparison" className="bg-black py-32 px-6 border-t border-white/[0.04]">
          <div className="max-w-4xl mx-auto text-center">
            <p className="text-[36px] sm:text-[52px] md:text-[64px] font-bold tracking-[-0.03em] leading-[1.08]">
              The StreamDeck<br/>
              <span className="text-white/30">you already own.</span>
            </p>

            <div className="mt-16 flex items-center justify-center gap-12 sm:gap-24">
              
              {/* $250 Hardware StreamDeck with Jhatka Shake & White Line Strike */}
              <div className="flex flex-col items-center gap-2">
                <div className="relative inline-block">
                  <motion.span 
                    initial={{ opacity: 1, x: 0 }}
                    whileInView={{ 
                      opacity: 0.15,
                      x: [0, -5, 5, -3, 3, 0]
                    }}
                    viewport={{ once: false, amount: 0.5 }}
                    transition={{ duration: 0.5, ease: "easeInOut" }}
                    className="text-6xl sm:text-8xl font-bold inline-block text-white"
                  >
                    $250
                  </motion.span>
                  
                  {/* White Strikethrough Line */}
                  <motion.div 
                    initial={{ scaleX: 0 }}
                    whileInView={{ scaleX: 1 }}
                    viewport={{ once: false, amount: 0.5 }}
                    transition={{ duration: 0.5, ease: [0.16, 1, 0.3, 1] }}
                    className="absolute left-[-6%] top-[52%] w-[112%] h-[4px] rounded-full bg-white origin-left pointer-events-none"
                  />
                </div>
                <span className="text-[11px] text-white/20 uppercase tracking-widest font-mono">Hardware StreamDeck</span>
              </div>

              <span className="text-xl text-white/20 font-light">vs</span>

              {/* $0 WinDeck (Appears AFTER 0.5s delay, NO GLOW) */}
              <div className="flex flex-col items-center gap-2">
                <motion.span 
                  initial={{ opacity: 0, scale: 0.75, y: 12 }}
                  whileInView={{ opacity: 1, scale: 1, y: 0 }}
                  viewport={{ once: false, amount: 0.5 }}
                  transition={{ delay: 0.5, duration: 0.5, ease: [0.16, 1, 0.3, 1] }}
                  className="text-6xl sm:text-8xl font-bold text-[#505be1]"
                >
                  $0
                </motion.span>
                <span className="text-[11px] text-[#505be1] font-semibold uppercase tracking-widest font-mono">WinDeck</span>
              </div>

            </div>

            <p className="mt-12 text-[16px] text-white/30 max-w-md mx-auto leading-relaxed font-light">
              The hardware is already in your pocket. Or charging on your desk. You paid for it years ago.
            </p>
          </div>
        </section>

        {/* Use Cases Section with Exact Text */}
        <section id="who-its-for" className="bg-[#050508] py-32 px-6 border-t border-white/[0.04]">
          <div className="max-w-5xl mx-auto">
            <div className="text-center mb-16">
              <p className="text-[11px] font-semibold uppercase tracking-[0.18em] text-[#505be1] mb-3">Why it matters</p>
              <h2 className="text-[36px] sm:text-[48px] font-bold tracking-[-0.03em] leading-tight">
                Built for people who actually focus.
              </h2>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
              
              {/* Hustler */}
              <motion.div 
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5 }}
                className="pd-card p-8 flex flex-col justify-between"
              >
                <p className="text-[11px] font-semibold uppercase tracking-widest text-emerald-400 mb-2">For the hustler</p>
                <h3 className="text-[22px] font-bold tracking-tight mb-3">Boss walks by. You're already on it.</h3>
                <p className="text-white/45 text-[14px] leading-relaxed">
                  One tap and you're on Slack. No one knows. WinDeck sits beside your PC screen, completely invisible to everyone else.
                </p>
              </motion.div>

              {/* Builder */}
              <motion.div 
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: 0.1 }}
                className="pd-card p-8 flex flex-col justify-between"
              >
                <p className="text-[11px] font-semibold uppercase tracking-widest text-amber-400 mb-2">For the builder</p>
                <h3 className="text-[22px] font-bold tracking-tight mb-3">Never break your flow state.</h3>
                <p className="text-white/40 text-[14px] leading-relaxed">
                  Reaching for the mouse kills the momentum. Tap your phone to switch apps, run scripts, or adjust volume without leaving the keyboard.
                </p>
              </motion.div>

              {/* Minimalist */}
              <motion.div 
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: 0.2 }}
                className="pd-card p-8 flex flex-col justify-between"
              >
                <p className="text-[11px] font-semibold uppercase tracking-widest text-pink-400 mb-2">For the minimalist</p>
                <h3 class="text-[22px] font-bold tracking-tight mb-3">A clean desk. Zero extra cables.</h3>
                <p className="text-white/40 text-[14px] leading-relaxed">
                  No USB dongles. No clunky plastic hardware box. Just the phone already sitting on your desk.
                </p>
              </motion.div>

              {/* Creator */}
              <motion.div 
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: 0.3 }}
                className="pd-card p-8 flex flex-col justify-between"
              >
                <p className="text-[11px] font-semibold uppercase tracking-widest text-purple-400 mb-2">For the creator</p>
                <h3 className="text-[22px] font-bold tracking-tight mb-3">Go live. Stay in control.</h3>
                <p className="text-white/40 text-[14px] leading-relaxed">
                  Switch between OBS, your browser, and chat in one tap. No mouse lag. Just pure control over your Windows PC.
                </p>
              </motion.div>

            </div>
          </div>
        </section>

        {/* 3 Step How It Works */}
        <section id="how-it-works" className="bg-black py-32 px-6 border-t border-white/[0.04]">
          <div className="max-w-5xl mx-auto">
            <div className="text-center mb-16">
              <p className="text-[11px] font-semibold uppercase tracking-[0.18em] text-[#505be1] mb-3">How it works</p>
              <h2 className="text-[36px] sm:text-[48px] font-bold tracking-[-0.03em]">Set up in under a minute.</h2>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              
              <div className="pd-card p-8 text-center">
                <span className="text-3xl font-extrabold text-[#505be1] block mb-4">01</span>
                <h3 className="text-[18px] font-semibold mb-2">Get WinDeck</h3>
                <p className="text-[13px] text-white/45 leading-relaxed">
                  Download the PC Server for Windows and the APK for Android. Takes 30 seconds.
                </p>
              </div>

              <div className="pd-card p-8 text-center">
                <span className="text-3xl font-extrabold text-emerald-400 block mb-4">02</span>
                <h3 className="text-[18px] font-semibold mb-2">Connect over Wi-Fi</h3>
                <p className="text-[13px] text-white/45 leading-relaxed">
                  Same local network. Enter the 6-digit OTP code shown on your PC screen into your phone.
                </p>
              </div>

              <div className="pd-card p-8 text-center">
                <span className="text-3xl font-extrabold text-purple-400 block mb-4">03</span>
                <h3 className="text-[18px] font-semibold mb-2">Control your PC</h3>
                <p className="text-[13px] text-white/45 leading-relaxed">
                  Launch apps, switch pages automatically, sync clipboards, and control system volume.
                </p>
              </div>

            </div>
          </div>
        </section>

        {/* Privacy Section */}
        <section className="bg-[#050508] py-24 px-6 border-t border-white/[0.04] text-center">
          <div className="max-w-3xl mx-auto">
            <p className="text-[11px] font-semibold uppercase tracking-widest text-[#505be1] mb-3">Privacy First</p>
            <h2 className="text-3xl sm:text-4xl font-bold mb-4">Nothing leaves your local network.</h2>
            <p className="text-white/45 text-sm leading-relaxed max-w-xl mx-auto">
              No external cloud servers. No accounts required. No tracking. WinDeck communicates 100% locally over your home Wi-Fi via zero-latency WebSockets.
            </p>
          </div>
        </section>

      </main>

      {/* Footer */}
      <footer className="py-12 border-t border-white/[0.06] text-center text-xs text-white/30 bg-black">
        <div className="max-w-5xl mx-auto px-6 flex flex-col sm:flex-row items-center justify-between gap-4">
          <p>© 2026 WinDeck. Turn your phone into a Windows Stream Deck.</p>
          <div className="flex gap-6">
            <a href="#download" className="hover:text-white">Download</a>
            <a href="#features" className="hover:text-white">Features</a>
            <a href="#how-it-works" className="hover:text-white">How it works</a>
          </div>
        </div>
      </footer>

    </div>
  );
}
