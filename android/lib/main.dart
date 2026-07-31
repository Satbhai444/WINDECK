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
    // Request network, notification, or other professional permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.notification,
    ].request();

    final prefs = await SharedPreferences.getInstance();
    final introDone = prefs.getBool('windeck_intro_done') ?? false;

    setState(() {
      _permissionsGranted = true;
      _showIntro = !introDone;
    });
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
