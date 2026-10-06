import 'package:boltin/models/app_bootstrap_data.dart';
import 'package:boltin/screen/all_prices_page.dart';
import 'package:boltin/screen/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

void main() {
  testWidgets('all-prices page groups snapshot rows by market', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: AllPricesPage(snapshot: sampleSnapshot())),
    );

    expect(find.text('همه‌ی قیمت‌ها'), findsOneWidget);
    expect(find.text('ارزهای کشورها'), findsOneWidget);
    expect(find.text('طلا و سکه'), findsOneWidget);
    expect(find.text('ارزهای دیجیتال'), findsOneWidget);
    expect(find.text('دلار آمریکا'), findsOneWidget);
    expect(find.text('بیت کوین'), findsOneWidget);
  });

  testWidgets('home feed shows bootstrap prices and AI copy', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(
          bootstrapData: AppBootstrapData(
            deviceId: 'device-1',
            appVersion: '1.0.0',
            platform: 'ios',
            snapshot: sampleSnapshot(),
            summaries: [sampleSummary()],
            summariesFailed: false,
            marketAnalysis: sampleMarketAnalysis(),
          ),
        ),
      ),
    );

    expect(find.text('بولتین'), findsOneWidget);
    expect(find.text('دلار آمریکا'), findsOneWidget);
    expect(find.text('یورو'), findsOneWidget);
    expect(find.text('تحلیل بازار با هوش مصنوعی'), findsOneWidget);
    expect(find.textContaining('۴۳۶۰'), findsOneWidget);
    expect(find.text('خلاصه اخبار ایران و جهان'), findsOneWidget);
  });
}
