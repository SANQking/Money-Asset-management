import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/local/app_database.dart';
import 'package:mobile/data/repositories/asset_repository_impl.dart';
import 'package:mobile/data/repositories/asset_store_service.dart';
import 'package:mobile/data/repositories/backup_repository_impl.dart';
import 'package:mobile/data/repositories/settings_repository_impl.dart';
import 'package:mobile/domain/models/app_settings.dart';
import 'package:mobile/domain/models/asset_category.dart';
import 'package:mobile/domain/models/asset_state.dart';
import 'package:mobile/domain/models/backup_record.dart';
import 'package:mobile/domain/services/asset_normalizer.dart';
import 'package:mobile/domain/services/backup_snapshot_codec.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'asset repository saves, reads and deletes assets with events',
    () async {
      final repository = DriftAssetRepository(database);
      final state = _sampleState();

      await repository.saveAsset(state.assets.first);
      final loaded = await repository.watchAssetsOnce();

      expect(loaded.single.id, 'a-2');
      expect(loaded.single.tags, ['镜头', '旅行']);
      expect(loaded.single.events.map((event) => event.id), ['e-1', 'e-2']);

      await repository.deleteAsset('a-2');
      expect(await repository.watchAssetsOnce(), isEmpty);
      expect(await database.select(database.assetEventRows).get(), isEmpty);
    },
  );

  test(
    'settings, categories and backups repositories replace and load data',
    () async {
      final settingsRepository = DriftSettingsRepository(database);
      final backupRepository = DriftBackupRepository(database);

      await settingsRepository.saveSettings(
        const AppSettings(
          theme: 'minimal',
          depreciationRate: 8,
          language: 'en',
        ),
      );
      await settingsRepository.saveCategories(const [
        AssetCategory(name: 'A', color: '#111111'),
        AssetCategory(name: 'B', color: '#222222'),
      ]);
      await backupRepository.saveBackups(const [
        BackupRecord(
          id: 'b-old',
          at: '2024-01-01T00:00:00.000',
          label: 'old',
          data: '{}',
        ),
        BackupRecord(
          id: 'b-new',
          at: '2025-01-01T00:00:00.000',
          label: 'new',
          data: '{}',
        ),
      ]);

      expect((await settingsRepository.loadSettings()).language, 'en');
      expect((await settingsRepository.loadCategories()).map((c) => c.name), [
        'A',
        'B',
      ]);
      expect((await backupRepository.loadBackups()).map((b) => b.id), [
        'b-new',
        'b-old',
      ]);

      await backupRepository.deleteBackup('b-new');
      expect((await backupRepository.loadBackups()).map((b) => b.id), [
        'b-old',
      ]);
    },
  );

  test('replaceState writes and loadState reads complete state', () async {
    final store = AssetStoreService(database);
    final state = _sampleState();

    await store.replaceState(state);
    final loaded = await store.loadState();

    expect(loaded.assets.map((asset) => asset.id), ['a-1', 'a-2']);
    expect(loaded.assets.last.events.map((event) => event.id), ['e-1', 'e-2']);
    expect(loaded.categories.map((category) => category.name), ['数码', '摄影']);
    expect(loaded.settings.language, 'en');
    expect(loaded.settings.depreciationRate, 12);
  });

  test(
    'clearAssets removes assets and events but keeps settings, categories and backups',
    () async {
      final store = AssetStoreService(
        database,
        clock: () => DateTime.utc(2026, 5, 13),
        idFactory: () => 'backup-id',
      );
      await store.replaceState(_sampleState());

      await store.clearAssets();

      final loaded = await store.loadState();
      expect(loaded.assets, isEmpty);
      expect(await database.select(database.assetEventRows).get(), isEmpty);
      expect(loaded.categories.map((category) => category.name), ['数码', '摄影']);
      expect(loaded.settings.theme, 'blackGold');

      final backups = await store.loadBackups();
      expect(backups, isEmpty);
    },
  );

  test('backupAssets creates explicit snapshot and limits backups', () async {
    var id = 0;
    final store = AssetStoreService(
      database,
      clock: () => DateTime.utc(2026, 5, 13, 9, id),
      idFactory: () => 'backup-${id++}',
    );
    await store.replaceState(_sampleState());

    await store.backupAssets(label: 'Manual asset backup');
    await store.backupAssets(label: 'Manual asset backup');
    await store.backupAssets(label: 'Manual asset backup');
    await store.backupAssets(label: 'Manual asset backup');

    final backups = await store.loadBackups();
    expect(backups.map((backup) => backup.id), [
      'backup-3',
      'backup-2',
      'backup-1',
    ]);
    expect(backups.first.label, 'Manual asset backup');
    expect(jsonDecode(backups.first.data)['version'], 2);
  });

  test(
    'restoreBackup restores snapshot without public json import API',
    () async {
      final store = AssetStoreService(
        database,
        backupSnapshotCodec: BackupSnapshotCodec(
          normalizer: AssetNormalizer(idFactory: () => 'restored-id'),
        ),
      );
      await store.replaceState(_sampleState());
      final backup = BackupRecord(
        id: 'backup-1',
        at: '2026-05-13T00:00:00.000',
        label: 'snapshot',
        data: BackupSnapshotCodec().encode(
          AssetNormalizer().normalizeState({
            'assets': [
              {'id': 'restored', 'name': '恢复资产', 'purchasePrice': 88},
            ],
            'categories': [
              {'name': '恢复分类', 'color': '#111111'},
            ],
            'settings': {'theme': 'pink'},
          }),
        ),
      );

      await store.restoreBackup(backup);

      final loaded = await store.loadState();
      expect(loaded.assets.single.name, '恢复资产');
      expect(loaded.categories.single.name, '恢复分类');
      expect(loaded.settings.theme, 'pink');
    },
  );

  test(
    'restoreBackup keeps current state when snapshot cannot be decoded',
    () async {
      final store = AssetStoreService(database);
      final original = _sampleState();
      await store.replaceState(original);

      expect(
        store.restoreBackup(
          const BackupRecord(
            id: 'bad',
            at: '2026-05-13T00:00:00.000',
            label: 'bad',
            data: '{bad json',
          ),
        ),
        throwsFormatException,
      );

      final loaded = await store.loadState();
      expect(loaded.assets.map((asset) => asset.id), ['a-1', 'a-2']);
      expect(loaded.categories.map((category) => category.name), ['数码', '摄影']);
      expect(loaded.settings.theme, 'blackGold');
    },
  );

  test('deleteBackup removes only the selected backup', () async {
    final backupRepository = DriftBackupRepository(database);
    final store = AssetStoreService(database);
    await backupRepository.saveBackups(const [
      BackupRecord(
        id: 'b-1',
        at: '2026-01-01T00:00:00.000',
        label: 'one',
        data: '{}',
      ),
      BackupRecord(
        id: 'b-2',
        at: '2026-01-02T00:00:00.000',
        label: 'two',
        data: '{}',
      ),
    ]);

    await store.deleteBackup('b-2');
    await store.deleteBackup('missing');

    expect((await store.loadBackups()).map((backup) => backup.id), ['b-1']);
  });
}

AssetState _sampleState() {
  final normalizer = AssetNormalizer(idFactory: () => 'generated');
  return normalizer.normalizeState({
    'assets': [
      {
        'id': 'a-2',
        'name': 'Camera',
        'purchasePrice': 3000,
        'purchaseDate': '2024-05-01',
        'category': '摄影',
        'currentValue': 2400,
        'tags': ['镜头', '旅行'],
        'events': [
          {'id': 'e-2', 'type': '保养', 'date': '2024-08-01', 'amount': 60},
          {'id': 'e-1', 'type': '维修', 'date': '2024-06-01', 'amount': 100},
        ],
      },
      {
        'id': 'a-1',
        'name': 'Laptop',
        'purchasePrice': 8000,
        'purchaseDate': '2023-01-01',
        'category': '数码',
        'status': 'idle',
        'currentValue': 5000,
      },
    ],
    'categories': [
      {'name': '数码', 'color': '#4299e1'},
      {'name': '摄影', 'color': '#123456'},
    ],
    'settings': {'theme': 'dark', 'language': 'en', 'depreciationRate': 12},
  });
}
