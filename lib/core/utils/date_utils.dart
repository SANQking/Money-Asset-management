class AssetDateUtils {
  const AssetDateUtils._();

  static String isoDate(DateTime value) {
    final utc = DateTime.utc(value.year, value.month, value.day);
    return utc.toIso8601String().substring(0, 10);
  }

  static int daysBetween(String? start, [String? end]) {
    final startDate = _parseDate(start);
    final endDate = _parseDate(end) ?? _dateOnly(DateTime.now());
    if (startDate == null) return 0;
    final millis = endDate.difference(startDate).inMilliseconds;
    final days = (millis / Duration.millisecondsPerDay).ceil();
    return days < 0 ? 0 : days;
  }

  static bool isSameOrAfter(String value, String floor) {
    final date = _parseDate(value);
    final floorDate = _parseDate(floor);
    if (date == null || floorDate == null) return false;
    return !date.isBefore(floorDate);
  }

  static DateTime? _parseDate(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null;
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(raw);
    if (match == null) return null;
    final year = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final day = int.tryParse(match.group(3)!);
    if (year == null || month == null || day == null) return null;
    final parsed = DateTime.utc(year, month, day);
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return null;
    }
    return parsed;
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime.utc(value.year, value.month, value.day);
  }
}
