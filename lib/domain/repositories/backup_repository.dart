import '../models/backup_record.dart';

abstract interface class BackupRepository {
  Future<List<BackupRecord>> loadBackups();
  Future<void> saveBackups(List<BackupRecord> backups);
  Future<void> deleteBackup(String id);
}
