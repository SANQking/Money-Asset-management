import 'package:drift/drift.dart';

import '../../domain/models/backup_record.dart';
import '../../domain/repositories/backup_repository.dart';
import '../local/app_database.dart';

class DriftBackupRepository implements BackupRepository {
  DriftBackupRepository(this.database);

  final AppDatabase database;

  @override
  Future<List<BackupRecord>> loadBackups() async {
    final rows =
        await (database.select(database.backupRows)..orderBy([
              (row) => OrderingTerm.desc(row.at),
              (row) => OrderingTerm.asc(row.id),
            ]))
            .get();
    return rows
        .map(
          (row) => BackupRecord(
            id: row.id,
            at: row.at,
            label: row.label,
            data: row.data,
          ),
        )
        .toList();
  }

  @override
  Future<void> saveBackups(List<BackupRecord> backups) async {
    await database.transaction(() async {
      await database.delete(database.backupRows).go();
      for (final backup in backups) {
        await database
            .into(database.backupRows)
            .insert(
              BackupRowsCompanion.insert(
                id: backup.id,
                at: backup.at,
                label: backup.label,
                data: backup.data,
              ),
            );
      }
    });
  }

  @override
  Future<void> deleteBackup(String id) async {
    await (database.delete(
      database.backupRows,
    )..where((row) => row.id.equals(id))).go();
  }
}
