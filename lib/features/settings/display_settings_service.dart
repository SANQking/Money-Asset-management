import '../../domain/models/app_settings.dart';
import '../../domain/models/asset_state.dart';
import '../../domain/repositories/asset_state_repository.dart';

class DisplaySettingsService {
  const DisplaySettingsService({required this.repository});

  final AssetStateRepository repository;

  Future<AppSettings> updateMoneyDecimalDigits(int digits) async {
    final state = await repository.loadState();
    final nextSettings = state.settings.copyWith(
      moneyDecimalDigits: digits.clamp(0, 2),
    );
    await repository.replaceState(
      AssetState(
        version: state.version,
        assets: state.assets,
        categories: state.categories,
        settings: nextSettings,
      ),
    );
    return nextSettings;
  }
}
