import 'package:boltin/models/change_direction.dart';

class Currency {
  final String slug;
  final String name;
  final double buyPrice;
  final double sellPrice;
  final ChangeDirection sellChangeDirection;
  final double? usdRate;
  final ChangeDirection usdRateChangeDirection;

  const Currency({
    required this.slug,
    required this.name,
    required this.buyPrice,
    required this.sellPrice,
    required this.sellChangeDirection,
    this.usdRate,
    required this.usdRateChangeDirection,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      slug: json['slug'] as String,
      name: json['name'] as String,
      buyPrice: (json['buy_price'] as num).toDouble(),
      sellPrice: (json['sell_price'] as num).toDouble(),
      sellChangeDirection: ChangeDirection.fromJson(
        json['sell_change_direction'] as String?,
      ),
      usdRate: (json['usd_rate'] as num?)?.toDouble(),
      usdRateChangeDirection: ChangeDirection.fromJson(
        json['usd_rate_change_direction'] as String?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'name': name,
      'buy_price': buyPrice,
      'sell_price': sellPrice,
      'sell_change_direction': sellChangeDirection.toJson(),
      'usd_rate': usdRate,
      'usd_rate_change_direction': usdRateChangeDirection.toJson(),
    };
  }
}
