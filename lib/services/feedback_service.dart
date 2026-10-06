import 'dart:convert';

import 'package:boltin/api/api.dart';
import 'package:boltin/api/endpoint.dart' as endpoint;
import 'package:http/http.dart' as http;

enum FeedbackCategory {
  bug('bug'),
  suggestion('suggestion'),
  complaint('complaint'),
  other('other');

  const FeedbackCategory(this.apiValue);
  final String apiValue;
}

class FeedbackException implements Exception {
  const FeedbackException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => statusCode == null
      ? 'FeedbackException: $message'
      : 'FeedbackException($statusCode): $message';
}

class FeedbackService {
  FeedbackService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<void> submit({
    required String feedbackText,
    required FeedbackCategory category,
    required String deviceId,
    required String appVersion,
    int? rating,
    String? contactEmail,
  }) async {
    final uri = buildApiUri(endpoint.feedback);
    final email = contactEmail?.trim();

    late final http.Response response;
    try {
      response = await _client.post(
        uri,
        headers: const {
          'accept': 'application/json',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'feedback_text': feedbackText.trim(),
          'category': category.apiValue,
          'rating': rating,
          'device_id': deviceId,
          'app_version': appVersion,
          'contact_email': email == null || email.isEmpty ? null : email,
        }),
      );
    } catch (error) {
      throw FeedbackException('ارتباط با سرور برقرار نشد: $error');
    }

    if (response.statusCode != 201) {
      throw FeedbackException(
        'ارسال بازخورد با خطا مواجه شد',
        statusCode: response.statusCode,
      );
    }
  }

  void dispose() => _client.close();
}
