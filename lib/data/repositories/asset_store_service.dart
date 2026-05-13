import '../../domain/models/asset_state.dart';
import '../../domain/models/backup_record.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/repositories/asset_state_repository.dart';
import '../../domain/services/backup_snapshot_codec.dart';
import '../../domain/services/backup_service.dart';
import '../local/app_database.dart';
import 'asset_repository_impl.dart';
import 'backup_repository_impl.dart';
import 'settings_repository_impl.dart';

class AssetStoreService implements AssetStateRepository {
  AssetStoreService(
    this.database, {
    BackupSnapshotCodec? backupSnapshotCodec,
    this.backupService = const BackupService(),
    DateTime Function()? clock,
    String Function()? idFactory,
  }) : backupSnapshotCodec = backupSnapshotCodec ?? BackupSnapshotCodec(),
       _clock = clock ?? DateTime.now,
       _idFactory = idFactory ?? _defaultId,
       _assetRepository = DriftAssetRepository(database),
       _settingsRepository = DriftSettingsRepository(database),
       _backupRepository = DriftBackupRepository(database);

  final AppDatabase database;
  final BackupSnapshotCodec backupSnapshotCodec;
  final BackupService backupService;
  final DateTime Function() _clock;
  final String Function() _idFactory;
  final DriftAssetRepository _assetRepository;
  final DriftSettingsRepository _settingsRepository;
  final DriftBackupRepository _backupRepository;

  @override
  Future<AppSettings> loadSettings() {
    return _settingsRepository.loadSettings();
  }

  @override
  Future<AssetState> loadState() async {
    final assets = await _assetRepository.watchAssetsOnce();
    final categories = await _settingsRepository.loadCategories();
    final settings = await _settingsRepository.loadSettings();
    return AssetState(
      assets: assets,
      categories: categories,
      settings: settings,
    );
  }

  @override
  Future<void> replaceState(AssetState state) async {
    await database.transaction(() async {
      await _replaceStateRows(state);
    });
  }

  @override
  Future<List<BackupRecord>> loadBackups() {
    return _backupRepository.loadBackups();
  }

  @override
  Future<BackupRecord> backupAssets({
    String label = 'Manual asset backup',
  }) async {
    final current = await loadState();
    late BackupRecord backup;
    await database.transaction(() async {
      backup = await _appendBackup(current, label);
    });
    return backup;
  }

  @override
  Future<void> clearAssets({bool backupCurrent = false}) async {
    final current = await loadState();
    await database.transaction(() async {
      if (backupCurrent) {
        await _appendBackup(current, 'Before clear assets');
      }
      await _replaceStateRows(
        AssetState(
          assets: const [],
          categories: current.categories,
          settings: current.settings,
        ),
      );
    });
  }

  @override
  Future<void> restoreBackup(BackupRecord backup) async {
    final current = await loadState();
    final next = backupSnapshotCodec.decode(backup.data, currentState: current);
    await database.transaction(() async {
      await _replaceStateRows(next);
    });
  }

  @override
  Future<void> deleteBackup(String id) {
    return _backupRepository.deleteBackup(id);
  }

  Future<BackupRecord> _appendBackup(AssetState state, String label) async {
    final backups = await _backupRepository.loadBackups();
    final backup = BackupRecord(
      id: _idFactory(),
      at: _clock().toIso8601String(),
      label: label,
      data: backupSnapshotCodec.encode(state, exportedAt: _clock()),
    );
    await _backupRepository.saveBackups(
      backupService.limitBackups([backup, ...backups]),
    );
    return backup;
  }

  Future<void> _replaceStateRows(AssetState state) async {
    await _assetRepository.replaceAssetsRows(state.assets);
    await _settingsRepository.saveCategoryRows(state.categories);
    await _settingsRepository.saveSettingRows(state.settings);
  }

  static String _defaultId() {
    return DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  }
}
