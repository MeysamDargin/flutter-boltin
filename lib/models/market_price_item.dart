import 'package:boltin/models/change_direction.dart';

class MarketPriceItem {
  final String slug;
  final String title;
  final double price;
  final String unit;
  final double? usdValue;
  final ChangeDirection usdChangeDirection;
  final String iconPath;
  final bool isNetworkIcon;

  const MarketPriceItem({
    required this.slug,
    required this.title,
    required this.price,
    required this.iconPath,
    this.unit = 'تومان',
    this.usdValue,
    this.usdChangeDirection = ChangeDirection.noChange,
    this.isNetworkIcon = false,
  });

  MarketPriceItem copyWith({String? iconPath, bool? isNetworkIcon}) {
    return MarketPriceItem(
      slug: slug,
      title: title,
      price: price,
      unit: unit,
      usdValue: usdValue,
      usdChangeDirection: usdChangeDirection,
      iconPath: iconPath ?? this.iconPath,
      isNetworkIcon: isNetworkIcon ?? this.isNetworkIcon,
    );
  }
}

enum MarketCategory { currency, gold, crypto }

// Home-feed cards follow this slug order; missing slugs are skipped.
const List<String> importantMarketSlugs = [
  'usd',
  'eur',
  'gbp',
  'aed',
  'try',
  'cny',
  'sekkeh',
  '18ayar',
  'usd_xau',
  'btc',
  'eth',
  'usdt',
];

List<MarketPriceItem> filterImportantItems(List<MarketPriceItem> items) {
  final bySlug = {for (final item in items) item.slug: item};
  return [
    for (final slug in importantMarketSlugs)
      if (bySlug[slug] != null) bySlug[slug]!,
  ];
}

