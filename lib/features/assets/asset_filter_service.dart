import '../../core/utils/date_utils.dart';
import '../../core/utils/number_utils.dart';
import '../../app/l10n/app_strings.dart';
import '../../domain/models/asset.dart';
import '../../domain/models/asset_category.dart';
import '../../domain/models/asset_status.dart';

enum AssetPriceFilter { all, under1000, between1000And5000, over5000 }

enum AssetDateFilter { all, withinYear, overYear }

enum AssetReminderFilter { all, warranty, idle }

enum AssetStatusFilter { all, active, idle, sold, retired }

enum AssetValueFilter { all, valued, unvalued }

extension AssetStatusFilterX on AssetStatusFilter {
  AssetStatus? get status {
    return switch (this) {
      AssetStatusFilter.all => null,
      AssetStatusFilter.active => AssetStatus.active,
      AssetStatusFilter.idle => AssetStatus.idle,
      AssetStatusFilter.sold => AssetStatus.sold,
      AssetStatusFilter.retired => AssetStatus.retired,
    };
  }

  String get label => status?.zhLabel ?? AppStrings.allStatuses;

  static AssetStatusFilter fromStatus(AssetStatus? status) {
    return switch (status) {
      null => AssetStatusFilter.all,
      AssetStatus.active => AssetStatusFilter.active,
      AssetStatus.idle => AssetStatusFilter.idle,
      AssetStatus.sold => AssetStatusFilter.sold,
      AssetStatus.retired => AssetStatusFilter.retired,
    };
  }
}

class AssetFilterQuery {
  const AssetFilterQuery({
    this.text = '',
    this.category = 'all',
    this.status,
    this.price = AssetPriceFilter.all,
    this.date = AssetDateFilter.all,
    this.reminder = AssetReminderFilter.all,
    this.value = AssetValueFilter.all,
  });

  final String text;
  final String category;
  final AssetStatus? status;
  final AssetPriceFilter price;
  final AssetDateFilter date;
  final AssetReminderFilter reminder;
  final AssetValueFilter value;

  AssetFilterQuery copyWith({
    String? text,
    String? category,
    AssetStatus? status,
    bool clearStatus = false,
    AssetPriceFilter? price,
    AssetDateFilter? date,
    AssetReminderFilter? reminder,
    AssetValueFilter? value,
  }) {
    return AssetFilterQuery(
      text: text ?? this.text,
      category: category ?? this.category,
      status: clearStatus ? null : status ?? this.status,
      price: price ?? this.price,
      date: date ?? this.date,
      reminder: reminder ?? this.reminder,
      value: value ?? this.value,
    );
  }
}

class AssetFilterService {
  const AssetFilterService({this.today});

  final String? today;

  List<Asset> filter(
    List<Asset> assets,
    AssetFilterQuery query,
    List<AssetCategory> categories,
  ) {
    return assets.where((asset) {
      return _matchesText(asset, query.text, categories) &&
          (query.category == 'all' || asset.category == query.category) &&
          (query.status == null || asset.status == query.status) &&
          _matchesPrice(asset, query.price) &&
          _matchesDate(asset, query.date) &&
          _matchesReminder(asset, query.reminder) &&
          _matchesValue(asset, query.value);
    }).toList();
  }

  bool _matchesText(Asset asset, String text, List<AssetCategory> categories) {
    final needle = text.trim().toLowerCase();
    if (needle.isEmpty) return true;
    final category = categories
        .where((item) => item.name == asset.category)
        .map((item) => item.name)
        .join(' ');
    final haystack = [
      asset.name,
      asset.category,
      category,
      asset.status.zhLabel,
      asset.notes,
      ...asset.tags,
    ].join(' ').toLowerCase();
    return haystack.contains(needle);
  }

  bool _matchesPrice(Asset asset, AssetPriceFilter filter) {
    final price = jsNumber(asset.purchasePrice);
    return switch (filter) {
      AssetPriceFilter.all => true,
      AssetPriceFilter.under1000 => price < 1000,
      AssetPriceFilter.between1000And5000 => price >= 1000 && price < 5000,
      AssetPriceFilter.over5000 => price >= 5000,
    };
  }

  bool _matchesDate(Asset asset, AssetDateFilter filter) {
    final age = AssetDateUtils.daysBetween(asset.purchaseDate, today);
    return switch (filter) {
      AssetDateFilter.all => true,
      AssetDateFilter.withinYear => age <= 365,
      AssetDateFilter.overYear => age > 365,
    };
  }

  bool _matchesReminder(Asset asset, AssetReminderFilter filter) {
    final now = today ?? AssetDateUtils.isoDate(DateTime.now());
    return switch (filter) {
      AssetReminderFilter.all => true,
      AssetReminderFilter.warranty =>
        asset.warrantyUntil.isNotEmpty &&
            AssetDateUtils.daysBetween(now, asset.warrantyUntil) <= 60 &&
            AssetDateUtils.isSameOrAfter(asset.warrantyUntil, now),
      AssetReminderFilter.idle =>
        asset.status != AssetStatus.sold &&
            AssetDateUtils.daysBetween(
                  asset.lastUsedDate.isEmpty
                      ? asset.purchaseDate
                      : asset.lastUsedDate,
                  now,
                ) >
                180,
    };
  }

  bool _matchesValue(Asset asset, AssetValueFilter filter) {
    final value = jsNumber(asset.currentValue);
    return switch (filter) {
      AssetValueFilter.all => true,
      AssetValueFilter.valued => value > 0,
      AssetValueFilter.unvalued => value <= 0,
    };
  }
}
