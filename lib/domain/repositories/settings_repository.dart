import '../models/app_settings.dart';
import '../models/asset_category.dart';

abstract interface class SettingsRepository {
  Future<AppSettings> loadSettings();
  Future<void> saveSettings(AppSettings settings);
  Future<List<AssetCategory>> loadCategories();
  Future<void> saveCategories(List<AssetCategory> categories);
}
