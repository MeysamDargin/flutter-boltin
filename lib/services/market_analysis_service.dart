import 'dart:convert';

import 'package:boltin/api/api.dart';
import 'package:boltin/api/endpoint.dart' as endpoint;
import 'package:boltin/models/market_analysis.dart';
import 'package:http/http.dart' as http;

class MarketAnalysisException implements Exception {
  final String message;
  final int? statusCode;

  const MarketAnalysisException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'MarketAnalysisException($statusCode): $message';
    }
    return 'MarketAnalysisException: $message';
  }
}

class MarketAnalysisService {
  MarketAnalysisService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<MarketAnalysis?> fetchLatest() async {
    final uri = buildApiUri(endpoint.marketAnalysisLatest);

    late final http.Response response;
    try {
      response = await _client.get(
        uri,
        headers: const {'accept': 'application/json'},
      );
    } catch (error) {
      throw MarketAnalysisException('Failed to reach API: $error');
    }

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode != 200) {
      throw MarketAnalysisException(
        'Unexpected status while fetching market analysis',
        statusCode: response.statusCode,
      );
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const MarketAnalysisException(
          'Invalid market analysis payload shape',
        );
      }

      final data = decoded['data'];
      if (data is! Map<String, dynamic>) {
        throw const MarketAnalysisException(
          'Invalid market analysis data object',
        );
      }

      return MarketAnalysis.fromJson(data);
    } on MarketAnalysisException {
      rethrow;
    } catch (error) {
      throw MarketAnalysisException(
        'Failed to parse market analysis: $error',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
