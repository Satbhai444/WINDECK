import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/connection_provider.dart';
import '../providers/pages_provider.dart';
import '../widgets/tile_grid.dart';
import '../widgets/tile_widget.dart'; // For IconMapper

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  bool _isFullscreen = false;
  Timer? _fadeTimer;
  bool _isFabVisible = true;

  void _resetFadeTimer() {
    if (!_isFullscreen) return;
    setState(() {
      _isFabVisible = true;
    });
    _fadeTimer?.cancel();
    _fadeTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isFabVisible = false;
        });
      }
    });
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      if (_isFullscreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        _resetFadeTimer();
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        _fadeTimer?.cancel();
        _isFabVisible = true;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final conn = context.read<ConnectionProvider>();
    final pages = context.read<PagesProvider>();

    _pageController = PageController(initialPage: pages.currentPageIndex);

    conn.setLayoutCallback((pagesData) {
      pages.syncFromServer(pagesData);
    });

    // Request layout immediately if already connected
    if (conn.isConnected) {
      conn.requestLayout();
    }

    conn.addListener(() {
      if (conn.autoSwitchEnabled) {
        pages.handleAutoSwitch(conn.activeWindow, conn.activeWindowTitle);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowWhatsNew();
    });
  }

  Future<void> _checkAndShowWhatsNew() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('shown_v1_1_whatsnew') ?? false;
    if (!hasShown && mounted) {
      _showWhatsNewDialog();
      await prefs.setBool('shown_v1_1_whatsnew', true);
    }
  }

  void _showWhatsNewDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161622),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.new_releases_rounded, color: Color(0xFF0078d4)),
            SizedBox(width: 8),
            Text("What's New in v1.1", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFeatureRow('dropzone', 'DropZone Transfer', 'Tap to instantly send photos & files wirelessly to your PC.'),
              const SizedBox(height: 12),
              _buildFeatureRow('airmouse', 'AirMouse & Pointer', 'Turn your phone into a smooth touchpad & presentation clicker.'),
              const SizedBox(height: 12),
              _buildFeatureRow('webcam', 'Webcam Bridge', 'Use your phone as a high-quality HD webcam for your PC (via OBS).'),
              const SizedBox(height: 12),
              _buildFeatureRow('timer', 'Pomodoro Timers', 'Live countdowns on tiles with heavy vibration alerts when finished.'),
              const SizedBox(height: 20),
              const Text("⚠️ To use these, add them from the PC app sidebar to your layout!", 
                style: TextStyle(color: Colors.cyanAccent, fontSize: 13, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Awesome!', style: TextStyle(color: Color(0xFF0078d4), fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String iconType, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(IconMapper.get(iconType, ''), size: 24, color: Colors.white70),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161622),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Disconnect?', style: TextStyle(color: Colors.white)),
        content: const Text('Do you want to disconnect from your PC and exit?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('No', style: TextStyle(color: Colors.cyan))),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Yes', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    ) ?? false;
  }



  @override
  Widget build(BuildContext context) {
    final conn = context.watch<ConnectionProvider>();
    final pages = context.watch<PagesProvider>();

    // Gap 3: Auto-navigate to discovery screen when silent re-auth fails
    if (conn.connectionPhase == ConnectionPhase.pairingRequired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          conn.disconnectExplicitly();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please pair again.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          Navigator.pushReplacementNamed(context, '/');
        }
      });
    }

    // Listen to external page changes (e.g. from AutoSwitch) and sync PageController
    if (_pageController.hasClients && _pageController.page?.round() != pages.currentPageIndex) {
      _pageController.animateToPage(
        pages.currentPageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A12),
        appBar: _isFullscreen ? null : AppBar(
          backgroundColor: const Color(0xFF0A0A12),
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          title: Row(
            children: [
              // WinDeck Logo
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0078d4), Color(0xFF2196F3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('W', style: TextStyle(
                    color: Colors.white, 
                    fontSize: 14, 
                    fontWeight: FontWeight.w900,
                  )),
                ),
              ),
              const SizedBox(width: 10),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(text: 'win', style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white,
                    )),
                    TextSpan(text: 'deck', style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0078d4),
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Connection indicator dot
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: conn.isConnected ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (conn.isConnected ? Colors.green : Colors.red).withValues(alpha: 0.5),
                      blurRadius: 6, spreadRadius: 1,
                    )
                  ],
                ),
              ),
            ],
          ),
          actions: [
            // Hamburger Menu (3-dot)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white54),
              color: const Color(0xFF1A1A2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onSelected: (value) async {
                switch (value) {
                  case 'sync':
                    conn.requestLayout();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Syncing layout...')),
                    );
                    break;
                  case 'settings':
                    Navigator.pushNamed(context, '/settings');
                    break;
                  case 'fullscreen':
                    _toggleFullscreen();
                    break;
                  case 'disconnect':
                    final confirm = await _onWillPop();
                    if (confirm) {
                      conn.disconnectExplicitly();
                      if (mounted) {
                        Navigator.pushReplacementNamed(context, '/');
                      }
                    }
                    break;
                }
              },
              itemBuilder: (context) => [
                _buildMenuItem(Icons.sync_rounded, 'Sync Layout', 'sync', const Color(0xFF0078d4)),
                _buildMenuItem(Icons.fullscreen_rounded, 'Fullscreen', 'fullscreen', const Color(0xFFa855f7)),
                _buildMenuItem(Icons.settings_rounded, 'Settings', 'settings', Colors.white54),
                const PopupMenuDivider(),
                _buildMenuItem(Icons.power_settings_new_rounded, 'Disconnect', 'disconnect', Colors.redAccent),
              ],
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
            const SizedBox(height: 4),


            // Page Tabs (pill-shaped)
            if (!_isFullscreen)
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: pages.pages.length,
                itemBuilder: (context, index) {
                  final isSelected = index == pages.currentPageIndex;
                  return GestureDetector(
                    onTap: () {
                      pages.setPageIndex(index);
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0078d4).withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF0078d4).withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.06),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        pages.pages[index].name,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF0078d4) : Colors.white38,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 4),

            // Main swipeable view containing pages
            Expanded(
              child: Listener(
                onPointerDown: (_) => _resetFadeTimer(),
                child: pages.pages.isEmpty
                    ? Center(
                      child: Text(
                        'No decks found.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
                      ),
                    )
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: pages.pages.length,
                      onPageChanged: (index) {
                        pages.setPageIndex(index);
                      },
                      itemBuilder: (context, index) {
                        return TileGrid(page: pages.pages[index]);
                      },
                    ),
              ),
            ),

            // Page Indicator Dots
            if (!_isFullscreen && pages.pages.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.pages.length,
                    (index) {
                      final isSelected = index == pages.currentPageIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isSelected ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF0078d4) : Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
        if (_isFullscreen)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: AnimatedOpacity(
              opacity: _isFabVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.black54,
                onPressed: _isFabVisible ? _toggleFullscreen : null,
                child: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ),
        if (conn.connectionPhase == ConnectionPhase.retrying || conn.connectionPhase == ConnectionPhase.rediscovering)
          Container(
            color: Colors.black.withValues(alpha: 0.8),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF0078d4)),
                  const SizedBox(height: 24),
                  Text(
                    conn.connectionPhase == ConnectionPhase.rediscovering
                        ? 'Searching for your PC...'
                        : 'Reconnecting...',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    conn.connectionPhase == ConnectionPhase.rediscovering
                        ? 'IP may have changed. Looking on the network...'
                        : 'Waiting for PC...',
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      conn.disconnectExplicitly();
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    child: const Text('Cancel & Return', style: TextStyle(color: Colors.redAccent)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),

      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(IconData icon, String label, String value, Color color) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: color == Colors.redAccent ? Colors.redAccent : Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }
}
