import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/models/app_settings.dart';
import 'package:mobile/domain/models/asset_state.dart';
import 'package:mobile/domain/models/backup_record.dart';
import 'package:mobile/domain/repositories/asset_state_repository.dart';
import 'package:mobile/domain/services/asset_normalizer.dart';
import 'package:mobile/features/settings/asset_reminder_settings_service.dart';

void main() {
  test('updates only reminder settings', () async {
    final normalizer = AssetNormalizer(idFactory: () => 'asset-id');
    final repository = _Repository(
      normalizer.normalizeState({
        'assets': [
          {'id': 'camera', 'name': '相机'},
        ],
        'categories': [
          {'name': '摄影', 'color': '#123456'},
        ],
        'settings': const AppSettings(theme: 'pink').toJson(),
      }),
    );
    final service = AssetReminderSettingsService(repository: repository);

    final settings = await service.updateSettings(
      remindersEnabled: true,
      reminderHour: 8,
      reminderMinute: 30,
      warrantyReminderEnabled: false,
      idleReminderEnabled: false,
      maintenanceReminderEnabled: true,
      warrantyLeadDays: 45,
      idleThresholdDays: 120,
      maintenanceCycleDays: 90,
    );

    expect(settings.remindersEnabled, isTrue);
    expect(settings.reminderHour, 8);
    expect(settings.reminderMinute, 30);
    expect(settings.warrantyReminderEnabled, isFalse);
    expect(settings.idleReminderEnabled, isFalse);
    expect(settings.maintenanceReminderEnabled, isTrue);
    expect(settings.warrantyLeadDays, 45);
    expect(settings.idleThresholdDays, 120);
    expect(settings.maintenanceCycleDays, 90);
    expect(repository.state.settings.theme, 'pink');
    expect(repository.state.assets.single.id, 'camera');
    expect(repository.state.categories.single.name, '摄影');
  });
}

class _Repository implements AssetStateRepository {
  _Repository(this.state);

  AssetState state;

  @override
  Future<AppSettings> loadSettings() async => state.settings;

  @override
  Future<BackupRecord> backupAssets({
    String label = 'Manual asset backup',
  }) async {
    return BackupRecord(id: 'backup', at: 'now', label: label, data: '{}');
  }

  @override
  Future<void> clearAssets({bool backupCurrent = false}) async {}

  @override
  Future<void> deleteBackup(String id) async {}

  @override
  Future<List<BackupRecord>> loadBackups() async => const [];

  @override
  Future<AssetState> loadState() async => state;

  @override
  Future<void> replaceState(AssetState state) async {
    this.state = state;
  }

  @override
  Future<void> restoreBackup(BackupRecord backup) async {}
}