final List<MarketPriceItem> sampleMarketItems = [
  const MarketPriceItem(
    slug: 'afn',
    title: 'افغانی',
    price: 2850.0,
    usdValue: 65.8,
    usdChangeDirection: ChangeDirection.down,
    iconPath: '',
  ),
  const MarketPriceItem(
    slug: 'thb',
    title: 'بات تایلند',
    price: 5670.0,
    usdValue: 33.0,
    usdChangeDirection: ChangeDirection.up,
    iconPath: '',
  ),
  const MarketPriceItem(
    slug: 'gbp',
    title: 'پوند انگلیس',
    price: 250400.0,
    usdValue: 0.741,
    usdChangeDirection: ChangeDirection.up,
    iconPath: '',
  ),
  const MarketPriceItem(
    slug: 'aed',
    title: 'درهم',
    price: 50690.0,
    usdValue: 3.67,
    usdChangeDirection: ChangeDirection.noChange,
    iconPath: '',
  ),
  const MarketPriceItem(
    slug: 'usd',
    title: 'دلار آمریکا',
    price: 187500.0,
    usdChangeDirection: ChangeDirection.noChange,
    iconPath: '',
  ),
  const MarketPriceItem(
    slug: 'usd-ist',
    title: 'دلار استانبول',
    price: 187100.0,
    usdChangeDirection: ChangeDirection.noChange,
    iconPath: '',
  ),
  const MarketPriceItem(
    slug: 'aud',
    title: 'دلار استرالیا',
    price: 132500.0,
    usdValue: 1.415,
    usdChangeDirection: ChangeDirection.noChange,
    iconPath: '',
  ),
  const MarketPriceItem(
    slug: 'cad',
    title: 'دلار کانادا',
    price: 134500.0,
    usdValue: 1.394,
    usdChangeDirection: ChangeDirection.down,
    iconPath: '',
  ),
  const MarketPriceItem(
    slug: 'rub',
    title: 'روبل روسیه',
    price: 2290.0,
    usdValue: 81.9,
    usdChangeDirection: ChangeDirection.up,
    iconPath: '',
  ),
  const MarketPriceItem(
    slug: 'inr',
    title: 'روپیه هند',
    price: 1970.0,
    usdValue: 95.2,
    usdChangeDirection: ChangeDirection.up,
    iconPath: '',
  ),
  const MarketPriceItem(
    slug: 'omr',
    title: 'ریال عمان',
    price: 487100.0,
    usdValue: 0.385,
    usdChangeDirection: ChangeDirection.down,
    iconPath: '',
  ),
  const MarketPriceItem(
    slug: 'myr',
    title: 'رینگیت مالزی',
    price: 45840.0,
    usdValue: 4.09,
    usdChangeDirection: ChangeDirection.up,
    iconPath: '',
  ),
  const MarketPriceItem(
    slug: 'amd',
    title: 'صد درام ارمنستان',
    price: 51200.0,
    usdValue: 3.66,
    usdChangeDirection: ChangeDirection.down,
    iconPath: '',
  ),
  const MarketPriceItem(
    slug: 'iqd',
    title: 'صد دینار عراق',
    price: 12290.0,
    usdValue: 15.26,
    usdChangeDirection: ChangeDirection.noChange,
    iconPath: '',
  ),
  const MarketPriceItem(
    slug: 'jpy',
    title: 'صد ین ژاپن',
    price: 118800.0,
    usdValue: 1.578,
    usdChangeDirection: ChangeDirection.up,
    iconPath: '',
  ),
  const MarketPriceItem(
    slug: 'gel',
    title: 'لاری گرجستان',
    price: 71700.0,
    usdValue: 2.61,
    usdChangeDirection: ChangeDirection.down,
    iconPath: '',
  ),
  const MarketPriceItem(
    slug: 'try',
    title: 'لیر ترکیه',
    price: 3990.0,
    usdValue: 47.7,
    usdChangeDirection: ChangeDirection.up,
    iconPath: '',
  ),
  const MarketPriceItem(
    slug: 'azn',
    title: 'منات آذربایجان',
    price: 110300.0,
    usdValue: 1.7,
    usdChangeDirection: ChangeDirection.noChange,
    iconPath: '',
  ),
  const MarketPriceItem(
    slug: 'cny',
    title: 'یوان چین',
    price: 27880.0,
    usdValue: 6.75,
    usdChangeDirection: ChangeDirection.up,
    iconPath: '',
  ),
  const MarketPriceItem(
    slug: 'eur',
    title: 'یورو',
    price: 216700.0,
    usdValue: 0.865,
    usdChangeDirection: ChangeDirection.up,
    iconPath: 'assets/icons/euro.png',
  ),

  const MarketPriceItem(
    slug: 'abshodeh',
    title: 'آبشده(مثقال طلا)',
    price: 80550000.0,
    usdChangeDirection: ChangeDirection.noChange,
    iconPath: 'assets/icons/GOLD-MESGHAL.webp',
  ),
  const MarketPriceItem(
    slug: 'usd_xau',
    title: 'انس طلا',
    price: 4341.92,
    unit: 'دلار',
    usdChangeDirection: ChangeDirection.down,
    iconPath: 'assets/icons/GOLD18.webp',
  ),
  const MarketPriceItem(
    slug: 'sekkeh',
    title: 'سکه امامی (طرح جدید)',
    price: 185000000.0,
    usdChangeDirection: ChangeDirection.noChange,
    iconPath: 'assets/icons/SEKE-EMAMI.webp',
  ),
  const MarketPriceItem(
    slug: '18ayar',
    title: 'گرم طلای 18 عیار',
    price: 18595040.0,
    usdChangeDirection: ChangeDirection.noChange,
    iconPath: 'assets/icons/GOLD18.webp',
  ),

  const MarketPriceItem(
    slug: 'eth',
    title: 'اتریوم',
    price: 358150412.0,
    usdValue: 1915.0,
    usdChangeDirection: ChangeDirection.up,
    iconPath: 'assets/icons/eth.png',
  ),
  const MarketPriceItem(
    slug: 'bnb',
    title: 'بایننس کوین',
    price: 111295627.0,
    usdValue: 594.2,
    usdChangeDirection: ChangeDirection.up,
    iconPath: 'assets/icons/bnb.png',
  ),
  const MarketPriceItem(
    slug: 'btc',
    title: 'بیت کوین',
    price: 12124402211.0,
    usdValue: 64958.0,
    usdChangeDirection: ChangeDirection.up,
    iconPath: 'assets/icons/btc.png',
  ),
  const MarketPriceItem(
    slug: 'usdt',
    title: 'تتر',
    price: 187218.0,
    usdValue: 1.0,
    usdChangeDirection: ChangeDirection.noChange,
    iconPath: 'assets/icons/usdt.png',
  ),
  const MarketPriceItem(
    slug: 'ton',
    title: 'تون کوین',
    price: 0.0,
    usdValue: 1.6,
    usdChangeDirection: ChangeDirection.up,
    iconPath: 'assets/icons/ton.png',
  ),
  const MarketPriceItem(
    slug: 'doge',
    title: 'دوج‌کوین',
    price: 13128.0,
    usdValue: 0.0702,
    usdChangeDirection: ChangeDirection.up,
    iconPath: 'assets/icons/doge.png',
  ),
  const MarketPriceItem(
    slug: 'xrp',
    title: 'ریپل',
    price: 194500.0,
    usdValue: 1.035,
    usdChangeDirection: ChangeDirection.up,
    iconPath: 'assets/icons/xrp.png',
  ),
  const MarketPriceItem(
    slug: 'shib',
    title: 'شیبا',
    price: 1.0,
    usdValue: 4.7e-6,
    usdChangeDirection: ChangeDirection.up,
    iconPath: 'assets/icons/shib.png',
  ),
  const MarketPriceItem(
    slug: 'not',
    title: 'نات کوین',
    price: 65.0,
    usdValue: 0.00035,
    usdChangeDirection: ChangeDirection.up,
    iconPath: 'assets/icons/not.png',
  ),
];
