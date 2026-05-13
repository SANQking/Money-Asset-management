import 'dart:convert';

import '../../core/constants/asset_limits.dart';
import '../models/asset_state.dart';
import 'asset_normalizer.dart';

class BackupSnapshotCodec {
  BackupSnapshotCodec({AssetNormalizer? normalizer})
    : normalizer = normalizer ?? AssetNormalizer();

  final AssetNormalizer normalizer;

  String encode(AssetState state, {DateTime? exportedAt}) {
    return const JsonEncoder.withIndent('  ').convert(
      state.toJson(
        exportedAt: (exportedAt ?? DateTime.now()).toIso8601String(),
      ),
    );
  }

  AssetState decode(String text, {AssetState? currentState}) {
    if (text.trim().isEmpty) throw const FormatException('backup empty');
    if (text.length > AssetLimits.maxImportChars) {
      throw const FormatException('backup too large');
    }
    final decoded = jsonDecode(text);
    final Map<String, Object?> data;
    if (decoded is List) {
      data = {'version': 1, 'assets': decoded};
    } else if (decoded is Map) {
      data = decoded.cast<String, Object?>();
    } else {
      throw const FormatException('backup no assets');
    }

    final version = (data['version'] as num?)?.toInt() ?? 0;
    if (version != 1 && version != 2) {
      throw const FormatException('unsupported backup version');
    }

    final assets = data['assets'];
    if (assets is! List) throw const FormatException('backup no assets');
    if (assets.length > AssetLimits.maxAssets) {
      throw const FormatException('too many assets');
    }

    final categories = data['categories'];
    if (categories is List && categories.length > AssetLimits.maxCategories) {
      throw const FormatException('too many categories');
    }

    return normalizer.normalizeState({
      'version': 2,
      'assets': assets,
      'categories': categories ?? currentState?.categories,
      'settings': {
        ...?currentState?.settings.toJson(),
        if (data['settings'] is Map)
          ...(data['settings'] as Map).cast<String, Object?>(),
      },
    });
  }
}
