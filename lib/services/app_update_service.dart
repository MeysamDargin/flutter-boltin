import 'dart:convert';

import 'package:boltin/api/api.dart';
import 'package:boltin/api/endpoint.dart' as endpoint;
import 'package:boltin/models/app_update_info.dart';
import 'package:http/http.dart' as http;

class AppUpdateException implements Exception {
  final String message;
  final int? statusCode;

  const AppUpdateException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'AppUpdateException($statusCode): $message';
    }
    return 'AppUpdateException: $message';
  }
}

class AppUpdateService {
  AppUpdateService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<AppUpdateInfo> checkForUpdate(String currentVersion) async {
    final uri = buildApiUri(
      endpoint.appUpdateCheck,
      queryParameters: {'current_version': currentVersion},
    );

    late final http.Response response;
    try {
      response = await _client.get(
        uri,
        headers: const {'accept': 'application/json'},
      );
    } catch (error) {
      throw AppUpdateException('Failed to reach API: $error');
    }

    if (response.statusCode != 200) {
      throw AppUpdateException(
        'Unexpected status while checking app update',
        statusCode: response.statusCode,
      );
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const AppUpdateException('Invalid update payload shape');
      }
      return AppUpdateInfo.fromJson(decoded);
    } on AppUpdateException {
      rethrow;
    } catch (error) {
      throw AppUpdateException('Failed to parse update payload: $error');
    }
  }

  void dispose() {
    _client.close();
  }
}
