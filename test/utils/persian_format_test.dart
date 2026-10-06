import 'package:boltin/utils/persian_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toPersianDigits', () {
    test('converts western digits and leaves other characters', () {
      expect(toPersianDigits('16:30'), '۱۶:۳۰');
      expect(toPersianDigits(190300), '۱۹۰۳۰۰');
    });
  });

  group('formatNumber', () {
    test('groups thousands and drops trailing zeros', () {
      expect(formatNumber(187500.0), '187,500');
      expect(formatNumber(65.80), '65.8');
      expect(formatNumber(0.0702), '0.0702');
      expect(formatNumber(-1200), '-1,200');
    });
  });

  group('formatPersianNumber', () {
    test('applies grouping and Persian digits', () {
      expect(formatPersianNumber(190300), '۱۹۰,۳۰۰');
      expect(formatPersianNumber(222400.0), '۲۲۲,۴۰۰');
    });
  });

  group('formatRelativePersian', () {
    test('returns just-now for very recent timestamps', () {
      expect(formatRelativePersian(DateTime.now()), 'همین الان');
    });

    test('returns minutes and hours in Persian', () {
      final fourMinutesAgo =
          DateTime.now().subtract(const Duration(minutes: 4));
      expect(formatRelativePersian(fourMinutesAgo), '۴ دقیقه پیش');

      final threeHoursAgo = DateTime.now().subtract(const Duration(hours: 3));
      expect(formatRelativePersian(threeHoursAgo), '۳ ساعت پیش');
    });
  });
}
