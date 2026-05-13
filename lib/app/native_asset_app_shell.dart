import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';
import '../app/theme/app_theme.dart';
import '../domain/models/asset_state.dart';
import '../domain/repositories/asset_state_repository.dart';
import '../features/assets/asset_list_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/settings/asset_notification_service.dart';
import '../features/settings/settings_page.dart';

class NativeAssetAppShell extends StatefulWidget {
  const NativeAssetAppShell({
    super.key,
    required this.repository,
    required this.themeController,
    this.initialState,
    this.notificationService,
  });

  final AssetStateRepository repository;
  final AppThemeController themeController;
  final AssetState? initialState;
  final AssetNotificationService? notificationService;

  @override
  NativeAssetAppShellState createState() => NativeAssetAppShellState();
}

class NativeAssetAppShellState extends State<NativeAssetAppShell> {
  final _settingsNavigatorKey = GlobalKey<NavigatorState>();
  var _index = 0;
  var _revision = 0;

  void _refreshNativePages() {
    setState(() {
      _revision += 1;
    });
  }

  void _openDataPage() {
    setState(() {
      _index = 2;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pushSettingsRoute(SettingsRoutes.data);
    });
  }

  void openSettingsRoute(String routeName) {
    setState(() {
      _index = 2;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pushSettingsRoute(routeName);
    });
  }

  void openReminders() {
    openSettingsRoute(SettingsRoutes.reminders);
  }

  void _pushSettingsRoute(String routeName) {
    debugPrint('GRZCGL settings push $routeName');
    final navigator = _settingsNavigatorKey.currentState;
    if (navigator == null) return;
    navigator.popUntil((route) => route.isFirst);
    if (routeName != SettingsRoutes.home) {
      navigator.pushNamed(routeName);
    }
  }

  Future<bool> _handleSystemBack() async {
    if (!mounted) return false;
    if (_index == 2) {
      final navigator = _settingsNavigatorKey.currentState;
      if (navigator != null && await navigator.maybePop()) {
        debugPrint('GRZCGL settings pop');
        return true;
      }
    }
    if (_index != 0) {
      debugPrint('GRZCGL shell back to dashboard');
      setState(() {
        _index = 0;
      });
      return true;
    }
    return false;
  }

  void _selectTab(int index) {
    debugPrint('GRZCGL shell tab $index');
    if (_index == 2 && index != 2) {
      _settingsNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        key: ValueKey('dashboard-$_revision'),
        repository: widget.repository,
        initialState: _revision == 0 ? widget.initialState : null,
        onImportRequested: _openDataPage,
      ),
      AssetListPage(
        key: ValueKey('assets-$_revision'),
        repository: widget.repository,
        onImportRequested: _openDataPage,
        onDataChanged: _refreshNativePages,
      ),
      SettingsPage(
        key: ValueKey('settings-$_revision'),
        repository: widget.repository,
        themeController: widget.themeController,
        navigatorKey: _settingsNavigatorKey,
        notificationService: widget.notificationService,
        onDataChanged: _refreshNativePages,
      ),
    ];

    return PopScope<void>(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        unawaited(_handleSystemBack());
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(index: _index, children: pages),
        bottomNavigationBar: NavigationBar(
          key: const Key('native-shell-navigation'),
          selectedIndex: _index,
          onDestinationSelected: _selectTab,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.gold.withValues(alpha: 0.18),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: '仪表盘',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: '资产',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: '设置',
            ),
          ],
        ),
      ),
    );
  }
}
