import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

class SocketService {
  IO.Socket? _socket;
  String? serverIp;
  int? serverPort;

  int _reconnectAttemptCount = 0;
  int get reconnectAttemptCount => _reconnectAttemptCount;
  void resetReconnectAttemptCount() { _reconnectAttemptCount = 0; }
  enc.Key? _encryptionKey;

  void _setEncryptionKey(String otp) {
    final bytes = utf8.encode(otp + 'windeck_salt');
    final hash = sha256.convert(bytes).bytes;
    _encryptionKey = enc.Key(Uint8List.fromList(hash));
  }

  String _encryptData(dynamic data) {
    if (_encryptionKey == null) return jsonEncode(data);
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(_encryptionKey!, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(jsonEncode(data), iv: iv);
    return '${iv.base16}:${encrypted.base16}'.toLowerCase();
  }

  dynamic _decryptData(dynamic payload) {
    if (_encryptionKey == null || payload is! String || !payload.contains(':')) return payload;
    try {
      final parts = payload.split(':');
      final iv = enc.IV.fromBase16(parts[0]);
      final encrypter = enc.Encrypter(enc.AES(_encryptionKey!, mode: enc.AESMode.cbc));
      final decrypted = encrypter.decrypt16(parts[1], iv: iv);
      return jsonDecode(decrypted);
    } catch (e) {
      print('Decryption error: $e');
      return payload;
    }
  }

  Future<bool> connect(
    String ip,
    int port,
    Function onConnect,
    Function onDisconnect,
    Function(Map<String, dynamic>) onStatus,
    Function(Map<String, dynamic>) onMediaUpdate,
    Function(Map<String, dynamic>) onWindowUpdate,
    Function(String) onClipboardUpdate,
    Function(String) onFileOffer, {
    Function(int attemptNumber)? onReconnectAttempt,
    Function(dynamic error)? onReconnectError,
    Function()? onReconnectFailed,
  }) async {
    serverIp = ip;
    serverPort = port;
    _reconnectAttemptCount = 0;

    _socket?.dispose();

    _socket = IO.io('http://$ip:$port', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionAttempts': 99999,
      'reconnectionDelay': 1000,
      'timeout': 3000,
    });

    _socket?.onConnect((_) => onConnect());
    _socket?.onDisconnect((_) => onDisconnect());
    _socket?.on('status', (data) => onStatus(Map<String, dynamic>.from(_decryptData(data))));
    _socket?.on('media-update', (data) => onMediaUpdate(Map<String, dynamic>.from(_decryptData(data))));
    _socket?.on('foreground-app-changed', (data) => onWindowUpdate(Map<String, dynamic>.from(_decryptData(data))));
    _socket?.on('clipboard-update', (data) => onClipboardUpdate(_decryptData(data).toString()));
    _socket?.on('file-offer', (data) => onFileOffer(_decryptData(data).toString()));

    // Reconnection event listeners for Fix 2 (stale-IP fallback)
    _socket?.on('reconnect_attempt', (attemptNumber) {
      _reconnectAttemptCount = attemptNumber is int ? attemptNumber : _reconnectAttemptCount + 1;
      onReconnectAttempt?.call(_reconnectAttemptCount);
    });

    _socket?.on('reconnect_error', (error) {
      onReconnectError?.call(error);
    });

    _socket?.on('reconnect_failed', (_) {
      onReconnectFailed?.call();
    });

    final completer = Completer<bool>();

    _socket?.onConnect((_) {
      if (!completer.isCompleted) completer.complete(true);
    });

    _socket?.onConnectError((err) {
      print('Connect error: $err');
      if (!completer.isCompleted) completer.complete(false);
    });

    _socket?.connect();

    try {
      return await completer.future.timeout(const Duration(seconds: 4));
    } catch (e) {
      return false;
    }
  }

  void authenticate(String otp, String deviceName, Function(bool success, String? error) onResult) {
    if (_socket == null || !_socket!.connected) {
      onResult(false, "Could not connect to PC. Please check Room ID and ensure both are on the same Wi-Fi.");
      return;
    }

    // Clear any previous once listeners to prevent multiple callbacks
    _socket?.off('authenticated');

    bool responded = false;
    _socket?.once('authenticated', (data) {
      responded = true;
      final mapData = Map<String, dynamic>.from(data);
      final success = mapData['success'] as bool;
      final error = mapData['error'] as String?;
      onResult(success, error);
    });

    _setEncryptionKey(otp);
    _socket?.emit('authenticate', {'otp': otp, 'deviceName': deviceName, 'version': '2.2.0'});

    // Timeout for authentication
    Future.delayed(const Duration(seconds: 3), () {
      if (!responded) {
        _socket?.off('authenticated');
        onResult(false, "Authentication timed out.");
      }
    });
  }

  void emit(String event, dynamic data) {
    if (event == 'authenticate') {
      _socket?.emit(event, data);
    } else {
      _socket?.emit(event, _encryptData(data));
    }
  }

  void onSyncLayout(Function(List) callback) {
    _socket?.on('sync-layout', (data) => callback(_decryptData(data) as List));
  }

  /// Stop Socket.io's internal reconnection loop (for stale-IP fallback).
  void stopReconnecting() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  /// Full disconnect — tears down the socket entirely.
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
