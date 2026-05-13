import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/models/asset_event.dart';
import 'package:mobile/domain/models/asset_status.dart';
import 'package:mobile/domain/services/asset_event_service.dart';
import 'package:mobile/domain/services/asset_normalizer.dart';

void main() {
  final normalizer = AssetNormalizer(idFactory: () => 'id');
  const service = AssetEventService();

  AssetEvent event(String type, {double amount = 0}) {
    return AssetEvent(
      id: type,
      type: type,
      date: '2026-05-13',
      amount: amount,
      notes: '',
    );
  }

  test('valuation event updates value and valuation date', () {
    final asset = normalizer.normalizeAsset({'currentValue': 100});
    final updated = service.addEvent(asset, event('估值', amount: 88));

    expect(updated.currentValue, 88);
    expect(updated.valuationDate, '2026-05-13');
    expect(updated.events.single.type, '估值');
  });

  test('use event updates last used date', () {
    final updated = service.addEvent(
      normalizer.normalizeAsset({}),
      event('使用'),
    );

    expect(updated.lastUsedDate, '2026-05-13');
  });

  test('sell event updates sold fields', () {
    final updated = service.addEvent(
      normalizer.normalizeAsset({}),
      event('出售', amount: 321),
    );

    expect(updated.status, AssetStatus.sold);
    expect(updated.soldDate, '2026-05-13');
    expect(updated.salePrice, 321);
    expect(updated.currentValue, 0);
  });

  test('retire event updates status and value', () {
    final updated = service.addEvent(
      normalizer.normalizeAsset({'currentValue': 100}),
      event('报废'),
    );

    expect(updated.status, AssetStatus.retired);
    expect(updated.currentValue, 0);
  });
}
