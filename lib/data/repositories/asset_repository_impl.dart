import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/models/asset.dart';
import '../../domain/models/asset_event.dart';
import '../../domain/models/asset_status.dart';
import '../../domain/repositories/asset_repository.dart';
import '../local/app_database.dart';

class DriftAssetRepository implements AssetRepository {
  DriftAssetRepository(this.database);

  final AppDatabase database;

  @override
  Future<List<Asset>> watchAssetsOnce() async {
    final rows =
        await (database.select(database.assetRows)..orderBy([
              (row) => OrderingTerm.asc(row.purchaseDate),
              (row) => OrderingTerm.asc(row.id),
            ]))
            .get();
    final events =
        await (database.select(database.assetEventRows)..orderBy([
              (row) => OrderingTerm.asc(row.date),
              (row) => OrderingTerm.asc(row.id),
            ]))
            .get();
    final eventsByAsset = <String, List<AssetEvent>>{};
    for (final event in events) {
      eventsByAsset
          .putIfAbsent(event.assetId, () => [])
          .add(
            AssetEvent(
              id: event.id,
              type: event.type,
              date: event.date,
              amount: event.amount,
              notes: event.notes,
            ),
          );
    }
    return rows
        .map(
          (row) => Asset(
            id: row.id,
            name: row.name,
            purchasePrice: row.purchasePrice,
            purchaseDate: row.purchaseDate,
            category: row.category,
            status: AssetStatus.fromValue(row.status),
            currentValue: row.currentValue,
            valuationDate: row.valuationDate,
            warrantyUntil: row.warrantyUntil,
            lastUsedDate: row.lastUsedDate,
            tags: (jsonDecode(row.tagsJson) as List)
                .map((tag) => tag.toString())
                .toList(),
            image: row.image,
            soldDate: row.soldDate,
            salePrice: row.salePrice,
            notes: row.notes,
            events: eventsByAsset[row.id] ?? const <AssetEvent>[],
          ),
        )
        .toList();
  }

  @override
  Future<void> saveAsset(Asset asset) async {
    await database.transaction(() async {
      await _writeAsset(asset);
    });
  }

  @override
  Future<void> deleteAsset(String id) async {
    await database.transaction(() async {
      await (database.delete(
        database.assetEventRows,
      )..where((row) => row.assetId.equals(id))).go();
      await (database.delete(
        database.assetRows,
      )..where((row) => row.id.equals(id))).go();
    });
  }

  Future<void> replaceAssets(List<Asset> assets) async {
    await database.transaction(() async {
      await replaceAssetsRows(assets);
    });
  }

  Future<void> replaceAssetsRows(List<Asset> assets) async {
    await database.delete(database.assetEventRows).go();
    await database.delete(database.assetRows).go();
    for (final asset in assets) {
      await _writeAsset(asset);
    }
  }

  Future<void> _writeAsset(Asset asset) async {
    await database
        .into(database.assetRows)
        .insertOnConflictUpdate(
          AssetRowsCompanion.insert(
            id: asset.id,
            name: asset.name,
            purchasePrice: asset.purchasePrice,
            purchaseDate: asset.purchaseDate,
            category: asset.category,
            status: asset.status.code,
            currentValue: asset.currentValue,
            valuationDate: Value(asset.valuationDate),
            warrantyUntil: Value(asset.warrantyUntil),
            lastUsedDate: Value(asset.lastUsedDate),
            tagsJson: Value(jsonEncode(asset.tags)),
            image: Value(asset.image),
            soldDate: Value(asset.soldDate),
            salePrice: Value(asset.salePrice),
            notes: Value(asset.notes),
          ),
        );
    await (database.delete(
      database.assetEventRows,
    )..where((row) => row.assetId.equals(asset.id))).go();
    for (final event in asset.events) {
      await database
          .into(database.assetEventRows)
          .insert(
            AssetEventRowsCompanion.insert(
              id: event.id,
              assetId: asset.id,
              type: event.type,
              date: event.date,
              amount: Value(event.amount),
              notes: Value(event.notes),
            ),
          );
    }
  }
}
