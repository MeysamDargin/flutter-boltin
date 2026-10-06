import 'package:boltin/models/market_price_item.dart';
import 'package:boltin/models/price_snapshot.dart';

final Map<String, MarketPriceItem> _iconSeedBySlug = {
  for (final item in sampleMarketItems) item.slug: item,
};

String _iconPathFor(String slug) => _iconSeedBySlug[slug]?.iconPath ?? '';

bool _isNetworkIconFor(String slug) =>
    _iconSeedBySlug[slug]?.isNetworkIcon ?? false;

List<MarketPriceItem> currencyItemsFromSnapshot(PriceSnapshot snapshot) {
  return snapshot.currencies
      .map(
        (currency) => MarketPriceItem(
          slug: currency.slug,
          title: currency.name,
          price: currency.sellPrice,
          unit: 'تومان',
          usdValue: currency.usdRate,
          usdChangeDirection: currency.usdRateChangeDirection,
          iconPath: _iconPathFor(currency.slug),
          isNetworkIcon: _isNetworkIconFor(currency.slug),
        ),
      )
      .toList();
}

List<MarketPriceItem> goldItemsFromSnapshot(PriceSnapshot snapshot) {
  return snapshot.golds
      .map(
        (gold) => MarketPriceItem(
          slug: gold.slug,
          title: gold.name,
          price: gold.price,
          unit: gold.isUsd ? 'دلار' : 'تومان',
          usdChangeDirection: gold.changeDirection,
          iconPath: _iconPathFor(gold.slug),
          isNetworkIcon: _isNetworkIconFor(gold.slug),
        ),
      )
      .toList();
}

List<MarketPriceItem> cryptoItemsFromSnapshot(PriceSnapshot snapshot) {
  return snapshot.cryptos
      .map(
        (crypto) => MarketPriceItem(
          slug: crypto.slug,
          title: crypto.nameFa,
          price: crypto.priceToman,
          unit: 'تومان',
          usdValue: crypto.priceUsd,
          usdChangeDirection: crypto.usdChangeDirection,
          iconPath: _iconPathFor(crypto.slug),
          isNetworkIcon: _isNetworkIconFor(crypto.slug),
        ),
      )
      .toList();
}

List<MarketPriceItem> marketItemsFromSnapshot(PriceSnapshot snapshot) {
  return [
    ...currencyItemsFromSnapshot(snapshot),
    ...goldItemsFromSnapshot(snapshot),
    ...cryptoItemsFromSnapshot(snapshot),
  ];
}
