import '../../core/utils/date_utils.dart';
import '../models/app_settings.dart';
import '../models/asset.dart';
import '../models/asset_reminder.dart';
import '../models/asset_status.dart';

class AssetReminderService {
  const AssetReminderService({this.today});

  final String? today;

  List<AssetReminder> remindersFor(List<Asset> assets, AppSettings settings) {
    final todayValue = today ?? AssetDateUtils.isoDate(DateTime.now());
    final reminders = <AssetReminder>[];
    for (final asset in assets) {
      if (asset.status == AssetStatus.sold ||
          asset.status == AssetStatus.retired) {
        continue;
      }
      final warranty = settings.warrantyReminderEnabled
          ? _warrantyReminder(asset, settings, todayValue)
          : null;
      final idle = settings.idleReminderEnabled
          ? _idleReminder(asset, settings, todayValue)
          : null;
      final maintenance = settings.maintenanceReminderEnabled
          ? _maintenanceReminder(asset, settings, todayValue)
          : null;
      if (warranty != null) reminders.add(warranty);
      if (idle != null) reminders.add(idle);
      if (maintenance != null) reminders.add(maintenance);
    }
    reminders.sort((a, b) {
      final typeCompare = a.type.index.compareTo(b.type.index);
      if (typeCompare != 0) return typeCompare;
      return a.days.compareTo(b.days);
    });
    return reminders;
  }

  Map<AssetReminderType, List<AssetReminder>> groupByType(
    List<AssetReminder> reminders,
  ) {
    return {
      for (final type in AssetReminderType.values)
        type: reminders.where((reminder) => reminder.type == type).toList(),
    };
  }

  AssetReminder? _warrantyReminder(
    Asset asset,
    AppSettings settings,
    String todayValue,
  ) {
    if (asset.warrantyUntil.trim().isEmpty ||
        !AssetDateUtils.isSameOrAfter(asset.warrantyUntil, todayValue)) {
      return null;
    }
    final days = AssetDateUtils.daysBetween(todayValue, asset.warrantyUntil);
    if (days > settings.warrantyLeadDays) return null;
    return AssetReminder(
      type: AssetReminderType.warranty,
      asset: asset,
      anchorDate: asset.warrantyUntil,
      dueDate: asset.warrantyUntil,
      days: days,
    );
  }

  AssetReminder? _idleReminder(
    Asset asset,
    AppSettings settings,
    String todayValue,
  ) {
    final anchor = asset.lastUsedDate.trim().isEmpty
        ? asset.purchaseDate
        : asset.lastUsedDate;
    final days = AssetDateUtils.daysBetween(anchor, todayValue);
    if (days <= settings.idleThresholdDays) return null;
    return AssetReminder(
      type: AssetReminderType.idle,
      asset: asset,
      anchorDate: anchor,
      dueDate: todayValue,
      days: days,
    );
  }

  AssetReminder? _maintenanceReminder(
    Asset asset,
    AppSettings settings,
    String todayValue,
  ) {
    final anchor = _latestMaintenanceAnchor(asset);
    final dueDate = _addDays(anchor, settings.maintenanceCycleDays);
    if (dueDate == null) return null;
    final overdueDays = AssetDateUtils.daysBetween(dueDate, todayValue);
    if (overdueDays <= 0 &&
        !AssetDateUtils.isSameOrAfter(todayValue, dueDate)) {
      return null;
    }
    return AssetReminder(
      type: AssetReminderType.maintenance,
      asset: asset,
      anchorDate: anchor,
      dueDate: dueDate,
      days: overdueDays,
    );
  }

  String _latestMaintenanceAnchor(Asset asset) {
    final candidates = [
      asset.purchaseDate,
      for (final event in asset.events)
        if (event.type == '保养' || event.type == '维修' || event.type == '购买')
          event.date,
    ];
    candidates.sort((a, b) {
      if (AssetDateUtils.isSameOrAfter(a, b)) return 1;
      return -1;
    });
    return candidates.last;
  }

  String? _addDays(String date, int days) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(date);
    if (match == null) return null;
    final year = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final day = int.tryParse(match.group(3)!);
    if (year == null || month == null || day == null) return null;
    final parsed = DateTime.utc(year, month, day);
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return null;
    }
    return AssetDateUtils.isoDate(parsed.add(Duration(days: days)));
  }
}
