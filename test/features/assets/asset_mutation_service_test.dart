import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/models/app_settings.dart';
import 'package:mobile/domain/models/asset_state.dart';
import 'package:mobile/domain/models/asset_status.dart';
import 'package:mobile/domain/models/backup_record.dart';
import 'package:mobile/domain/repositories/asset_state_repository.dart';
import 'package:mobile/domain/services/asset_normalizer.dart';
import 'package:mobile/features/assets/asset_mutation_service.dart';

void main() {
  test('saveAsset adds normalized asset to the top', () async {
    final repository = _MemoryAssetStateRepository(_sampleState());
    final service = _service(repository, ids: ['new-asset']);

    final asset = await service.saveAsset(
      const AssetDraft(
        name: '镜头',
        category: '摄影',
        status: AssetStatus.active,
        purchasePrice: '1200',
        purchaseDate: '2026-05-12',
        currentValue: '',
        valuationDate: '',
        warrantyUntil: '',
        lastUsedDate: '',
        soldDate: '',
        salePrice: '',
        tags: '摄影, 旅行',
        image: 'https://example.com/lens.png',
        notes: '备用镜头',
      ),
    );

    expect(asset.id, 'new-asset');
    expect(asset.currentValue, 1200);
    expect(asset.tags, ['摄影', '旅行']);
    expect(repository.state.assets.map((item) => item.id), [
      'new-asset',
      'camera',
      'laptop',
    ]);
  });

  test('saveAsset edits by id and keeps other assets', () async {
    final repository = _MemoryAssetStateRepository(_sampleState());
    final service = _service(repository);

    final edited = await service.saveAsset(
      const AssetDraft(
        name: '相机 Mark II',
        category: '摄影',
        status: AssetStatus.idle,
        purchasePrice: '3000',
        purchaseDate: '2026-01-01',
        currentValue: '2100',
        valuationDate: '2026-05-13',
        warrantyUntil: '',
        lastUsedDate: '',
        soldDate: '',
        salePrice: '',
        tags: '旅行',
        image: '',
        notes: '已清洁',
      ),
      editingId: 'camera',
    );

    expect(edited.id, 'camera');
    expect(repository.state.assets, hasLength(2));
    expect(repository.state.assets.first.name, '相机 Mark II');
    expect(repository.state.assets.last.id, 'laptop');
  });

  test('deleteAsset removes the target asset', () async {
    final repository = _MemoryAssetStateRepository(_sampleState());
    final service = _service(repository);

    await service.deleteAsset('camera');

    expect(repository.state.assets.map((asset) => asset.id), ['laptop']);
  });

  test('addEvent applies event linkage rules', () async {
    final repository = _MemoryAssetStateRepository(_sampleState());
    final service = _service(
      repository,
      ids: ['event-valuation', 'event-use', 'event-sell', 'event-retire'],
    );

    var updated = await service.addEvent(
      'camera',
      const AssetEventDraft(
        type: '估值',
        date: '2026-05-13',
        amount: '2000',
        notes: '',
      ),
    );
    expect(updated.currentValue, 2000);
    expect(updated.valuationDate, '2026-05-13');

    updated = await service.addEvent(
      'camera',
      const AssetEventDraft(
        type: '使用',
        date: '2026-05-14',
        amount: '',
        notes: '',
      ),
    );
    expect(updated.lastUsedDate, '2026-05-14');

    updated = await service.addEvent(
      'camera',
      const AssetEventDraft(
        type: '出售',
        date: '2026-05-15',
        amount: '1800',
        notes: '',
      ),
    );
    expect(updated.status, AssetStatus.sold);
    expect(updated.soldDate, '2026-05-15');
    expect(updated.salePrice, 1800);
    expect(updated.currentValue, 0);

    final retired = await service.addEvent(
      'laptop',
      const AssetEventDraft(
        type: '报废',
        date: '2026-05-16',
        amount: '',
        notes: '',
      ),
    );
    expect(retired.status, AssetStatus.retired);
    expect(retired.currentValue, 0);
  });

  test(
    'deleteEvent only removes event and does not recalculate asset status',
    () async {
      final repository = _MemoryAssetStateRepository(_sampleState());
      final service = _service(repository);

      await service.deleteEvent('camera', 'event-1');

      final camera = repository.state.assets.firstWhere(
        (asset) => asset.id == 'camera',
      );
      expect(camera.events, isEmpty);
      expect(camera.currentValue, 2400);
      expect(camera.status, AssetStatus.active);
    },
  );

  test('invalid image fails without replacing state', () async {
    final repository = _MemoryAssetStateRepository(_sampleState());
    final service = _service(repository, ids: ['bad']);

    await expectLater(
      service.saveAsset(
        const AssetDraft(
          name: '坏图片',
          category: '其他',
          status: AssetStatus.active,
          purchasePrice: '1',
          purchaseDate: '2026-05-13',
          currentValue: '',
          valuationDate: '',
          warrantyUntil: '',
          lastUsedDate: '',
          soldDate: '',
          salePrice: '',
          tags: '',
          image: 'http://example.com/a.png',
          notes: '',
        ),
      ),
      throwsFormatException,
    );

    expect(repository.replaceCount, 0);
    expect(repository.state.assets.map((asset) => asset.id), [
      'camera',
      'laptop',
    ]);
  });
}

AssetMutationService _service(
  _MemoryAssetStateRepository repository, {
  List<String> ids = const [],
}) {
  var index = 0;
  return AssetMutationService(
    repository: repository,
    normalizer: AssetNormalizer(now: DateTime(2026, 5, 13)),
    clock: () => DateTime(2026, 5, 13),
    idFactory: () => ids.isEmpty ? 'id-${index++}' : ids[index++],
  );
}

AssetState _sampleState() {
  final normalizer = AssetNormalizer(now: DateTime(2026, 5, 13));
  return normalizer.normalizeState({
    'assets': [
      {
        'id': 'camera',
        'name': '相机',
        'category': '摄影',
        'status': 'active',
        'purchasePrice': 3000,
        'purchaseDate': '2026-01-01',
        'currentValue': 2400,
        'events': [
          {'id': 'event-1', 'type': '维修', 'date': '2026-02-01', 'amount': 100},
        ],
      },
      {
        'id': 'laptop',
        'name': '笔记本',
        'category': '数码',
        'status': 'idle',
        'purchasePrice': 8000,
        'purchaseDate': '2024-01-01',
        'currentValue': 5000,
      },
    ],
    'categories': [
      {'name': '摄影', 'color': '#123456'},
      {'name': '数码', 'color': '#4299e1'},
    ],
  });
}

class _MemoryAssetStateRepository implements AssetStateRepository {
  _MemoryAssetStateRepository(this.state);

  AssetState state;
  var replaceCount = 0;

  @override
  Future<AppSettings> loadSettings() async => state.settings;

  @override
  Future<AssetState> loadState() async => state;

  @override
  Future<void> replaceState(AssetState state) async {
    replaceCount += 1;
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
