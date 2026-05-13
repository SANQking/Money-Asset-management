import 'package:flutter/material.dart';

import '../../domain/models/app_theme_mode.dart';
import '../../domain/models/asset_state.dart';
import '../../domain/repositories/asset_state_repository.dart';

class AppThemeTokens {
  const AppThemeTokens({
    required this.mode,
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.text,
    required this.muted,
    required this.accent,
    required this.accentLight,
    required this.onAccent,
    required this.border,
    required this.success,
    required this.danger,
    required this.cardRadius,
    required this.sheetRadius,
    required this.hasPhysicalBorders,
    required this.cardShadow,
    required this.primaryShadow,
    required this.pageGradient,
    required this.secondaryActionBackground,
    required this.secondaryActionForeground,
  });

  final AppThemeMode mode;
  final Color background;
  final Color surface;
  final Color surfaceRaised;
  final Color text;
  final Color muted;
  final Color accent;
  final Color accentLight;
  final Color onAccent;
  final Color border;
  final Color success;
  final Color danger;
  final double cardRadius;
  final double sheetRadius;
  final bool hasPhysicalBorders;
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> primaryShadow;
  final List<Color> pageGradient;
  final Color secondaryActionBackground;
  final Color secondaryActionForeground;

  bool get isMinimal => mode == AppThemeMode.minimal;
  bool get isBlackGold => mode == AppThemeMode.blackGold;
  bool get isPink => mode == AppThemeMode.pink;
  double get cardPadding => isMinimal ? 28 : 16;

  Border? get cardBorder =>
      hasPhysicalBorders ? Border.all(color: border) : null;
  BorderSide get inputBorderSide =>
      hasPhysicalBorders ? BorderSide(color: border) : BorderSide.none;
  BorderSide get focusedBorderSide =>
      BorderSide(color: accent, width: isMinimal ? 0 : 1.2);

  TextStyle numberStyle({
    required double fontSize,
    Color? color,
    FontWeight fontWeight = FontWeight.w800,
  }) {
    return TextStyle(
      color: color ?? accentLight,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 0,
      fontFeatures: const [FontFeature.tabularFigures()],
      fontFamily: 'monospace',
    );
  }

