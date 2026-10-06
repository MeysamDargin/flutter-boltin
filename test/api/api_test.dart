import 'package:boltin/api/api.dart';
import 'package:boltin/api/endpoint.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildApiUri joins base url and path', () {
    final uri = buildApiUri(snapshotLatest);
    expect(uri.toString(), '$apiBaseUrl$snapshotLatest');
    expect(uri.path, snapshotLatest);
  });

  test('buildApiUri stringifies query parameters', () {
    final uri = buildApiUri(
      appUpdateCheck,
      queryParameters: {'current_version': '1.0.0'},
    );
    expect(uri.queryParameters['current_version'], '1.0.0');
  });

  test('summaryByCategory interpolates the category segment', () {
    expect(summaryByCategory('geopolitics'), '/api/v1/summaries/geopolitics');
  });
}
