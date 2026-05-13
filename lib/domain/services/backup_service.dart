import 'dart:convert';

import '../../core/constants/asset_limits.dart';
import '../models/backup_record.dart';

class BackupService {
  const BackupService();

  List<BackupRecord> limitBackups(List<BackupRecord> backups) {
    final out = <BackupRecord>[];
    var size = 0;
    for (final backup in backups.take(AssetLimits.maxBackups)) {
      final data = jsonEncode(backup.toJson());
      final next = size + data.length;
      if (next > AssetLimits.maxBackupTotalChars) continue;
      out.add(backup);
      size = next;
    }
    return out;
  }
}
