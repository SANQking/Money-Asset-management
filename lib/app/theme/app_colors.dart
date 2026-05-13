import 'package:flutter/material.dart';

import 'app_theme.dart';

class AppColors {
  const AppColors._();

  static AppThemeTokens get tokens => AppThemeController.activeTokens;

  static Color get background => tokens.background;
  static Color get surface => tokens.surface;
  static Color get surfaceRaised => tokens.surfaceRaised;
  static Color get border => tokens.border;
  static Color get gold => tokens.accent;
  static Color get goldLight => tokens.accentLight;
  static Color get text => tokens.text;
  static Color get muted => tokens.muted;
  static Color get danger => tokens.danger;
  static Color get success => tokens.success;
}
