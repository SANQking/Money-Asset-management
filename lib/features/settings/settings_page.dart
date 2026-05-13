import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme.dart';
import '../../domain/models/app_theme_mode.dart';
import '../../domain/models/asset_category.dart';
import '../../domain/models/asset_state.dart';
import '../../domain/repositories/asset_state_repository.dart';
import '../../shared/widgets/dashboard_card.dart';
import '../../shared/widgets/brand_loading_view.dart';
import '../migration/data_migration_page.dart';
import 'asset_notification_service.dart';
import 'asset_reminder_settings_service.dart';
import 'asset_reminders_page.dart';
import 'category_mutation_service.dart';
import 'display_settings_service.dart';

enum SettingsSection {
  home,
  preferences,
  dataManagement,
  categoryManagement,
  assetReminders,
}

class SettingsRoutes {
  const SettingsRoutes._();

  static const home = '/';
  static const preferences = '/preferences';
  static const data = '/data';
  static const categories = '/categories';
  static const reminders = '/reminders';
}

class SettingsPage extends StatefulWidget {
  SettingsPage({
    super.key,
    required this.repository,
    required this.themeController,
    this.navigatorKey,
    CategoryMutationService? categoryService,
    AssetReminderSettingsService? reminderSettingsService,
    AssetNotificationService? notificationService,
    DisplaySettingsService? displaySettingsService,
    this.onDataChanged,
  }) : categoryService =
           categoryService ?? CategoryMutationService(repository: repository),
       reminderSettingsService =
           reminderSettingsService ??
           AssetReminderSettingsService(repository: repository),
       notificationService =
           notificationService ?? FlutterAssetNotificationService(),
       displaySettingsService =
           displaySettingsService ??
           DisplaySettingsService(repository: repository);

  final AssetStateRepository repository;
  final AppThemeController themeController;
  final GlobalKey<NavigatorState>? navigatorKey;
  final CategoryMutationService categoryService;
  final AssetReminderSettingsService? reminderSettingsService;
  final AssetNotificationService? notificationService;
  final DisplaySettingsService displaySettingsService;
  final VoidCallback? onDataChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Future<AssetState> _stateFuture;
  AppThemeMode? _savingMode;

  @override
  void initState() {
    super.initState();
    _stateFuture = widget.repository.loadState();
  }

  void _reload() {
    setState(() {
      _stateFuture = widget.repository.loadState();
    });
  }

  void _openSection(BuildContext context, SettingsSection section) {
    final routeName = switch (section) {
      SettingsSection.home => SettingsRoutes.home,
      SettingsSection.preferences => SettingsRoutes.preferences,
      SettingsSection.dataManagement => SettingsRoutes.data,
      SettingsSection.categoryManagement => SettingsRoutes.categories,
      SettingsSection.assetReminders => SettingsRoutes.reminders,
    };
    debugPrint('GRZCGL settings route $routeName');
    Navigator.of(context).pushNamed(routeName);
  }

  Future<void> _selectTheme(AppThemeMode mode) async {
    if (_savingMode != null || mode == widget.themeController.mode) return;
    setState(() => _savingMode = mode);
    try {
      await widget.themeController.updateTheme(mode);
      if (!mounted) return;
      _showSnack('已切换到${mode.label}主题');
    } catch (_) {
      if (!mounted) return;
      _showSnack('主题保存失败，请稍后重试');
    } finally {
      if (mounted) setState(() => _savingMode = null);
    }
  }

  Future<void> _selectMoneyDecimalDigits(int digits) async {
    try {
      await widget.displaySettingsService.updateMoneyDecimalDigits(digits);
      _reload();
      if (!mounted) return;
      _showSnack('数字显示已更新');
    } catch (_) {
      if (!mounted) return;
      _showSnack('数字显示保存失败，请稍后重试');
    }
  }

  Future<void> _saveCategory({
    String? originalName,
    required String name,
    required String color,
  }) async {
    try {
      await widget.categoryService.saveCategory(
        originalName: originalName,
        name: name,
        color: color,
      );
      _reload();
      if (mounted) _showSnack(originalName == null ? '分类已新增' : '分类已更新');
    } catch (_) {
      if (mounted) _showSnack('分类保存失败，请检查名称和颜色');
    }
  }

