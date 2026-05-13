import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/models/app_settings.dart';
import 'package:mobile/domain/models/asset_state.dart';
import 'package:mobile/domain/models/backup_record.dart';
import 'package:mobile/domain/repositories/asset_state_repository.dart';
import 'package:mobile/domain/services/asset_normalizer.dart';
import 'package:mobile/domain/services/backup_service.dart';
import 'package:mobile/domain/services/backup_snapshot_codec.dart';
import 'package:mobile/features/migration/data_migration_page.dart';

void main() {
  testWidgets('data management removes json and csv import export UI', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(DataMigrationPage(repository: _Repository(_sampleState()))),
    );
    await tester.pumpAndSettle();

    expect(find.text('本机数据'), findsOneWidget);
    expect(find.text('备份'), findsOneWidget);
    expect(find.textContaining('JSON'), findsNothing);
    expect(find.textContaining('CSV'), findsNothing);
    expect(find.text('导入文本'), findsNothing);
    expect(find.text('选择文件'), findsNothing);
    expect(find.text('生成导出文本'), findsNothing);
    expect(find.text('导出文件'), findsNothing);
  });

  testWidgets('clear assets can be canceled or confirmed', (tester) async {
    final repository = _Repository(_sampleState());
    var changed = 0;

    await tester.pumpWidget(
      _wrap(
        DataMigrationPage(
          repository: repository,
          onDataChanged: () => changed += 1,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('clear-assets-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('取消').last);
    await tester.pumpAndSettle();

    expect(repository.state.assets, isNotEmpty);
    expect(repository.backups, isEmpty);
    expect(changed, 0);

    await tester.tap(find.byKey(const Key('clear-assets-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-clear-assets-button')));
    await tester.pumpAndSettle();

    expect(repository.state.assets, isEmpty);
    expect(repository.state.categories.map((category) => category.name), [
      '摄影',
      '数码',
    ]);
    expect(repository.state.settings.theme, 'blackGold');
    expect(repository.backups, isEmpty);
    expect(changed, 1);
    expect(find.text('资产数据已清空'), findsOneWidget);
  });

  testWidgets('manual backup creates backup and refreshes list', (
    tester,
  ) async {
    final repository = _Repository(_sampleState());

    await tester.pumpWidget(_wrap(DataMigrationPage(repository: repository)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('backup-assets-button')), findsOneWidget);
    await tester.tap(find.byKey(const Key('backup-assets-button')));
    await tester.pumpAndSettle();

    expect(repository.backups.single.label, 'Manual asset backup');
    expect(find.text('资产数据已备份'), findsOneWidget);
    expect(find.text('Manual asset backup'), findsOneWidget);
  });

  testWidgets('views, restores and deletes backup after confirmation', (
    tester,
  ) async {
    final repository = _Repository(_sampleState());
    repository.backups = [
      BackupRecord(
        id: 'backup-1',
        at: '2026-05-13T09:00:00.000',
        label: 'Before clear assets',
        data: BackupSnapshotCodec().encode(
          AssetNormalizer().normalizeState({
            'assets': [
              {'id': 'restored', 'name': '恢复资产', 'purchasePrice': 88},
            ],
          }),
          exportedAt: DateTime(2026, 5, 13),
        ),
      ),
      const BackupRecord(
        id: 'backup-2',
        at: '2026-05-12T09:00:00.000',
        label: 'Old backup',
        data: '{}',
      ),
    ];

    await tester.pumpWidget(_wrap(DataMigrationPage(repository: repository)));
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('Before clear assets'));
    await tester.tap(find.byKey(const Key('view-backup-backup-1')));
    await tester.pumpAndSettle();
    expect(find.textContaining('恢复资产'), findsOneWidget);
    await tester.tap(find.byKey(const Key('close-backup-view-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('restore-backup-backup-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-restore-backup-button')));
    await tester.pumpAndSettle();

    expect(repository.state.assets.single.name, '恢复资产');
    expect(find.text('备份已恢复'), findsOneWidget);

    await tester.tap(find.byKey(const Key('delete-backup-backup-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('取消').last);
    await tester.pumpAndSettle();
    expect(repository.backups.map((backup) => backup.id), contains('backup-2'));

    await tester.tap(find.byKey(const Key('delete-backup-backup-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete-backup-button')));
    await tester.pumpAndSettle();

    expect(
      repository.backups.map((backup) => backup.id),
      isNot(contains('backup-2')),
    );
    expect(find.text('备份已删除'), findsOneWidget);
  });

  testWidgets('restore backup shows corrupted backup message and keeps state', (
    tester,
  ) async {
    final repository = _Repository(_sampleState());
    repository.backups = const [
      BackupRecord(
        id: 'broken',
        at: '2026-05-13T09:00:00.000',
        label: 'Broken backup',
        data: '{bad json',
      ),
    ];

    await tester.pumpWidget(_wrap(DataMigrationPage(repository: repository)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('restore-backup-broken')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-restore-backup-button')));
    await tester.pumpAndSettle();

    expect(find.text('备份已损坏，无法恢复'), findsOneWidget);
    expect(repository.state.assets.single.name, '相机');
  });

  testWidgets('restore and delete show specific failure messages', (
    tester,
  ) async {
    final repository = _Repository(_sampleState())
      ..failRestore = true
      ..failDelete = true
      ..backups = const [
        BackupRecord(
          id: 'backup-1',
          at: '2026-05-13T09:00:00.000',
          label: 'Backup one',
          data: '{"version":2,"assets":[]}',
        ),
      ];

    await tester.pumpWidget(_wrap(DataMigrationPage(repository: repository)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('restore-backup-backup-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-restore-backup-button')));
    await tester.pumpAndSettle();
    expect(find.text('恢复失败，请稍后重试'), findsOneWidget);

    await tester.tap(find.byKey(const Key('delete-backup-backup-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete-backup-button')));
    await tester.pumpAndSettle();
    expect(find.text('删除失败，请稍后重试'), findsOneWidget);
    expect(repository.backups.single.id, 'backup-1');
  });
}

Widget _wrap(Widget child) {
  return MaterialApp(debugShowCheckedModeBanner: false, home: child);
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 8 && finder.evaluate().isEmpty; i += 1) {
    await tester.drag(
      find.byKey(const Key('data-migration-scroll-view')),
      const Offset(0, -240),
    );
    await tester.pumpAndSettle();
  }
  if (finder.evaluate().isNotEmpty) {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }
}

AssetState _sampleState() {
  return AssetNormalizer().normalizeState({
    'assets': [
      {
        'id': 'camera',
        'name': '相机',
        'category': '摄影',
        'purchasePrice': 3000,
        'purchaseDate': '2026-01-01',
      },
    ],
    'categories': [
      {'name': '摄影', 'color': '#123456'},
      {'name': '数码', 'color': '#4299e1'},
    ],
    'settings': const AppSettings(theme: 'blackGold').toJson(),
  });
}

class _Repository implements AssetStateRepository {
  _Repository(this.state);

  AssetState state;
  List<BackupRecord> backups = [];
  var failRestore = false;
  var failDelete = false;
  final _backupService = const BackupService();
  final _codec = BackupSnapshotCodec();

  @override
  Future<AppSettings> loadSettings() async => state.settings;

  @override
  Future<AssetState> loadState() async => state;

  @override
  Future<void> replaceState(AssetState state) async {
    this.state = state;
  }

  @override
  Future<List<BackupRecord>> loadBackups() async => backups;

  @override
  Future<BackupRecord> backupAssets({
    String label = 'Manual asset backup',
  }) async {
    final current = state;
    final backup = BackupRecord(
      id: 'backup-${backups.length + 1}',
      at: '2026-05-13T09:00:00.000',
      label: label,
      data: _codec.encode(current, exportedAt: DateTime(2026, 5, 13)),
    );
    backups = _backupService.limitBackups([backup, ...backups]);
    return backup;
  }

  @override
  Future<void> clearAssets({bool backupCurrent = false}) async {
    final current = state;
    if (backupCurrent) {
      await backupAssets(label: 'Before clear assets');
    }
    state = AssetState(
      assets: const [],
      categories: current.categories,
      settings: current.settings,
    );
  }

  @override
  Future<void> restoreBackup(BackupRecord backup) async {
    if (failRestore) throw StateError('restore failed');
    state = _codec.decode(backup.data, currentState: state);
  }

  @override
  Future<void> deleteBackup(String id) async {
    if (failDelete) throw StateError('delete failed');
    backups = backups.where((backup) => backup.id != id).toList();
  }
}
