import 'dart:convert';

import 'package:boltin/api/endpoint.dart' as endpoint;
import 'package:boltin/models/channel_summary.dart';
import 'package:boltin/services/analytics_service.dart';
import 'package:boltin/services/app_update_service.dart';
import 'package:boltin/services/channel_summary_service.dart';
import 'package:boltin/services/feedback_service.dart';
import 'package:boltin/services/market_analysis_service.dart';
import 'package:boltin/services/snapshot_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../helpers/fixtures.dart';

MockClient jsonClient({
  required int statusCode,
  required Object body,
  void Function(http.Request request)? onRequest,
}) {
  return MockClient((request) async {
    onRequest?.call(request);
    return http.Response(
      body is String ? body : jsonEncode(body),
      statusCode,
      headers: {'content-type': 'application/json'},
    );
  });
}

void main() {
  group('SnapshotService', () {
    test('parses a 200 payload', () async {
      final service = SnapshotService(
        client: jsonClient(statusCode: 200, body: snapshotJson()),
      );
      final snapshot = await service.fetchLatest();
      expect(snapshot.currencyBySlug('usd')?.sellPrice, 190300);
      service.dispose();
    });

    test('throws on non-200', () async {
      final service = SnapshotService(
        client: jsonClient(statusCode: 503, body: {'error': 'down'}),
      );
      expect(
        () => service.fetchLatest(),
        throwsA(isA<SnapshotException>().having((e) => e.statusCode, 'code', 503)),
      );
      service.dispose();
    });

    test('throws on invalid payload shape', () async {
      final service = SnapshotService(
        client: jsonClient(statusCode: 200, body: ['not-a-map']),
      );
      expect(service.fetchLatest(), throwsA(isA<SnapshotException>()));
      service.dispose();
    });
  });

  group('ChannelSummaryService', () {
    test('parses the data list', () async {
      final service = ChannelSummaryService(
        client: jsonClient(
          statusCode: 200,
          body: {
            'data': [
              summaryJson(),
              summaryJson(category: 'technology', summaryId: 18),
            ],
          },
        ),
      );
      final summaries = await service.fetchLatest();
      expect(summaries, hasLength(2));
      expect(summaries.last.category.apiValue, 'technology');
      service.dispose();
    });

    test('fetchLatestByCategory hits the category path', () async {
      late http.Request seen;
      final service = ChannelSummaryService(
        client: jsonClient(
          statusCode: 200,
          body: {'data': summaryJson(category: 'technology')},
          onRequest: (request) => seen = request,
        ),
      );
      final summary = await service.fetchLatestByCategory(
        SummaryCategory.technology,
      );
      expect(seen.url.path, endpoint.summaryByCategory('technology'));
      expect(summary.category, SummaryCategory.technology);
      service.dispose();
    });

    test('maps 404 to a typed exception', () async {
      final service = ChannelSummaryService(
        client: jsonClient(statusCode: 404, body: {'error': 'missing'}),
      );
      expect(
        () => service.fetchLatestByCategory(SummaryCategory.geopolitics),
        throwsA(isA<ChannelSummaryException>().having((e) => e.statusCode, 'code', 404)),
      );
      service.dispose();
    });
  });

  group('MarketAnalysisService', () {
    test('unwraps the data object', () async {
      final service = MarketAnalysisService(
        client: jsonClient(statusCode: 200, body: {'data': marketAnalysisJson()}),
      );
      final analysis = await service.fetchLatest();
      expect(analysis?.id, 9);
      service.dispose();
    });

    test('returns null on 404', () async {
      final service = MarketAnalysisService(
        client: jsonClient(statusCode: 404, body: {}),
      );
      expect(await service.fetchLatest(), isNull);
      service.dispose();
    });

    test('throws on unexpected status', () async {
      final service = MarketAnalysisService(
        client: jsonClient(statusCode: 500, body: {}),
      );
      expect(service.fetchLatest(), throwsA(isA<MarketAnalysisException>()));
      service.dispose();
    });
  });

  group('AppUpdateService', () {
    test('sends current_version and parses the payload', () async {
      late http.Request seen;
      final service = AppUpdateService(
        client: jsonClient(
          statusCode: 200,
          body: updateInfoJson(forceUpdate: true),
          onRequest: (request) => seen = request,
        ),
      );
      final info = await service.checkForUpdate('1.0.0');
      expect(seen.url.queryParameters['current_version'], '1.0.0');
      expect(info.forceUpdate, isTrue);
      service.dispose();
    });
  });

  group('AnalyticsService', () {
    test('posts device identity fields', () async {
      late http.Request seen;
      final service = AnalyticsService(
        client: jsonClient(
          statusCode: 200,
          body: {'ok': true},
          onRequest: (request) => seen = request,
        ),
      );
      await service.ping(
        deviceId: 'device-1',
        platform: 'ios',
        appVersion: '1.0.0',
      );
      expect(seen.method, 'POST');
      expect(jsonDecode(seen.body), {
        'device_id': 'device-1',
        'platform': 'ios',
        'app_version': '1.0.0',
      });
      service.dispose();
    });

    test('throws on non-200', () async {
      final service = AnalyticsService(
        client: jsonClient(statusCode: 400, body: {}),
      );
      expect(
        () => service.ping(
          deviceId: 'x',
          platform: 'android',
          appVersion: '1.0.0',
        ),
        throwsA(isA<AnalyticsException>()),
      );
      service.dispose();
    });
  });

  group('FeedbackService', () {
    test('posts a 201 payload and omits empty email', () async {
      late http.Request seen;
      final service = FeedbackService(
        client: jsonClient(
          statusCode: 201,
          body: {'ok': true},
          onRequest: (request) => seen = request,
        ),
      );
      await service.submit(
        feedbackText: '  کارت قیمت عالی است  ',
        category: FeedbackCategory.suggestion,
        deviceId: 'device-1',
        appVersion: '1.0.0',
        rating: 5,
        contactEmail: '  ',
      );
      final body = jsonDecode(seen.body) as Map<String, dynamic>;
      expect(body['feedback_text'], 'کارت قیمت عالی است');
      expect(body['category'], 'suggestion');
      expect(body['rating'], 5);
      expect(body['contact_email'], isNull);
      service.dispose();
    });

    test('throws unless the server returns 201', () async {
      final service = FeedbackService(
        client: jsonClient(statusCode: 200, body: {}),
      );
      expect(
        () => service.submit(
          feedbackText: 'hi',
          category: FeedbackCategory.bug,
          deviceId: 'd',
          appVersion: '1.0.0',
        ),
        throwsA(isA<FeedbackException>().having((e) => e.statusCode, 'code', 200)),
      );
      service.dispose();
    });
  });
}
