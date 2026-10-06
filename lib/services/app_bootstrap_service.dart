import 'dart:io';

import 'package:boltin/models/app_bootstrap_data.dart';
import 'package:boltin/models/app_update_info.dart';
import 'package:boltin/models/channel_summary.dart';
import 'package:boltin/models/market_analysis.dart';
import 'package:boltin/models/price_snapshot.dart';
import 'package:boltin/services/analytics_service.dart';
import 'package:boltin/services/app_update_service.dart';
import 'package:boltin/services/channel_summary_service.dart';
import 'package:boltin/services/device_identity_service.dart';
import 'package:boltin/services/market_analysis_service.dart';
import 'package:boltin/services/snapshot_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppBootstrapService {
  AppBootstrapService({
    SnapshotService? snapshotService,
    ChannelSummaryService? summaryService,
    MarketAnalysisService? marketAnalysisService,
    AppUpdateService? appUpdateService,
    AnalyticsService? analyticsService,
    DeviceIdentityService? deviceIdentityService,
  }) : _snapshotService = snapshotService ?? SnapshotService(),
       _summaryService = summaryService ?? ChannelSummaryService(),
       _marketAnalysisService =
           marketAnalysisService ?? MarketAnalysisService(),
       _appUpdateService = appUpdateService ?? AppUpdateService(),
       _analyticsService = analyticsService ?? AnalyticsService(),
       _deviceIdentityService =
           deviceIdentityService ?? const DeviceIdentityService();

  static const _requestTimeout = Duration(seconds: 18);

  final SnapshotService _snapshotService;
  final ChannelSummaryService _summaryService;
  final MarketAnalysisService _marketAnalysisService;
  final AppUpdateService _appUpdateService;
  final AnalyticsService _analyticsService;
  final DeviceIdentityService _deviceIdentityService;

  // Prices are required to enter the app. Summaries, analysis, update-check,
  // and analytics may fail without blocking bootstrap.
  Future<AppBootstrapOutcome> load() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final deviceId = await _deviceIdentityService.getOrCreateDeviceId();
      final platform = Platform.isAndroid ? 'android' : 'ios';
      final appVersion = packageInfo.version;

      PriceSnapshot? snapshot;
      var summaries = <ChannelSummary>[];
      var summariesFailed = false;
      MarketAnalysis? marketAnalysis;
      AppUpdateInfo? updateInfo;

      await Future.wait<void>([
        () async {
          try {
            snapshot = await _snapshotService.fetchLatest().timeout(
              _requestTimeout,
            );
          } catch (_) {
            throw const AppBootstrapException(
              'دریافت قیمت‌ها با مشکل مواجه شد. اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.',
            );
          }
        }(),
        () async {
          try {
            summaries = await _summaryService.fetchLatest().timeout(
              _requestTimeout,
            );
          } catch (_) {
            summariesFailed = true;
          }
        }(),
        () async {
          try {
            marketAnalysis = await _marketAnalysisService.fetchLatest().timeout(
              _requestTimeout,
            );
          } catch (_) {
            marketAnalysis = null;
          }
        }(),
        () async {
          try {
            updateInfo = await _appUpdateService
                .checkForUpdate(appVersion)
                .timeout(_requestTimeout);
          } catch (_) {
            updateInfo = null;
          }
        }(),
        () async {
          try {
            await _analyticsService
                .ping(
                  deviceId: deviceId,
                  platform: platform,
                  appVersion: appVersion,
                )
                .timeout(_requestTimeout);
          } catch (_) {}
        }(),
      ]);

      return AppBootstrapOutcome(
        data: AppBootstrapData(
          deviceId: deviceId,
          appVersion: appVersion,
          platform: platform,
          snapshot: snapshot!,
          summaries: summaries,
          summariesFailed: summariesFailed,
          marketAnalysis: marketAnalysis,
        ),
        updateInfo: updateInfo,
      );
    } on AppBootstrapException {
      rethrow;
    } catch (_) {
      throw const AppBootstrapException(
        'ارتباط با سرور برقرار نشد. لطفاً اتصال اینترنت را بررسی کنید.',
      );
    }
  }

  void dispose() {
    _snapshotService.dispose();
    _summaryService.dispose();
    _marketAnalysisService.dispose();
    _appUpdateService.dispose();
    _analyticsService.dispose();
  }
}
