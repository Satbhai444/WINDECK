import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/connection_provider.dart';

class CameraStreamScreen extends StatefulWidget {
  const CameraStreamScreen({super.key});

  @override
  State<CameraStreamScreen> createState() => _CameraStreamScreenState();
}

class _CameraStreamScreenState extends State<CameraStreamScreen> {
  CameraController? _controller;
  bool _isStreaming = false;
  bool _isInitializing = true;
  int _lastFrameTime = 0;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 1; // Default to front camera usually

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        // Try to find front camera, otherwise use the first one
        _currentCameraIndex = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
        if (_currentCameraIndex == -1) _currentCameraIndex = 0;
        await _setupController(_cameras[_currentCameraIndex]);
      }
    } catch (e) {
      debugPrint('Camera error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _setupController(CameraDescription camera) async {
    final oldController = _controller;
    _controller = CameraController(
      camera,
      ResolutionPreset.low, // Use low for lower latency over WiFi
      imageFormatGroup: ImageFormatGroup.jpeg, // Crucial for fast streaming without CPU encode
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {});
        _startStreaming();
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
    
    if (oldController != null) {
      await oldController.dispose();
    }
  }

  void _startStreaming() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isStreaming) return;

    _isStreaming = true;
    _controller!.startImageStream((CameraImage image) {
      // Throttle to roughly 15-20 fps to avoid choking the websocket/wifi
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastFrameTime < 50) return; // ~20fps max
      _lastFrameTime = now;

      try {
        if (image.format.group == ImageFormatGroup.jpeg) {
          final conn = context.read<ConnectionProvider>();
          final base64Frame = base64Encode(image.planes[0].bytes);
          conn.emitRaw('camera-frame', base64Frame);
        }
      } catch (e) {
        // Error encoding or sending
      }
    });
  }

  Future<void> _stopStreaming() async {
    if (_isStreaming && _controller != null) {
      _isStreaming = false;
      try {
        await _controller!.stopImageStream();
      } catch (e) {
        debugPrint('Error stopping stream: $e');
      }
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) return;
    await _stopStreaming();
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    setState(() { _isInitializing = true; });
    await _setupController(_cameras[_currentCameraIndex]);
    setState(() { _isInitializing = false; });
  }

  @override
  void dispose() {
    _stopStreaming();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Webcam Bridge', style: TextStyle(color: Colors.white, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_cameras.length > 1)
            IconButton(
              icon: const Icon(LucideIcons.switchCamera, color: Colors.white),
              onPressed: _toggleCamera,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _isInitializing
                    ? const CircularProgressIndicator(color: Color(0xFF0078d4))
                    : (_controller != null && _controller!.value.isInitialized)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: CameraPreview(_controller!),
                          )
                        : const Text('Camera not available', style: TextStyle(color: Colors.white54)),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              child: const Text(
                'Streaming to PC\nAdd Browser Source to OBS:\nhttp://<PC-IP>:3000/camera-view',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
