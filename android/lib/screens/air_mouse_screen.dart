import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/connection_provider.dart';

class AirMouseScreen extends StatefulWidget {
  const AirMouseScreen({super.key});

  @override
  State<AirMouseScreen> createState() => _AirMouseScreenState();
}

class _AirMouseScreenState extends State<AirMouseScreen> {
  void _onPanUpdate(DragUpdateDetails details) {
    final conn = context.read<ConnectionProvider>();
    
    // Non-linear acceleration curve for smoother and faster movement
    double dx = details.delta.dx;
    double dy = details.delta.dy;
    
    // Base multiplier
    double baseMult = 1.2;
    // Acceleration factor (higher delta = much higher multiplier)
    double accelX = dx.abs() > 1.0 ? 1.0 + (dx.abs() * 0.08) : 1.0;
    double accelY = dy.abs() > 1.0 ? 1.0 + (dy.abs() * 0.08) : 1.0;

    conn.emitRaw('mouse-move', {
      'dx': dx * baseMult * accelX,
      'dy': dy * baseMult * accelY,
    });
  }

  void _onTap() {
    final conn = context.read<ConnectionProvider>();
    conn.emitRaw('mouse-click', {'button': 'left'});
  }

  void _onLongPress() {
    final conn = context.read<ConnectionProvider>();
    conn.emitRaw('mouse-click', {'button': 'right'});
  }

  void _onScroll(DragUpdateDetails details) {
    final conn = context.read<ConnectionProvider>();
    // delta dy mapped to scroll
    conn.emitRaw('mouse-scroll', {'deltaY': details.delta.dy * -5}); // invert for natural scrolling, scale for Windows
  }

  Widget _buildToolbarButton(IconData icon, String action, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        iconSize: 28,
        onPressed: () {
          context.read<ConnectionProvider>().emitRaw('presentation-control', action);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF161622),
        title: const Text('Air Mouse & Presenter', style: TextStyle(color: Colors.white, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Presentation Toolbar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF161622),
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildToolbarButton(LucideIcons.arrowLeftCircle, 'slide-prev', 'Previous Slide'),
                _buildToolbarButton(LucideIcons.arrowRightCircle, 'slide-next', 'Next Slide'),
                _buildToolbarButton(LucideIcons.monitorPlay, 'presentation-start', 'Start Presentation'),
                _buildToolbarButton(LucideIcons.square, 'blank-screen', 'Blank Screen'),
                _buildToolbarButton(LucideIcons.xSquare, 'presentation-exit', 'Exit Presentation'),
              ],
            ),
          ),
          // Touchpad Area
          Expanded(
            child: Row(
              children: [
                // Main Touchpad
                Expanded(
                  child: GestureDetector(
                    onPanUpdate: _onPanUpdate,
                    onTap: _onTap,
                    onLongPress: _onLongPress,
                    child: Container(
                      color: Colors.transparent, // Must have a color to receive gestures
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.mousePointer2, size: 48, color: Colors.white.withValues(alpha: 0.1)),
                            const SizedBox(height: 16),
                            Text('Drag to move\nTap to left click\nLong press to right click', 
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 12)
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Scroll Strip
                GestureDetector(
                  onVerticalDragUpdate: _onScroll,
                  child: Container(
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border(left: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.chevronUp, color: Colors.white.withValues(alpha: 0.3)),
                        const SizedBox(height: 20),
                        const Text('SCROLL', style: TextStyle(color: Colors.white30, fontSize: 10, letterSpacing: 2)),
                        const SizedBox(height: 20),
                        Icon(LucideIcons.chevronDown, color: Colors.white.withValues(alpha: 0.3)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
