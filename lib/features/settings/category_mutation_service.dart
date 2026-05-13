import '../../core/constants/asset_limits.dart';
import '../../domain/models/asset.dart';
import '../../domain/models/asset_category.dart';
import '../../domain/models/asset_state.dart';
import '../../domain/repositories/asset_state_repository.dart';

class CategoryMutationService {
  const CategoryMutationService({required this.repository});

  final AssetStateRepository repository;

  Future<void> saveCategory({
    String? originalName,
    required String name,
    required String color,
  }) async {
    final state = await repository.loadState();
    final nextName = _cleanName(name);
    final nextColor = _cleanColor(color);
    final duplicate = state.categories.any(
      (category) => category.name == nextName && category.name != originalName,
    );
    if (duplicate) throw const FormatException('duplicate category');

    if (originalName == null &&
        state.categories.length >= AssetLimits.maxCategories) {
      throw const FormatException('too many categories');
    }

    final categories = <AssetCategory>[];
    var replaced = false;
    for (final category in state.categories) {
      if (category.name == originalName) {
        categories.add(AssetCategory(name: nextName, color: nextColor));
        replaced = true;
      } else {
        categories.add(category);
      }
    }
    if (!replaced) {
      categories.add(AssetCategory(name: nextName, color: nextColor));
    }

    final assets = originalName == null || originalName == nextName
        ? state.assets
        : state.assets
              .map(
                (asset) => asset.category == originalName
                    ? asset.copyWith(category: nextName)
                    : asset,
              )
              .toList();

    await repository.replaceState(
      _copyState(state, categories: categories, assets: assets),
    );
  }

  Future<void> deleteCategory(String name) async {
    final state = await repository.loadState();
    if (state.assets.any((asset) => asset.category == name)) {
      throw const FormatException('category in use');
    }
    await repository.replaceState(
      _copyState(
        state,
        categories: state.categories
            .where((category) => category.name != name)
            .toList(),
      ),
    );
  }

  AssetState _copyState(
    AssetState state, {
    required List<AssetCategory> categories,
    List<Asset>? assets,
  }) {
    return AssetState(
      version: state.version,
      assets: assets ?? state.assets,
      categories: categories,
      settings: state.settings,
    );
  }

  String _cleanName(String value) {
    final name = value.trim();
    if (name.isEmpty) throw const FormatException('empty category');
    if (name.length > AssetLimits.maxTextChars) {
      throw const FormatException('category too long');
    }
    return name;
  }

  String _cleanColor(String value) {
    final color = value.trim();
    if (!RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(color)) {
      throw const FormatException('invalid color');
    }
    return color;
  }
}
