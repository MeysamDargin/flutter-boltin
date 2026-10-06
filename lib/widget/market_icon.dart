import 'package:boltin/models/market_price_item.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

String? countryCodeForSlug(String slug) {
  switch (slug.toLowerCase()) {
    case 'afn':
      return 'AF';
    case 'thb':
      return 'TH';
    case 'gbp':
      return 'GB';
    case 'aed':
      return 'AE';
    case 'usd':
    case 'usd-ist':
      return 'US';
    case 'aud':
      return 'AU';
    case 'cad':
      return 'CA';
    case 'rub':
      return 'RU';
    case 'inr':
      return 'IN';
    case 'omr':
      return 'OM';
    case 'myr':
      return 'MY';
    case 'amd':
      return 'AM';
    case 'iqd':
      return 'IQ';
    case 'jpy':
      return 'JP';
    case 'gel':
      return 'GE';
    case 'try':
      return 'TR';
    case 'azn':
      return 'AZ';
    case 'cny':
      return 'CN';
    default:
      return null;
  }
}

class MarketIcon extends StatelessWidget {
  final MarketPriceItem item;
  final double size;

  const MarketIcon({super.key, required this.item, this.size = 26});

  @override
  Widget build(BuildContext context) {
    final countryCode = countryCodeForSlug(item.slug);

    final Widget errorFallback = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white24,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.monetization_on,
        color: Colors.white70,
        size: size * 0.58,
      ),
    );

    if (countryCode != null) {
      return ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: CountryFlag.fromCountryCode(
            countryCode,
            theme: ImageTheme(shape: const Circle()),
          ),
        ),
      );
    }

    if (item.iconPath.isEmpty) return errorFallback;

    if (item.isNetworkIcon) {
      return ClipOval(
        child: Image.network(
          item.iconPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => errorFallback,
        ),
      );
    }

    return ClipOval(
      child: Image.asset(
        item.iconPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => errorFallback,
      ),
    );
  }
}
