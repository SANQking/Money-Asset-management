import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme.dart';
import '../../app/l10n/app_strings.dart';
import '../../core/utils/money_format.dart';
import '../../domain/models/asset.dart';
import '../../domain/models/asset_state.dart';
import '../../domain/repositories/asset_state_repository.dart';
import '../../domain/services/asset_stats_service.dart';
import '../../shared/widgets/dashboard_card.dart';
import '../../shared/widgets/brand_loading_view.dart';
import '../../shared/widgets/metric_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    required this.repository,
    this.statsService = const AssetStatsService(),
    this.onImportRequested,
    this.initialState,
  });

  final AssetStateRepository repository;
  final AssetStatsService statsService;
  final VoidCallback? onImportRequested;
  final AssetState? initialState;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<AssetState> _stateFuture;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<AssetState>(
          future: _stateFuture,
          initialData: widget.initialState,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _DashboardContent(
                state: snapshot.data!,
                statsService: widget.statsService,
                onImportRequested: widget.onImportRequested,
              );
            }
            if (snapshot.hasError) {
              return _DashboardError(message: '资产数据加载失败', onRetry: _reload);
            }
            return const BrandLoadingView(message: '正在读取本机数据');
          },
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.state,
    required this.statsService,
    required this.onImportRequested,
  });

  final AssetState state;
  final AssetStatsService statsService;
  final VoidCallback? onImportRequested;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final stats = statsService.stats(state.assets);
    final categoryItems = _categoryItems();
    final rankedAssets = [...state.assets]
      ..sort(
        (a, b) => statsService.realCost(b).compareTo(statsService.realCost(a)),
      );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: theme.pageGradient,
        ),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          theme.isMinimal ? 28 : AppSpacing.x4,
          theme.isMinimal ? 32 : AppSpacing.x5,
          theme.isMinimal ? 28 : AppSpacing.x4,
          AppSpacing.x6,
        ),
        children: [
          _DashboardHeader(themeMode: theme.mode),
          const SizedBox(height: AppSpacing.x4),
          _MetricGrid(
            stats: stats,
            decimalDigits: state.settings.moneyDecimalDigits,
          ),
          if (state.assets.isEmpty) ...[
            const SizedBox(height: AppSpacing.x4),
            _EmptyDashboard(onImportRequested: onImportRequested),
          ],
          const SizedBox(height: AppSpacing.x4),
          _ReminderCard(idle: stats.idle, expiring: stats.expiring),
          const SizedBox(height: AppSpacing.x4),
          _CategoryDistribution(
            items: categoryItems,
            decimalDigits: state.settings.moneyDecimalDigits,
          ),
          const SizedBox(height: AppSpacing.x4),
          _RealCostRank(
            assets: rankedAssets.take(10).toList(),
            statsService: statsService,
            decimalDigits: state.settings.moneyDecimalDigits,
          ),
        ],
      ),
    );
  }

  List<_CategoryItem> _categoryItems() {
    final itemsByName = <String, _CategoryItem>{};
    for (final category in state.categories) {
      final total = state.assets
          .where((asset) => asset.category == category.name)
          .fold<double>(
            0,
            (sum, asset) => sum + statsService.currentWorth(asset),
          );
      itemsByName[category.name] = _CategoryItem(
        name: category.name,
        color: category.color,
        amount: total,
      );
    }
    for (final asset in state.assets) {
      final rawName = asset.category.trim();
      final name = rawName.isEmpty ? '未分类' : rawName;
      if (itemsByName.containsKey(name)) continue;
      final total = state.assets
          .where((candidate) {
            final candidateName = candidate.category.trim();
            return (candidateName.isEmpty ? '未分类' : candidateName) == name;
          })
          .fold<double>(
            0,
            (sum, candidate) => sum + statsService.currentWorth(candidate),
          );
      itemsByName[name] = _CategoryItem(
        name: name,
        color: '#D4AF37',
        amount: total,
      );
    }
    final items = itemsByName.values.toList();
    items.sort((a, b) {
      final amountCompare = b.amount.compareTo(a.amount);
      if (amountCompare != 0) return amountCompare;
      return a.name.compareTo(b.name);
    });
    return items;
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.themeMode});

  final Object themeMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '资产仪表盘',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.dashboardSubtitle,
          style: TextStyle(color: AppColors.muted, fontSize: 14, height: 1.4),
        ),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.stats, required this.decimalDigits});

  final AssetStats stats;
  final int decimalDigits;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 720 ? 3 : 2;
    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: AppSpacing.x3,
      mainAxisSpacing: AppSpacing.x3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: width >= 720 ? 2.2 : 1.65,
      children: [
        MetricCard(label: AppStrings.assetCount, value: '${stats.count}'),
        MetricCard(
          label: AppStrings.originalValue,
          value: formatMoney(stats.original, decimalDigits: decimalDigits),
        ),
        MetricCard(
          label: AppStrings.currentValue,
          value: formatMoney(stats.worth, decimalDigits: decimalDigits),
          accentColor: AppColors.goldLight,
        ),
        MetricCard(
          label: AppStrings.depreciation,
          value: formatMoney(stats.depreciation, decimalDigits: decimalDigits),
        ),
        MetricCard(
          label: AppStrings.maintenanceCost,
          value: formatMoney(stats.repair, decimalDigits: decimalDigits),
        ),
        MetricCard(
          label: AppStrings.dailyCost,
          value: formatDailyCost(stats.dailyCost, decimalDigits: decimalDigits),
          accentColor: AppColors.goldLight,
        ),
      ],
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.idle, required this.expiring});

  final int idle;
  final int expiring;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: '提醒', themeMode: context.appTheme.mode),
          const SizedBox(height: AppSpacing.x3),
          Row(
            children: [
              Expanded(
                child: _ReminderTile(label: '长期闲置', value: idle),
              ),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: _ReminderTile(label: '保修将到期', value: expiring),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return DecoratedBox(
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
            Text(label, style: TextStyle(color: AppColors.muted, fontSize: 12)),
            const SizedBox(height: 6),
            Text('$value', style: theme.numberStyle(fontSize: 22)),
          ],
        ),
      ),
    );
  }
}

