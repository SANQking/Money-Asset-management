import '../models/asset.dart';

abstract interface class AssetRepository {
  Future<List<Asset>> watchAssetsOnce();
  Future<void> saveAsset(Asset asset);
  Future<void> deleteAsset(String id);
}
