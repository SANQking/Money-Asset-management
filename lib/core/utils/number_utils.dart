double jsNumber(Object? value) {
  if (value == null) return 0;
  if (value is num) return value.isFinite ? value.toDouble() : 0;
  if (value is bool) return value ? 1 : 0;
  final text = value.toString().trim();
  if (text.isEmpty) return 0;
  final parsed = double.tryParse(text);
  return parsed == null || !parsed.isFinite ? 0 : parsed;
}
