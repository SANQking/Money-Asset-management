import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/models/asset_status.dart';
import 'package:mobile/domain/services/asset_normalizer.dart';
import 'package:mobile/features/assets/asset_filter_service.dart';

void main() {
  final normalizer = AssetNormalizer(idFactory: () => 'id');
  final state = normalizer.normalizeState({
    'assets': [
      {
        'id': 'camera',
        'name': '相机',
        'category': '摄影',
        'status': 'active',
        'purchasePrice': 3000,
        'purchaseDate': '2026-01-01',
        'currentValue': 2400,
        'warrantyUntil': '2026-06-01',
        'tags': ['旅行', '镜头'],
        'notes': '全画幅',
      },
      {
        'id': 'laptop',
        'name': '笔记本',
        'category': '数码',
        'status': 'idle',
        'purchasePrice': 8000,
        'purchaseDate': '2024-01-01',
        'currentValue': 5000,
        'lastUsedDate': '2024-01-01',
      },
      {
        'id': 'mouse',
        'name': '鼠标',
        'category': '数码',
        'status': 'sold',
        'purchasePrice': 99,
        'purchaseDate': '2025-01-01',
        'currentValue': 0,
      },
    ],
    'categories': [
      {'name': '摄影', 'color': '#123456'},
      {'name': '数码', 'color': '#4299e1'},
    ],
  });
  const service = AssetFilterService(today: '2026-05-13');

  List<String> ids(AssetFilterQuery query) {
    return service
        .filter(state.assets, query, state.categories)
        .map((asset) => asset.id)
        .toList();
  }

  test('search matches name, category, status label, notes and tags', () {
    expect(ids(const AssetFilterQuery(text: '相机')), ['camera']);
    expect(ids(const AssetFilterQuery(text: '摄影')), ['camera']);
    expect(ids(const AssetFilterQuery(text: '闲置')), ['laptop']);
    expect(ids(const AssetFilterQuery(text: '全画幅')), ['camera']);
    expect(ids(const AssetFilterQuery(text: '镜头')), ['camera']);
  });

  test('filters by category and status', () {
    expect(ids(const AssetFilterQuery(category: '数码')), ['laptop', 'mouse']);
    expect(ids(const AssetFilterQuery(status: AssetStatus.sold)), ['mouse']);
  });

  test('clears status filter back to all statuses', () {
    const activeOnly = AssetFilterQuery(status: AssetStatus.active);
    final all = activeOnly.copyWith(clearStatus: true);

    expect(all.status, isNull);
    expect(ids(all), ['camera', 'laptop', 'mouse']);
  });

  test('filters by price and purchase date like web rules', () {
    expect(ids(const AssetFilterQuery(price: AssetPriceFilter.under1000)), [
      'mouse',
    ]);
    expect(
      ids(const AssetFilterQuery(price: AssetPriceFilter.between1000And5000)),
      ['camera'],
    );
    expect(ids(const AssetFilterQuery(price: AssetPriceFilter.over5000)), [
      'laptop',
    ]);
    expect(ids(const AssetFilterQuery(date: AssetDateFilter.withinYear)), [
      'camera',
    ]);
    expect(ids(const AssetFilterQuery(date: AssetDateFilter.overYear)), [
      'laptop',
      'mouse',
    ]);
  });

  test('filters reminder boundaries', () {
    expect(
      ids(const AssetFilterQuery(reminder: AssetReminderFilter.warranty)),
      ['camera'],
    );
    expect(ids(const AssetFilterQuery(reminder: AssetReminderFilter.idle)), [
      'laptop',
    ]);
  });

  test('filters by value status', () {
    expect(ids(const AssetFilterQuery(value: AssetValueFilter.valued)), [
      'camera',
      'laptop',
    ]);
    expect(ids(const AssetFilterQuery(value: AssetValueFilter.unvalued)), [
      'mouse',
    ]);
    expect(
      ids(
        const AssetFilterQuery(
          category: '数码',
          value: AssetValueFilter.valued,
        ),
      ),
      ['laptop'],
    );
  });
}
