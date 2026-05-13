enum AppThemeMode {
  minimal('minimal', '简约'),
  blackGold('blackGold', '黑金'),
  pink('pink', '粉色');

  const AppThemeMode(this.value, this.label);

  final String value;
  final String label;

  static AppThemeMode fromValue(Object? value) {
    return switch (value?.toString()) {
      'minimal' || 'plain' => AppThemeMode.minimal,
      'blackGold' || 'dark' => AppThemeMode.blackGold,
      'pink' => AppThemeMode.pink,
      _ => AppThemeMode.blackGold,
    };
  }
}
