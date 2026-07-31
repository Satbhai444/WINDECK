import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/connection_provider.dart';

class MediaHubScreen extends StatelessWidget {
  const MediaHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final conn = context.watch<ConnectionProvider>();
    final media = conn.mediaData;
    final hasMedia = media['title'] != null && media['title'] != 'Unknown Title';
    final title = hasMedia ? media['title'] : 'No Media Playing';
    final artist = (media['artist'] == null || media['artist'] == 'Unknown Artist')
        ? (hasMedia ? 'Playing on PC' : 'Connect to your PC to control media')
        : media['artist'];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Media Hub', style: TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold,
        )),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(flex: 2),
            
            // Album Art Card
            Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: LinearGradient(
                  colors: hasMedia 
                    ? [const Color(0xFF0078d4).withValues(alpha: 0.3), const Color(0xFF6C63FF).withValues(alpha: 0.2)]
                    : [Colors.white.withValues(alpha: 0.05), Colors.white.withValues(alpha: 0.02)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                boxShadow: hasMedia ? [
                  BoxShadow(
                    color: const Color(0xFF0078d4).withValues(alpha: 0.15),
                    blurRadius: 40, spreadRadius: 5,
                  ),
                ] : [],
              ),
              child: Center(
                child: Icon(
                  hasMedia ? Icons.music_note_rounded : Icons.music_off_rounded,
                  size: 80,
                  color: hasMedia ? const Color(0xFF0078d4) : Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Song Info
            Text(
              title,
              style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              artist,
              style: TextStyle(
                fontSize: 14, color: Colors.white.withValues(alpha: 0.4), fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const Spacer(flex: 2),

            // Playback Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous
                _ControlButton(
                  icon: Icons.skip_previous_rounded,
                  size: 52,
                  iconSize: 28,
                  color: Colors.white.withValues(alpha: 0.08),
                  iconColor: Colors.white70,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    conn.executeAction('system', 'media-prev');
                  },
                ),
                const SizedBox(width: 24),
                // Play/Pause
                _ControlButton(
                  icon: Icons.play_arrow_rounded,
                  size: 72,
                  iconSize: 40,
                  color: const Color(0xFF0078d4),
                  iconColor: Colors.white,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    conn.executeAction('system', 'media-play-pause');
                  },
                ),
                const SizedBox(width: 24),
                // Next
                _ControlButton(
                  icon: Icons.skip_next_rounded,
                  size: 52,
                  iconSize: 28,
                  color: Colors.white.withValues(alpha: 0.08),
                  iconColor: Colors.white70,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    conn.executeAction('system', 'media-next');
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Volume Line Gesture Bar
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0.5) {
                  conn.executeAction('system', 'volume-up');
                } else if (details.delta.dx < -0.5) {
                  conn.executeAction('system', 'volume-down');
                }
              },
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        conn.executeAction('system', 'volume-down');
                      },
                      child: Icon(Icons.volume_down_rounded, color: Colors.white.withValues(alpha: 0.5), size: 20),
                    ),
                    const SizedBox(width: 16),
                    // The Lines
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(24, (index) {
                          // Create a nice line pattern
                          double height = index % 4 == 0 ? 16 : 8;
                          return Container(
                            width: 2,
                            height: height,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: index < 12 ? 0.4 : 0.1),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        conn.executeAction('system', 'volume-up');
                      },
                      child: Icon(Icons.volume_up_rounded, color: Colors.white.withValues(alpha: 0.5), size: 20),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size / 3),
          boxShadow: color == const Color(0xFF0078d4) ? [
            BoxShadow(
              color: const Color(0xFF0078d4).withValues(alpha: 0.3),
              blurRadius: 20, spreadRadius: 2,
            ),
          ] : [],
        ),
        child: Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }
}
