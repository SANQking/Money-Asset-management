import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/money_format.dart';

void main() {
  test('formats money with configurable display decimals only', () {
    expect(formatMoney(1234.56), '¥1,235');
    expect(formatMoney(1234.56, decimalDigits: 1), '¥1,234.6');
    expect(formatMoney(1234.56, decimalDigits: 2), '¥1,234.56');
    expect(formatMoney(-12.345, decimalDigits: 2), '-¥12.35');
  });

  test('formats daily cost with unit', () {
    expect(formatDailyCost(12.345, decimalDigits: 2), '¥12.35/天');
  });
}
