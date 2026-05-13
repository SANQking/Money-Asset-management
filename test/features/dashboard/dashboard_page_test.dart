import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/models/app_settings.dart';
import 'package:mobile/domain/models/asset_state.dart';
import 'package:mobile/domain/models/backup_record.dart';
import 'package:mobile/domain/repositories/asset_state_repository.dart';
import 'package:mobile/domain/services/asset_normalizer.dart';
import 'package:mobile/domain/services/asset_stats_service.dart';
import 'package:mobile/features/dashboard/dashboard_page.dart';

void main() {
  testWidgets('shows empty sqlite dashboard state', (tester) async {
    await tester.pumpWidget(
      _wrap(
        DashboardPage(
          repository: _FakeAssetStateRepository(
            state: const AssetState(
              assets: [],
              categories: [],
              settings: AppSettings(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('资产仪表盘'), findsOneWidget);
    expect(find.text('资产数量'), findsOneWidget);
    expect(find.text('0'), findsWidgets);
    expect(find.text('暂无资产数据'), findsOneWidget);
  });

  testWidgets(
    'renders metrics, reminders, categories and rank from repository data',
    (tester) async {
      final normalizer = AssetNormalizer(idFactory: () => 'id');
      final state = normalizer.normalizeState({
        'assets': [
          {
            'id': 'camera',
            'name': '相机',
            'purchasePrice': 3000,
            'purchaseDate': '2024-01-01',
            'category': '摄影',
            'currentValue': 2400,
            'warrantyUntil': '2026-06-01',
            'events': [
              {'type': '维修', 'amount': 100, 'date': '2024-06-01'},
            ],
          },
          {
            'id': 'laptop',
            'name': '笔记本',
            'purchasePrice': 8000,
            'purchaseDate': '2023-01-01',
            'category': '数码',
            'currentValue': 5000,
            'lastUsedDate': '2024-01-01',
          },
          {
            'id': 'phone',
            'name': '手机',
            'purchasePrice': 5000,
            'purchaseDate': '2023-01-01',
            'category': '数码',
            'status': 'sold',
            'salePrice': 4200,
            'currentValue': 0,
          },
        ],
        'categories': [
          {'name': '摄影', 'color': '#123456'},
          {'name': '数码', 'color': '#4299e1'},
          {'name': '收藏', 'color': '#D4AF37'},
        ],
      });

      await tester.pumpWidget(
        _wrap(
          DashboardPage(
            repository: _FakeAssetStateRepository(state: state),
            statsService: const AssetStatsService(today: '2026-05-13'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
      expect(find.text('¥16,000'), findsOneWidget);
      expect(find.text('¥7,400'), findsOneWidget);
      expect(find.text('¥8,600'), findsOneWidget);
      expect(find.text('¥100'), findsOneWidget);
      expect(find.text('日均成本'), findsOneWidget);
      expect(find.text('¥14/天'), findsOneWidget);
      expect(find.text('出售损益'), findsNothing);
      expect(find.text('长期闲置'), findsOneWidget);
      expect(find.text('保修将到期'), findsOneWidget);
      expect(find.text('分类价值排行'), findsOneWidget);
      expect(find.text('分类分布'), findsNothing);
      expect(find.text('摄影'), findsOneWidget);
      expect(find.text('数码'), findsOneWidget);
      expect(find.text('收藏'), findsOneWidget);
      expect(find.text('¥0'), findsWidgets);
      await tester.drag(find.byType(ListView), const Offset(0, -700));
      await tester.pumpAndSettle();

      expect(find.text('真实成本排行'), findsOneWidget);
      expect(find.text('笔记本'), findsOneWidget);
      expect(find.text('相机'), findsOneWidget);
    },
  );

  testWidgets('shows error state and retries loading', (tester) async {
    final repository = _FakeAssetStateRepository(
      state: const AssetState(
        assets: [],
        categories: [],
        settings: AppSettings(),
      ),
      failFirstLoad: true,
    );

    await tester.pumpWidget(_wrap(DashboardPage(repository: repository)));
    await tester.pumpAndSettle();

    expect(find.text('资产数据加载失败'), findsOneWidget);
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();

    expect(find.text('资产仪表盘'), findsOneWidget);
    expect(repository.loadCount, 2);
  });
}

Widget _wrap(Widget child) {
  return MaterialApp(debugShowCheckedModeBanner: false, home: child);
}

class _FakeAssetStateRepository implements AssetStateRepository {
  _FakeAssetStateRepository({required this.state, this.failFirstLoad = false});

  final AssetState state;
  final bool failFirstLoad;
  var loadCount = 0;

  @override
  Future<AppSettings> loadSettings() async => state.settings;

  @override
  Future<AssetState> loadState() async {
    loadCount += 1;
    if (failFirstLoad && loadCount == 1) {
      throw StateError('failed');
    }
    return state;
  }

  @override
  Future<List<BackupRecord>> loadBackups() async => const [];

  @override
  Future<BackupRecord> backupAssets({
    String label = 'Manual asset backup',
  }) async {
    return BackupRecord(id: 'backup', at: 'now', label: label, data: '{}');
  }

  @override
  Future<void> clearAssets({bool backupCurrent = false}) async {}

  @override
  Future<void> restoreBackup(BackupRecord backup) async {}

  @override
  Future<void> deleteBackup(String id) async {}

  @override
  Future<void> replaceState(AssetState state) async {}
}
