import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/models/app_settings.dart';
import 'package:mobile/domain/models/asset.dart';
import 'package:mobile/domain/models/backup_record.dart';
import 'package:mobile/domain/models/asset_category.dart';
import 'package:mobile/domain/models/asset_state.dart';
import 'package:mobile/domain/models/asset_status.dart';
import 'package:mobile/domain/repositories/asset_state_repository.dart';
import 'package:mobile/features/settings/category_mutation_service.dart';

void main() {
  test('adds category and edits name while updating matching assets', () async {
    final repository = _Repository(_state());
    final service = CategoryMutationService(repository: repository);

    await service.saveCategory(name: '摄影', color: '#123456');
    expect(
      repository.state.categories.map((category) => category.name),
      contains('摄影'),
    );

    await service.saveCategory(
      originalName: '数码',
      name: '电子',
      color: '#111111',
    );
    expect(repository.state.categories.first.name, '电子');
    expect(repository.state.assets.single.category, '电子');
  });

  test(
    'rejects duplicate, invalid color and deleting category in use',
    () async {
      final repository = _Repository(_state());
      final service = CategoryMutationService(repository: repository);

      expect(
        () => service.saveCategory(name: '数码', color: '#123456'),
        throwsFormatException,
      );
      expect(
        () => service.saveCategory(name: '摄影', color: 'red'),
        throwsFormatException,
      );
      expect(() => service.deleteCategory('数码'), throwsFormatException);

      await service.deleteCategory('其他');
      expect(
        repository.state.categories.map((category) => category.name),
        isNot(contains('其他')),
      );
    },
  );
}

AssetState _state() {
  return AssetState(
    assets: [
      Asset(
        id: 'asset-1',
        name: '相机',
        purchasePrice: 1,
        purchaseDate: '2026-01-01',
        category: '数码',
        status: AssetStatus.active,
        currentValue: 1,
        valuationDate: '',
        warrantyUntil: '',
        lastUsedDate: '',
        tags: const [],
        image: '',
        soldDate: '',
        salePrice: 0,
        notes: '',
        events: const [],
      ),
    ],
    categories: const [
      AssetCategory(name: '数码', color: '#4299e1'),
      AssetCategory(name: '其他', color: '#718096'),
    ],
    settings: const AppSettings(),
  );
}

class _Repository implements AssetStateRepository {
  _Repository(this.state);

  AssetState state;

  @override
  Future<AppSettings> loadSettings() async => state.settings;

  @override
  Future<AssetState> loadState() async => state;

  @override
  Future<void> replaceState(AssetState state) async {
    this.state = state;
  }

  @override
  Future<List<BackupRecord>> loadBackups() async => const [];

  @override
  Future<BackupRecord> backupAssets({
    String label = 'Manual asset backup',
  }) async {
    return BackupRecord(id: 'backup', at: 'now', label: label, data: '{}');
  }

  @override
  Future<void> clearAssets({bool backupCurrent = false}) async {}

  @override
  Future<void> restoreBackup(BackupRecord backup) async {}

  @override
  Future<void> deleteBackup(String id) async {}
}
