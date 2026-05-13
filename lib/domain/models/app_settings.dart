class AppSettings {
  const AppSettings({
    this.theme = 'blackGold',
    this.depreciationRate = 18,
    this.language = 'zh',
    this.remindersEnabled = false,
    this.reminderHour = 9,
    this.reminderMinute = 0,
    this.warrantyReminderEnabled = true,
    this.idleReminderEnabled = true,
    this.maintenanceReminderEnabled = true,
    this.warrantyLeadDays = 60,
    this.idleThresholdDays = 180,
    this.maintenanceCycleDays = 180,
    this.moneyDecimalDigits = 0,
  });

  final String theme;
  final double depreciationRate;
  final String language;
  final bool remindersEnabled;
  final int reminderHour;
  final int reminderMinute;
  final bool warrantyReminderEnabled;
  final bool idleReminderEnabled;
  final bool maintenanceReminderEnabled;
  final int warrantyLeadDays;
  final int idleThresholdDays;
  final int maintenanceCycleDays;
  final int moneyDecimalDigits;

  AppSettings copyWith({
    String? theme,
    double? depreciationRate,
    String? language,
    bool? remindersEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? warrantyReminderEnabled,
    bool? idleReminderEnabled,
    bool? maintenanceReminderEnabled,
    int? warrantyLeadDays,
    int? idleThresholdDays,
    int? maintenanceCycleDays,
    int? moneyDecimalDigits,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      depreciationRate: depreciationRate ?? this.depreciationRate,
      language: language ?? this.language,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      warrantyReminderEnabled:
          warrantyReminderEnabled ?? this.warrantyReminderEnabled,
      idleReminderEnabled: idleReminderEnabled ?? this.idleReminderEnabled,
      maintenanceReminderEnabled:
          maintenanceReminderEnabled ?? this.maintenanceReminderEnabled,
      warrantyLeadDays: warrantyLeadDays ?? this.warrantyLeadDays,
      idleThresholdDays: idleThresholdDays ?? this.idleThresholdDays,
      maintenanceCycleDays: maintenanceCycleDays ?? this.maintenanceCycleDays,
      moneyDecimalDigits: moneyDecimalDigits ?? this.moneyDecimalDigits,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'theme': theme,
      'depreciationRate': depreciationRate,
      'language': language,
      'remindersEnabled': remindersEnabled,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
      'warrantyReminderEnabled': warrantyReminderEnabled,
      'idleReminderEnabled': idleReminderEnabled,
      'maintenanceReminderEnabled': maintenanceReminderEnabled,
      'warrantyLeadDays': warrantyLeadDays,
      'idleThresholdDays': idleThresholdDays,
      'maintenanceCycleDays': maintenanceCycleDays,
      'moneyDecimalDigits': moneyDecimalDigits,
    };
  }
}
