import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/tile_model.dart';
import '../providers/connection_provider.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:vibration/vibration.dart';
import '../screens/air_mouse_screen.dart';
import '../screens/camera_stream_screen.dart';

class IconMapper {
  static const Map<String, IconData> _map = {
    '🌐': LucideIcons.globe,
    '🔊': LucideIcons.volume2,
    '🔈': LucideIcons.volume1,
    '🔉': LucideIcons.volume1,
    '🔇': LucideIcons.volumeX,
    '📸': LucideIcons.camera,
    '🔒': LucideIcons.lock,
    '🌙': LucideIcons.moon,
    '🔄': LucideIcons.refreshCw,
    '⏻': LucideIcons.power,
    '⏺️': LucideIcons.video,
    '🖥️': LucideIcons.monitor,
    '➕': LucideIcons.plus,
    '⏯️': LucideIcons.play,
    '⏮️': LucideIcons.skipBack,
    '⏭️': LucideIcons.skipForward,
    '🔅': LucideIcons.sun,
    '🔆': LucideIcons.sunMedium,
    '🎤': LucideIcons.mic,
    '📷': LucideIcons.video,
    '✋': LucideIcons.hand,
    '💬': LucideIcons.messageSquare,
    '📝': LucideIcons.fileText,
    '📞': LucideIcons.phoneOff,
    '📱': LucideIcons.smartphone,
    '⏩': LucideIcons.fastForward,
    '⏪': LucideIcons.rewind,
    'lock': LucideIcons.lock,
    'sleep': LucideIcons.moon,
    'restart': LucideIcons.refreshCw,
    'shutdown': LucideIcons.power,
    'screen-record': LucideIcons.video,
    'screenshot': LucideIcons.camera,
    'show-desktop': LucideIcons.monitor,
    'mute': LucideIcons.volumeX,
    'volume-down': LucideIcons.volume1,
    'volume-up': LucideIcons.volume2,
    'volume': LucideIcons.volume2,
    'brightness': LucideIcons.sunMedium,
    'media-play-pause': LucideIcons.play,
    'media-prev': LucideIcons.skipBack,
    'media-next': LucideIcons.skipForward,
    'brightness-down': LucideIcons.sun,
    'brightness-up': LucideIcons.sunMedium,
    'globe': LucideIcons.globe,
    'volume-2': LucideIcons.volume2,
    'volume-x': LucideIcons.volumeX,
    'camera': LucideIcons.camera,
    'plus': LucideIcons.plus,
    'play': LucideIcons.play,
    'pause': LucideIcons.pause,
    'skip-forward': LucideIcons.skipForward,
    'skip-back': LucideIcons.skipBack,
    'mic': LucideIcons.mic,
    'video': LucideIcons.video,
    'hand': LucideIcons.hand,
    'chat': LucideIcons.messageSquare,
    'captions': LucideIcons.fileText,
    'phone-off': LucideIcons.phoneOff,
    'dropzone': LucideIcons.uploadCloud,
    'airmouse': LucideIcons.mousePointer2,
    'webcam': LucideIcons.video,
    'timer': LucideIcons.timer,
  };

  static bool isMapped(String value) => _map.containsKey(value);
  static IconData get(String value, [String payload = '']) {
    if (_map.containsKey(value)) return _map[value]!;
    if (_map.containsKey(payload)) return _map[payload]!;
    return LucideIcons.squareCode;
  }
}
class TileWidget extends StatefulWidget {
  final TileModel tile;
  const TileWidget({super.key, required this.tile});

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget> with SingleTickerProviderStateMixin {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;
  
  // For gesture-based volume/brightness
  double _dragAccumulator = 0;
  static const double _dragThreshold = 20.0; // pixels per tick

  bool _isUploading = false;
  
  // For Timer Tile
  Timer? _countdownTimer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut)
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  bool get _isGestureTile {
    return widget.tile.type == 'system' && 
           (widget.tile.payload == 'volume' || widget.tile.payload == 'brightness');
  }

  void _handleTap() async {
    final conn = context.read<ConnectionProvider>();
    if (conn.hapticsEnabled) HapticFeedback.mediumImpact();
    _tapController.forward().then((_) => _tapController.reverse());
    
    if (conn.soundsEnabled) {
      try {
        if (_audioPlayer.state == PlayerState.playing) await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource('sounds/tap.wav'));
      } catch (_) {}
    }

    if (widget.tile.type == 'empty') {
      return;
    }

    if (widget.tile.type == 'airmouse') {
      Navigator.push(context, MaterialPageRoute(builder: (c) => const AirMouseScreen()));
      return;
    }

    if (widget.tile.type == 'webcam') {
      Navigator.push(context, MaterialPageRoute(builder: (c) => const CameraStreamScreen()));
      return;
    }

    if (widget.tile.type == 'dropzone') {
      _handleDropZoneUpload();
      return;
    }

    if (widget.tile.type == 'timer') {
      _toggleTimer();
      return;
    }

