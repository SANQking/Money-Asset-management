String formatMoney(double value, {int decimalDigits = 0}) {
  final digitsCount = decimalDigits.clamp(0, 2);
  final sign = value < 0 ? '-' : '';
  final fixed = value.abs().toStringAsFixed(digitsCount);
  final parts = fixed.split('.');
  final digits = parts.first;
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }
  final decimals = digitsCount > 0 ? '.${parts.last}' : '';
  return '$sign¥$buffer$decimals';
}

String formatDailyCost(double value, {int decimalDigits = 0}) {
  return '${formatMoney(value, decimalDigits: decimalDigits)}/天';
}
