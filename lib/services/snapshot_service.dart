import 'dart:convert';

import 'package:boltin/api/api.dart';
import 'package:boltin/api/endpoint.dart' as endpoint;
import 'package:boltin/models/price_snapshot.dart';
import 'package:http/http.dart' as http;

class SnapshotException implements Exception {
  final String message;
  final int? statusCode;

  const SnapshotException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'SnapshotException($statusCode): $message';
    }
    return 'SnapshotException: $message';
  }
}

class SnapshotService {
  SnapshotService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<PriceSnapshot> fetchLatest() async {
    final uri = buildApiUri(endpoint.snapshotLatest);

    late final http.Response response;
    try {
      response = await _client.get(
        uri,
        headers: const {'accept': 'application/json'},
      );
    } catch (error) {
      throw SnapshotException('Failed to reach API: $error');
    }

    if (response.statusCode != 200) {
      throw SnapshotException(
        'Unexpected status while fetching snapshot',
        statusCode: response.statusCode,
      );
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const SnapshotException('Invalid snapshot payload shape');
      }
      return PriceSnapshot.fromJson(decoded);
    } on SnapshotException {
      rethrow;
    } catch (error) {
      throw SnapshotException('Failed to parse snapshot: $error');
    }
  }

  void dispose() {
    _client.close();
  }
}
