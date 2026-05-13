import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/models/asset_status.dart';
import 'package:mobile/domain/services/asset_normalizer.dart';
import 'package:mobile/domain/services/asset_stats_service.dart';

void main() {
  test('matches web app aggregate asset statistics', () {
    final normalizer = AssetNormalizer(idFactory: () => 'id');
    final active = normalizer.normalizeAsset({
      'name': 'Laptop',
      'purchasePrice': 10000,
      'purchaseDate': '2025-01-01',
      'currentValue': 7000,
      'lastUsedDate': '2025-01-01',
      'warrantyUntil': '2026-06-01',
      'events': [
        {'type': '维修', 'amount': 300, 'date': '2025-03-01'},
        {'type': '保养', 'amount': 200, 'date': '2025-04-01'},
      ],
    });
    final sold = normalizer.normalizeAsset({
      'name': 'Phone',
      'purchasePrice': 5000,
      'currentValue': 4500,
      'status': 'sold',
      'salePrice': 4200,
      'events': [
        {'type': '维修', 'amount': 100, 'date': '2025-03-01'},
      ],
    });

    final service = AssetStatsService(today: '2026-05-13');
    final stats = service.stats([active, sold]);

    expect(stats.count, 2);
    expect(stats.original, 15000);
    expect(stats.worth, 7000);
    expect(stats.depreciation, 8000);
    expect(stats.repair, 600);
    expect(stats.sold, -900);
    expect(stats.dailyCost, moreOrLessEquals(5020.1207, epsilon: 0.001));
    expect(stats.idle, 1);
    expect(stats.expiring, 1);
    expect(service.maintenanceCost(active), 500);
    expect(service.realCost(active), 10500);
  });

  test('computes suggested depreciation value', () {
    final normalizer = AssetNormalizer(idFactory: () => 'id');
    final state = normalizer.normalizeState({
      'assets': [
        {'purchasePrice': 10000, 'purchaseDate': '2025-05-13'},
      ],
      'settings': {'depreciationRate': 18},
    });
    final service = AssetStatsService(today: '2026-05-13');

    expect(service.suggestedValue(state.assets.single, state.settings), 8200);
  });

  test('ignores sold and retired current worth', () {
    final normalizer = AssetNormalizer(idFactory: () => 'id');
    final sold = normalizer.normalizeAsset({
      'status': AssetStatus.sold.code,
      'currentValue': 999,
    });
    final retired = normalizer.normalizeAsset({
      'status': AssetStatus.retired.code,
      'currentValue': 999,
    });
    final service = AssetStatsService(today: '2026-05-13');

    expect(service.currentWorth(sold), 0);
    expect(service.currentWorth(retired), 0);
  });

  test('computes daily cost with sold date and safe one-day fallback', () {
    final normalizer = AssetNormalizer(idFactory: () => 'id');
    final sameDay = normalizer.normalizeAsset({
      'purchasePrice': 100,
      'purchaseDate': '2026-05-13',
    });
    final future = normalizer.normalizeAsset({
      'purchasePrice': 200,
      'purchaseDate': '2026-06-01',
    });
    final invalid = normalizer.normalizeAsset({
      'purchasePrice': 300,
      'purchaseDate': 'bad-date',
    });
    final sold = normalizer.normalizeAsset({
      'purchasePrice': 1000,
      'purchaseDate': '2026-05-01',
      'status': 'sold',
      'soldDate': '2026-05-11',
    });
    const service = AssetStatsService(today: '2026-05-13');

    expect(service.dailyCost(sameDay), 100);
    expect(service.dailyCost(future), 200);
    expect(service.dailyCost(invalid), 300);
    expect(service.dailyCost(sold), 100);
    expect(service.usedDays(sameDay), 1);
    expect(service.usedDays(future), 1);
    expect(service.usedDays(invalid), 1);
    expect(service.usedDays(sold), 10);
    expect(service.stats([sameDay, future, invalid, sold]).dailyCost, 700);
  });
}
