import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nsd/nsd.dart' as nsd;

/// Reusable service for discovering WinDeck servers via UDP broadcast and mDNS.
/// Used by both DiscoveryScreen (initial pairing) and ConnectionProvider (stale-IP fallback).
class DiscoveryService {
  RawDatagramSocket? _udpSocket;
  nsd.Discovery? _mdnsDiscovery;
  final Set<String> _seenIps = {};
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  /// Start listening for WinDeck server broadcasts.
  /// [onServerFound] is called for each newly discovered server with (ip, port, name).
  Future<void> startDiscovery(Function(String ip, int port, String name) onServerFound) async {
    if (_isRunning) return;
    _isRunning = true;
    _seenIps.clear();

    // UDP Broadcast Discovery
    try {
      _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 3001);
      _udpSocket?.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = _udpSocket?.receive();
          if (datagram != null) {
            try {
              final String message = utf8.decode(datagram.data);
              final Map<String, dynamic> data = jsonDecode(message);

              if (data['type'] == 'windeck-server') {
                final ip = datagram.address.address;
                if (!_seenIps.contains(ip)) {
                  _seenIps.add(ip);
                  final port = data['port'] ?? 3000;
                  final name = data['name'] ?? 'Windows PC';
                  onServerFound(ip, port is int ? port : int.tryParse(port.toString()) ?? 3000, name);
                }
              }
            } catch (e) {
              // Malformed packet, ignore
            }
          }
        }
      });
    } catch (e) {
      if (kDebugMode) print('[DiscoveryService] UDP bind failed: $e');
    }

    // mDNS Discovery
    try {
      _mdnsDiscovery = await nsd.startDiscovery('_windeck._tcp');
      _mdnsDiscovery!.addListener(() {
        for (final service in _mdnsDiscovery!.services) {
          if (service.host != null) {
            final ip = service.host!;
            if (!_seenIps.contains(ip)) {
              _seenIps.add(ip);
              final name = service.name ?? 'Windows PC';
              final port = service.port ?? 3000;
              onServerFound(ip, port, name);
            }
          }
        }
      });
    } catch (e) {
      if (kDebugMode) print('[DiscoveryService] mDNS failed: $e');
    }
  }

  /// Stop all discovery listeners and release resources.
  void stopDiscovery() {
    _isRunning = false;
    _udpSocket?.close();
    _udpSocket = null;
    if (_mdnsDiscovery != null) {
      try {
        nsd.stopDiscovery(_mdnsDiscovery!);
      } catch (_) {}
      _mdnsDiscovery = null;
    }
    _seenIps.clear();
  }
}
