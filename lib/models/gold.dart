import 'package:boltin/models/change_direction.dart';

enum GoldUnit {
  toman,
  usd;

  static GoldUnit fromJson(String? value) {
    switch (value) {
      case 'usd':
        return GoldUnit.usd;
      case 'toman':
      default:
        return GoldUnit.toman;
    }
  }

  String toJson() => name;
}

class Gold {
  final String slug;
  final String name;
  final double price;
  final GoldUnit unit;
  final ChangeDirection changeDirection;

  const Gold({
    required this.slug,
    required this.name,
    required this.price,
    required this.unit,
    required this.changeDirection,
  });

  factory Gold.fromJson(Map<String, dynamic> json) {
    return Gold(
      slug: json['slug'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      unit: GoldUnit.fromJson(json['unit'] as String?),
      changeDirection: ChangeDirection.fromJson(
        json['change_direction'] as String?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'name': name,
      'price': price,
      'unit': unit.toJson(),
      'change_direction': changeDirection.toJson(),
    };
  }

  bool get isUsd => unit == GoldUnit.usd;
  bool get isToman => unit == GoldUnit.toman;
}
