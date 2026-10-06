import 'package:boltin/models/crypto.dart';
import 'package:boltin/models/currency.dart';
import 'package:boltin/models/gold.dart';
import 'package:boltin/models/snapshot_meta.dart';

class PriceSnapshot {
  final SnapshotMeta meta;
  final List<Currency> currencies;
  final List<Gold> golds;
  final List<Crypto> cryptos;

  const PriceSnapshot({
    required this.meta,
    required this.currencies,
    required this.golds,
    required this.cryptos,
  });

  factory PriceSnapshot.fromJson(Map<String, dynamic> json) {
    return PriceSnapshot(
      meta: SnapshotMeta.fromJson(json['meta'] as Map<String, dynamic>),
      currencies: (json['currencies'] as List<dynamic>)
          .map((e) => Currency.fromJson(e as Map<String, dynamic>))
          .toList(),
      golds: (json['golds'] as List<dynamic>)
          .map((e) => Gold.fromJson(e as Map<String, dynamic>))
          .toList(),
      cryptos: (json['cryptos'] as List<dynamic>)
          .map((e) => Crypto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meta': meta.toJson(),
      'currencies': currencies.map((e) => e.toJson()).toList(),
      'golds': golds.map((e) => e.toJson()).toList(),
      'cryptos': cryptos.map((e) => e.toJson()).toList(),
    };
  }

  Currency? currencyBySlug(String slug) {
    for (final currency in currencies) {
      if (currency.slug == slug) return currency;
    }
    return null;
  }

  Gold? goldBySlug(String slug) {
    for (final gold in golds) {
      if (gold.slug == slug) return gold;
    }
    return null;
  }

  Crypto? cryptoBySlug(String slug) {
    for (final crypto in cryptos) {
      if (crypto.slug == slug) return crypto;
    }
    return null;
  }
}
