import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/money_format.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/asset_reminder.dart';
import '../../domain/models/asset_state.dart';
import '../../domain/repositories/asset_state_repository.dart';
import '../../domain/services/asset_reminder_service.dart';
import '../../shared/widgets/brand_loading_view.dart';
import '../../shared/widgets/dashboard_card.dart';
import 'asset_notification_service.dart';
import 'asset_reminder_settings_service.dart';

class AssetRemindersPage extends StatefulWidget {
  AssetRemindersPage({
    super.key,
    required this.repository,
    required this.onBack,
    AssetReminderService? reminderService,
    AssetReminderSettingsService? settingsService,
    AssetNotificationService? notificationService,
    this.onViewAsset,
  }) : reminderService = reminderService ?? const AssetReminderService(),
       settingsService =
           settingsService ??
           AssetReminderSettingsService(repository: repository),
       notificationService =
           notificationService ?? FlutterAssetNotificationService();

  final AssetStateRepository repository;
  final VoidCallback onBack;
  final AssetReminderService reminderService;
  final AssetReminderSettingsService settingsService;
  final AssetNotificationService notificationService;
  final ValueChanged<String>? onViewAsset;

  @override
  State<AssetRemindersPage> createState() => _AssetRemindersPageState();
}

class _AssetRemindersPageState extends State<AssetRemindersPage> {
  late Future<_ReminderViewState> _future;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ReminderViewState> _load() async {
    await widget.notificationService.initialize();
    final state = await widget.repository.loadState();
    final reminders = widget.reminderService.remindersFor(
      state.assets,
      state.settings,
    );
    final permission = await widget.notificationService.permissionState();
    if (state.settings.remindersEnabled && permission.enabled) {
      await widget.notificationService.scheduleDailySummary(
        settings: state.settings,
        reminderCount: reminders.length,
      );
    }
    return _ReminderViewState(
      state: state,
      reminders: reminders,
      permission: permission,
    );
  }

