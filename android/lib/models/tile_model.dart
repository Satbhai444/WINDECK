import 'package:uuid/uuid.dart';

class TileModel {
  String id;
  String title;
  String type; // 'empty', 'app', 'system', 'macro'
  String iconType; // 'emoji', 'exe'
  String iconValue; 
  String payload;

  TileModel({
    required this.id,
    this.title = '',
    this.type = 'empty',
    this.iconType = 'icon',
    this.iconValue = 'plus',
    this.payload = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'iconType': iconType,
        'iconValue': iconValue,
        'payload': payload,
      };

  factory TileModel.fromJson(Map<String, dynamic> json) {
    return TileModel(
      id: json['id'] ?? const Uuid().v4(),
      title: json['title'] ?? '',
      type: json['type'] ?? 'empty',
      iconType: json['iconType'] ?? 
                (json['type'] == 'app' ? 'exe' : 
                ((json['type'] == 'system' || json['type'] == 'url') ? 'emoji' : 'lucide')),
      iconValue: json['type'] == 'app' 
                ? (json['iconValue'] ?? json['payload'] ?? '') 
                : (json['iconValue'] ?? 'plus'),
      payload: json['payload'] ?? '',
    );
  }
}
