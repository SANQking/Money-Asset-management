import 'asset_event.dart';
import 'asset_status.dart';

class Asset {
  const Asset({
    required this.id,
    required this.name,
    required this.purchasePrice,
    required this.purchaseDate,
    required this.category,
    required this.status,
    required this.currentValue,
    required this.valuationDate,
    required this.warrantyUntil,
    required this.lastUsedDate,
    required this.tags,
    required this.image,
    required this.soldDate,
    required this.salePrice,
    required this.notes,
    required this.events,
  });

  final String id;
  final String name;
  final double purchasePrice;
  final String purchaseDate;
  final String category;
  final AssetStatus status;
  final double currentValue;
  final String valuationDate;
  final String warrantyUntil;
  final String lastUsedDate;
  final List<String> tags;
  final String image;
  final String soldDate;
  final double salePrice;
  final String notes;
  final List<AssetEvent> events;

  Asset copyWith({
    String? category,
    AssetStatus? status,
    double? currentValue,
    String? valuationDate,
    String? lastUsedDate,
    String? soldDate,
    double? salePrice,
    List<AssetEvent>? events,
  }) {
    return Asset(
      id: id,
      name: name,
      purchasePrice: purchasePrice,
      purchaseDate: purchaseDate,
      category: category ?? this.category,
      status: status ?? this.status,
      currentValue: currentValue ?? this.currentValue,
      valuationDate: valuationDate ?? this.valuationDate,
      warrantyUntil: warrantyUntil,
      lastUsedDate: lastUsedDate ?? this.lastUsedDate,
      tags: tags,
      image: image,
      soldDate: soldDate ?? this.soldDate,
      salePrice: salePrice ?? this.salePrice,
      notes: notes,
      events: events ?? this.events,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'purchasePrice': purchasePrice,
      'purchaseDate': purchaseDate,
      'category': category,
      'status': status.code,
      'currentValue': currentValue,
      'valuationDate': valuationDate,
      'warrantyUntil': warrantyUntil,
      'lastUsedDate': lastUsedDate,
      'tags': tags,
      'image': image,
      'soldDate': soldDate,
      'salePrice': salePrice,
      'notes': notes,
      'events': events.map((event) => event.toJson()).toList(),
    };
  }
}
