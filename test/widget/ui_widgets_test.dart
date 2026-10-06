import 'package:boltin/models/change_direction.dart';
import 'package:boltin/models/market_price_item.dart';
import 'package:boltin/screen/news_page.dart';
import 'package:boltin/widget/app_update_dialog.dart';
import 'package:boltin/widget/feedback_dialog.dart';
import 'package:boltin/widget/market_icon.dart';
import 'package:boltin/widget/price_card.dart';
import 'package:boltin/widget/price_card_error.dart';
import 'package:boltin/widget/usd_rate_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

const _sampleItem = MarketPriceItem(
  slug: 'custom-gold',
  title: 'سکه امامی',
  price: 185000000,
  iconPath: '',
  usdValue: 1.02,
  usdChangeDirection: ChangeDirection.up,
);

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 19, 46),
      body: child,
    ),
  );
}

void main() {
  test('countryCodeForSlug maps ISO codes and leaves euro unmapped', () {
    expect(countryCodeForSlug('usd'), 'US');
    expect(countryCodeForSlug('usd-ist'), 'US');
    expect(countryCodeForSlug('eur'), isNull);
    expect(countryCodeForSlug('btc'), isNull);
  });

  testWidgets('price error state offers retry', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      _wrap(MarketPriceError(onRetry: () => retried = true)),
    );

    expect(find.text('دریافت قیمت‌ها با مشکل مواجه شد'), findsOneWidget);
    await tester.tap(find.text('تلاش مجدد'));
    expect(retried, isTrue);
  });

  testWidgets('price slider renders titles and the see-all action', (tester) async {
    var opened = false;
    await tester.pumpWidget(
      _wrap(
        MarketPriceSlider(
          items: const [_sampleItem],
          updateText: '۱۶:۳۰',
          onSeeAllTap: () => opened = true,
        ),
      ),
    );

    expect(find.text('قیمت‌های مهم بازار'), findsOneWidget);
    expect(find.text('سکه امامی'), findsOneWidget);
    expect(find.textContaining('همه'), findsOneWidget);
    await tester.tap(find.textContaining('همه'));
    expect(opened, isTrue);
  });

  testWidgets('usd rate badge shows the Persian number', (tester) async {
    await tester.pumpWidget(_wrap(const UsdRateBadge(item: _sampleItem)));
    expect(find.text('۱.۰۲'), findsOneWidget);
  });

  testWidgets('news placeholder explains the upcoming section', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NewsPage()));
    expect(find.text('بخش خبرها در حال توسعه است'), findsOneWidget);
    expect(find.textContaining('به‌زودی'), findsOneWidget);
  });

  testWidgets('optional update dialog can be dismissed later', (tester) async {
    var later = false;
    await tester.pumpWidget(
      MaterialApp(
        home: AppUpdateDialog(
          info: sampleUpdateInfo(),
          onUpdateTap: () {},
          onLaterTap: () => later = true,
        ),
      ),
    );

    expect(find.text('نسخه جدید بولتین آماده است'), findsOneWidget);
    expect(find.text('بعدا'), findsOneWidget);
    await tester.tap(find.text('بعدا'));
    expect(later, isTrue);
  });

  testWidgets('forced update hides the later action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppUpdateDialog(
          info: sampleUpdateInfo(forceUpdate: true),
          onUpdateTap: () {},
        ),
      ),
    );

    expect(find.text('آپدیت اجباری'), findsOneWidget);
    expect(find.text('بعدا'), findsNothing);
    expect(find.text('آپدیت و ادامه'), findsOneWidget);
  });

  testWidgets('feedback dialog validates empty text', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: FeedbackDialog(onSubmit: ({
          required text,
          required category,
          rating,
          email,
        }) async {}),
      ),
    );

    final submit = find.widgetWithText(ElevatedButton, 'ارسال بازخورد');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();
    expect(find.text('لطفاً متن بازخورد را بنویسید'), findsOneWidget);
  });
}
