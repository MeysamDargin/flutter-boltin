import 'package:boltin/models/app_update_info.dart';
import 'package:boltin/models/channel_summary.dart';
import 'package:boltin/models/market_analysis.dart';
import 'package:boltin/models/price_snapshot.dart';

Map<String, dynamic> snapshotJson() => {
      'meta': {
        'snapshot_id': 42,
        'fetched_at': '2026-08-20T16:30:00.000Z',
        'site_update_text': '۱۶:۳۰ پنجشنبه ۲۹ مرداد ۱۴۰۵',
        'source_url': 'https://example.com/rates',
      },
      'currencies': [
        {
          'slug': 'usd',
          'name': 'دلار آمریکا',
          'buy_price': 190000,
          'sell_price': 190300,
          'sell_change_direction': 'up',
          'usd_rate': null,
          'usd_rate_change_direction': 'no_change',
        },
        {
          'slug': 'eur',
          'name': 'یورو',
          'buy_price': 222000,
          'sell_price': 222400,
          'sell_change_direction': 'down',
          'usd_rate': 0.86,
          'usd_rate_change_direction': 'down',
        },
      ],
      'golds': [
        {
          'slug': '18ayar',
          'name': 'گرم طلای 18 عیار',
          'price': 18595040,
          'unit': 'toman',
          'change_direction': 'up',
        },
        {
          'slug': 'usd_xau',
          'name': 'انس طلا',
          'price': 4360,
          'unit': 'usd',
          'change_direction': 'down',
        },
      ],
      'cryptos': [
        {
          'slug': 'btc',
          'name_fa': 'بیت کوین',
          'name_en': 'Bitcoin',
          'price_toman': 12124402211,
          'toman_change_direction': 'up',
          'price_usd': 64958,
          'usd_change_direction': 'up',
        },
      ],
    };

PriceSnapshot sampleSnapshot() => PriceSnapshot.fromJson(snapshotJson());

Map<String, dynamic> summaryJson({
  String category = 'geopolitics',
  int summaryId = 17,
}) =>
    {
      'category': category,
      'category_label': category == 'geopolitics' ? 'ایران و جهان' : 'تکنولوژی',
      'channel_username': 'boltin_news',
      'channel_id': 1001,
      'summary_id': summaryId,
      'from_message_id': 10,
      'to_message_id': 40,
      'post_count': 17,
      'ai_model': 'gpt-4.1',
      'summary_text': 'ظهر بخیر؛ خلاصه‌ی اخبار ظهر.',
      'created_at': '2026-08-20T12:04:00.000Z',
    };

ChannelSummary sampleSummary() => ChannelSummary.fromJson(summaryJson());

Map<String, dynamic> marketAnalysisJson() => {
      'id': 9,
      'title': 'طلا و انس',
      'analysis_text':
          'قیمت طلا در بازار جهانی حدود ۴۳۶۰ دلار در هر انس است.',
      'ai_model': 'gpt-4.1',
      'created_at': '2026-08-20T16:00:00.000Z',
    };

MarketAnalysis sampleMarketAnalysis() =>
    MarketAnalysis.fromJson(marketAnalysisJson());

Map<String, dynamic> updateInfoJson({
  bool updateAvailable = true,
  bool forceUpdate = false,
}) =>
    {
      'update_available': updateAvailable,
      'force_update': forceUpdate,
      'current_version': '1.0.0',
      'latest_version': '1.1.0',
      'min_required_version': forceUpdate ? '1.1.0' : '1.0.0',
      'update_url': 'https://example.com/boltin.apk',
      'release_notes': 'Bug fixes and faster feed refresh.',
      'is_critical': forceUpdate,
    };

AppUpdateInfo sampleUpdateInfo({bool forceUpdate = false}) =>
    AppUpdateInfo.fromJson(updateInfoJson(forceUpdate: forceUpdate));
