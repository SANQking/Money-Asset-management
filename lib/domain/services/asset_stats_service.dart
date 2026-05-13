import 'dart:math';

import '../../core/utils/date_utils.dart';
import '../../core/utils/number_utils.dart';
import '../models/app_settings.dart';
import '../models/asset.dart';
import '../models/asset_status.dart';

class AssetStats {
  const AssetStats({
    required this.count,
    required this.original,
    required this.worth,
    required this.depreciation,
    required this.repair,
    required this.sold,
    required this.dailyCost,
    required this.idle,
    required this.expiring,
  });

  final int count;
  final double original;
  final double worth;
  final double depreciation;
  final double repair;
  final double sold;
  final double dailyCost;
  final int idle;
  final int expiring;
}

class AssetStatsService {
  const AssetStatsService({this.today});

  final String? today;

  double maintenanceCost(Asset asset) {
    return asset.events
        .where((event) => event.type == '维修' || event.type == '保养')
        .fold<double>(0, (sum, event) => sum + jsNumber(event.amount));
  }

  double realCost(Asset asset) {
    return jsNumber(asset.purchasePrice) +
        maintenanceCost(asset) -
        jsNumber(asset.salePrice);
  }

  double currentWorth(Asset asset) {
    return asset.status == AssetStatus.sold ||
            asset.status == AssetStatus.retired
        ? 0
        : jsNumber(asset.currentValue);
  }

  double depreciation(Asset asset) {
    return max(0, jsNumber(asset.purchasePrice) - currentWorth(asset));
  }

  double dailyCost(Asset asset) {
    return jsNumber(asset.purchasePrice) / usedDays(asset);
  }

  int usedDays(Asset asset) {
    final todayValue = today ?? AssetDateUtils.isoDate(DateTime.now());
    final endDate =
        asset.status == AssetStatus.sold && asset.soldDate.trim().isNotEmpty
        ? asset.soldDate
        : todayValue;
    return max(1, AssetDateUtils.daysBetween(asset.purchaseDate, endDate));
  }

  int suggestedValue(Asset asset, AppSettings settings) {
    final age = AssetDateUtils.daysBetween(asset.purchaseDate, today) / 365;
    final rate = jsNumber(settings.depreciationRate) / 100;
    return max(0, (jsNumber(asset.purchasePrice) * pow(1 - rate, age)).round());
  }

  AssetStats stats(List<Asset> assets) {
    final todayValue = today ?? AssetDateUtils.isoDate(DateTime.now());
    final active = assets.where(
      (asset) =>
          asset.status != AssetStatus.sold &&
          asset.status != AssetStatus.retired,
    );
    return AssetStats(
      count: assets.length,
      original: assets.fold(
        0,
        (sum, asset) => sum + jsNumber(asset.purchasePrice),
      ),
      worth: assets.fold(0, (sum, asset) => sum + currentWorth(asset)),
      depreciation: assets.fold(0, (sum, asset) => sum + depreciation(asset)),
      repair: assets.fold(0, (sum, asset) => sum + maintenanceCost(asset)),
      sold: assets
          .where((asset) => asset.status == AssetStatus.sold)
          .fold(
            0,
            (sum, asset) =>
                sum +
                jsNumber(asset.salePrice) -
                jsNumber(asset.purchasePrice) -
                maintenanceCost(asset),
          ),
      dailyCost: assets.fold(0, (sum, asset) => sum + dailyCost(asset)),
      idle: active
          .where(
            (asset) =>
                AssetDateUtils.daysBetween(
                  asset.lastUsedDate.isEmpty
                      ? asset.purchaseDate
                      : asset.lastUsedDate,
                  todayValue,
                ) >
                180,
          )
          .length,
      expiring: active
          .where(
            (asset) =>
                asset.warrantyUntil.isNotEmpty &&
                AssetDateUtils.daysBetween(todayValue, asset.warrantyUntil) <=
                    60 &&
                AssetDateUtils.isSameOrAfter(asset.warrantyUntil, todayValue),
          )
          .length,
    );
  }
}
