import 'dart:convert';

import 'package:boltin/api/api.dart';
import 'package:boltin/api/endpoint.dart' as endpoint;
import 'package:boltin/models/channel_summary.dart';
import 'package:http/http.dart' as http;

class ChannelSummaryException implements Exception {
  final String message;
  final int? statusCode;

  const ChannelSummaryException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'ChannelSummaryException($statusCode): $message';
    }
    return 'ChannelSummaryException: $message';
  }
}

class ChannelSummaryService {
  ChannelSummaryService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<ChannelSummary>> fetchLatest() async {
    final uri = buildApiUri(endpoint.summariesLatest);

    late final http.Response response;
    try {
      response = await _client.get(
        uri,
        headers: const {'accept': 'application/json'},
      );
    } catch (error) {
      throw ChannelSummaryException('Failed to reach API: $error');
    }

    if (response.statusCode != 200) {
      throw ChannelSummaryException(
        'Unexpected status while fetching summaries',
        statusCode: response.statusCode,
      );
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const ChannelSummaryException('Invalid summaries payload shape');
      }

      final data = decoded['data'];
      if (data is! List<dynamic>) {
        throw const ChannelSummaryException('Invalid summaries data list');
      }

      return data
          .map((e) => ChannelSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ChannelSummaryException {
      rethrow;
    } catch (error) {
      throw ChannelSummaryException('Failed to parse summaries: $error');
    }
  }

  Future<ChannelSummary> fetchLatestByCategory(SummaryCategory category) async {
    final uri = buildApiUri(endpoint.summaryByCategory(category.apiValue));

    late final http.Response response;
    try {
      response = await _client.get(
        uri,
        headers: const {'accept': 'application/json'},
      );
    } catch (error) {
      throw ChannelSummaryException('Failed to reach API: $error');
    }

    if (response.statusCode == 404) {
      throw ChannelSummaryException(
        'No summary available for ${category.apiValue}',
        statusCode: 404,
      );
    }

    if (response.statusCode != 200) {
      throw ChannelSummaryException(
        'Unexpected status while fetching summary',
        statusCode: response.statusCode,
      );
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const ChannelSummaryException('Invalid summary payload shape');
      }

      final data = decoded['data'];
      if (data is! Map<String, dynamic>) {
        throw const ChannelSummaryException('Invalid summary data object');
      }

      return ChannelSummary.fromJson(data);
    } on ChannelSummaryException {
      rethrow;
    } catch (error) {
      throw ChannelSummaryException('Failed to parse summary: $error');
    }
  }

  void dispose() {
    _client.close();
  }
}
