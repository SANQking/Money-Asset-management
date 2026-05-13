import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/theme/app_theme.dart';
import 'package:mobile/domain/models/app_settings.dart';
import 'package:mobile/domain/models/app_theme_mode.dart';
import 'package:mobile/domain/models/asset.dart';
import 'package:mobile/domain/models/asset_category.dart';
import 'package:mobile/domain/models/asset_status.dart';
import 'package:mobile/domain/models/asset_state.dart';
import 'package:mobile/domain/models/backup_record.dart';
import 'package:mobile/domain/repositories/asset_state_repository.dart';
import 'package:mobile/domain/services/asset_normalizer.dart';

void main() {
  test('normalizes legacy and unknown theme values', () {
    expect(AppThemeMode.fromValue('dark'), AppThemeMode.blackGold);
    expect(AppThemeMode.fromValue('plain'), AppThemeMode.minimal);
    expect(AppThemeMode.fromValue('unknown'), AppThemeMode.blackGold);
    expect(AppThemeMode.fromValue(null), AppThemeMode.blackGold);
  });

  test('normalizer stores supported theme contract values', () {
    final normalizer = AssetNormalizer();

    expect(
      normalizer
          .normalizeState({
            'settings': {'theme': 'dark'},
          })
          .settings
          .theme,
      'blackGold',
    );
    expect(
      normalizer
          .normalizeState({
            'settings': {'theme': 'pink'},
          })
          .settings
          .theme,
      'pink',
    );
    expect(
      normalizer
          .normalizeState({
            'settings': {'theme': 'bad'},
          })
          .settings
          .theme,
      'blackGold',
    );
  });

  test('theme controller only changes settings theme', () async {
    final asset = Asset(
      id: 'asset-1',
      name: '相机',
      purchasePrice: 3000,
      purchaseDate: '2026-01-01',
      category: '数码',
      status: AssetStatus.active,
      currentValue: 2400,
      valuationDate: '',
      warrantyUntil: '',
      lastUsedDate: '',
      tags: const [],
      image: '',
      soldDate: '',
      salePrice: 0,
      notes: '',
      events: const [],
    );
    final repository = _MemoryThemeRepository(
      AssetState(
        assets: [asset],
        categories: const [AssetCategory(name: '数码', color: '#4299e1')],
        settings: const AppSettings(
          theme: 'blackGold',
          depreciationRate: 12,
          language: 'zh',
        ),
      ),
    );
    final controller = AppThemeController(repository);

    await controller.updateTheme(AppThemeMode.pink);

    expect(repository.state.settings.theme, 'pink');
    expect(repository.state.settings.depreciationRate, 12);
    expect(repository.state.settings.language, 'zh');
    expect(repository.state.assets.single.id, 'asset-1');
    expect(repository.state.assets.single.name, '相机');
    expect(repository.state.categories.single.name, '数码');
  });

  test('theme controller load only reads settings', () async {
    final repository = _MemoryThemeRepository(
      const AssetState(
        assets: [],
        categories: [],
        settings: AppSettings(theme: 'pink'),
      ),
    );
    final controller = AppThemeController(repository);

    await controller.load();

    expect(controller.mode, AppThemeMode.pink);
    expect(repository.loadStateCount, 0);
  });
}

class _MemoryThemeRepository implements AssetStateRepository {
  _MemoryThemeRepository(this.state);

  AssetState state;
  var loadStateCount = 0;

  @override
  Future<AppSettings> loadSettings() async => state.settings;

  @override
  Future<AssetState> loadState() async {
    loadStateCount += 1;
    return state;
  }

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
