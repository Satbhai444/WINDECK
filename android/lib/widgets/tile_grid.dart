import 'package:flutter/material.dart';
import '../models/page_model.dart';
import 'tile_widget.dart';

class TileGrid extends StatelessWidget {
  final PageModel page;

  const TileGrid({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLandscape = constraints.maxWidth > constraints.maxHeight;
        int crossAxisCount = isLandscape ? 4 : 2;
        int rowCount = isLandscape ? 2 : 4;
        
        // Calculate aspect ratio to fit exactly rowCount (4) rows vertically
        double horizontalPadding = 32.0; // 16 * 2
        double verticalPadding = 16.0;   // 8 * 2
        double crossAxisSpacing = 16.0;
        double mainAxisSpacing = 16.0;

        double availableWidth = constraints.maxWidth - horizontalPadding - (crossAxisSpacing * (crossAxisCount - 1));
        double availableHeight = constraints.maxHeight - verticalPadding - (mainAxisSpacing * (rowCount - 1));
        
        double itemWidth = availableWidth / crossAxisCount;
        double itemHeight = availableHeight / rowCount;
        double computedAspectRatio = (itemWidth / itemHeight).clamp(0.5, 2.0);

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: computedAspectRatio,
          ),
          itemCount:
              page.tiles.length, // Render all tiles, allowing dynamic expansion
          itemBuilder: (context, index) {
            return TileWidget(tile: page.tiles[index]);
          },
        );
      },
    );
  }
}
