import 'dart:async';
import 'dart:io';

import 'package:boltin/button_bar/nav_bar.dart';
import 'package:boltin/models/app_bootstrap_data.dart';
import 'package:boltin/models/app_update_info.dart';
import 'package:boltin/screen/splash_page.dart';
import 'package:boltin/services/analytics_service.dart';
import 'package:boltin/services/app_update_service.dart';
import 'package:boltin/services/device_identity_service.dart';
import 'package:boltin/widget/app_update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  static const _pingInterval = Duration(seconds: 30);

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final DeviceIdentityService _deviceIdentityService =
      const DeviceIdentityService();
  final AppUpdateService _appUpdateService = AppUpdateService();
  final AnalyticsService _analyticsService = AnalyticsService();

  Timer? _analyticsTimer;
  String? _deviceId;
  String? _appVersion;
  String? _platform;
  AppBootstrapData? _bootstrapData;
  bool _isForegroundSyncRunning = false;
  bool _isUpdateDialogVisible = false;
  bool _wasInBackground = false;
  bool _didPromptUpdateThisVisit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _analyticsTimer?.cancel();
    _appUpdateService.dispose();
    _analyticsService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_bootstrapData == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppForegrounded();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _wasInBackground = true;
        _stopAnalyticsHeartbeat();
        break;
      case AppLifecycleState.inactive:
        // Notifications and system sheets go inactive; that is not a background
        // exit, so do not re-prompt the update dialog.
        break;
    }
  }

  void _onSplashReady(AppBootstrapData data) {
    _deviceId = data.deviceId;
    _appVersion = data.appVersion;
    _platform = data.platform;
    _didPromptUpdateThisVisit = true;
    setState(() => _bootstrapData = data);
    _startAnalyticsHeartbeat();
  }

  Future<void> _ensureSessionInfo() async {
    if (_deviceId != null && _appVersion != null && _platform != null) {
      return;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final deviceId = await _deviceIdentityService.getOrCreateDeviceId();

    if (!mounted) return;

    _deviceId = deviceId;
    _appVersion = packageInfo.version;
    _platform = Platform.isAndroid ? 'android' : 'ios';
  }

  Future<void> _handleAppForegrounded() async {
    if (_isForegroundSyncRunning) return;
    _isForegroundSyncRunning = true;

    try {
      await _ensureSessionInfo();
      _startAnalyticsHeartbeat();

      final returningFromBackground = _wasInBackground;
      _wasInBackground = false;
      if (returningFromBackground) {
        _didPromptUpdateThisVisit = false;
      }

      await Future.wait([
        if (!_didPromptUpdateThisVisit) _checkForAppUpdate(),
        _sendAnalyticsPing(),
      ]);
    } finally {
      _isForegroundSyncRunning = false;
    }
  }

  void _startAnalyticsHeartbeat() {
    _analyticsTimer?.cancel();
    _analyticsTimer = Timer.periodic(_pingInterval, (_) {
      _sendAnalyticsPing();
    });
  }

  void _stopAnalyticsHeartbeat() {
    _analyticsTimer?.cancel();
    _analyticsTimer = null;
  }

  Future<void> _sendAnalyticsPing() async {
    final deviceId = _deviceId;
    final appVersion = _appVersion;
    final platform = _platform;

    if (deviceId == null || appVersion == null || platform == null) {
      return;
    }

    try {
      await _analyticsService.ping(
        deviceId: deviceId,
        platform: platform,
        appVersion: appVersion,
      );
    } catch (_) {}
  }

  Future<void> _checkForAppUpdate() async {
    final appVersion = _appVersion;
    if (appVersion == null) return;

    try {
      final updateInfo = await _appUpdateService.checkForUpdate(appVersion);
      if (!mounted) return;
      _didPromptUpdateThisVisit = true;
      if (!updateInfo.updateAvailable && !updateInfo.forceUpdate) return;
      await _showUpdateDialog(updateInfo);
    } catch (_) {}
  }

  Future<void> _showUpdateDialog(AppUpdateInfo info) async {
    if (_isUpdateDialogVisible) return;

    final context = _navigatorKey.currentContext;
    if (context == null) return;

    _isUpdateDialogVisible = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: !info.forceUpdate,
      builder: (dialogContext) {
        return AppUpdateDialog(
          info: info,
          onUpdateTap: () => _openUpdateUrl(info),
          onLaterTap: info.forceUpdate
              ? null
              : () => Navigator.of(dialogContext).pop(),
        );
      },
    );
    _isUpdateDialogVisible = false;
  }

  static const _launcherChannel = MethodChannel('com.meysamdargin.boltin.app/launcher');

  Future<void> _openUpdateUrl(AppUpdateInfo info) async {
    try {
      await _launcherChannel.invokeMethod('openUrl', {'url': info.updateUrl});
    } catch (e) {
      debugPrint('Failed to open url: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'boltin',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          fontFamily: 'IRANYekan',
        ),
        home: _bootstrapData == null
            ? SplashPage(
                onReady: _onSplashReady,
                onOpenUpdateUrl: _openUpdateUrl,
              )
            : ButtonNavbar(1, bootstrapData: _bootstrapData),
      ),
    );
  }
}
