import 'package:boltin/models/change_direction.dart';

class Crypto {
  final String slug;
  final String nameFa;
  final String nameEn;
  final double priceToman;
  final ChangeDirection tomanChangeDirection;
  final double priceUsd;
  final ChangeDirection usdChangeDirection;

  const Crypto({
    required this.slug,
    required this.nameFa,
    required this.nameEn,
    required this.priceToman,
    required this.tomanChangeDirection,
    required this.priceUsd,
    required this.usdChangeDirection,
  });

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      slug: json['slug'] as String,
      nameFa: json['name_fa'] as String,
      nameEn: json['name_en'] as String,
      priceToman: (json['price_toman'] as num).toDouble(),
      tomanChangeDirection: ChangeDirection.fromJson(
        json['toman_change_direction'] as String?,
      ),
      priceUsd: (json['price_usd'] as num).toDouble(),
      usdChangeDirection: ChangeDirection.fromJson(
        json['usd_change_direction'] as String?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'name_fa': nameFa,
      'name_en': nameEn,
      'price_toman': priceToman,
      'toman_change_direction': tomanChangeDirection.toJson(),
      'price_usd': priceUsd,
      'usd_change_direction': usdChangeDirection.toJson(),
    };
  }
}
