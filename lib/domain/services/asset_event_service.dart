import '../models/asset.dart';
import '../models/asset_event.dart';
import '../models/asset_status.dart';

class AssetEventService {
  const AssetEventService();

  Asset addEvent(Asset asset, AssetEvent event) {
    final events = [...asset.events, event];
    switch (event.type) {
      case '估值':
        return asset.copyWith(
          events: events,
          currentValue: event.amount,
          valuationDate: event.date,
        );
      case '使用':
        return asset.copyWith(events: events, lastUsedDate: event.date);
      case '出售':
        return asset.copyWith(
          events: events,
          status: AssetStatus.sold,
          soldDate: event.date,
          salePrice: event.amount,
          currentValue: 0,
        );
      case '报废':
        return asset.copyWith(
          events: events,
          status: AssetStatus.retired,
          currentValue: 0,
        );
      default:
        return asset.copyWith(events: events);
    }
  }
}