class _CategoryDistribution extends StatelessWidget {
  const _CategoryDistribution({
    required this.items,
    required this.decimalDigits,
  });

  final List<_CategoryItem> items;
  final int decimalDigits;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: AppStrings.categoryValueRank,
            themeMode: context.appTheme.mode,
          ),
          const SizedBox(height: AppSpacing.x2),
          if (items.isEmpty)
            Text('暂无可统计分类', style: TextStyle(color: AppColors.muted))
          else
            ...items.map(
              (item) => _CategoryRow(
                item: item,
                decimalDigits: decimalDigits,
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.item, required this.decimalDigits});

  final _CategoryItem item;
  final int decimalDigits;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.x3),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _parseColor(item.color),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          Expanded(
            child: Text(item.name, style: TextStyle(color: AppColors.text)),
          ),
          Text(
            formatMoney(item.amount, decimalDigits: decimalDigits),
            style: TextStyle(color: AppColors.goldLight),
          ),
        ],
      ),
    );
  }
}

class _RealCostRank extends StatelessWidget {
  const _RealCostRank({
    required this.assets,
    required this.statsService,
    required this.decimalDigits,
  });

  final List<Asset> assets;
  final AssetStatsService statsService;
  final int decimalDigits;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: '真实成本排行', themeMode: context.appTheme.mode),
          const SizedBox(height: AppSpacing.x2),
          if (assets.isEmpty)
            Text('暂无排行数据', style: TextStyle(color: AppColors.muted))
          else
            ...assets.asMap().entries.map(
              (entry) => _RankRow(
                index: entry.key + 1,
                asset: entry.value,
                amount: statsService.realCost(entry.value),
                decimalDigits: decimalDigits,
              ),
            ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.index,
    required this.asset,
    required this.amount,
    required this.decimalDigits,
  });

  final int index;
  final Asset asset;
  final double amount;
  final int decimalDigits;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.x3),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$index',
              style: TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              asset.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            formatMoney(amount, decimalDigits: decimalDigits),
            style: theme.numberStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard({required this.onImportRequested});

  final VoidCallback? onImportRequested;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: '暂无资产数据', themeMode: theme.mode),
          const SizedBox(height: AppSpacing.x2),
          Text(
            '当前 SQLite 数据库还没有资产。可以导入旧备份，或从资产页新增第一条资产。',
            style: TextStyle(color: theme.muted, height: 1.45),
          ),
          const SizedBox(height: AppSpacing.x3),
          Wrap(
            spacing: AppSpacing.x2,
            runSpacing: AppSpacing.x2,
            children: [
              FilledButton(
                key: const Key('dashboard-import-button'),
                onPressed: onImportRequested,
                child: const Text('导入旧备份'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x5),
        child: DashboardCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, style: TextStyle(color: AppColors.text)),
              const SizedBox(height: AppSpacing.x4),
              FilledButton(onPressed: onRetry, child: const Text('重试')),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.themeMode});

  final String title;
  final Object themeMode;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.text,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _CategoryItem {
  const _CategoryItem({
    required this.name,
    required this.color,
    required this.amount,
  });

  final String name;
  final String color;
  final double amount;
}

Color _parseColor(String value) {
  final match = RegExp(r'^#([0-9a-fA-F]{6})$').firstMatch(value);
  if (match == null) return AppColors.gold;
  return Color(int.parse('FF${match.group(1)}', radix: 16));
}
