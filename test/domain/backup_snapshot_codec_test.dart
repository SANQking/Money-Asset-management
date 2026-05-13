import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/models/asset_status.dart';
import 'package:mobile/domain/services/asset_normalizer.dart';
import 'package:mobile/domain/services/backup_snapshot_codec.dart';

void main() {
  late BackupSnapshotCodec codec;

  setUp(() {
    codec = BackupSnapshotCodec(
      normalizer: AssetNormalizer(
        now: DateTime.utc(2026, 5, 13),
        idFactory: () => 'fixed-id',
      ),
    );
  });

  test('decodes v1 asset snapshots and encodes v2 backup snapshots', () {
    final state = codec.decode(
      jsonEncode([
        {'name': '电脑', 'purchasePrice': '1000'},
      ]),
    );
    final encoded =
        jsonDecode(codec.encode(state, exportedAt: DateTime.utc(2026, 5, 13)))
            as Map<String, Object?>;

    expect(state.assets.single.name, '电脑');
    expect(encoded['version'], 2);
    expect(encoded['assets'], isA<List>());
    expect(encoded['categories'], isA<List>());
    expect(encoded['settings'], isA<Map>());
  });

  test('decodes v2 snapshots with settings and categories', () {
    final state = codec.decode(
      jsonEncode({
        'version': 2,
        'assets': [
          {'name': '相机', 'status': '闲置'},
        ],
        'categories': [
          {'name': '摄影', 'color': '#123456'},
        ],
        'settings': {'language': 'en'},
      }),
    );

    expect(state.assets.single.status, AssetStatus.idle);
    expect(state.categories.single.name, '摄影');
    expect(state.settings.language, 'en');
  });

  test('rejects invalid and oversized snapshots', () {
    expect(() => codec.decode(''), throwsFormatException);
    expect(
      () => codec.decode('{"version":3,"assets":[]}'),
      throwsFormatException,
    );
    expect(
      () => codec.decode(
        jsonEncode({'version': 2, 'assets': List.filled(1001, {})}),
      ),
      throwsFormatException,
    );
  });
}
