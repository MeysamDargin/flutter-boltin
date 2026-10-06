import 'package:boltin/models/change_direction.dart';
import 'package:boltin/models/crypto.dart';
import 'package:boltin/models/currency.dart';
import 'package:boltin/models/gold.dart';
import 'package:boltin/models/price_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

void main() {
  group('ChangeDirection', () {
    test('parses known values and falls back to noChange', () {
      expect(ChangeDirection.fromJson('up'), ChangeDirection.up);
      expect(ChangeDirection.fromJson('down'), ChangeDirection.down);
      expect(ChangeDirection.fromJson('no_change'), ChangeDirection.noChange);
      expect(ChangeDirection.fromJson(null), ChangeDirection.noChange);
      expect(ChangeDirection.fromJson('wat'), ChangeDirection.noChange);
    });

    test('round-trips through toJson', () {
      for (final value in ChangeDirection.values) {
        expect(ChangeDirection.fromJson(value.toJson()), value);
      }
    });
  });

  group('PriceSnapshot', () {
    test('parses currencies, golds, cryptos, and lookup helpers', () {
      final snapshot = PriceSnapshot.fromJson(snapshotJson());

      expect(snapshot.meta.snapshotId, 42);
      expect(snapshot.currencies, hasLength(2));
      expect(snapshot.golds, hasLength(2));
      expect(snapshot.cryptos, hasLength(1));

      expect(snapshot.currencyBySlug('usd')?.sellPrice, 190300);
      expect(snapshot.goldBySlug('usd_xau')?.isUsd, isTrue);
      expect(snapshot.cryptoBySlug('btc')?.nameEn, 'Bitcoin');
      expect(snapshot.currencyBySlug('missing'), isNull);
    });

    test('round-trips through toJson', () {
      final original = sampleSnapshot();
      final roundTripped = PriceSnapshot.fromJson(original.toJson());

      expect(roundTripped.meta.snapshotId, original.meta.snapshotId);
      expect(roundTripped.currencies.first.slug, 'usd');
      expect(roundTripped.golds.last.unit, GoldUnit.usd);
      expect(roundTripped.cryptos.single.priceUsd, 64958);
    });
  });

  group('Currency / Gold / Crypto', () {
    test('maps sell vs buy and optional usd rate', () {
      final usd = Currency.fromJson(snapshotJson()['currencies'][0]);
      expect(usd.buyPrice, 190000);
      expect(usd.sellPrice, 190300);
      expect(usd.usdRate, isNull);
      expect(usd.sellChangeDirection, ChangeDirection.up);
    });

    test('gold unit helpers', () {
      final toman = Gold.fromJson(snapshotJson()['golds'][0]);
      final usd = Gold.fromJson(snapshotJson()['golds'][1]);
      expect(toman.isToman, isTrue);
      expect(usd.isUsd, isTrue);
    });

    test('crypto bilingual names', () {
      final btc = Crypto.fromJson(snapshotJson()['cryptos'][0]);
      expect(btc.nameFa, 'بیت کوین');
      expect(btc.nameEn, 'Bitcoin');
      expect(btc.usdChangeDirection.isUp, isTrue);
    });
  });
}
