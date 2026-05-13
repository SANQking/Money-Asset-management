import 'app_settings.dart';
import 'asset.dart';
import 'asset_category.dart';

class AssetState {
  const AssetState({
    this.version = 2,
    required this.assets,
    required this.categories,
    required this.settings,
  });

  final int version;
  final List<Asset> assets;
  final List<AssetCategory> categories;
  final AppSettings settings;

  Map<String, Object?> toJson({String? exportedAt}) {
    return {
      'version': version,
      // ignore: use_null_aware_elements
      if (exportedAt != null) 'exportedAt': exportedAt,
      'assets': assets.map((asset) => asset.toJson()).toList(),
      'categories': categories.map((category) => category.toJson()).toList(),
      'settings': settings.toJson(),
    };
  }
}
