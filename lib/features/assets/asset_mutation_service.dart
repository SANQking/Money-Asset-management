import '../../core/utils/date_utils.dart';
import '../../domain/models/asset.dart';
import '../../domain/models/asset_event.dart';
import '../../domain/models/asset_state.dart';
import '../../domain/models/asset_status.dart';
import '../../domain/repositories/asset_state_repository.dart';
import '../../domain/services/asset_event_service.dart';
import '../../domain/services/asset_normalizer.dart';

class AssetDraft {
  const AssetDraft({
    required this.name,
    required this.category,
    required this.status,
    required this.purchasePrice,
    required this.purchaseDate,
    required this.currentValue,
    required this.valuationDate,
    required this.warrantyUntil,
    required this.lastUsedDate,
    required this.soldDate,
    required this.salePrice,
    required this.tags,
    required this.image,
    required this.notes,
  });

  final String name;
  final String category;
  final AssetStatus status;
  final String purchasePrice;
  final String purchaseDate;
  final String currentValue;
  final String valuationDate;
  final String warrantyUntil;
  final String lastUsedDate;
  final String soldDate;
  final String salePrice;
  final String tags;
  final String image;
  final String notes;

  factory AssetDraft.empty({required String today, String category = '其他'}) {
    return AssetDraft(
      name: '',
      category: category,
      status: AssetStatus.active,
      purchasePrice: '',
      purchaseDate: today,
      currentValue: '',
      valuationDate: '',
      warrantyUntil: '',
      lastUsedDate: '',
      soldDate: '',
      salePrice: '',
      tags: '',
      image: '',
      notes: '',
    );
  }

  factory AssetDraft.fromAsset(Asset asset) {
    return AssetDraft(
      name: asset.name,
      category: asset.category,
      status: asset.status,
      purchasePrice: _numberText(asset.purchasePrice),
      purchaseDate: asset.purchaseDate,
      currentValue: _numberText(asset.currentValue),
      valuationDate: asset.valuationDate,
      warrantyUntil: asset.warrantyUntil,
      lastUsedDate: asset.lastUsedDate,
      soldDate: asset.soldDate,
      salePrice: _numberText(asset.salePrice),
      tags: asset.tags.join(', '),
      image: asset.image,
      notes: asset.notes,
    );
  }

  Map<String, Object?> toInput({
    required String id,
    List<AssetEvent> events = const [],
  }) {
    return {
      'id': id,
      'name': name,
      'category': category,
      'status': status.code,
      'purchasePrice': purchasePrice,
      'purchaseDate': purchaseDate,
      'currentValue': currentValue,
      'valuationDate': valuationDate,
      'warrantyUntil': warrantyUntil,
      'lastUsedDate': lastUsedDate,
      'soldDate': soldDate,
      'salePrice': salePrice,
      'tags': tags,
      'image': image,
      'notes': notes,
      'events': events.map((event) => event.toJson()).toList(),
    };
  }
}

class AssetEventDraft {
  const AssetEventDraft({
    required this.type,
    required this.date,
    required this.amount,
    required this.notes,
  });

  final String type;
  final String date;
  final String amount;
  final String notes;
}

class AssetMutationService {
  AssetMutationService({
    required this.repository,
    AssetNormalizer? normalizer,
    this.eventService = const AssetEventService(),
    DateTime Function()? clock,
    String Function()? idFactory,
  }) : normalizer = normalizer ?? AssetNormalizer(now: clock?.call()),
       _clock = clock ?? DateTime.now,
       _idFactory = idFactory ?? _defaultId;

  final AssetStateRepository repository;
  final AssetNormalizer normalizer;
  final AssetEventService eventService;
  final DateTime Function() _clock;
  final String Function() _idFactory;

  String get today => AssetDateUtils.isoDate(_clock());

  Future<Asset> saveAsset(AssetDraft draft, {String? editingId}) async {
    final state = await repository.loadState();
    final existing = editingId == null
        ? null
        : _findAsset(state.assets, editingId);
    final id = editingId ?? _idFactory();
    final asset = normalizer.normalizeAsset(
      draft.toInput(id: id, events: existing?.events ?? const []),
    );
    final assets = editingId == null
        ? [asset, ...state.assets]
        : state.assets
              .map((item) => item.id == editingId ? asset : item)
              .toList();
    await repository.replaceState(_copyState(state, assets: assets));
    return asset;
  }

  Future<void> deleteAsset(String id) async {
    final state = await repository.loadState();
    await repository.replaceState(
      _copyState(
        state,
        assets: state.assets.where((asset) => asset.id != id).toList(),
      ),
    );
  }

  Future<Asset> addEvent(String assetId, AssetEventDraft draft) async {
    final state = await repository.loadState();
    final event = normalizer.normalizeEvent({
      'id': _idFactory(),
      'type': draft.type,
      'date': draft.date,
      'amount': draft.amount,
      'notes': draft.notes,
    });
    Asset? updated;
    final assets = state.assets.map((asset) {
      if (asset.id != assetId) return asset;
      updated = eventService.addEvent(asset, event);
      return updated!;
    }).toList();
    if (updated == null) throw StateError('Asset not found: $assetId');
    await repository.replaceState(_copyState(state, assets: assets));
    return updated!;
  }

  Future<void> deleteEvent(String assetId, String eventId) async {
    final state = await repository.loadState();
    final assets = state.assets.map((asset) {
      if (asset.id != assetId) return asset;
      return asset.copyWith(
        events: asset.events.where((event) => event.id != eventId).toList(),
      );
    }).toList();
    await repository.replaceState(_copyState(state, assets: assets));
  }

  AssetState _copyState(AssetState state, {required List<Asset> assets}) {
    return AssetState(
      version: state.version,
      assets: assets,
      categories: state.categories,
      settings: state.settings,
    );
  }

  static String _defaultId() {
    return DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  }
}

String _numberText(double value) {
  if (value == value.roundToDouble()) return value.round().toString();
  return value.toString();
}

Asset? _findAsset(List<Asset> assets, String id) {
  for (final asset in assets) {
    if (asset.id == id) return asset;
  }
  return null;
}
