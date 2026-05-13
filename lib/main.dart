import 'package:flutter/material.dart';

import 'app/native_asset_app_shell.dart';
import 'app/theme/app_theme.dart';
import 'data/local/app_database.dart';
import 'data/repositories/asset_store_service.dart';
import 'domain/repositories/asset_state_repository.dart';
import 'features/settings/asset_notification_service.dart';

void main() {
  debugPrint('GRZCGL app main');
  final database = AppDatabase();
  runApp(GrzcglApp(repository: AssetStoreService(database)));
}

class GrzcglApp extends StatefulWidget {
  const GrzcglApp({
    super.key,
    required this.repository,
    this.notificationService,
  });

  final AssetStateRepository repository;
  final AssetNotificationService? notificationService;

  @override
  State<GrzcglApp> createState() => _GrzcglAppState();
}

class _GrzcglAppState extends State<GrzcglApp> {
  late final AppThemeController _themeController;
  late final AssetNotificationService _notificationService;
  late Future<void> _themeFuture;

  @override
  void initState() {
    super.initState();
    _themeController = AppThemeController(widget.repository);
    _notificationService =
        widget.notificationService ?? FlutterAssetNotificationService();
    _themeFuture = _themeController.load();
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, _) {
        return AppThemeScope(
          controller: _themeController,
          child: MaterialApp(
            title: 'Money',
            debugShowCheckedModeBanner: false,
            theme: _themeController.tokens.toThemeData(),
            home: FutureBuilder<void>(
              future: _themeFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const _AppStartupScreen();
                }
                if (snapshot.hasError) {
                  debugPrint('GRZCGL theme load failed: ${snapshot.error}');
                  return _AppStartupError(
                    onRetry: () {
                      setState(() {
                        _themeFuture = _themeController.load();
                      });
                    },
                  );
                }
                return NativeAssetAppShell(
                  repository: widget.repository,
                  themeController: _themeController,
                  notificationService: _notificationService,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _AppStartupScreen extends StatefulWidget {
  const _AppStartupScreen();

  @override
  State<_AppStartupScreen> createState() => _AppStartupScreenState();
}

class _AppStartupScreenState extends State<_AppStartupScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('app-splash-screen'),
      backgroundColor: const Color(0xFF15120D),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF15120D), Color(0xFF12110F), Color(0xFF111111)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(opacity: _fade.value, child: child);
              },
              child: Image.asset(
                'assets/branding/splash_logo.png',
                key: const Key('app-splash-logo'),
                width: 216,
                height: 216,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppStartupError extends StatelessWidget {
  const _AppStartupError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('app-startup-error'),
      backgroundColor: const Color(0xFF15120D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '应用启动失败',
                  style: TextStyle(
                    color: Color(0xFFF8F2E6),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '本机数据读取失败，请重试',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFC8B98F), height: 1.4),
                ),
                const SizedBox(height: 24),
                FilledButton(onPressed: onRetry, child: const Text('重试')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
