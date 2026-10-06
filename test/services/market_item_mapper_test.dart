import 'package:boltin/models/market_price_item.dart';
import 'package:boltin/services/market_item_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

void main() {
  final snapshot = sampleSnapshot();

  test('splits snapshot into currency, gold, and crypto lists', () {
    expect(currencyItemsFromSnapshot(snapshot).map((e) => e.slug), ['usd', 'eur']);
    expect(goldItemsFromSnapshot(snapshot).map((e) => e.slug), ['18ayar', 'usd_xau']);
    expect(cryptoItemsFromSnapshot(snapshot).map((e) => e.slug), ['btc']);
  });

  test('uses sell price for currencies and toman price for crypto', () {
    final usd = currencyItemsFromSnapshot(snapshot).first;
    expect(usd.price, 190300);
    expect(usd.unit, 'تومان');

    final ounce = goldItemsFromSnapshot(snapshot).last;
    expect(ounce.unit, 'دلار');
    expect(ounce.price, 4360);

    final btc = cryptoItemsFromSnapshot(snapshot).single;
    expect(btc.price, 12124402211);
    expect(btc.usdValue, 64958);
  });

  test('filterImportantItems keeps the home-feed order', () {
    final filtered = filterImportantItems(marketItemsFromSnapshot(snapshot));
    expect(
      filtered.map((e) => e.slug).toList(),
      ['usd', 'eur', '18ayar', 'usd_xau', 'btc'],
    );
  });

  test('filterImportantItems skips slugs that are missing from the snapshot', () {
    final onlyUsd = filterImportantItems([
      const MarketPriceItem(
        slug: 'usd',
        title: 'دلار آمریکا',
        price: 1,
        iconPath: '',
      ),
    ]);
    expect(onlyUsd, hasLength(1));
    expect(onlyUsd.single.slug, 'usd');
  });
}