  Future<void> _reload() async {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _updateSettings(
    _ReminderViewState view,
    AppSettings next,
  ) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      var permission = view.permission;
      if (next.remindersEnabled && !permission.enabled) {
        final granted = await widget.notificationService.requestPermission();
        permission = NotificationPermissionState(
          supported: permission.supported,
          enabled: granted,
        );
        if (!granted && mounted) {
          _showSnack('系统通知未开启，App 内提醒仍可浏览');
        }
      }
      final saved = await widget.settingsService.updateSettings(
        remindersEnabled: next.remindersEnabled,
        reminderHour: next.reminderHour,
        reminderMinute: next.reminderMinute,
        warrantyReminderEnabled: next.warrantyReminderEnabled,
        idleReminderEnabled: next.idleReminderEnabled,
        maintenanceReminderEnabled: next.maintenanceReminderEnabled,
        warrantyLeadDays: next.warrantyLeadDays,
        idleThresholdDays: next.idleThresholdDays,
        maintenanceCycleDays: next.maintenanceCycleDays,
      );
      final state = AssetState(
        version: view.state.version,
        assets: view.state.assets,
        categories: view.state.categories,
        settings: saved,
      );
      final reminders = widget.reminderService.remindersFor(
        state.assets,
        saved,
      );
      if (saved.remindersEnabled && permission.enabled) {
        await widget.notificationService.scheduleDailySummary(
          settings: saved,
          reminderCount: reminders.length,
        );
      } else {
        await widget.notificationService.cancelDailySummary();
      }
      if (!mounted) return;
      setState(() {
        _future = Future.value(
          _ReminderViewState(
            state: state,
            reminders: reminders,
            permission: permission,
          ),
        );
      });
      _showSnack('提醒设置已保存');
    } catch (_) {
      if (mounted) _showSnack('提醒设置保存失败，请稍后重试');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return FutureBuilder<_ReminderViewState>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const BrandLoadingView(message: '正在读取提醒');
        }
        if (snapshot.hasError) {
          return _ReminderFrame(
            onBack: widget.onBack,
            child: DashboardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('提醒加载失败', style: TextStyle(color: theme.text)),
                  const SizedBox(height: AppSpacing.x3),
                  FilledButton(onPressed: _reload, child: const Text('重试')),
                ],
              ),
            ),
          );
        }
        final view = snapshot.data!;
        final settings = view.state.settings;
        final grouped = widget.reminderService.groupByType(view.reminders);
        return _ReminderFrame(
          onBack: widget.onBack,
          child: Column(
            children: [
              _ReminderStatusCard(
                view: view,
                saving: _saving,
                onChanged: (next) => _updateSettings(view, next),
                onToggle: (enabled) => _updateSettings(
                  view,
                  settings.copyWith(remindersEnabled: enabled),
                ),
              ),
              const SizedBox(height: AppSpacing.x4),
              _ReminderTypeCard(
                settings: settings,
                saving: _saving,
                onChanged: (next) => _updateSettings(view, next),
              ),
              const SizedBox(height: AppSpacing.x4),
              _ReminderSettingsCard(
                settings: settings,
                saving: _saving,
                onChanged: (next) => _updateSettings(view, next),
              ),
              const SizedBox(height: AppSpacing.x4),
              for (final type in AssetReminderType.values) ...[
                _ReminderGroupCard(
                  type: type,
                  reminders: grouped[type] ?? const [],
                  decimalDigits: settings.moneyDecimalDigits,
                  onViewAsset: widget.onViewAsset,
                ),
                const SizedBox(height: AppSpacing.x4),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ReminderViewState {
  const _ReminderViewState({
    required this.state,
    required this.reminders,
    required this.permission,
  });

  final AssetState state;
  final List<AssetReminder> reminders;
  final NotificationPermissionState permission;
}

class _ReminderFrame extends StatelessWidget {
  const _ReminderFrame({required this.onBack, required this.child});

  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return ListView(
      key: const Key('asset-reminders-scroll-view'),
      padding: EdgeInsets.fromLTRB(
        theme.isMinimal ? 28 : AppSpacing.x4,
        theme.isMinimal ? 32 : AppSpacing.x5,
        theme.isMinimal ? 28 : AppSpacing.x4,
        AppSpacing.x6,
      ),
      children: [
        TextButton.icon(
          key: const Key('settings-back-button'),
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
          label: const Text('返回设置'),
        ),
        const SizedBox(height: AppSpacing.x2),
        Text(
          '资产提醒',
          style: TextStyle(
            color: theme.text,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        Text('保修、闲置与保养通知', style: TextStyle(color: theme.muted, height: 1.4)),
        const SizedBox(height: AppSpacing.x4),
        child,
      ],
    );
  }
}

class _ReminderStatusCard extends StatelessWidget {
  const _ReminderStatusCard({
    required this.view,
    required this.saving,
    required this.onChanged,
    required this.onToggle,
  });

  final _ReminderViewState view;
  final bool saving;
  final ValueChanged<AppSettings> onChanged;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final settings = view.state.settings;
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '通知状态',
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Switch(
                key: const Key('asset-reminders-enabled-switch'),
                value: settings.remindersEnabled,
                onChanged: saving ? null : onToggle,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x3),
          Wrap(
            spacing: AppSpacing.x2,
            runSpacing: AppSpacing.x2,
            children: [
              _StatusPill(label: '今日提醒', value: '${view.reminders.length}'),
              _StatusPill(
                label: '通知权限',
                value: view.permission.enabled ? '已开启' : '未开启',
              ),
              _StatusPill(
                label: '下次通知',
                value:
                    '${_two(settings.reminderHour)}:${_two(settings.reminderMinute)}',
              ),
            ],
          ),
          if (settings.remindersEnabled && !view.permission.enabled) ...[
            const SizedBox(height: AppSpacing.x3),
            Text(
              '系统通知未开启，App 内提醒仍可浏览',
              style: TextStyle(color: theme.muted, height: 1.4),
            ),
          ],
          const SizedBox(height: AppSpacing.x3),
          _NumberSettingRow(
            keyName: 'reminder-hour',
            label: '通知小时',
            value: settings.reminderHour,
            min: 0,
            max: 23,
            enabled: !saving,
            onChanged: (value) =>
                onChanged(settings.copyWith(reminderHour: value)),
          ),
          _NumberSettingRow(
            keyName: 'reminder-minute',
            label: '通知分钟',
            value: settings.reminderMinute,
            min: 0,
            max: 59,
            enabled: !saving,
            onChanged: (value) =>
                onChanged(settings.copyWith(reminderMinute: value)),
          ),
        ],
      ),
    );
  }
}

class _ReminderTypeCard extends StatelessWidget {
  const _ReminderTypeCard({
    required this.settings,
    required this.saving,
    required this.onChanged,
  });

  final AppSettings settings;
  final bool saving;
  final ValueChanged<AppSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final enabled = settings.remindersEnabled && !saving;
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '提醒类型',
            style: TextStyle(
              color: theme.text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.x2),
          Text(
            '关闭某类提醒后，它不会出现在列表或每日通知中',
            style: TextStyle(color: theme.muted, height: 1.35),
          ),
          const SizedBox(height: AppSpacing.x3),
          _ReminderSwitchRow(
            keyName: 'warranty-reminder-enabled',
            label: '保修提醒',
            description: '保修到期前提醒',
            value: settings.warrantyReminderEnabled,
            enabled: enabled,
            onChanged: (value) =>
                onChanged(settings.copyWith(warrantyReminderEnabled: value)),
          ),
          _ReminderSwitchRow(
            keyName: 'idle-reminder-enabled',
            label: '闲置提醒',
            description: '长期未使用资产提醒',
            value: settings.idleReminderEnabled,
            enabled: enabled,
            onChanged: (value) =>
                onChanged(settings.copyWith(idleReminderEnabled: value)),
          ),
          _ReminderSwitchRow(
            keyName: 'maintenance-reminder-enabled',
            label: '保养提醒',
            description: '按保养周期提醒',
            value: settings.maintenanceReminderEnabled,
            enabled: enabled,
            onChanged: (value) =>
                onChanged(settings.copyWith(maintenanceReminderEnabled: value)),
          ),
        ],
      ),
    );
  }
}

