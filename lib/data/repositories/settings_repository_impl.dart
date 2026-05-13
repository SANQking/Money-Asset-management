import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/models/app_settings.dart';
import '../../domain/models/app_theme_mode.dart';
import '../../domain/models/asset_category.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/services/asset_normalizer.dart';
import '../local/app_database.dart';

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this.database);

  final AppDatabase database;

  @override
  Future<AppSettings> loadSettings() async {
    final rows = await database.select(database.settingRows).get();
    final map = {for (final row in rows) row.key: row.value};
    return AppSettings(
      theme: AppThemeMode.fromValue(
        map['theme'] ?? AssetNormalizer.defaultSettings.theme,
      ).value,
      depreciationRate:
          double.tryParse(map['depreciationRate'] ?? '') ??
          AssetNormalizer.defaultSettings.depreciationRate,
      language: map['language'] ?? AssetNormalizer.defaultSettings.language,
      remindersEnabled: _parseBool(
        map['remindersEnabled'],
        AssetNormalizer.defaultSettings.remindersEnabled,
      ),
      reminderHour: _parseInt(
        map['reminderHour'],
        AssetNormalizer.defaultSettings.reminderHour,
        min: 0,
        max: 23,
      ),
      reminderMinute: _parseInt(
        map['reminderMinute'],
        AssetNormalizer.defaultSettings.reminderMinute,
        min: 0,
        max: 59,
      ),
      warrantyReminderEnabled: _parseBool(
        map['warrantyReminderEnabled'],
        AssetNormalizer.defaultSettings.warrantyReminderEnabled,
      ),
      idleReminderEnabled: _parseBool(
        map['idleReminderEnabled'],
        AssetNormalizer.defaultSettings.idleReminderEnabled,
      ),
      maintenanceReminderEnabled: _parseBool(
        map['maintenanceReminderEnabled'],
        AssetNormalizer.defaultSettings.maintenanceReminderEnabled,
      ),
      warrantyLeadDays: _parseInt(
        map['warrantyLeadDays'],
        AssetNormalizer.defaultSettings.warrantyLeadDays,
        min: 1,
        max: 365,
      ),
      idleThresholdDays: _parseInt(
        map['idleThresholdDays'],
        AssetNormalizer.defaultSettings.idleThresholdDays,
        min: 1,
        max: 3650,
      ),
      maintenanceCycleDays: _parseInt(
        map['maintenanceCycleDays'],
        AssetNormalizer.defaultSettings.maintenanceCycleDays,
        min: 1,
        max: 3650,
      ),
      moneyDecimalDigits: _parseInt(
        map['moneyDecimalDigits'],
        AssetNormalizer.defaultSettings.moneyDecimalDigits,
        min: 0,
        max: 2,
      ),
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await saveSettingRows(settings);
  }

  @override
  Future<List<AssetCategory>> loadCategories() async {
    final rows = await (database.select(
      database.categoryRows,
    )..orderBy([(row) => OrderingTerm.asc(row.sortOrder)])).get();
    if (rows.isEmpty) return AssetNormalizer.defaultCategories;
    return rows
        .map((row) => AssetCategory(name: row.name, color: row.color))
        .toList();
  }

  @override
  Future<void> saveCategories(List<AssetCategory> categories) async {
    await database.transaction(() async {
      await saveCategoryRows(categories);
    });
  }

  Future<void> saveCategoryRows(List<AssetCategory> categories) async {
    await database.delete(database.categoryRows).go();
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];
      await database
          .into(database.categoryRows)
          .insert(
            CategoryRowsCompanion.insert(
              name: category.name,
              color: category.color,
              sortOrder: Value(i),
            ),
          );
    }
  }

  Future<void> saveSettingRows(AppSettings settings) async {
    final values = settings.toJson().map(
      (key, value) => MapEntry(key, value.toString()),
    );
    for (final entry in values.entries) {
      await database
          .into(database.settingRows)
          .insertOnConflictUpdate(
            SettingRowsCompanion.insert(key: entry.key, value: entry.value),
          );
    }
  }

  String encodeCategories(List<AssetCategory> categories) {
    return jsonEncode(categories.map((category) => category.toJson()).toList());
  }

  bool _parseBool(String? value, bool fallback) {
    if (value == null) return fallback;
    return switch (value.trim().toLowerCase()) {
      'true' || '1' || 'yes' || 'on' => true,
      'false' || '0' || 'no' || 'off' => false,
      _ => fallback,
    };
  }

  int _parseInt(
    String? value,
    int fallback, {
    required int min,
    required int max,
  }) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null) return fallback;
    return parsed.clamp(min, max);
  }
}
