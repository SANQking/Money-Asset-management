import 'dart:convert';
import 'dart:math';

import '../../core/constants/asset_limits.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/number_utils.dart';
import '../models/app_settings.dart';
import '../models/app_theme_mode.dart';
import '../models/asset.dart';
import '../models/asset_category.dart';
import '../models/asset_event.dart';
import '../models/asset_state.dart';
import '../models/asset_status.dart';

class AssetNormalizer {
  AssetNormalizer({DateTime? now, String Function()? idFactory})
    : _now = now,
      _idFactory = idFactory ?? _defaultId;

  final DateTime? _now;
  final String Function() _idFactory;

  static const defaultCategories = <AssetCategory>[
    AssetCategory(name: '数码', color: '#4299e1'),
    AssetCategory(name: '家电', color: '#ed8936'),
    AssetCategory(name: '家具', color: '#9f7aea'),
    AssetCategory(name: '交通', color: '#48bb78'),
    AssetCategory(name: '收藏', color: '#ecc94b'),
    AssetCategory(name: '证件', color: '#f56565'),
    AssetCategory(name: '其他', color: '#718096'),
  ];

  static const defaultSettings = AppSettings();

  String get today => AssetDateUtils.isoDate(_now ?? DateTime.now());

  Asset normalizeAsset(Map<String, Object?> input) {
    final rawEvents = _asList(input['events'])
        .take(AssetLimits.maxEventsPerAsset)
        .whereType<Map>()
        .map((event) => event.cast<String, Object?>());
    final purchasePrice = jsNumber(input['purchasePrice']);
    final currentInput = input['currentValue'];
    final currentValue = currentInput == null || currentInput.toString().isEmpty
        ? purchasePrice
        : jsNumber(currentInput);

    return Asset(
      id: _limitText(_stringOr(input['id'], _idFactory())),
      name: _limitText(_stringOr(input['name'], '未命名资产')),
      purchasePrice: purchasePrice,
      purchaseDate: _limitText(_stringOr(input['purchaseDate'], today), 40),
      category: _limitText(_stringOr(input['category'], '其他')),
      status: AssetStatus.fromValue(input['status']),
      currentValue: currentValue,
      valuationDate: _limitText(_stringOr(input['valuationDate'], ''), 40),
      warrantyUntil: _limitText(_stringOr(input['warrantyUntil'], ''), 40),
      lastUsedDate: _limitText(_stringOr(input['lastUsedDate'], ''), 40),
      tags: _toTags(
        input['tags'],
      ).take(AssetLimits.maxTags).map((tag) => _limitText(tag, 80)).toList(),
      image: cleanImage(input['image']),
      soldDate: _limitText(_stringOr(input['soldDate'], ''), 40),
      salePrice: input['salePrice']?.toString() == ''
          ? 0
          : jsNumber(input['salePrice']),
      notes: _limitText(
        _stringOr(input['notes'], ''),
        AssetLimits.maxNotesChars,
      ),
      events: rawEvents.map(normalizeEvent).toList(),
    );
  }

  AssetEvent normalizeEvent(Map<String, Object?> input) {
    return AssetEvent(
      id: _limitText(_stringOr(input['id'], _idFactory())),
      type: _limitText(_stringOr(input['type'], '备注'), 80),
      date: _limitText(_stringOr(input['date'], today), 40),
      amount: jsNumber(input['amount']),
      notes: _limitText(
        _stringOr(input['notes'], ''),
        AssetLimits.maxNotesChars,
      ),
    );
  }

  AssetState normalizeState(
    Map<String, Object?> input, {
    bool validateSize = true,
  }) {
    final rawCategories = _asList(input['categories']);
    final categories =
        (rawCategories.isEmpty ? defaultCategories : rawCategories)
            .take(AssetLimits.maxCategories)
            .map(_normalizeCategory)
            .toList();
    final rawAssets = _asList(input['assets']);
    final settings = _normalizeSettings(input['settings']);
    final state = AssetState(
      assets: rawAssets
          .take(AssetLimits.maxAssets)
          .whereType<Map>()
          .map((asset) => normalizeAsset(asset.cast<String, Object?>()))
          .toList(),
      categories: categories,
      settings: settings,
    );
    if (validateSize) validateStateSize(state);
    return state;
  }

  String cleanImage(Object? value) {
    final image = value?.toString().trim() ?? '';
    if (image.isEmpty) return '';
    if (_imageBytes(image) > AssetLimits.maxImageBytes) {
      throw FormatException('image too large');
    }
    final dataPattern = RegExp(
      r'^data:image/(png|jpe?g|webp|gif);base64,[a-z0-9+/=\s]+$',
      caseSensitive: false,
    );
    final httpsPattern = RegExp(r'''^https://[^\s<>"']{1,900}$''');
    if (dataPattern.hasMatch(image) || httpsPattern.hasMatch(image)) {
      return image;
    }
    throw FormatException('unsafe image');
  }

