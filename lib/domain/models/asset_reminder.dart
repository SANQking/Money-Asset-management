import 'asset.dart';

enum AssetReminderType {
  warranty('保修将到期'),
  idle('长期闲置'),
  maintenance('保养提醒');

  const AssetReminderType(this.label);

  final String label;
}

class AssetReminder {
  const AssetReminder({
    required this.type,
    required this.asset,
    required this.anchorDate,
    required this.dueDate,
    required this.days,
  });

  final AssetReminderType type;
  final Asset asset;
  final String anchorDate;
  final String dueDate;
  final int days;
}