  ThemeData toThemeData() {
    final brightness = isBlackGold ? Brightness.dark : Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
      primary: accent,
      onPrimary: onAccent,
      surface: surface,
      onSurface: text,
      error: danger,
    );
    final outline = hasPhysicalBorders ? border : Colors.transparent;
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(isPink ? 999 : cardRadius),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      splashColor: accent.withValues(alpha: 0.10),
      highlightColor: accent.withValues(alpha: 0.07),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: accent.withValues(alpha: isMinimal ? 0.08 : 0.18),
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected) ? accent : muted,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: onAccent,
          minimumSize: const Size(44, 44),
          shape: buttonShape,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: outline),
          minimumSize: const Size(44, 44),
          shape: buttonShape,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          minimumSize: const Size(44, 44),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceRaised,
        contentTextStyle: TextStyle(color: text),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sheetRadius),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceRaised,
        selectedColor: accent.withValues(alpha: 0.16),
        side: BorderSide(color: outline),
        labelStyle: TextStyle(color: accentLight, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: muted),
        enabledBorder: OutlineInputBorder(
          borderSide: inputBorderSide,
          borderRadius: BorderRadius.circular(isPink ? 18 : 10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: focusedBorderSide,
          borderRadius: BorderRadius.circular(isPink ? 18 : 10),
        ),
        filled: isMinimal || isPink,
        fillColor: surfaceRaised,
      ),
    );
  }

  static const minimal = AppThemeTokens(
    mode: AppThemeMode.minimal,
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFF7F7F7),
    text: Color(0xFF000000),
    muted: Color(0xFF6B7280),
    accent: Color(0xFF000000),
    accentLight: Color(0xFF111111),
    onAccent: Color(0xFFFFFFFF),
    border: Colors.transparent,
    success: Color(0xFF047857),
    danger: Color(0xFFB42318),
    cardRadius: 6,
    sheetRadius: 20,
    hasPhysicalBorders: false,
    cardShadow: [],
    primaryShadow: [],
    pageGradient: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
    secondaryActionBackground: Color(0xFFF1F1F1),
    secondaryActionForeground: Color(0xFF000000),
  );

  static const blackGold = AppThemeTokens(
    mode: AppThemeMode.blackGold,
    background: Color(0xFF15120D),
    surface: Color(0xFF1A1712),
    surfaceRaised: Color(0xFF242016),
    text: Color(0xFFF8F2E6),
    muted: Color(0xFFC8B98F),
    accent: Color(0xFFD4AF37),
    accentLight: Color(0xFFF9D976),
    onAccent: Color(0xFF171108),
    border: Color(0xFF3B311E),
    success: Color(0xFF62B47A),
    danger: Color(0xFFD85C4A),
    cardRadius: 10,
    sheetRadius: 18,
    hasPhysicalBorders: true,
    cardShadow: [
      BoxShadow(
        color: Color(0x1FD4AF37),
        blurRadius: 30,
        spreadRadius: -18,
        offset: Offset(0, 12),
      ),
    ],
    primaryShadow: [
      BoxShadow(
        color: Color(0x26D4AF37),
        blurRadius: 28,
        spreadRadius: -12,
        offset: Offset(0, 12),
      ),
    ],
    pageGradient: [Color(0xFF15120D), Color(0xFF12110F), Color(0xFF111111)],
    secondaryActionBackground: Color(0xFF1A1712),
    secondaryActionForeground: Color(0xFFD4AF37),
  );

  static const pink = AppThemeTokens(
    mode: AppThemeMode.pink,
    background: Color(0xFFFFF5F7),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFFE8EF),
    text: Color(0xFF2D3748),
    muted: Color(0xFF718096),
    accent: Color(0xFFFF6B8B),
    accentLight: Color(0xFFFF6B8B),
    onAccent: Color(0xFF2D3748),
    border: Color(0xFFFFD2DD),
    success: Color(0xFF2F855A),
    danger: Color(0xFFE53E3E),
    cardRadius: 24,
    sheetRadius: 28,
    hasPhysicalBorders: true,
    cardShadow: [
      BoxShadow(
        color: Color(0x18FF6B8B),
        blurRadius: 28,
        spreadRadius: -16,
        offset: Offset(0, 14),
      ),
    ],
    primaryShadow: [
      BoxShadow(
        color: Color(0x33FF6B8B),
        blurRadius: 24,
        spreadRadius: -10,
        offset: Offset(0, 12),
      ),
    ],
    pageGradient: [Color(0xFFFFF5F7), Color(0xFFFFF5F7)],
    secondaryActionBackground: Color(0xFFFFFFFF),
    secondaryActionForeground: Color(0xFFFF6B8B),
  );

  static AppThemeTokens fromMode(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.minimal => minimal,
      AppThemeMode.blackGold => blackGold,
      AppThemeMode.pink => pink,
    };
  }
}

class AppThemeController extends ChangeNotifier {
  AppThemeController(this.repository);

  final AssetStateRepository repository;

  AppThemeMode _mode = AppThemeMode.blackGold;
  var _loaded = false;

  static AppThemeTokens _activeTokens = AppThemeTokens.blackGold;

  AppThemeMode get mode => _mode;
  AppThemeTokens get tokens => AppThemeTokens.fromMode(_mode);
  bool get loaded => _loaded;

  static AppThemeTokens get activeTokens => _activeTokens;

  Future<void> load() async {
    final settings = await repository.loadSettings();
    _setMode(AppThemeMode.fromValue(settings.theme), loaded: true);
  }

  Future<void> updateTheme(AppThemeMode mode) async {
    final state = await repository.loadState();
    final normalized = AppThemeMode.fromValue(mode.value);
    final next = AssetState(
      version: state.version,
      assets: state.assets,
      categories: state.categories,
      settings: state.settings.copyWith(theme: normalized.value),
    );
    await repository.replaceState(next);
    _setMode(normalized, loaded: true);
  }

  void _setMode(AppThemeMode mode, {required bool loaded}) {
    _mode = mode;
    _loaded = loaded;
    _activeTokens = tokens;
    notifyListeners();
  }
}

class AppThemeScope extends InheritedNotifier<AppThemeController> {
  const AppThemeScope({
    super.key,
    required AppThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppThemeScope>();
    assert(scope?.notifier != null, 'AppThemeScope is missing.');
    return scope!.notifier!;
  }

  static AppThemeController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppThemeScope>()
        ?.notifier;
  }

  static AppThemeTokens tokensOf(BuildContext context) {
    return maybeOf(context)?.tokens ?? AppThemeController.activeTokens;
  }
}

extension AppThemeContext on BuildContext {
  AppThemeTokens get appTheme => AppThemeScope.tokensOf(this);
}
