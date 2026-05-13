import '../models/asset_state.dart';
import '../models/backup_record.dart';
import '../models/app_settings.dart';

abstract interface class AssetStateRepository {
  Future<AppSettings> loadSettings();
  Future<AssetState> loadState();
  Future<void> replaceState(AssetState state);
  Future<List<BackupRecord>> loadBackups();
  Future<BackupRecord> backupAssets({String label = 'Manual asset backup'});
  Future<void> clearAssets({bool backupCurrent = false});
  Future<void> restoreBackup(BackupRecord backup);
  Future<void> deleteBackup(String id);
}
