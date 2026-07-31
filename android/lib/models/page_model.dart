import 'tile_model.dart';
import 'package:uuid/uuid.dart';

class PageModel {
  String id;
  String name;
  String type; // 'custom', 'websites', 'system', 'apps'
  String? linkedExe; // Auto-switch feature (match by exe name)
  String? titlePattern; // Auto-switch feature (match by window title substring)
  List<TileModel> tiles;

  PageModel({
    required this.id,
    required this.name,
    this.type = 'custom',
    this.linkedExe,
    this.titlePattern,
    required this.tiles,
  });

  factory PageModel.createDefault(String name, {String type = 'custom'}) {
    return PageModel(
      id: const Uuid().v4(),
      name: name,
      type: type,
      tiles: List.generate(
        8,
        (index) => TileModel(id: const Uuid().v4()),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'linkedExe': linkedExe,
        'titlePattern': titlePattern,
        'tiles': tiles.map((t) => t.toJson()).toList(),
      };

  factory PageModel.fromJson(Map<String, dynamic> json) => PageModel(
        id: json['id'] ?? const Uuid().v4(),
        name: json['name'] ?? 'Unnamed Page',
        type: json['type'] ?? _inferTypeFromName(json['name'] ?? ''),
        linkedExe: json['linkedExe'],
        titlePattern: json['titlePattern'],
        tiles: (json['tiles'] as List)
            .map((t) => TileModel.fromJson(Map<String, dynamic>.from(t)))
            .toList(),
      );

  static String _inferTypeFromName(String name) {
    final lower = name.toLowerCase();
    if (lower == 'system') return 'system';
    if (lower == 'websites') return 'websites';
    if (lower.startsWith('apps')) return 'apps';
    return 'custom';
  }
}
