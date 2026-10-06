import 'package:boltin/models/app_update_info.dart';
import 'package:boltin/models/channel_summary.dart';
import 'package:boltin/models/market_analysis.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

void main() {
  group('ChannelSummary', () {
    test('parses category enum and payload fields', () {
      final summary = ChannelSummary.fromJson(summaryJson());
      expect(summary.category, SummaryCategory.geopolitics);
      expect(summary.postCount, 17);
      expect(summary.summaryId, 17);
      expect(summary.category.apiValue, 'geopolitics');
    });

    test('rejects unknown categories', () {
      expect(
        () => SummaryCategory.fromApi('sports'),
        throwsArgumentError,
      );
    });

    test('round-trips through toJson', () {
      final original = sampleSummary();
      final roundTripped = ChannelSummary.fromJson(original.toJson());
      expect(roundTripped.summaryText, original.summaryText);
      expect(roundTripped.category, SummaryCategory.geopolitics);
    });
  });

  group('MarketAnalysis', () {
    test('parses analysis text and optional title', () {
      final analysis = MarketAnalysis.fromJson(marketAnalysisJson());
      expect(analysis.id, 9);
      expect(analysis.title, 'طلا و انس');
      expect(analysis.analysisText, contains('۴۳۶۰'));
    });

    test('falls back to empty analysis text', () {
      final json = Map<String, dynamic>.from(marketAnalysisJson())
        ..['analysis_text'] = null;
      expect(MarketAnalysis.fromJson(json).analysisText, isEmpty);
    });
  });

  group('AppUpdateInfo', () {
    test('parses optional update', () {
      final info = AppUpdateInfo.fromJson(updateInfoJson());
      expect(info.updateAvailable, isTrue);
      expect(info.forceUpdate, isFalse);
      expect(info.latestVersion, '1.1.0');
      expect(info.releaseNotes, isNotEmpty);
    });

    test('parses forced update', () {
      final info = AppUpdateInfo.fromJson(updateInfoJson(forceUpdate: true));
      expect(info.forceUpdate, isTrue);
      expect(info.minRequiredVersion, '1.1.0');
    });
  });
}
