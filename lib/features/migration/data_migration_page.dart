import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme.dart';
import '../../domain/models/backup_record.dart';
import '../../domain/repositories/asset_state_repository.dart';
import '../../shared/widgets/dashboard_card.dart';

class DataMigrationPage extends StatelessWidget {
  const DataMigrationPage({
    super.key,
    required this.repository,
    this.onDataChanged,
  });

  final AssetStateRepository repository;
  final VoidCallback? onDataChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.pageGradient,
          ),
        ),
        child: SafeArea(
          child: DataManagementSection(
            repository: repository,
            onDataChanged: onDataChanged,
            header: const _DataPageHeader(),
          ),
        ),
      ),
    );
  }
}

class DataManagementSection extends StatefulWidget {
  const DataManagementSection({
    super.key,
    required this.repository,
    this.onDataChanged,
    this.header,
  });

  final AssetStateRepository repository;
  final VoidCallback? onDataChanged;
  final Widget? header;

  @override
  State<DataManagementSection> createState() => _DataManagementSectionState();
}

class _DataManagementSectionState extends State<DataManagementSection> {
  late Future<List<BackupRecord>> _backupsFuture;
  var _busy = false;
  String? _busyBackupId;
  _BackupAction? _busyBackupAction;

  @override
  void initState() {
    super.initState();
    _backupsFuture = widget.repository.loadBackups();
  }

  void _refreshBackups() {
    setState(() {
      _backupsFuture = widget.repository.loadBackups();
    });
  }

