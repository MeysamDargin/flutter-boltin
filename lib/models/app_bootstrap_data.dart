import 'package:boltin/models/app_update_info.dart';
import 'package:boltin/models/channel_summary.dart';
import 'package:boltin/models/market_analysis.dart';
import 'package:boltin/models/price_snapshot.dart';

class AppBootstrapData {
  const AppBootstrapData({
    required this.deviceId,
    required this.appVersion,
    required this.platform,
    required this.snapshot,
    required this.summaries,
    required this.summariesFailed,
    required this.marketAnalysis,
  });

  final String deviceId;
  final String appVersion;
  final String platform;
  final PriceSnapshot snapshot;
  final List<ChannelSummary> summaries;
  final bool summariesFailed;
  final MarketAnalysis? marketAnalysis;

  ChannelSummary? summaryByCategory(SummaryCategory category) {
    for (final summary in summaries) {
      if (summary.category == category) return summary;
    }
    return null;
  }
}

class AppBootstrapException implements Exception {
  const AppBootstrapException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AppBootstrapOutcome {
  const AppBootstrapOutcome({required this.data, this.updateInfo});

  final AppBootstrapData data;
  final AppUpdateInfo? updateInfo;
}
