import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import '../globals.dart';
import 'package:flutter/foundation.dart';

class SocketService {
  WebSocketChannel? _channel;
  String? serverIp;
  int? serverPort;
  Function(List)? _onSyncLayoutCallback;
  
  Function? _onConnect;
  Function? _onDisconnect;
  Function(Map<String, dynamic>)? _onStatus;
  Function(Map<String, dynamic>)? _onMediaUpdate;
  Function(Map<String, dynamic>)? _onWindowUpdate;
  Function(String)? _onClipboardUpdate;
  Function(String)? _onFileOffer;
  Function(int)? _onReconnectAttempt;
  Function(dynamic)? _onReconnectError;
  Function()? _onReconnectFailed;

  int _reconnectAttemptCount = 0;
  int get reconnectAttemptCount => _reconnectAttemptCount;
  void resetReconnectAttemptCount() { _reconnectAttemptCount = 0; }
  enc.Key? _encryptionKey;

  Timer? _reconnectTimer;
  bool _intentionalDisconnect = false;

  void _setEncryptionKey(String otp) {
    final bytes = utf8.encode('${otp}windeck_salt');
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
      debugPrint('Decryption error: $e');
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
    Function(int)? onReconnectAttempt,
    Function(dynamic)? onReconnectError,
    Function()? onReconnectFailed,
  }) async {
    serverIp = ip;
    serverPort = port;
    _intentionalDisconnect = false;

    _onConnect = onConnect;
    _onDisconnect = onDisconnect;
    _onStatus = onStatus;
    _onMediaUpdate = onMediaUpdate;
    _onWindowUpdate = onWindowUpdate;
    _onClipboardUpdate = onClipboardUpdate;
    _onFileOffer = onFileOffer;
    _onReconnectAttempt = onReconnectAttempt;
    _onReconnectError = onReconnectError;
    _onReconnectFailed = onReconnectFailed;

    return await _connectInternal();
  }

  Future<bool> _connectInternal() async {
    if (serverIp == null || serverPort == null) return false;
    final completer = Completer<bool>();
    
    try {
      final wsUrl = Uri.parse('ws://$serverIp:$serverPort/ws');
      _channel = WebSocketChannel.connect(wsUrl);
      
      _channel!.stream.listen(
        (message) {
          if (!completer.isCompleted) {
             completer.complete(true);
             _onConnect?.call();
             _reconnectAttemptCount = 0;
          }
          _handleIncomingMessage(message.toString());
        },
        onError: (error) {
          debugPrint('WS Error: $error');
          if (!completer.isCompleted) {
            completer.complete(false);
          } else {
             _onReconnectError?.call(error);
             _scheduleReconnect();
          }
        },
        onDone: () {
          debugPrint('WS Closed');
          _onDisconnect?.call();
          if (!_intentionalDisconnect) {
            _scheduleReconnect();
          }
        },
      );
      
      Future.delayed(const Duration(seconds: 4), () {
        if (!completer.isCompleted) {
          completer.complete(false);
          _channel?.sink.close();
        }
      });
      
      return await completer.future;
    } catch (e) {
       debugPrint('WS Connect Exception: $e');
       if (!completer.isCompleted) completer.complete(false);
       return false;
    }
  }

  void _scheduleReconnect() {
    if (_intentionalDisconnect) return;
    if (_reconnectTimer?.isActive ?? false) return;
    
    _reconnectAttemptCount++;
    if (_reconnectAttemptCount > 99999) {
      _onReconnectFailed?.call();
      return;
    }
    
    _onReconnectAttempt?.call(_reconnectAttemptCount);
    _reconnectTimer = Timer(const Duration(seconds: 2), () {
      _connectInternal();
    });
  }

  Completer<Map<String, dynamic>>? _authCompleter;

  void _handleIncomingMessage(String rawMessage) {
    try {
      final map = jsonDecode(rawMessage);
      final event = map['event'];
      final rawData = map['data'];
      
      if (event == 'authenticated') {
         if (_authCompleter != null && !_authCompleter!.isCompleted) {
             _authCompleter!.complete(Map<String, dynamic>.from(rawData));
         }
      } else if (event == 'status') {
         _onStatus?.call(Map<String, dynamic>.from(_decryptData(rawData)));
      } else if (event == 'media-update') {
         _onMediaUpdate?.call(Map<String, dynamic>.from(_decryptData(rawData)));
      } else if (event == 'foreground-app-changed') {
         _onWindowUpdate?.call(Map<String, dynamic>.from(_decryptData(rawData)));
      } else if (event == 'clipboard-update') {
         _onClipboardUpdate?.call(_decryptData(rawData).toString());
      } else if (event == 'file-offer') {
         _onFileOffer?.call(_decryptData(rawData).toString());
      } else if (event == 'sync-layout') {
         _onSyncLayoutCallback?.call(_decryptData(rawData) as List);
      }
    } catch (e) {
       debugPrint('Error handling WS message: $e');
    }
  }

  void authenticate(String otp, String deviceName, Function(bool success, String? error) onResult) {
    if (_channel == null) {
      onResult(false, "Could not connect to PC.");
      return;
    }

    _setEncryptionKey(otp);
    
    _authCompleter = Completer<Map<String, dynamic>>();
    _authCompleter!.future.then((data) {
       final success = data['success'] as bool;
       final error = data['error'] as String?;
       onResult(success, error);
    });

    _sendRaw('authenticate', {'otp': otp, 'deviceName': deviceName, 'version': Globals.appVersion});

    Future.delayed(const Duration(seconds: 3), () {
      if (_authCompleter != null && !_authCompleter!.isCompleted) {
        _authCompleter!.complete({'success': false, 'error': "Authentication timed out."});
      }
    });
  }
  
  void _sendRaw(String event, dynamic data) {
    if (_channel != null) {
       final payload = jsonEncode({
         'event': event,
         'data': data
       });
       _channel!.sink.add(payload);
    }
  }

  void emit(String event, dynamic data) {
    if (event == 'authenticate') {
      _sendRaw(event, data);
    } else {
      _sendRaw(event, _encryptData(data));
    }
  }

  void onSyncLayout(Function(List) callback) {
    _onSyncLayoutCallback = callback;
  }

  void stopReconnecting() {
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  void disconnect() {
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
  }
}
