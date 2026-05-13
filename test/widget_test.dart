import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

import 'package:mobile/app/theme/app_theme.dart';
import 'package:mobile/app/native_asset_app_shell.dart';
import 'package:mobile/domain/models/app_settings.dart';
import 'package:mobile/domain/models/asset_state.dart';
import 'package:mobile/domain/models/backup_record.dart';
import 'package:mobile/domain/repositories/asset_state_repository.dart';
import 'package:mobile/domain/services/asset_normalizer.dart';
import 'package:mobile/features/settings/asset_notification_service.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/dashboard_card.dart';
import 'package:mobile/shared/widgets/metric_card.dart';

void main() {
  testWidgets('defaults to native shell', (tester) async {
    await tester.pumpWidget(
      _wrapApp(_FakeAssetStateRepository(state: _emptyState())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NativeAssetAppShell), findsOneWidget);
    expect(find.text('资产仪表盘'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('数据'), findsNothing);
  });

  testWidgets('switches native bottom navigation pages', (tester) async {
    await tester.pumpWidget(
      _wrapApp(_FakeAssetStateRepository(state: _emptyState())),
    );
    await tester.pumpAndSettle();

    await _tapBottomNav(tester, '资产');
    await tester.pumpAndSettle();
    expect(find.text('所有资产列表'), findsOneWidget);

    await _tapBottomNav(tester, '设置');
    await tester.pumpAndSettle();
    expect(find.text('偏好设置'), findsOneWidget);
    expect(find.text('数据管理'), findsOneWidget);
    expect(find.text('分类管理'), findsOneWidget);
    expect(find.text('资产提醒'), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings-data-management-button')));
    await tester.pumpAndSettle();
    expect(find.text('本机数据'), findsOneWidget);
    expect(find.text('备份'), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings-back-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-preferences-button')));
    await tester.pumpAndSettle();
    expect(find.text('简约'), findsOneWidget);
    expect(find.text('黑金'), findsOneWidget);
    expect(find.text('粉色'), findsOneWidget);
    expect(find.text('黑白色搭配的极简美学'), findsOneWidget);
    expect(find.text('黑金色搭配的高级质感'), findsOneWidget);
    expect(find.text('浅粉色搭配的温馨氛围'), findsOneWidget);
    expect(find.text('数字显示'), findsOneWidget);
    expect(find.text('小数位数'), findsOneWidget);
    expect(find.textContaining('偏好设置会保存到本机 SQLite'), findsNothing);
  });

  testWidgets('changes numeric display decimal setting', (tester) async {
    final repository = _FakeAssetStateRepository(state: _emptyState());
    await tester.pumpWidget(_wrapApp(repository));
    await tester.pumpAndSettle();

    await _tapBottomNav(tester, '设置');
    await tester.tap(find.byKey(const Key('settings-preferences-button')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('decimal-digits-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('decimal-digits-2')));
    await tester.pumpAndSettle();

    expect(repository.state.settings.moneyDecimalDigits, 2);
  });

  testWidgets('changes theme globally and persists setting', (tester) async {
    final repository = _FakeAssetStateRepository(state: _emptyState());
    await tester.pumpWidget(_wrapApp(repository));
    await tester.pumpAndSettle();

    await _tapBottomNav(tester, '设置');
    if (find
        .byKey(const Key('settings-preferences-button'))
        .evaluate()
        .isNotEmpty) {
      await tester.tap(find.byKey(const Key('settings-preferences-button')));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(const Key('theme-option-minimal')));
    await tester.pumpAndSettle();

    expect(repository.state.settings.theme, 'minimal');
    expect(AppThemeController.activeTokens.background, const Color(0xFFFFFFFF));
    expect(AppThemeController.activeTokens.hasPhysicalBorders, isFalse);

    await _tapBottomNav(tester, '仪表盘');
    await tester.pumpAndSettle();
    final dashboardScaffold = tester.widget<Scaffold>(
      find.byType(Scaffold).first,
    );
    expect(dashboardScaffold.backgroundColor, const Color(0xFFFFFFFF));
    final dashboardTitle = tester.widget<Text>(find.text('资产仪表盘'));
    expect((dashboardTitle.style as TextStyle).color, const Color(0xFF000000));

    await _tapBottomNav(tester, '设置');
    if (find
        .byKey(const Key('settings-preferences-button'))
        .evaluate()
        .isNotEmpty) {
      await tester.tap(find.byKey(const Key('settings-preferences-button')));
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(find.byKey(const Key('theme-option-pink')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('theme-option-pink')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    expect(repository.state.settings.theme, 'pink');
    expect(AppThemeController.activeTokens.background, const Color(0xFFFFF5F7));
    expect(AppThemeController.activeTokens.accent, const Color(0xFFFF6B8B));
  });

  testWidgets(
    'settings subsection background updates immediately on theme change',
    (tester) async {
      final repository = _FakeAssetStateRepository(state: _emptyState());
      await tester.pumpWidget(_wrapApp(repository));
      await tester.pumpAndSettle();

      await _tapBottomNav(tester, '设置');
      await tester.tap(find.byKey(const Key('settings-preferences-button')));
      await tester.pumpAndSettle();

      Scaffold settingsScaffold = tester
          .widgetList<Scaffold>(
            find.ancestor(
              of: find.byKey(const Key('theme-option-minimal')),
              matching: find.byType(Scaffold),
            ),
          )
          .last;
      expect(settingsScaffold.backgroundColor, const Color(0xFF15120D));

      await tester.tap(find.byKey(const Key('theme-option-minimal')));
      await tester.pumpAndSettle();

      settingsScaffold = tester
          .widgetList<Scaffold>(
            find.ancestor(
              of: find.byKey(const Key('theme-option-minimal')),
              matching: find.byType(Scaffold),
            ),
          )
          .last;
      expect(settingsScaffold.backgroundColor, const Color(0xFFFFFFFF));
      expect(find.byKey(const Key('theme-option-minimal')), findsOneWidget);
    },
  );

  testWidgets(
    'data management section has no legacy webview or json csv entry',
    (tester) async {
      await tester.pumpWidget(
        _wrapApp(_FakeAssetStateRepository(state: _emptyState())),
      );
      await tester.pumpAndSettle();

      await _tapBottomNav(tester, '设置');
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('settings-data-management-button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('本机数据'), findsOneWidget);
      expect(find.text('数据管理'), findsOneWidget);
      expect(find.textContaining('WebView'), findsNothing);
      expect(find.textContaining('旧版入口'), findsNothing);
      expect(find.textContaining('JSON'), findsNothing);
      expect(find.textContaining('CSV'), findsNothing);
      expect(find.text('导入文本'), findsNothing);
      expect(find.text('选择文件'), findsNothing);
      expect(find.text('生成导出文本'), findsNothing);
      expect(find.text('导出文件'), findsNothing);
      expect(find.byKey(const Key('open-legacy-webview-button')), findsNothing);
    },
  );

  testWidgets(
    'minimal theme uses raised gray cards and asset filter backgrounds',
    (tester) async {
      await tester.pumpWidget(
        _wrapApp(_FakeAssetStateRepository(state: _minimalState())),
      );
      await tester.pumpAndSettle();

      final metricDecoration = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(MetricCard).first,
          matching: find.byType(DecoratedBox),
        ),
      );
      final metricBox = metricDecoration.decoration as BoxDecoration;
      expect(metricBox.color, const Color(0xFFF7F7F7));
      expect(metricBox.border, isNull);

      final cards = tester.widgetList<DecoratedBox>(
        find.descendant(
          of: find.byType(DashboardCard),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect(cards, isNotEmpty);
      for (final card in cards) {
        final decoration = card.decoration as BoxDecoration;
        expect(decoration.color, const Color(0xFFF7F7F7));
        expect(decoration.border, isNull);
      }

      await _tapBottomNav(tester, '资产');
      await tester.pumpAndSettle();

      final searchField = tester.widget<TextField>(
        find.byKey(const Key('asset-search-field')),
      );
      expect(searchField.decoration?.fillColor, const Color(0xFFF7F7F7));
      expect(searchField.decoration?.enabledBorder, isA<OutlineInputBorder>());

      final filterChip = tester.widget<Chip>(
        find.byKey(const Key('asset-filter-chip-全部分类')),
      );
      expect(filterChip.backgroundColor, const Color(0xFFF1F1F1));
      expect(filterChip.side, BorderSide.none);

      await _tapBottomNav(tester, '设置');
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('settings-data-management-button')),
      );
      await tester.pumpAndSettle();

      final clearButton = tester.widget<FilledButton>(
        find.byKey(const Key('clear-assets-button')),
      );
      expect(
        clearButton.style?.minimumSize?.resolve(<WidgetState>{}),
        const Size(44, 44),
      );
      expect(find.byKey(const Key('backup-assets-button')), findsOneWidget);
    },
  );

  testWidgets(
    'switching away from settings subpage resets settings navigator',
    (tester) async {
      await tester.pumpWidget(
        _wrapApp(_FakeAssetStateRepository(state: _emptyState())),
      );
      await tester.pumpAndSettle();

      await _tapBottomNav(tester, '设置');
      await tester.tap(
        find.byKey(const Key('settings-data-management-button')),
      );
      await tester.pumpAndSettle();
      expect(find.text('本机数据'), findsOneWidget);

      await _tapBottomNav(tester, '资产');
      await tester.pumpAndSettle();
      expect(find.text('所有资产列表'), findsOneWidget);

      await _tapBottomNav(tester, '设置');
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('settings-data-management-button')),
        findsOneWidget,
      );
      expect(find.text('本机数据'), findsNothing);
    },
  );

  testWidgets('system back returns from settings subsections and tabs', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapApp(_FakeAssetStateRepository(state: _emptyState())),
    );
    await tester.pumpAndSettle();

    await _tapBottomNav(tester, '设置');
    await tester.tap(find.byKey(const Key('settings-data-management-button')));
    await tester.pumpAndSettle();
    expect(find.text('本机数据'), findsOneWidget);

    final handledSettingsBack = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(handledSettingsBack, isTrue);
    expect(
      find.byKey(const Key('settings-data-management-button')),
      findsOneWidget,
    );

    final handledTabBack = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(handledTabBack, isTrue);
    expect(find.text('资产仪表盘'), findsOneWidget);

    await _tapBottomNav(tester, '设置');
    await tester.tap(
      find.byKey(const Key('settings-category-management-button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('分类管理'), findsOneWidget);
    expect(find.byKey(const Key('add-category-button')), findsOneWidget);

    final handledCategoryBack = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(handledCategoryBack, isTrue);
    expect(
      find.byKey(const Key('settings-category-management-button')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('settings-asset-reminders-button')));
    await tester.pumpAndSettle();
    expect(find.text('资产提醒'), findsWidgets);

    final handledReminderBack = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(handledReminderBack, isTrue);
    expect(
      find.byKey(const Key('settings-asset-reminders-button')),
      findsOneWidget,
    );
  });

  testWidgets('system back from assets and settings center returns dashboard', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapApp(_FakeAssetStateRepository(state: _emptyState())),
    );
    await tester.pumpAndSettle();

    await _tapBottomNav(tester, '资产');
    expect(find.text('所有资产列表'), findsOneWidget);
    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('资产仪表盘'), findsOneWidget);

    await _tapBottomNav(tester, '设置');
    expect(
      find.byKey(const Key('settings-data-management-button')),
      findsOneWidget,
    );
    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('资产仪表盘'), findsOneWidget);
  });

  testWidgets('startup shows loading and error fallback', (tester) async {
    final slowRepository = _FakeAssetStateRepository(
      state: _emptyState(),
      settingsCompleter: Completer<AppSettings>(),
    );
    await tester.pumpWidget(_wrapApp(slowRepository));
    await tester.pump();

    expect(find.byKey(const Key('app-splash-screen')), findsOneWidget);
    expect(find.byKey(const Key('app-splash-logo')), findsOneWidget);
    expect(slowRepository.loadStateCount, 0);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    final failedRepository = _FakeAssetStateRepository(
      state: _emptyState(),
      failSettingsLoad: true,
    );
    await tester.pumpWidget(_wrapApp(failedRepository, key: UniqueKey()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('app-startup-error')), findsOneWidget);
    expect(find.text('应用启动失败'), findsOneWidget);
  });

  testWidgets('startup does not initialize notifications before shell', (
    tester,
  ) async {
    final notificationService = _StartupNotificationService.instance;
    notificationService.initializeCount = 0;
    await tester.pumpWidget(
      _wrapApp(_FakeAssetStateRepository(state: _emptyState())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NativeAssetAppShell), findsOneWidget);
    expect(notificationService.initializeCount, 0);
  });

  testWidgets('adding an asset refreshes dashboard metrics and ranking', (
    tester,
  ) async {
    final repository = _FakeAssetStateRepository(state: _emptyState());
    await tester.pumpWidget(_wrapApp(repository));
    await tester.pumpAndSettle();

    await _tapBottomNav(tester, '资产');
    await tester.tap(find.byKey(const Key('add-asset-button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('asset-name-field')), '同步相机');
    await tester.enterText(
      find.byKey(const Key('asset-purchase-price-field')),
      '2399',
    );
    await _tapSaveAsset(tester);
    await tester.pumpAndSettle();

    await _tapBottomNav(tester, '仪表盘');
    await tester.pumpAndSettle();

    expect(find.text('1'), findsWidgets);
    expect(find.text('¥2,399'), findsWidgets);
    await tester.drag(find.byType(ListView).first, const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(find.text('真实成本排行'), findsOneWidget);
    expect(find.text('同步相机'), findsOneWidget);
  });
}

AssetState _emptyState() {
  return const AssetState(assets: [], categories: [], settings: AppSettings());
}

AssetState _minimalState() {
  return const AssetState(
    assets: [],
    categories: [],
    settings: AppSettings(theme: 'minimal'),
  );
}

Widget _wrapApp(_FakeAssetStateRepository repository, {Key? key}) {
  return GrzcglApp(
    key: key,
    repository: repository,
    notificationService: _StartupNotificationService.instance,
  );
}

Future<void> _tapSaveAsset(WidgetTester tester) async {
  final saveButton = find.byKey(const Key('asset-save-button'));
  for (var i = 0; i < 8 && _isBelowViewport(tester, saveButton); i += 1) {
    await tester.drag(
      find.byKey(const Key('asset-sheet-scroll-view')),
      const Offset(0, -220),
    );
    await tester.pumpAndSettle();
  }
  await tester.tap(saveButton);
}

bool _isBelowViewport(WidgetTester tester, Finder finder) {
  final rect = tester.getRect(finder);
  return rect.bottom >
      tester.view.physicalSize.height / tester.view.devicePixelRatio;
}

Future<void> _tapBottomNav(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byKey(const Key('native-shell-navigation')),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeAssetStateRepository implements AssetStateRepository {
  _FakeAssetStateRepository({
    required this.state,
    this.failSettingsLoad = false,
    this.settingsCompleter,
  });

  AssetState state;
  final bool failSettingsLoad;
  final Completer<AppSettings>? settingsCompleter;
  var _nextAssetId = 0;
  var loadStateCount = 0;

  @override
  Future<AppSettings> loadSettings() async {
    if (failSettingsLoad) {
      throw StateError('settings failed');
    }
    if (settingsCompleter != null) {
      return settingsCompleter!.future;
    }
    return state.settings;
  }

  @override
  Future<AssetState> loadState() async {
    loadStateCount += 1;
    return state;
  }

  @override
  Future<void> replaceState(AssetState state) async {
    this.state = AssetNormalizer(
      now: DateTime(2026, 5, 13),
      idFactory: () => 'asset-${_nextAssetId++}',
    ).normalizeState(state.toJson());
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
}

class _StartupNotificationService implements AssetNotificationService {
  static final instance = _StartupNotificationService._();

  _StartupNotificationService._();

  var initializeCount = 0;

  @override
  Future<void> initialize({void Function(String? payload)? onTap}) async {
    initializeCount += 1;
  }

  @override
  Future<NotificationPermissionState> permissionState() async {
    return const NotificationPermissionState(supported: false, enabled: false);
  }

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> scheduleDailySummary({
    required AppSettings settings,
    required int reminderCount,
  }) async {}

  @override
  Future<void> cancelDailySummary() async {}
}