  Future<void> _deleteCategory(String name) async {
    try {
      await widget.categoryService.deleteCategory(name);
      _reload();
      if (mounted) _showSnack('分类已删除');
    } catch (_) {
      if (mounted) _showSnack('该分类仍被资产使用，无法删除');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      initialRoute: SettingsRoutes.home,
      onGenerateRoute: (settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) {
            final theme = context.appTheme;
            return Scaffold(
              backgroundColor: theme.background,
              body: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: theme.pageGradient,
                  ),
                ),
                child: SafeArea(child: _buildSection(context, settings.name)),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, String? routeName) {
    return switch (routeName) {
      SettingsRoutes.preferences => _SettingsSectionFrame(
        title: '偏好设置',
        onBack: () => Navigator.of(context).pop(),
        child: _PreferencesSection(
          stateFuture: _stateFuture,
          themeController: widget.themeController,
          savingMode: _savingMode,
          onSelected: _selectTheme,
          onDecimalDigitsSelected: _selectMoneyDecimalDigits,
        ),
      ),
      SettingsRoutes.data => DataManagementSection(
        repository: widget.repository,
        onDataChanged: () {
          widget.onDataChanged?.call();
          _reload();
        },
        header: _SettingsSubHeader(
          title: '数据管理',
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
      SettingsRoutes.categories => FutureBuilder<AssetState>(
        future: _stateFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const BrandLoadingView(message: '正在读取分类');
          }
          return _SettingsSectionFrame(
            title: '分类管理',
            onBack: () => Navigator.of(context).pop(),
            child: _CategoryManagementSection(
              state: snapshot.data!,
              onAdd: () => _showCategoryForm(),
              onEdit: _showCategoryForm,
              onDelete: _deleteCategory,
            ),
          );
        },
      ),
      SettingsRoutes.reminders => AssetRemindersPage(
        repository: widget.repository,
        settingsService: widget.reminderSettingsService,
        notificationService: widget.notificationService,
        onBack: () => Navigator.of(context).pop(),
        onViewAsset: (_) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text('请到资产页查看详情')));
        },
      ),
      _ => _SettingsHome(onOpen: (section) => _openSection(context, section)),
    };
  }

  void _showCategoryForm([AssetCategory? category]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.appTheme.sheetRadius),
        ),
      ),
      builder: (context) => _CategoryFormSheet(
        category: category,
        onSave: (name, color) {
          Navigator.pop(context);
          _saveCategory(originalName: category?.name, name: name, color: color);
        },
      ),
    );
  }
}

class _SettingsHome extends StatelessWidget {
  const _SettingsHome({required this.onOpen});

  final ValueChanged<SettingsSection> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return ListView(
      key: const Key('settings-scroll-view'),
      padding: EdgeInsets.fromLTRB(
        theme.isMinimal ? 28 : AppSpacing.x4,
        theme.isMinimal ? 32 : AppSpacing.x5,
        theme.isMinimal ? 28 : AppSpacing.x4,
        AppSpacing.x6,
      ),
      children: [
        Text(
          '设置',
          style: TextStyle(
            color: theme.text,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: theme.isMinimal ? 28 : AppSpacing.x4),
        _SettingsMenuButton(
          buttonKey: const Key('settings-preferences-button'),
          icon: Icons.tune,
          title: '偏好设置',
          subtitle: '主题与显示偏好',
          onTap: () => onOpen(SettingsSection.preferences),
        ),
        const SizedBox(height: AppSpacing.x3),
        _SettingsMenuButton(
          buttonKey: const Key('settings-data-management-button'),
          icon: Icons.storage,
          title: '数据管理',
          subtitle: '导入、导出和恢复备份',
          onTap: () => onOpen(SettingsSection.dataManagement),
        ),
        const SizedBox(height: AppSpacing.x3),
        _SettingsMenuButton(
          buttonKey: const Key('settings-category-management-button'),
          icon: Icons.category_outlined,
          title: '分类管理',
          subtitle: '维护资产分类和颜色',
          onTap: () => onOpen(SettingsSection.categoryManagement),
        ),
        const SizedBox(height: AppSpacing.x3),
        _SettingsMenuButton(
          buttonKey: const Key('settings-asset-reminders-button'),
          icon: Icons.notifications_active_outlined,
          title: '资产提醒',
          subtitle: '保修、闲置与保养通知',
          onTap: () => onOpen(SettingsSection.assetReminders),
        ),
      ],
    );
  }
}