  void validateStateSize(AssetState state) {
    if (jsonEncode(state.toJson()).length > AssetLimits.maxStateChars) {
      throw FormatException('state too large');
    }
  }

  AssetCategory _normalizeCategory(Object? value) {
    if (value is AssetCategory) return value;
    final map = value is Map
        ? value.cast<String, Object?>()
        : <String, Object?>{};
    final color = _stringOr(map['color'], '#718096');
    return AssetCategory(
      name: _limitText(_stringOr(map['name'], '其他')),
      color: RegExp(r'^#[0-9a-f]{6}$', caseSensitive: false).hasMatch(color)
          ? color
          : '#718096',
    );
  }

  AppSettings _normalizeSettings(Object? value) {
    final map = value is Map
        ? value.cast<String, Object?>()
        : <String, Object?>{};
    return AppSettings(
      theme: AppThemeMode.fromValue(
        _stringOr(map['theme'], defaultSettings.theme),
      ).value,
      depreciationRate: jsNumber(
        map.containsKey('depreciationRate')
            ? map['depreciationRate']
            : defaultSettings.depreciationRate,
      ),
      language: _stringOr(map['language'], defaultSettings.language),
      remindersEnabled: _boolOr(
        map['remindersEnabled'],
        defaultSettings.remindersEnabled,
      ),
      reminderHour: _intOr(
        map['reminderHour'],
        defaultSettings.reminderHour,
        min: 0,
        max: 23,
      ),
      reminderMinute: _intOr(
        map['reminderMinute'],
        defaultSettings.reminderMinute,
        min: 0,
        max: 59,
      ),
      warrantyReminderEnabled: _boolOr(
        map['warrantyReminderEnabled'],
        defaultSettings.warrantyReminderEnabled,
      ),
      idleReminderEnabled: _boolOr(
        map['idleReminderEnabled'],
        defaultSettings.idleReminderEnabled,
      ),
      maintenanceReminderEnabled: _boolOr(
        map['maintenanceReminderEnabled'],
        defaultSettings.maintenanceReminderEnabled,
      ),
      warrantyLeadDays: _intOr(
        map['warrantyLeadDays'],
        defaultSettings.warrantyLeadDays,
        min: 1,
        max: 365,
      ),
      idleThresholdDays: _intOr(
        map['idleThresholdDays'],
        defaultSettings.idleThresholdDays,
        min: 1,
        max: 3650,
      ),
      maintenanceCycleDays: _intOr(
        map['maintenanceCycleDays'],
        defaultSettings.maintenanceCycleDays,
        min: 1,
        max: 3650,
      ),
      moneyDecimalDigits: _intOr(
        map['moneyDecimalDigits'],
        defaultSettings.moneyDecimalDigits,
        min: 0,
        max: 2,
      ),
    );
  }

  List<Object?> _asList(Object? value) {
    return value is List ? value.cast<Object?>() : const <Object?>[];
  }

  List<String> _toTags(Object? value) {
    if (value is List) {
      return value
          .where((item) => item != null && item != false && item != 0)
          .map((item) => item.toString())
          .where((tag) => tag.isNotEmpty)
          .toList();
    }
    return (value?.toString() ?? '')
        .split(RegExp(r'[，,\s]+'))
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  String _stringOr(Object? value, String fallback) {
    final text = value?.toString();
    return text == null || text.isEmpty ? fallback : text;
  }

  bool _boolOr(Object? value, bool fallback) {
    if (value is bool) return value;
    return switch (value?.toString().trim().toLowerCase()) {
      'true' || '1' || 'yes' || 'on' => true,
      'false' || '0' || 'no' || 'off' => false,
      _ => fallback,
    };
  }

  int _intOr(
    Object? value,
    int fallback, {
    required int min,
    required int max,
  }) {
    final parsed = value is num
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '');
    if (parsed == null) return fallback;
    return parsed.clamp(min, max);
  }

  String _limitText(String value, [int max = AssetLimits.maxTextChars]) {
    return value.substring(0, min(value.length, max));
  }

  int _imageBytes(String value) {
    final match = RegExp(
      r'^data:image/[a-z0-9.+-]+;base64,(.*)$',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(value);
    if (match == null) return value.length;
    return (match.group(1)!.length * 3 / 4).ceil();
  }

  static String _defaultId() {
    final millis = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final random = Random()
        .nextDouble()
        .toStringAsPrecision(8)
        .replaceAll('.', '');
    return '$millis${random.substring(0, min(6, random.length))}';
  }
}
