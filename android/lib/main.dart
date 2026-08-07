import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'providers/connection_provider.dart';
import 'providers/pages_provider.dart';
import 'screens/discovery_screen.dart';
import 'screens/home_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'globals.dart';
import 'services/update_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectionProvider(navigatorKey)),
        ChangeNotifierProvider(create: (_) => PagesProvider()),
      ],
      child: const WinDeckApp(),
    ),
  );
}

class WinDeckApp extends StatefulWidget {
  const WinDeckApp({super.key});

  @override
  State<WinDeckApp> createState() => _WinDeckAppState();
}

class _WinDeckAppState extends State<WinDeckApp> {
  bool _permissionsGranted = false;

  bool _showIntro = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final prefs = await SharedPreferences.getInstance();
    final introDone = prefs.getBool('windeck_intro_done') ?? false;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      Globals.appVersion = packageInfo.version;
    } catch (e) {
      // fallback
    }

    setState(() {
      _permissionsGranted = true;
      _showIntro = !introDone;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _requestNotificationPermission();
      _checkForUpdate();
    });
  }

  Future<void> _checkForUpdate() async {
    final service = UpdateService();
    final update = await service.checkForUpdate();
    if (update != null && mounted) {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        _showUpdateDialog(ctx, update);
      }
    }
  }

  void _showUpdateDialog(BuildContext context, Map<String, dynamic> update) {
    bool isDownloading = false;
    double progress = 0.0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF161622),
          title: Text('Update Available: v${update['version']}', style: const TextStyle(color: Colors.white)),
          content: isDownloading
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Downloading update...', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(value: progress, backgroundColor: Colors.white12, color: const Color(0xFF0078d4)),
                  ],
                )
              : Text('A new version is available. Would you like to update now?\n\nChangelog:\n${update['changelog']}', style: const TextStyle(color: Colors.white70)),
          actions: [
            if (!isDownloading) TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Later', style: TextStyle(color: Colors.white54))),
            if (!isDownloading) ElevatedButton(
              onPressed: () async {
                setDialogState(() => isDownloading = true);
                try {
                  await UpdateService().downloadAndInstallUpdate(update['downloadUrl'], (p) {
                    setDialogState(() => progress = p);
                  });
                } catch (e) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update failed.')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0078d4)),
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isGranted || status.isPermanentlyDenied) return;

    final ctx = navigatorKey.currentContext;
    if (ctx == null || !mounted) return;

    await showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (dialogCtx) => Dialog(
        backgroundColor: const Color(0xFF161622),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF0078d4).withValues(alpha: 0.2), const Color(0xFF0078d4).withValues(alpha: 0.05)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0078d4).withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.notifications_active_rounded, color: Color(0xFF0078d4), size: 34),
              ),
              const SizedBox(height: 20),
              const Text('Stay Connected', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 10),
              Text(
                'WinDeck uses notifications to alert you when your phone pairs, disconnects, or receives a file.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 13.5, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(dialogCtx);
                    await Permission.notification.request();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0078d4),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Enable Notifications', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text('Maybe Later', style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'WinDeck',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E2C),
        primarySwatch: Colors.cyan,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => !_permissionsGranted
            ? const Scaffold(
                backgroundColor: Color(0xFF1E1E2C),
                body: Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
              )
            : (_showIntro ? IntroScreen() : const DiscoveryScreen()),
        '/intro': (context) => IntroScreen(),
        '/discovery': (context) => const DiscoveryScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