class _SettingsMenuButton extends StatelessWidget {
  const _SettingsMenuButton({
    required this.buttonKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Key buttonKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: buttonKey,
        borderRadius: BorderRadius.circular(theme.cardRadius),
        onTap: onTap,
        child: DashboardCard(
          child: Row(
            children: [
              Icon(icon, color: theme.accent, size: 28),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: theme.muted, height: 1.35),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSectionFrame extends StatelessWidget {
  const _SettingsSectionFrame({
    required this.title,
    required this.onBack,
    required this.child,
  });

  final String title;
  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return ListView(
      key: Key('settings-$title-scroll-view'),
      padding: EdgeInsets.fromLTRB(
        theme.isMinimal ? 28 : AppSpacing.x4,
        theme.isMinimal ? 32 : AppSpacing.x5,
        theme.isMinimal ? 28 : AppSpacing.x4,
        AppSpacing.x6,
      ),
      children: [
        _SettingsSubHeader(title: title, onBack: onBack),
        const SizedBox(height: AppSpacing.x4),
        child,
      ],
    );
  }
}

class _SettingsSubHeader extends StatelessWidget {
  const _SettingsSubHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          key: const Key('settings-back-button'),
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
          label: const Text('返回设置'),
        ),
        const SizedBox(height: AppSpacing.x2),
        Text(
          title,
          style: TextStyle(
            color: theme.text,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _PreferencesSection extends StatelessWidget {
  const _PreferencesSection({
    required this.stateFuture,
    required this.themeController,
    required this.savingMode,
    required this.onSelected,
    required this.onDecimalDigitsSelected,
  });

  final Future<AssetState> stateFuture;
  final AppThemeController themeController;
  final AppThemeMode? savingMode;
  final ValueChanged<AppThemeMode> onSelected;
  final ValueChanged<int> onDecimalDigitsSelected;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Column(
      children: [
        DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '主题',
                style: TextStyle(
                  color: theme.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: theme.isMinimal ? 24 : AppSpacing.x3),
              for (final mode in AppThemeMode.values)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: mode == AppThemeMode.values.last
                        ? 0
                        : AppSpacing.x3,
                  ),
                  child: _ThemeOptionTile(
                    mode: mode,
                    selected: themeController.mode == mode,
                    saving: savingMode == mode,
                    onSelected: () => onSelected(mode),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.x3),
        FutureBuilder<AssetState>(
          future: stateFuture,
          builder: (context, snapshot) {
            final digits = snapshot.data?.settings.moneyDecimalDigits ?? 0;
            return _DecimalDisplayCard(
              selectedDigits: digits,
              enabled: snapshot.connectionState == ConnectionState.done,
              onSelected: onDecimalDigitsSelected,
            );
          },
        ),
      ],
    );
  }
}

class _DecimalDisplayCard extends StatelessWidget {
  const _DecimalDisplayCard({
    required this.selectedDigits,
    required this.enabled,
    required this.onSelected,
  });

  final int selectedDigits;
  final bool enabled;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '数字显示',
            style: TextStyle(
              color: theme.muted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.x3),
          Text(
            '小数位数',
            style: TextStyle(
              color: theme.text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '只影响金额和统计的展示，不改变保存的数据',
            style: TextStyle(color: theme.muted, height: 1.35),
          ),
          const SizedBox(height: AppSpacing.x3),
          Wrap(
            spacing: AppSpacing.x2,
            runSpacing: AppSpacing.x2,
            children: [
              for (final digits in const [0, 1, 2])
                _SegmentButton(
                  keyName: 'decimal-digits-$digits',
                  label: '$digits 位',
                  selected: selectedDigits == digits,
                  enabled: enabled,
                  onTap: () => onSelected(digits),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.keyName,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String keyName;
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final background = selected
        ? theme.accent
        : theme.secondaryActionBackground;
    final foreground = selected
        ? theme.onAccent
        : theme.secondaryActionForeground;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key(keyName),
        borderRadius: BorderRadius.circular(
          theme.isPink ? 999 : theme.cardRadius,
        ),
        onTap: enabled ? onTap : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44, minWidth: 72),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x3,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: background.withValues(alpha: enabled ? 1 : 0.5),
            borderRadius: BorderRadius.circular(
              theme.isPink ? 999 : theme.cardRadius,
            ),
            border: theme.cardBorder,
            boxShadow: selected ? theme.primaryShadow : const [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(color: foreground, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.mode,
    required this.selected,
    required this.saving,
    required this.onSelected,
  });

  final AppThemeMode mode;
  final bool selected;
  final bool saving;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final optionTheme = AppThemeTokens.fromMode(mode);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('theme-option-${mode.value}'),
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        onTap: onSelected,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: EdgeInsets.all(appTheme.isMinimal ? 24 : AppSpacing.x3),
          decoration: BoxDecoration(
            color: selected
                ? appTheme.accent.withValues(
                    alpha: appTheme.isMinimal ? 0.06 : 0.12,
                  )
                : appTheme.surfaceRaised,
            borderRadius: BorderRadius.circular(appTheme.cardRadius),
            border: appTheme.cardBorder,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: optionTheme.background,
                  borderRadius: BorderRadius.circular(
                    optionTheme.isPink ? 22 : 10,
                  ),
                  border: optionTheme.hasPhysicalBorders
                      ? Border.all(color: optionTheme.border)
                      : null,
                  boxShadow: optionTheme.primaryShadow,
                ),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: optionTheme.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.label,
                      style: TextStyle(
                        color: appTheme.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _themeDescription(mode),
                      style: TextStyle(
                        color: appTheme.muted,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.x2),
              if (saving)
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: appTheme.accent,
                  ),
                )
              else
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? appTheme.accent : appTheme.muted,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _themeDescription(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.minimal => '黑白色搭配的极简美学',
      AppThemeMode.blackGold => '黑金色搭配的高级质感',
      AppThemeMode.pink => '浅粉色搭配的温馨氛围',
    };
  }
}

class _CategoryManagementSection extends StatelessWidget {
  const _CategoryManagementSection({
    required this.state,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final AssetState state;
  final VoidCallback onAdd;
  final ValueChanged<AssetCategory> onEdit;
  final ValueChanged<String> onDelete;

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
                  '资产分类',
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              FilledButton.icon(
                key: const Key('add-category-button'),
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('新增分类'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x3),
          if (state.categories.isEmpty)
            Text('暂无分类', style: TextStyle(color: theme.muted))
          else
            ...state.categories.map(
              (category) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.x2),
                child: _CategoryTile(
                  category: category,
                  assetCount: state.assets
                      .where((asset) => asset.category == category.name)
                      .length,
                  onEdit: () => onEdit(category),
                  onDelete: () => onDelete(category.name),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.assetCount,
    required this.onEdit,
    required this.onDelete,
  });

  final AssetCategory category;
  final int assetCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final color = _parseColor(category.color);
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
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      color: theme.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$assetCount 个资产 · ${category.color}',
                    style: TextStyle(color: theme.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              key: Key('edit-category-${category.name}'),
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: '编辑分类',
            ),
            IconButton(
              key: Key('delete-category-${category.name}'),
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              tooltip: '删除分类',
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFormSheet extends StatefulWidget {
  const _CategoryFormSheet({required this.category, required this.onSave});

  final AssetCategory? category;
  final void Function(String name, String color) onSave;

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  late final TextEditingController _name;
  late String _color;

  static const _colors = [
    '#4299e1',
    '#ed8936',
    '#9f7aea',
    '#48bb78',
    '#ecc94b',
    '#f56565',
    '#718096',
    '#D4AF37',
  ];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.category?.name ?? '');
    _color = widget.category?.color ?? _colors.first;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          theme.isMinimal ? 28 : AppSpacing.x4,
          AppSpacing.x4,
          theme.isMinimal ? 28 : AppSpacing.x4,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.x4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.category == null ? '新增分类' : '编辑分类',
              style: TextStyle(
                color: theme.text,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.x4),
            TextField(
              key: const Key('category-name-field'),
              controller: _name,
              style: TextStyle(color: theme.text),
              decoration: const InputDecoration(labelText: '分类名称'),
            ),
            const SizedBox(height: AppSpacing.x4),
            Text(
              '颜色',
              style: TextStyle(color: theme.muted, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.x2),
            Wrap(
              spacing: AppSpacing.x2,
              runSpacing: AppSpacing.x2,
              children: [
                for (final color in _colors)
                  InkWell(
                    key: Key('category-color-$color'),
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => setState(() => _color = color),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _parseColor(color),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _color == color
                              ? theme.text
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.x4),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('category-save-button'),
                onPressed: () => widget.onSave(_name.text, _color),
                child: const Text('保存分类'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _parseColor(String color) {
  final normalized = color.replaceFirst('#', '');
  final value = int.tryParse(normalized, radix: 16);
  if (value == null) return const Color(0xFF718096);
  return Color(0xFF000000 | value);
}
