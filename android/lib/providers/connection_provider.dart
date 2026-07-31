import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../services/socket_service.dart';
import '../services/discovery_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Phases of the connection lifecycle, used by the UI overlay.
enum ConnectionPhase {
  idle,              // Not connected, no active recovery
  connected,         // Authenticated and working
  retrying,          // Socket.io auto-reconnecting to same IP (0–15s)
  rediscovering,     // Stale IP detected, running UDP/mDNS discovery for new IP
  pairingRequired,   // Silent re-auth failed, user must re-enter OTP
}

class ConnectionProvider extends ChangeNotifier {
  bool _isConnected = false;
  int _cpuUsage = 0;
  int _ramUsage = 0;
  Map<String, dynamic> _mediaData = {};
  String _activeWindow = '';
  String _activeWindowTitle = '';

  // Fix 1: Cached auth credentials (single source of truth — not in SocketService)
  String? _lastOtp;
  String? _lastDeviceName;
  bool _hasConnectedBefore = false;

  bool _hapticsEnabled = true;
  bool _soundsEnabled = true;
  bool _clipboardSyncEnabled = true;
  bool _autoSwitchEnabled = true;
  String _deviceName = 'Android Device';
  String _lastSetFromPhone = '';
  String _lastPolledClipboard = '';

  // Fix 2: Connection phase tracking
  ConnectionPhase _connectionPhase = ConnectionPhase.idle;

  // Gap 5: Guard flag to prevent _onSocketDisconnect from overwriting explicit disconnect
  bool _isExplicitDisconnect = false;

  // Fix 2: Timer for stale-IP detection
  Timer? _reconnectTimer;
  static const _staleIpThreshold = Duration(seconds: 15);

  // Fix 2: Discovery service for fallback
  final DiscoveryService _discoveryService = DiscoveryService();

  bool get isConnected => _isConnected;
  int get cpuUsage => _cpuUsage;
  int get ramUsage => _ramUsage;
  Map<String, dynamic> get mediaData => _mediaData;
  String get activeWindow => _activeWindow;
  String get activeWindowTitle => _activeWindowTitle;
  String get serverIp => _socketService.serverIp ?? 'localhost';
  String get otp => _lastOtp ?? '';
  ConnectionPhase get connectionPhase => _connectionPhase;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get soundsEnabled => _soundsEnabled;
  bool get clipboardSyncEnabled => _clipboardSyncEnabled;
  bool get autoSwitchEnabled => _autoSwitchEnabled;
  String get deviceName => _deviceName;

  final GlobalKey<NavigatorState>? _navigatorKey;

  ConnectionProvider([this._navigatorKey]) {
    _loadSettings();
    _startClipboardPoller();
  }

