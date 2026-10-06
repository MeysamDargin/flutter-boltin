import 'dart:async';

import 'package:boltin/models/app_bootstrap_data.dart';
import 'package:boltin/models/channel_summary.dart';
import 'package:boltin/models/market_analysis.dart';
import 'package:boltin/models/price_snapshot.dart';
import 'package:boltin/screen/all_prices_page.dart';
import 'package:boltin/services/channel_summary_service.dart';
import 'package:boltin/services/device_identity_service.dart';
import 'package:boltin/services/feedback_service.dart';
import 'package:boltin/services/market_item_mapper.dart';
import 'package:boltin/services/market_analysis_service.dart';
import 'package:boltin/services/snapshot_service.dart';
import 'package:boltin/utils/persian_format.dart';
import 'package:boltin/widget/ai_market_summary_card.dart';
import 'package:boltin/widget/ai_news_summary_card.dart';
import 'package:boltin/widget/feedback_dialog.dart';
import 'package:boltin/widget/price_card.dart';
import 'package:boltin/widget/price_card_error.dart';
import 'package:boltin/widget/price_card_shimmer.dart';
import 'package:boltin/widget/tab_nav.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.bootstrapData});

  final AppBootstrapData? bootstrapData;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SnapshotService _snapshotService = SnapshotService();
  final ChannelSummaryService _summaryService = ChannelSummaryService();
  final MarketAnalysisService _marketAnalysisService = MarketAnalysisService();
  final FeedbackService _feedbackService = FeedbackService();
  final DeviceIdentityService _deviceIdentityService =
      const DeviceIdentityService();

  static const _marketAnalysisFallbackText =
      'هوش مصنوعی درحال تحقیق در بازار هست و منتظر بمانید.';

  PriceSnapshot? _snapshot;
  bool _isInitialLoading = true;
  bool _hasError = false;

  ChannelSummary? _geopoliticsSummary;
  ChannelSummary? _technologySummary;
  bool _isSummaryLoading = true;
  bool _hasSummaryError = false;
  MarketAnalysis? _marketAnalysis;
  bool _isMarketAnalysisLoading = true;
  int _newsTabIndex = 0;

  Timer? _refreshTimer;

  static const _refreshInterval = Duration(minutes: 1);

  @override
  void initState() {
    super.initState();
    final bootstrap = widget.bootstrapData;
    if (bootstrap != null) {
      _snapshot = bootstrap.snapshot;
      _isInitialLoading = false;
      _geopoliticsSummary = bootstrap.summaryByCategory(
        SummaryCategory.geopolitics,
      );
      _technologySummary = bootstrap.summaryByCategory(
        SummaryCategory.technology,
      );
      _isSummaryLoading = false;
      _hasSummaryError = bootstrap.summariesFailed;
      _marketAnalysis = bootstrap.marketAnalysis;
      _isMarketAnalysisLoading = false;
    } else {
      _loadInitialSnapshot();
      _loadSummaries();
      _loadMarketAnalysis();
    }
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      _refreshSnapshotSilently();
      _refreshSummariesSilently();
      _refreshMarketAnalysisSilently();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _snapshotService.dispose();
    _summaryService.dispose();
    _marketAnalysisService.dispose();
    _feedbackService.dispose();
    super.dispose();
  }

  Future<void> _loadInitialSnapshot() async {
    setState(() {
      _isInitialLoading = true;
      _hasError = false;
    });
    try {
      final snapshot = await _snapshotService.fetchLatest();
      if (!mounted) return;
      setState(() {
        _snapshot = snapshot;
        _isInitialLoading = false;
        _hasError = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isInitialLoading = false;
        _hasError = true;
      });
    }
  }

  // Silent poll: keep the last good snapshot if this request fails.
  Future<void> _refreshSnapshotSilently() async {
    try {
      final snapshot = await _snapshotService.fetchLatest();
      if (!mounted) return;
      setState(() {
        _snapshot = snapshot;
        _hasError = false;
      });
    } catch (_) {
      if (!mounted) return;
      if (_snapshot == null) {
        setState(() => _hasError = true);
      }
    }
  }

  Future<void> _loadSummaries() async {
    setState(() {
      _isSummaryLoading = true;
      _hasSummaryError = false;
    });

    try {
      final summaries = await _summaryService.fetchLatest();
      if (!mounted) return;
      setState(() {
        _geopoliticsSummary = _findSummary(
          summaries,
          SummaryCategory.geopolitics,
        );
        _technologySummary = _findSummary(
          summaries,
          SummaryCategory.technology,
        );
        _isSummaryLoading = false;
        _hasSummaryError = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSummaryLoading = false;
        _hasSummaryError = true;
      });
    }
  }

  Future<void> _refreshSummariesSilently() async {
    try {
      final summaries = await _summaryService.fetchLatest();
      if (!mounted) return;
      setState(() {
        _geopoliticsSummary = _findSummary(
          summaries,
          SummaryCategory.geopolitics,
        );
        _technologySummary = _findSummary(
          summaries,
          SummaryCategory.technology,
        );
        _hasSummaryError = false;
      });
    } catch (_) {
      if (!mounted) return;
      if (_geopoliticsSummary == null && _technologySummary == null) {
        setState(() => _hasSummaryError = true);
      }
    }
  }

  Future<void> _loadMarketAnalysis() async {
    setState(() {
      _isMarketAnalysisLoading = true;
    });

    try {
      final analysis = await _marketAnalysisService.fetchLatest();
      if (!mounted) return;
      setState(() {
        _marketAnalysis = analysis;
        _isMarketAnalysisLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isMarketAnalysisLoading = false;
      });
    }
  }

  Future<void> _refreshMarketAnalysisSilently() async {
    try {
      final analysis = await _marketAnalysisService.fetchLatest();
      if (!mounted) return;
      setState(() {
        _marketAnalysis = analysis;
      });
    } catch (_) {
      if (!mounted) return;
    }
  }

  ChannelSummary? _findSummary(
    List<ChannelSummary> summaries,
    SummaryCategory category,
  ) {
    for (final summary in summaries) {
      if (summary.category == category) return summary;
    }
    return null;
  }

  void _openAllPrices() {
    final snapshot = _snapshot;
    if (snapshot == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AllPricesPage(snapshot: snapshot)),
    );
  }

  Future<void> _openFeedbackDialog() async {
    final submitted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => FeedbackDialog(
        onSubmit:
            ({
              required text,
              required category,
              rating,
              email,
            }) async {
              final results = await Future.wait([
                _deviceIdentityService.getOrCreateDeviceId(),
                PackageInfo.fromPlatform(),
              ]);
              final deviceId = results[0] as String;
              final packageInfo = results[1] as PackageInfo;

              await _feedbackService.submit(
                feedbackText: text,
                category: category,
                rating: rating,
                deviceId: deviceId,
                appVersion: packageInfo.version,
                contactEmail: email,
              );
            },
      ),
    );

    if (!mounted || submitted != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'بازخورد شما با موفقیت ارسال شد. ممنون که به بهتر شدن بولتین کمک می‌کنید.',
          textDirection: TextDirection.rtl,
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color.fromARGB(255, 16, 129, 91),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      ),
    );
  }

  ChannelSummary? get _activeNewsSummary {
    return _newsTabIndex == 0 ? _geopoliticsSummary : _technologySummary;
  }

  SummaryCategory get _activeNewsCategory {
    return _newsTabIndex == 0
        ? SummaryCategory.geopolitics
        : SummaryCategory.technology;
  }

  String get _activeNewsTitle {
    return _newsTabIndex == 0
        ? 'خلاصه اخبار ایران و جهان'
        : 'خلاصه اخبار تکنولوژی';
  }

  String get _marketAnalysisText {
    final text = _marketAnalysis?.analysisText.trim() ?? '';
    if (text.isEmpty) return _marketAnalysisFallbackText;
    return text;
  }

  String? get _marketAnalysisUpdateText {
    final createdAt = _marketAnalysis?.createdAt;
    if (createdAt == null) return null;
    return formatRelativePersian(createdAt);
  }

  @override
  Widget build(BuildContext context) {
    final bottomClearance = MediaQuery.viewPaddingOf(context).bottom + 96;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 19, 46),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color.fromARGB(156, 9, 33, 75),
                    width: 2.0,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _openFeedbackDialog,
                      tooltip: 'ارسال بازخورد',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      icon: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/icons/support-svgrepo-com (1).png',
                          color: const Color.fromARGB(255, 199, 209, 226),
                          width: 29.0,
                          height: 29.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Row(
                      children: const [
                        Text(
                          'بولتین',
                          style: TextStyle(
                            color: Color.fromARGB(255, 199, 209, 226),
                            fontSize: 22.0,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'IRANYekanXVF',
                          ),
                        ),
                        SizedBox(width: 5),
                        Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            'b',
                            style: TextStyle(
                              color: Color.fromARGB(255, 16, 170, 116),
                              fontSize: 22.0,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'PressStart2P',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: bottomClearance),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Column(
                        children: [
                          _buildPriceSection(),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                            child: Text(
                              'قیمت‌ها از سامانه ثنا، بانک مرکزی و صرافی‌های معتبر ایرانی گرفته می‌شود.',
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: Color.fromARGB(140, 199, 209, 226),
                                fontSize: 10,
                                height: 1.6,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: AiMarketSummaryCard(
                        summary: _marketAnalysisText,
                        updateText: _marketAnalysisUpdateText,
                        isLoading: _isMarketAnalysisLoading,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: TabNav(
                        onTabChanged: (index) {
                          setState(() => _newsTabIndex = index);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: AiNewsSummaryCard(
                        title: _activeNewsTitle,
                        category: _activeNewsCategory,
                        summary: _activeNewsSummary,
                        isLoading: _isSummaryLoading,
                        hasError: _hasSummaryError,
                        onRetry: _loadSummaries,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    if (_isInitialLoading) {
      return const MarketPriceSliderShimmer();
    }

    final snapshot = _snapshot;
    if (snapshot == null || _hasError) {
      return MarketPriceError(onRetry: _loadInitialSnapshot);
    }

    return MarketPriceSlider(
      items: filterImportantItems(marketItemsFromSnapshot(snapshot)),
      updateText: snapshot.meta.siteUpdateText,
      onSeeAllTap: _openAllPrices,
    );
  }
}
