import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/models/asset_status.dart';
import 'package:mobile/domain/services/asset_normalizer.dart';

void main() {
  test('normalizes default values and tags like the web app', () {
    final normalizer = AssetNormalizer(
      now: DateTime.utc(2026, 5, 13),
      idFactory: () => 'fixed-id',
    );

    final asset = normalizer.normalizeAsset({
      'purchasePrice': '1200',
      'tags': '电脑， 工作,随身  常用',
      'currentValue': '',
    });

    expect(asset.id, 'fixed-id');
    expect(asset.name, '未命名资产');
    expect(asset.purchaseDate, '2026-05-13');
    expect(asset.category, '其他');
    expect(asset.status, AssetStatus.active);
    expect(asset.purchasePrice, 1200);
    expect(asset.currentValue, 1200);
    expect(asset.tags, ['电脑', '工作', '随身', '常用']);
  });

  test('filters falsey tag values from imported arrays', () {
    final normalizer = AssetNormalizer(idFactory: () => 'fixed-id');

    final asset = normalizer.normalizeAsset({
      'tags': ['keep', null, false, 0, ''],
    });

    expect(asset.tags, ['keep']);
  });

  test('supports Chinese legacy status labels and text limits', () {
    final normalizer = AssetNormalizer(idFactory: () => 'id');
    final asset = normalizer.normalizeAsset({
      'name': 'x' * 1200,
      'status': '已出售',
      'notes': 'n' * 6000,
    });

    expect(asset.name.length, 1000);
    expect(asset.notes.length, 5000);
    expect(asset.status, AssetStatus.sold);
  });

  test('accepts safe image sources and rejects unsafe images', () {
    final normalizer = AssetNormalizer(idFactory: () => 'id');

    expect(
      normalizer.normalizeAsset({'image': 'https://example.com/a.png'}).image,
      'https://example.com/a.png',
    );
    expect(
      normalizer.normalizeAsset({'image': 'data:image/png;base64,AAAA'}).image,
      'data:image/png;base64,AAAA',
    );
    expect(
      () => normalizer.normalizeAsset({'image': 'http://example.com/a.png'}),
      throwsFormatException,
    );
  });

  test('normalizes categories and settings defaults', () {
    final normalizer = AssetNormalizer(idFactory: () => 'id');
    final state = normalizer.normalizeState({
      'assets': [],
      'categories': [
        {'name': '自定义', 'color': 'bad'},
      ],
      'settings': {'language': 'en'},
    });

    expect(state.categories.single.name, '自定义');
    expect(state.categories.single.color, '#718096');
    expect(state.settings.theme, 'blackGold');
    expect(state.settings.depreciationRate, 18);
    expect(state.settings.language, 'en');
  });
}