  void _startClipboardPoller() {
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!_isConnected || !_clipboardSyncEnabled) return;
      try {
        final data = await Clipboard.getData(Clipboard.kTextPlain);
        final text = data?.text;
        if (text != null && text.isNotEmpty && text != _lastPolledClipboard && text != _lastSetFromPhone) {
          _lastPolledClipboard = text;
          _socketService.emit('send-clipboard', text);
        }
      } catch (e) {
        // Ignore clipboard read errors
      }
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _hapticsEnabled = prefs.getBool('windeck_haptics') ?? true;
    _soundsEnabled = prefs.getBool('windeck_sounds') ?? true;
    _clipboardSyncEnabled = prefs.getBool('windeck_clipboard_sync') ?? true;
    _autoSwitchEnabled = prefs.getBool('windeck_auto_switch') ?? true;
    _deviceName = prefs.getString('windeck_device_name') ?? 'Android Device';
    notifyListeners();
  }

  Future<void> setHaptics(bool value) async {
    _hapticsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('windeck_haptics', value);
    notifyListeners();
  }

  Future<void> setSounds(bool value) async {
    _soundsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('windeck_sounds', value);
    notifyListeners();
  }

  Future<void> setClipboardSync(bool value) async {
    _clipboardSyncEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('windeck_clipboard_sync', value);
    notifyListeners();
  }

  Future<void> setAutoSwitch(bool value) async {
    _autoSwitchEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('windeck_auto_switch', value);
    notifyListeners();
  }

  Future<void> setDeviceName(String value) async {
    _deviceName = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('windeck_device_name', value);
    notifyListeners();
  }

  final SocketService _socketService = SocketService();

  Future<bool> connect(String ip, int port) async {
    // Cancel any ongoing discovery fallback
    _discoveryService.stopDiscovery();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    return await _socketService.connect(
      ip,
      port,
      _onSocketConnect,
      _onSocketDisconnect,
      _onStatus,
      _onMediaUpdate,
      _onWindowUpdate,
      _onClipboardUpdate,
      _onFileOffer,
      onReconnectAttempt: _onReconnectAttempt,
      onReconnectError: _onReconnectError,
      onReconnectFailed: _onReconnectFailed,
    );
  }

  Future<void> authenticate(String otp, String deviceName, Function(bool success, String? error) onResult) async {
    _socketService.authenticate(otp, deviceName, (success, error) {
      if (success) {
        _isConnected = true;
        _lastOtp = otp;
        _lastDeviceName = deviceName;
        _hasConnectedBefore = true;
        _connectionPhase = ConnectionPhase.connected;

        // Gap 2: Reset reconnect counter on successful auth
        _socketService.resetReconnectAttemptCount();
        _reconnectTimer?.cancel();
        _reconnectTimer = null;

        notifyListeners();
      }
      onResult(success, error);
    });
  }

  /// Transport-level disconnect handler. Does NOT clear cached credentials.
  /// Called by socket.io on network blips.
  void disconnect() {
    _socketService.disconnect();
    _isConnected = false;
    notifyListeners();
  }

  /// User-initiated explicit disconnect (from "Disconnect?" dialog).
  /// Clears all cached credentials and resets to idle state.
  void disconnectExplicitly() {
    _isExplicitDisconnect = true;
    _lastOtp = null;
    _lastDeviceName = null;
    _hasConnectedBefore = false;
    _connectionPhase = ConnectionPhase.idle;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _discoveryService.stopDiscovery();
    _socketService.disconnect();
    _isConnected = false;
    notifyListeners();
  }

  // --- Socket event callbacks ---

  /// Fix 1: Single source of truth for re-authentication.
  /// On first connect: does nothing (screen calls authenticate() after user enters OTP).
  /// On reconnect: automatically re-authenticates with cached credentials.
  void _onSocketConnect() {
    consoleLog('Socket connected...');

    // Gap 2: Reset reconnect counter since we have a transport connection
    _socketService.resetReconnectAttemptCount();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    if (_hasConnectedBefore && _lastOtp != null && _lastDeviceName != null) {
      consoleLog('Attempting silent re-authentication...');
      authenticate(_lastOtp!, _lastDeviceName!, (success, error) {
        if (!success) {
          // Gap 3: Silent re-auth failed (e.g. server restarted with new OTP)
          consoleLog('Silent re-auth failed: $error');
          _connectionPhase = ConnectionPhase.pairingRequired;
          notifyListeners();
        }
      });
    }
  }

  /// Gap 5: Respects _isExplicitDisconnect guard to prevent phase overwrite.
  void _onSocketDisconnect() {
    _isConnected = false;
    if (!_isExplicitDisconnect) {
      _connectionPhase = ConnectionPhase.retrying;
      // Fix 2: Start the stale-IP timer on disconnect
      _startStaleIpTimer();
    }
    _isExplicitDisconnect = false; // reset for next time
    notifyListeners();
  }

  void _onStatus(Map<String, dynamic> data) {
    _cpuUsage = data['cpuUsage'] ?? 0;
    _ramUsage = data['ramUsage'] ?? 0;
    notifyListeners();
  }

  void _onMediaUpdate(Map<String, dynamic> data) {
    _mediaData = data;
    notifyListeners();
  }

  void _onWindowUpdate(Map<String, dynamic> data) {
    _activeWindow = data['exe'] ?? '';
    _activeWindowTitle = data['title'] ?? '';
    notifyListeners();
  }

  void _onClipboardUpdate(String text) {
    if (!_clipboardSyncEnabled) return;
    if (text == _lastSetFromPhone) return;
    Clipboard.setData(ClipboardData(text: text));
  }

  void _onFileOffer(String url) async {
    try {
      final uri = Uri.parse(url);
      final filename = uri.queryParameters['path']?.split(RegExp(r'[/\\]'))?.last ?? 'Unknown File';

      if (_navigatorKey != null && _navigatorKey.currentContext != null) {
        showDialog(
          context: _navigatorKey.currentContext!,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E2C),
            title: const Text('Incoming File', style: TextStyle(color: Colors.white)),
            content: Text('PC wants to send:\n$filename\n\nDo you want to accept this file?', style: const TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('File transfer declined'), behavior: SnackBarBehavior.floating),
                  );
                },
                child: const Text('Decline', style: TextStyle(color: Colors.redAccent)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                onPressed: () async {
                  Navigator.pop(ctx);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    consoleLog('Cannot launch file download URL: $url');
                  }
                },
                child: const Text('Accept', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      } else {
        // Fallback if no context
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      consoleLog('Error launching file download: $e');
    }
  }

  void syncPhoneClipboardToPc(String text) {
    if (!_clipboardSyncEnabled) return;
    _lastSetFromPhone = text;
    _socketService.emit('send-clipboard', text);
  }

  // --- Fix 2: Stale-IP detection & discovery fallback ---

  void _onReconnectAttempt(int attemptNumber) {
    consoleLog('Reconnect attempt #$attemptNumber');
  }

  void _onReconnectError(dynamic error) {
    consoleLog('Reconnect error: $error');
  }

  void _onReconnectFailed() {
    consoleLog('Socket.io reconnection exhausted — falling back to discovery');
    _triggerDiscoveryFallback();
  }

  /// Starts a timer that triggers discovery fallback after [_staleIpThreshold].
  void _startStaleIpTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_staleIpThreshold, () {
      consoleLog('Reconnect timeout exceeded $_staleIpThreshold — falling back to discovery');
      _triggerDiscoveryFallback();
    });
  }

  /// Stop retrying the stale IP, switch to discovery mode.
  void _triggerDiscoveryFallback() {
    // Stop socket.io's reconnection loop to the old IP
    _socketService.stopReconnecting();

    _connectionPhase = ConnectionPhase.rediscovering;
    notifyListeners();

    // Start discovery — on server found, connect() will fire _onSocketConnect()
    // which handles re-auth automatically (Gap 4: no explicit authenticate() call here).
    _discoveryService.startDiscovery((ip, port, name) {
      consoleLog('Discovery found server at $ip:$port ($name) — reconnecting...');
      _discoveryService.stopDiscovery();
      connect(ip, port);
      // _onSocketConnect() will handle silent re-auth since _hasConnectedBefore is true
    });
  }

  // --- Actions ---

  void executeAction(String type, String payload) {
    if (!_isConnected) return;
    if (type == 'app') {
      _socketService.emit('launch-app', payload);
    } else if (type == 'system') {
      _socketService.emit('system-action', payload);
    } else if (type == 'macro') {
      _socketService.emit('custom-macro', payload);
    } else if (type == 'url') {
      _socketService.emit('open-url', payload);
    }
  }

  void requestLayout() {
    _socketService.emit('get-layout', null);
  }

  /// Emit a raw socket event — used by AirMouse, Webcam, Presentation control.
  void emitRaw(String event, dynamic data) {
    _socketService.emit(event, data);
  }

  void setLayoutCallback(Function(List) callback) {
    _socketService.onSyncLayout(callback);
  }

  void consoleLog(String msg) {
    if (kDebugMode) {
      print('[ConnectionProvider] $msg');
    }
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _discoveryService.stopDiscovery();
    super.dispose();
  }
}