class _ReminderSwitchRow extends StatelessWidget {
  const _ReminderSwitchRow({
    required this.keyName,
    required this.label,
    required this.description,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String keyName;
  final String label;
  final String description;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: enabled ? theme.text : theme.muted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(color: theme.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            key: Key(keyName),
            value: value,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}

class _ReminderSettingsCard extends StatelessWidget {
  const _ReminderSettingsCard({
    required this.settings,
    required this.saving,
    required this.onChanged,
  });

  final AppSettings settings;
  final bool saving;
  final ValueChanged<AppSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '提醒规则',
            style: TextStyle(
              color: theme.text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.x3),
          _NumberSettingRow(
            keyName: 'warranty-lead-days',
            label: '保修提前天数',
            value: settings.warrantyLeadDays,
            min: 1,
            max: 365,
            enabled: !saving,
            onChanged: (value) =>
                onChanged(settings.copyWith(warrantyLeadDays: value)),
          ),
          _NumberSettingRow(
            keyName: 'idle-threshold-days',
            label: '闲置天数',
            value: settings.idleThresholdDays,
            min: 1,
            max: 3650,
            enabled: !saving,
            onChanged: (value) =>
                onChanged(settings.copyWith(idleThresholdDays: value)),
          ),
          _NumberSettingRow(
            keyName: 'maintenance-cycle-days',
            label: '保养周期天数',
            value: settings.maintenanceCycleDays,
            min: 1,
            max: 3650,
            enabled: !saving,
            onChanged: (value) =>
                onChanged(settings.copyWith(maintenanceCycleDays: value)),
          ),
        ],
      ),
    );
  }
}

class _NumberSettingRow extends StatefulWidget {
  const _NumberSettingRow({
    required this.keyName,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.enabled,
    required this.onChanged,
  });

  final String keyName;
  final String label;
  final int value;
  final int min;
  final int max;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  State<_NumberSettingRow> createState() => _NumberSettingRowState();
}

class _NumberSettingRowState extends State<_NumberSettingRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant _NumberSettingRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        _controller.text != widget.value.toString()) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.label,
              style: TextStyle(color: theme.text, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            width: 96,
            child: TextField(
              key: Key('${widget.keyName}-field'),
              enabled: widget.enabled,
              controller: _controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: theme.numberStyle(fontSize: 16, color: theme.text),
              decoration: const InputDecoration(isDense: true),
              onSubmitted: _submit,
              onEditingComplete: () => _submit(_controller.text),
            ),
          ),
        ],
      ),
    );
  }

  void _submit(String value) {
    final parsed = int.tryParse(value) ?? widget.value;
    final next = parsed.clamp(widget.min, widget.max);
    _controller.text = next.toString();
    widget.onChanged(next);
  }
}

class _ReminderGroupCard extends StatelessWidget {
  const _ReminderGroupCard({
    required this.type,
    required this.reminders,
    required this.decimalDigits,
    required this.onViewAsset,
  });

  final AssetReminderType type;
  final List<AssetReminder> reminders;
  final int decimalDigits;
  final ValueChanged<String>? onViewAsset;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  type.label,
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${reminders.length}',
                style: theme.numberStyle(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x3),
          if (reminders.isEmpty)
            Text('暂无提醒', style: TextStyle(color: theme.muted))
          else
            ...reminders.map(
              (reminder) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.x2),
                child: _ReminderTile(
                  reminder: reminder,
                  decimalDigits: decimalDigits,
                  onViewAsset: onViewAsset == null
                      ? null
                      : () => onViewAsset!(reminder.asset.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.reminder,
    required this.decimalDigits,
    required this.onViewAsset,
  });

  final AssetReminder reminder;
  final int decimalDigits;
  final VoidCallback? onViewAsset;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final description = switch (reminder.type) {
      AssetReminderType.warranty => '${reminder.days} 天后到期',
      AssetReminderType.idle => '已闲置 ${reminder.days} 天',
      AssetReminderType.maintenance =>
        reminder.days <= 0 ? '今天需要保养' : '已超出 ${reminder.days} 天',
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.surfaceRaised,
        borderRadius: BorderRadius.circular(theme.cardRadius),
        border: theme.cardBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.asset.name,
                    style: TextStyle(
                      color: theme.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${reminder.asset.category} · $description · ${formatMoney(reminder.asset.currentValue, decimalDigits: decimalDigits)}',
                    style: TextStyle(color: theme.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: onViewAsset, child: const Text('查看资产')),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.surfaceRaised,
        borderRadius: BorderRadius.circular(theme.isPink ? 999 : 10),
        border: theme.cardBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: theme.muted, fontSize: 12)),
            const SizedBox(height: 2),
            Text(value, style: theme.numberStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

String _two(int value) => value.toString().padLeft(2, '0');