    // For gesture tiles, show a slider bottom sheet on tap
    if (_isGestureTile) {
      _showSliderSheet();
      return;
    }

    context.read<ConnectionProvider>().executeAction(widget.tile.type, widget.tile.payload);
  }

  Future<void> _handleDropZoneUpload() async {
    final conn = context.read<ConnectionProvider>();
    if (conn.serverIp.isEmpty || conn.otp.isEmpty) return;

    try {
      FilePickerResult? result = await FilePicker.pickFiles(allowMultiple: true);
      if (result != null && result.files.isNotEmpty) {
        
        final filesToUpload = result.files.take(10).toList();
        
        setState(() => _isUploading = true);
        
        int successCount = 0;
        
        for (int i = 0; i < filesToUpload.length; i++) {
            if (!mounted) break;
            
            // Optional: update UI with progress like "Uploading 1/5..."
            // For now, it will just show the generic loading indicator
            
            var request = http.MultipartRequest('POST', Uri.parse('http://${conn.serverIp}:3000/upload'));
            request.headers['X-WinDeck-Auth'] = conn.otp;
            request.files.add(await http.MultipartFile.fromPath('file', filesToUpload[i].path!));
            
            try {
                var response = await request.send();
                if (response.statusCode == 200) {
                    successCount++;
                }
            } catch (e) {
                print('Failed to upload file ${filesToUpload[i].name}: $e');
            }
        }
        
        if (mounted) {
            if (successCount > 0) {
                if (conn.hapticsEnabled) HapticFeedback.heavyImpact();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transferred $successCount file(s) to PC!')));
            } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload failed.')));
            }
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _toggleTimer() {
    if (_countdownTimer != null && _countdownTimer!.isActive) {
      _countdownTimer!.cancel();
      setState(() => _remainingSeconds = 0);
      return;
    }
    
    // Parse payload as minutes
    double minutes = double.tryParse(widget.tile.payload) ?? 25.0;
    setState(() => _remainingSeconds = (minutes * 60).toInt());
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        _onTimerComplete();
      }
    });
  }

  void _onTimerComplete() async {
    final conn = context.read<ConnectionProvider>();
    if (conn.hapticsEnabled) {
      try { await Vibration.vibrate(pattern: [0, 500, 200, 500, 200, 1000]); } catch (_) {}
    }
    if (conn.soundsEnabled) {
      try {
        if (_audioPlayer.state == PlayerState.playing) await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource('sounds/tap.wav'));
      } catch (_) {}
    }
  }

  void _handleLongPress() {
    final conn = context.read<ConnectionProvider>();
    if (conn.hapticsEnabled) HapticFeedback.heavyImpact();
    if (_isGestureTile) {
      _showSliderSheet();
      return;
    }
    // No-op for other tiles since editing is now PC-only
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!_isGestureTile) return;
    
    _dragAccumulator -= details.delta.dy; // negative because drag up = increase
    
    if (_dragAccumulator.abs() >= _dragThreshold) {
      final conn = context.read<ConnectionProvider>();
      final isUp = _dragAccumulator > 0;
      
      if (widget.tile.payload == 'volume') {
        conn.executeAction('system', isUp ? 'volume-up' : 'volume-down');
      } else if (widget.tile.payload == 'brightness') {
        conn.executeAction('system', isUp ? 'brightness-up' : 'brightness-down');
      }
      
      if (conn.hapticsEnabled) HapticFeedback.lightImpact();
      _dragAccumulator = 0;
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _dragAccumulator = 0;
  }

  void _showSliderSheet() {
    final conn = context.read<ConnectionProvider>();
    final isVolume = widget.tile.payload == 'volume';
    final color = isVolume ? const Color(0xFF0078d4) : const Color(0xFFf59e0b);
    final icon = isVolume ? Icons.volume_up_rounded : Icons.brightness_6_rounded;
    final label = isVolume ? 'Volume' : 'Brightness';
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: 320,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161622),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(label, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Swipe up/down on the tile\nor use buttons below', 
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Down button
                  GestureDetector(
                    onTap: () {
                      if (conn.hapticsEnabled) HapticFeedback.lightImpact();
                      conn.executeAction('system', isVolume ? 'volume-down' : 'brightness-down');
                    },
                    onLongPressStart: (_) => _startRepeating(conn, isVolume ? 'volume-down' : 'brightness-down'),
                    onLongPressEnd: (_) => _stopRepeating(),
                    child: Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Icon(
                        isVolume ? Icons.volume_down_rounded : Icons.brightness_low_rounded, 
                        color: color, size: 28
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Mute / indicator
                  if (isVolume)
                    GestureDetector(
                      onTap: () {
                        if (conn.hapticsEnabled) HapticFeedback.mediumImpact();
                        conn.executeAction('system', 'mute');
                      },
                      child: Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.volume_off_rounded, color: Colors.redAccent, size: 24),
                      ),
                    )
                  else
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.brightness_auto_rounded, color: color.withValues(alpha: 0.5), size: 24),
                    ),
                  const SizedBox(width: 24),
                  // Up button
                  GestureDetector(
                    onTap: () {
                      if (conn.hapticsEnabled) HapticFeedback.lightImpact();
                      conn.executeAction('system', isVolume ? 'volume-up' : 'brightness-up');
                    },
                    onLongPressStart: (_) => _startRepeating(conn, isVolume ? 'volume-up' : 'brightness-up'),
                    onLongPressEnd: (_) => _stopRepeating(),
                    child: Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Icon(
                        isVolume ? Icons.volume_up_rounded : Icons.brightness_high_rounded, 
                        color: color, size: 28
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Timer? _repeatTimer;
  void _startRepeating(ConnectionProvider conn, String action) {
    _repeatTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      conn.executeAction('system', action);
      if (conn.hapticsEnabled) HapticFeedback.lightImpact();
    });
  }
  void _stopRepeating() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final serverIp = context.read<ConnectionProvider>().serverIp;
    
    String iconUrl = '';
    String faviconUrl = '';

    // Fetch favicon for website/url tiles
    if (widget.tile.type == 'url' || widget.tile.type == 'web' || 
        (widget.tile.type == 'system' && widget.tile.payload.startsWith('http'))) {
      try {
        final raw = widget.tile.payload.isNotEmpty ? widget.tile.payload : widget.tile.iconValue;
        final uri = Uri.tryParse(raw);
        if (uri != null && uri.host.isNotEmpty) {
          faviconUrl = 'https://www.google.com/s2/favicons?sz=64&domain=${uri.host}';
        }
      } catch (_) {}
    }

    if (widget.tile.type != 'empty' && (widget.tile.iconType == 'exe' || widget.tile.type == 'app')) {
      final exePath = widget.tile.payload.isNotEmpty ? widget.tile.payload : widget.tile.iconValue;
      iconUrl = 'http://$serverIp:3000/icon?path=${Uri.encodeComponent(exePath)}';
    }

    final bool isApp = widget.tile.type == 'app';
    final bool isEmpty = widget.tile.type == 'empty';
    final bool isExeIcon = widget.tile.iconType == 'exe' || isApp;
    final bool isWebTile = faviconUrl.isNotEmpty;

    // Tile colors
    Color tileColor;
    Color tileBorderColor;
    if (_isGestureTile) {
      final isVol = widget.tile.payload == 'volume';
      tileColor = (isVol ? const Color(0xFF0078d4) : const Color(0xFFf59e0b)).withValues(alpha: 0.12);
      tileBorderColor = (isVol ? const Color(0xFF0078d4) : const Color(0xFFf59e0b)).withValues(alpha: 0.25);
    } else if (isEmpty) {
      tileColor = Colors.white.withValues(alpha: 0.03);
      tileBorderColor = Colors.white.withValues(alpha: 0.08);
    } else {
      tileColor = const Color(0xFF0078d4).withValues(alpha: 0.10);
      tileBorderColor = const Color(0xFF0078d4).withValues(alpha: 0.20);
    }

    return GestureDetector(
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      onVerticalDragUpdate: _isGestureTile ? _onVerticalDragUpdate : null,
      onVerticalDragEnd: _isGestureTile ? _onVerticalDragEnd : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(24),
            border: isEmpty 
              ? Border.all(color: tileBorderColor, width: 1, style: BorderStyle.solid)
              : Border.all(color: tileBorderColor, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: isEmpty
                      ? Icon(Icons.add_rounded, size: 32, color: Colors.white.withValues(alpha: 0.2))
                      : widget.tile.type == 'timer' && _remainingSeconds > 0
                          ? Text(
                              '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                            )
                          : isWebTile
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        faviconUrl,
                                        width: 36, height: 36,
                                        fit: BoxFit.contain,
                                        errorBuilder: (c, e, s) => const Icon(Icons.language_rounded, color: Colors.white70, size: 36),
                                      ),
                                    ),
                                  ],
                                )
                              : !isExeIcon
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(IconMapper.get(widget.tile.iconValue, widget.tile.payload), size: 40, color: Colors.white),
                                        if (_isGestureTile) ...[
                                          const SizedBox(height: 4),
                                          Icon(Icons.swap_vert_rounded, size: 16, color: Colors.white.withValues(alpha: 0.3)),
                                        ],
                                        if (_isUploading && widget.tile.type == 'dropzone') ...[
                                          const SizedBox(height: 8),
                                          const SizedBox(
                                            width: 16, height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                          ),
                                        ],
                                      ],
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                          iconUrl,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.high,
                                          errorBuilder: (c, e, s) => Container(
                                            color: Colors.transparent,
                                            child: const Icon(Icons.apps_rounded, color: Colors.white30, size: 40),
                                          ),
                                        ),
                                      ),
                                    ),
                ),
              ),
              // Show label for all non-empty tiles
              if (!isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 8, right: 8),
                  child: Text(
                    widget.tile.title,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