  Future<void> _run(
    String successMessage,
    Future<void> Function() action,
    String failureMessage,
  ) async {
    setState(() => _busy = true);
    try {
      await action();
      widget.onDataChanged?.call();
      _refreshBackups();
      if (!mounted) return;
      _showSnack(successMessage);
    } catch (error, stackTrace) {
      debugPrint('Data management action failed: $error\n$stackTrace');
      if (!mounted) return;
      _showSnack(failureMessage);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _runBackupAction({
    required BackupRecord backup,
    required _BackupAction action,
    required String successMessage,
    required String failureMessage,
    required Future<void> Function() task,
  }) async {
    if (_busyBackupId != null) return;
    setState(() {
      _busyBackupId = backup.id;
      _busyBackupAction = action;
    });
    try {
      await task();
      widget.onDataChanged?.call();
      _refreshBackups();
      if (!mounted) return;
      _showSnack(successMessage);
    } on FormatException catch (error, stackTrace) {
      debugPrint('Backup is corrupted: $error\n$stackTrace');
      if (!mounted) return;
      _showSnack('备份已损坏，无法恢复');
    } catch (error, stackTrace) {
      debugPrint('Backup action failed: $error\n$stackTrace');
      if (!mounted) return;
      _showSnack(failureMessage);
    } finally {
      if (mounted) {
        setState(() {
          _busyBackupId = null;
          _busyBackupAction = null;
        });
      }
    }
  }

  Future<void> _clearAssets() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('清空资产数据', style: TextStyle(color: AppColors.text)),
        content: Text(
          '将删除所有资产和生命周期事件。分类、主题和备份会保留。',
          style: TextStyle(color: AppColors.muted, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('confirm-clear-assets-button'),
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('清空'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run(
      '资产数据已清空',
      () => widget.repository.clearAssets(backupCurrent: false),
      '清空失败，请稍后重试',
    );
  }

  Future<void> _backupAssets() async {
    await _run('资产数据已备份', () async {
      await widget.repository.backupAssets(label: 'Manual asset backup');
    }, '备份失败，请稍后重试');
  }

  Future<void> _restoreBackup(BackupRecord backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('恢复备份', style: TextStyle(color: AppColors.text)),
        content: Text(
          '将用 ${backup.at} 的备份覆盖当前 SQLite 数据。',
          style: TextStyle(color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('confirm-restore-backup-button'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('恢复'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _runBackupAction(
      backup: backup,
      action: _BackupAction.restore,
      successMessage: '备份已恢复',
      failureMessage: '恢复失败，请稍后重试',
      task: () => widget.repository.restoreBackup(backup),
    );
  }

  Future<void> _deleteBackup(BackupRecord backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('删除备份', style: TextStyle(color: AppColors.text)),
        content: Text(
          '将删除 ${backup.at} 的备份，此操作不会影响当前资产数据。',
          style: TextStyle(color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('confirm-delete-backup-button'),
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _runBackupAction(
      backup: backup,
      action: _BackupAction.delete,
      successMessage: '备份已删除',
      failureMessage: '删除失败，请稍后重试',
      task: () => widget.repository.deleteBackup(backup.id),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return ListView(
      key: const Key('data-migration-scroll-view'),
      padding: EdgeInsets.fromLTRB(
        theme.isMinimal ? 28 : AppSpacing.x4,
        theme.isMinimal ? 32 : AppSpacing.x5,
        theme.isMinimal ? 28 : AppSpacing.x4,
        AppSpacing.x6,
      ),
      children: [
        if (widget.header != null) ...[
          widget.header!,
          const SizedBox(height: AppSpacing.x4),
        ],
        if (_busy) LinearProgressIndicator(color: AppColors.gold),
        if (_busy) const SizedBox(height: AppSpacing.x4),
        _LocalDataCard(
          onClearAssets: _busy ? null : _clearAssets,
          onBackupAssets: _busy ? null : _backupAssets,
        ),
        const SizedBox(height: AppSpacing.x4),
        _BackupsCard(
          backupsFuture: _backupsFuture,
          onView: _showBackup,
          onRestore: _busy ? null : _restoreBackup,
          onDelete: _busy ? null : _deleteBackup,
          busyBackupId: _busyBackupId,
          busyBackupAction: _busyBackupAction,
        ),
      ],
    );
  }

  void _showBackup(BackupRecord backup) {
    final theme = context.appTheme;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(theme.sheetRadius),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.45,
        maxChildSize: 0.94,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: EdgeInsets.all(theme.isMinimal ? 28 : AppSpacing.x4),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    backup.label,
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('close-backup-view-button'),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x2),
            Text(backup.at, style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: AppSpacing.x4),
            SelectableText(
              backup.data,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _BackupAction { restore, delete }

class _DataPageHeader extends StatelessWidget {
  const _DataPageHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '数据管理',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '管理本机资产数据和自动备份。',
          style: TextStyle(color: AppColors.muted, fontSize: 14, height: 1.4),
        ),
      ],
    );
  }
}

class _LocalDataCard extends StatelessWidget {
  const _LocalDataCard({
    required this.onClearAssets,
    required this.onBackupAssets,
  });

  final VoidCallback? onClearAssets;
  final VoidCallback? onBackupAssets;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本机数据',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.x2),
          Text(
            '清空后会删除所有资产和生命周期事件。分类、主题和备份会保留。',
            style: TextStyle(color: AppColors.muted, height: 1.45),
          ),
          SizedBox(height: theme.isMinimal ? 24 : AppSpacing.x3),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  key: const Key('clear-assets-button'),
                  onPressed: onClearAssets,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.isMinimal
                        ? theme.secondaryActionBackground
                        : AppColors.danger,
                    foregroundColor: theme.isMinimal
                        ? AppColors.danger
                        : Colors.white,
                    minimumSize: const Size(44, 44),
                  ),
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: const Text('清空资产数据'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  key: const Key('backup-assets-button'),
                  onPressed: onBackupAssets,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.accent,
                    foregroundColor: theme.onAccent,
                    minimumSize: const Size(44, 44),
                  ),
                  icon: const Icon(Icons.backup_outlined),
                  label: const Text('备份资产数据'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackupsCard extends StatelessWidget {
  const _BackupsCard({
    required this.backupsFuture,
    required this.onView,
    required this.onRestore,
    required this.onDelete,
    required this.busyBackupId,
    required this.busyBackupAction,
  });

  final Future<List<BackupRecord>> backupsFuture;
  final ValueChanged<BackupRecord> onView;
  final ValueChanged<BackupRecord>? onRestore;
  final ValueChanged<BackupRecord>? onDelete;
  final String? busyBackupId;
  final _BackupAction? busyBackupAction;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return DashboardCard(
      child: FutureBuilder<List<BackupRecord>>(
        future: backupsFuture,
        builder: (context, snapshot) {
          final backups = snapshot.data ?? const <BackupRecord>[];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '备份',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.x2),
              if (snapshot.connectionState != ConnectionState.done)
                LinearProgressIndicator(color: AppColors.gold)
              else if (backups.isEmpty)
                Text('暂无备份', style: TextStyle(color: AppColors.muted))
              else
                ...backups.map(
                  (backup) => Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.x2),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(theme.cardRadius),
                        border: theme.cardBorder,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.x3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              backup.label,
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${backup.at} · ${backup.data.length} 字符',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.x2),
                            Wrap(
                              spacing: AppSpacing.x2,
                              runSpacing: AppSpacing.x2,
                              children: [
                                TextButton(
                                  key: Key('view-backup-${backup.id}'),
                                  onPressed: () => onView(backup),
                                  child: const Text('查看'),
                                ),
                                TextButton(
                                  key: Key('restore-backup-${backup.id}'),
                                  onPressed:
                                      onRestore == null ||
                                          busyBackupId == backup.id
                                      ? null
                                      : () => onRestore!(backup),
                                  child:
                                      busyBackupId == backup.id &&
                                          busyBackupAction ==
                                              _BackupAction.restore
                                      ? const Text('恢复中...')
                                      : const Text('恢复'),
                                ),
                                TextButton(
                                  key: Key('delete-backup-${backup.id}'),
                                  onPressed:
                                      onDelete == null ||
                                          busyBackupId == backup.id
                                      ? null
                                      : () => onDelete!(backup),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.danger,
                                  ),
                                  child:
                                      busyBackupId == backup.id &&
                                          busyBackupAction ==
                                              _BackupAction.delete
                                      ? const Text('删除中...')
                                      : const Text('删除'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
