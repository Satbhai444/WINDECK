import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connection_provider.dart';

class MediaPlayerCard extends StatelessWidget {
  const MediaPlayerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final conn = context.watch<ConnectionProvider>();
    final mediaData = conn.mediaData;
    
    // 4 = playing, 5 = paused in windows-media-sessions
    final isPlaying = mediaData['playbackStatus'] == 4;
    final title = mediaData['title'] ?? 'Not playing';
    final artist = mediaData['artist'] ?? '';
    final sourceApp = mediaData['sourceApp']?.toString().toLowerCase() ?? '';

    IconData getAppIcon() {
      if (sourceApp.contains('spotify')) return Icons.library_music_rounded;
      if (sourceApp.contains('chrome') || sourceApp.contains('youtube')) return Icons.play_circle_fill;
      return Icons.music_note_rounded;
    }

    Color getAppColor() {
      if (sourceApp.contains('spotify')) return const Color(0xFF1DB954);
      if (sourceApp.contains('youtube')) return Colors.red;
      return Colors.white24;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Media player',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.cast_rounded, color: Colors.white.withValues(alpha: 0.8), size: 20),
            ],
          ),
          const SizedBox(height: 20),
          
          // Album Art Placeholder
          Center(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.music_note_rounded,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  if (sourceApp.isNotEmpty)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: getAppColor(),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(getAppIcon(), size: 16, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Track Info
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (artist.isNotEmpty && artist != 'Unknown Artist') ...[
            const SizedBox(height: 4),
            Text(
              artist,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          
          // Progress Bar (Mock for now since no backend data)
          Row(
            children: [
              Text('00:00', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                    activeTrackColor: Colors.white.withValues(alpha: 0.8),
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    value: 0.0,
                    onChanged: (val) {},
                  ),
                ),
              ),
              Text('04:00', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          
          // Playback Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded),
                color: Colors.white,
                iconSize: 32,
                onPressed: () => conn.executeAction('system', 'media-prev'),
              ),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                color: Colors.white,
                iconSize: 42,
                onPressed: () => conn.executeAction('system', 'media-play-pause'),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded),
                color: Colors.white,
                iconSize: 32,
                onPressed: () => conn.executeAction('system', 'media-next'),
              ),
            ],
          ),
          
          // Volume Slider (Mocked for now)
          Row(
            children: [
              Icon(Icons.volume_down_rounded, color: Colors.white.withValues(alpha: 0.5), size: 16),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    value: 0.5,
                    onChanged: (val) {},
                  ),
                ),
              ),
              Icon(Icons.volume_up_rounded, color: Colors.white.withValues(alpha: 0.5), size: 16),
            ],
          ),
        ],
      ),
    );
  }
}
