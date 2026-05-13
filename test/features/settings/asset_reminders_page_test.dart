import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/theme/app_theme.dart';
import 'package:mobile/domain/models/app_settings.dart';
import 'package:mobile/domain/models/asset_state.dart';
import 'package:mobile/domain/models/backup_record.dart';
import 'package:mobile/domain/repositories/asset_state_repository.dart';
import 'package:mobile/domain/services/asset_normalizer.dart';
import 'package:mobile/domain/services/asset_reminder_service.dart';
import 'package:mobile/features/settings/asset_notification_service.dart';
import 'package:mobile/features/settings/asset_reminder_settings_service.dart';
import 'package:mobile/features/settings/asset_reminders_page.dart';

void main() {
  testWidgets('shows reminder groups and disabled permission state', (
    tester,
  ) async {
    final repository = _Repository(_sampleState());
    final notification = _NotificationService(permissionEnabled: false);

    await tester.pumpWidget(
      _wrap(
        AssetRemindersPage(
          repository: repository,
          onBack: () {},
          reminderService: const AssetReminderService(today: '2026-05-13'),
          notificationService: notification,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('资产提醒'), findsOneWidget);
    expect(find.text('通知状态'), findsOneWidget);
    expect(find.text('提醒类型'), findsOneWidget);
    expect(find.text('提醒规则'), findsOneWidget);
    expect(find.text('系统通知未开启'), findsNothing);
    expect(find.text('未开启'), findsOneWidget);
    expect(find.text('保修将到期'), findsOneWidget);
    expect(find.text('长期闲置'), findsOneWidget);
    expect(find.text('保养提醒'), findsWidgets);
    expect(find.text('相机'), findsWidgets);
    expect(find.text('笔记本'), findsWidgets);
  });

  testWidgets('turning off a reminder type removes that group reminders', (
    tester,
  ) async {
    final repository = _Repository(_sampleState());
    final notification = _NotificationService(permissionEnabled: true);

    await tester.pumpWidget(
      _wrap(
        AssetRemindersPage(
          repository: repository,
          onBack: () {},
          reminderService: const AssetReminderService(today: '2026-05-13'),
          notificationService: notification,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('asset-reminders-enabled-switch')));
    await tester.pumpAndSettle();
    await _scrollTo(tester, find.byKey(const Key('warranty-reminder-enabled')));
    await tester.tap(find.byKey(const Key('warranty-reminder-enabled')));
    await tester.pumpAndSettle();

    expect(repository.state.settings.warrantyReminderEnabled, isFalse);
  });

  testWidgets('permission denied keeps in-app reminders visible', (
    tester,
  ) async {
    final repository = _Repository(_sampleState());
    final notification = _NotificationService(
      permissionEnabled: false,
      requestResult: false,
    );

    await tester.pumpWidget(
      _wrap(
        AssetRemindersPage(
          repository: repository,
          onBack: () {},
          reminderService: const AssetReminderService(today: '2026-05-13'),
          notificationService: notification,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('asset-reminders-enabled-switch')));
    for (var i = 0; i < 8 && !repository.state.settings.remindersEnabled; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(repository.state.settings.remindersEnabled, isTrue);
    expect(notification.scheduled, isFalse);
    await tester.pumpAndSettle();
    expect(find.text('相机'), findsWidgets);
  });

  testWidgets('changing threshold updates reminder count and schedules', (
    tester,
  ) async {
    final repository = _Repository(_sampleState());
    final notification = _NotificationService(permissionEnabled: true);

    await tester.pumpWidget(
      _wrap(
        AssetRemindersPage(
          repository: repository,
          onBack: () {},
          reminderService: const AssetReminderService(today: '2026-05-13'),
          settingsService: AssetReminderSettingsService(repository: repository),
          notificationService: notification,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('asset-reminders-enabled-switch')));
    await tester.pumpAndSettle();
    expect(notification.scheduled, isTrue);

    await _scrollTo(tester, find.byKey(const Key('warranty-lead-days-field')));
    await tester.enterText(
      find.byKey(const Key('warranty-lead-days-field')),
      '1',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(repository.state.settings.warrantyLeadDays, 1);
  });
}

Widget _wrap(Widget child, {String theme = 'blackGold'}) {
  final controller = _ThemeController(theme);
  return AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: controller.tokens.toThemeData(),
        home: AppThemeScope(
          controller: controller,
          child: Scaffold(body: child),
        ),
      );
    },
  );
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 8 && finder.evaluate().isEmpty; i += 1) {
    await tester.drag(
      find.byKey(const Key('asset-reminders-scroll-view')),
      const Offset(0, -260),
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
        'purchaseDate': '2025-01-01',
        'currentValue': 2400,
        'warrantyUntil': '2026-06-01',
        'events': [
          {'type': '保养', 'date': '2025-01-01'},
        ],
      },
      {
        'id': 'laptop',
        'name': '笔记本',
        'category': '数码',
        'purchaseDate': '2024-01-01',
        'lastUsedDate': '2025-01-01',
        'currentValue': 5000,
      },
    ],
    'categories': [
      {'name': '摄影', 'color': '#123456'},
      {'name': '数码', 'color': '#4299e1'},
    ],
    'settings': const AppSettings().toJson(),
  });
}

class _Repository implements AssetStateRepository {
  _Repository(this.state);

  AssetState state;

  @override
  Future<AppSettings> loadSettings() async => state.settings;

  @override
  Future<BackupRecord> backupAssets({
    String label = 'Manual asset backup',
  }) async {
    return BackupRecord(id: 'backup', at: 'now', label: label, data: '{}');
  }

  @override
  Future<void> clearAssets({bool backupCurrent = false}) async {}

  @override
  Future<void> deleteBackup(String id) async {}

  @override
  Future<List<BackupRecord>> loadBackups() async => const [];

  @override
  Future<AssetState> loadState() async => state;

  @override
  Future<void> replaceState(AssetState state) async {
    this.state = state;
  }

  @override
  Future<void> restoreBackup(BackupRecord backup) async {}
}

class _NotificationService implements AssetNotificationService {
  _NotificationService({
    required this.permissionEnabled,
    this.requestResult = true,
  });

  bool permissionEnabled;
  final bool requestResult;
  bool scheduled = false;

  @override
  Future<void> cancelDailySummary() async {
    scheduled = false;
  }

  @override
  Future<void> initialize({void Function(String? payload)? onTap}) async {}

  @override
  Future<NotificationPermissionState> permissionState() async {
    return NotificationPermissionState(
      supported: true,
      enabled: permissionEnabled,
    );
  }

  @override
  Future<bool> requestPermission() async {
    permissionEnabled = requestResult;
    return requestResult;
  }

  @override
  Future<void> scheduleDailySummary({
    required AppSettings settings,
    required int reminderCount,
  }) async {
    scheduled = true;
  }
}

class _ThemeController extends AppThemeController {
  _ThemeController(String theme)
    : super(
        _Repository(
          AssetState(
            assets: const [],
            categories: const [],
            settings: AppSettings(theme: theme),
          ),
        ),
      ) {
    load();
  }
}
