const List<String> _persianDigits = [
  '۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹',
];

String toPersianDigits(Object input) {
  final text = input.toString();
  final buffer = StringBuffer();
  for (final rune in text.runes) {
    final char = String.fromCharCode(rune);
    final digit = int.tryParse(char);
    buffer.write(digit != null ? _persianDigits[digit] : char);
  }
  return buffer.toString();
}

String _trimTrailingZeros(String value) {
  if (!value.contains('.')) return value;
  var trimmed = value.replaceFirst(RegExp(r'0+$'), '');
  trimmed = trimmed.replaceFirst(RegExp(r'\.$'), '');
  return trimmed;
}

String _groupThousands(String integerPart) {
  final buffer = StringBuffer();
  final length = integerPart.length;
  for (var i = 0; i < length; i++) {
    if (i > 0 && (length - i) % 3 == 0) buffer.write(',');
    buffer.write(integerPart[i]);
  }
  return buffer.toString();
}

String formatNumber(num value) {
  final isNegative = value < 0;
  final absValue = value.abs();
  final decimalDigits = absValue >= 1 ? 2 : 6;
  final fixed = _trimTrailingZeros(absValue.toStringAsFixed(decimalDigits));

  final parts = fixed.split('.');
  final grouped = _groupThousands(parts[0]);
  final result = parts.length > 1 ? '$grouped.${parts[1]}' : grouped;

  return isNegative ? '-$result' : result;
}

String formatPersianNumber(num value) => toPersianDigits(formatNumber(value));

String formatRelativePersian(DateTime dateTime) {
  final local = dateTime.isUtc ? dateTime.toLocal() : dateTime;
  final diff = DateTime.now().difference(local);

  if (diff.isNegative || diff.inSeconds < 45) {
    return 'همین الان';
  }
  if (diff.inMinutes < 60) {
    return '${toPersianDigits(diff.inMinutes)} دقیقه پیش';
  }
  if (diff.inHours < 24) {
    return '${toPersianDigits(diff.inHours)} ساعت پیش';
  }
  if (diff.inDays < 7) {
    return '${toPersianDigits(diff.inDays)} روز پیش';
  }
  return '${toPersianDigits(local.year)}/${toPersianDigits(local.month.toString().padLeft(2, '0'))}/${toPersianDigits(local.day.toString().padLeft(2, '0'))}';
}
