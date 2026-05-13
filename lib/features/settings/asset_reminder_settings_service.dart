import '../../domain/models/app_settings.dart';
import '../../domain/models/asset_state.dart';
import '../../domain/repositories/asset_state_repository.dart';

class AssetReminderSettingsService {
  const AssetReminderSettingsService({required this.repository});

  final AssetStateRepository repository;

  Future<AppSettings> updateSettings({
    bool? remindersEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? warrantyReminderEnabled,
    bool? idleReminderEnabled,
    bool? maintenanceReminderEnabled,
    int? warrantyLeadDays,
    int? idleThresholdDays,
    int? maintenanceCycleDays,
  }) async {
    final state = await repository.loadState();
    final nextSettings = state.settings.copyWith(
      remindersEnabled: remindersEnabled,
      reminderHour: _clamp(reminderHour, state.settings.reminderHour, 0, 23),
      reminderMinute: _clamp(
        reminderMinute,
        state.settings.reminderMinute,
        0,
        59,
      ),
      warrantyReminderEnabled: warrantyReminderEnabled,
      idleReminderEnabled: idleReminderEnabled,
      maintenanceReminderEnabled: maintenanceReminderEnabled,
      warrantyLeadDays: _clamp(
        warrantyLeadDays,
        state.settings.warrantyLeadDays,
        1,
        365,
      ),
      idleThresholdDays: _clamp(
        idleThresholdDays,
        state.settings.idleThresholdDays,
        1,
        3650,
      ),
      maintenanceCycleDays: _clamp(
        maintenanceCycleDays,
        state.settings.maintenanceCycleDays,
        1,
        3650,
      ),
    );
    await repository.replaceState(
      AssetState(
        version: state.version,
        assets: state.assets,
        categories: state.categories,
        settings: nextSettings,
      ),
    );
    return nextSettings;
  }

  int? _clamp(int? value, int fallback, int min, int max) {
    if (value == null) return null;
    return value.clamp(min, max);
  }
}
