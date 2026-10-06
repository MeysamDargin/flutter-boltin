import 'dart:convert';

import 'package:boltin/api/api.dart';
import 'package:boltin/api/endpoint.dart' as endpoint;
import 'package:http/http.dart' as http;

class AnalyticsException implements Exception {
  final String message;
  final int? statusCode;

  const AnalyticsException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'AnalyticsException($statusCode): $message';
    }
    return 'AnalyticsException: $message';
  }
}

class AnalyticsService {
  AnalyticsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<void> ping({
    required String deviceId,
    required String platform,
    required String appVersion,
  }) async {
    final uri = buildApiUri(endpoint.analyticsPing);

    late final http.Response response;
    try {
      response = await _client.post(
        uri,
        headers: const {
          'accept': 'application/json',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'device_id': deviceId,
          'platform': platform,
          'app_version': appVersion,
        }),
      );
    } catch (error) {
      throw AnalyticsException('Failed to reach API: $error');
    }

    if (response.statusCode != 200) {
      throw AnalyticsException(
        'Unexpected status while sending analytics ping',
        statusCode: response.statusCode,
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
