import 'package:flutter/material.dart';

import 'dart:convert';

import '../../app/l10n/app_strings.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/money_format.dart';
import '../../domain/models/asset.dart';
import '../../domain/models/asset_state.dart';
import '../../domain/models/asset_status.dart';
import '../../domain/repositories/asset_state_repository.dart';
import '../../domain/services/asset_stats_service.dart';
import '../../shared/widgets/brand_loading_view.dart';
import '../../shared/widgets/dashboard_card.dart';
import '../../shared/widgets/date_wheel_field.dart';
import 'asset_image_picker_service.dart';
import 'asset_filter_service.dart';
import 'asset_mutation_service.dart';

class AssetListPage extends StatefulWidget {
  AssetListPage({
    super.key,
    required this.repository,
    this.statsService = const AssetStatsService(),
    this.filterService = const AssetFilterService(),
    AssetMutationService? mutationService,
    AssetImagePickerService? imagePickerService,
    this.onImportRequested,
    this.onDataChanged,
  }) : mutationService =
           mutationService ?? AssetMutationService(repository: repository),
       imagePickerService =
           imagePickerService ?? ImagePickerAssetImagePickerService();

  final AssetStateRepository repository;
  final AssetStatsService statsService;
  final AssetFilterService filterService;
  final AssetMutationService mutationService;
  final AssetImagePickerService imagePickerService;
  final VoidCallback? onImportRequested;
  final VoidCallback? onDataChanged;

  @override
  State<AssetListPage> createState() => _AssetListPageState();
}

class _AssetListPageState extends State<AssetListPage> {
  late Future<AssetState> _stateFuture;
  var _query = const AssetFilterQuery();

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

  void _handleDataChanged() {
    _reload();
    widget.onDataChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<AssetState>(
          future: _stateFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const BrandLoadingView(message: '正在读取资产列表');
            }
            if (snapshot.hasError) {
              return _AssetListError(onRetry: _reload);
            }
            final state = snapshot.data!;
            final filtered = widget.filterService.filter(
              state.assets,
              _query,
              state.categories,
            );
            return _AssetListContent(
              state: state,
              assets: filtered,
              query: _query,
              statsService: widget.statsService,
              mutationService: widget.mutationService,
              imagePickerService: widget.imagePickerService,
              onChanged: _handleDataChanged,
              onImportRequested: widget.onImportRequested,
              onQueryChanged: (query) => setState(() => _query = query),
            );
          },
        ),
      ),
    );
  }
}

class _AssetListContent extends StatelessWidget {
  const _AssetListContent({
    required this.state,
    required this.assets,
    required this.query,
    required this.statsService,
    required this.mutationService,
    required this.imagePickerService,
    required this.onChanged,
    required this.onImportRequested,
    required this.onQueryChanged,
  });

  final AssetState state;
  final List<Asset> assets;
  final AssetFilterQuery query;
  final AssetStatsService statsService;
  final AssetMutationService mutationService;
  final AssetImagePickerService imagePickerService;
  final VoidCallback onChanged;
  final VoidCallback? onImportRequested;
  final ValueChanged<AssetFilterQuery> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final decimalDigits = state.settings.moneyDecimalDigits;
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
          _AssetListHeader(
            onAdd: () => _showAssetForm(
              context,
              mutationService: mutationService,
              imagePickerService: imagePickerService,
              state: state,
              onSaved: onChanged,
            ),
          ),
          const SizedBox(height: AppSpacing.x4),
          _AssetFilters(
            state: state,
            query: query,
            onQueryChanged: onQueryChanged,
          ),
          const SizedBox(height: AppSpacing.x4),
          if (state.assets.isEmpty)
            _EmptyAssets(
              message: AppStrings.noAssets,
              onAdd: () => _showAssetForm(
                context,
                mutationService: mutationService,
                imagePickerService: imagePickerService,
                state: state,
                onSaved: onChanged,
              ),
              onImportRequested: onImportRequested,
            )
          else if (assets.isEmpty)
            const _EmptyAssets(message: AppStrings.noMatchedAssets)
          else
            ...assets.map(
              (asset) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.x3),
                child: _AssetCard(
                  asset: asset,
                  statsService: statsService,
                  decimalDigits: decimalDigits,
                  onTap: () => _showAssetDetail(
                    context,
                    asset,
                    state,
                    statsService,
                    mutationService,
                    imagePickerService,
                    decimalDigits,
                    onChanged,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AssetListHeader extends StatelessWidget {
  const _AssetListHeader({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.assetsTitle,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
            FilledButton(
              key: const Key('add-asset-button'),
              onPressed: onAdd,
              child: const Text(AppStrings.addAsset),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.assetListSubtitle,
          style: TextStyle(color: AppColors.muted, fontSize: 14, height: 1.4),
        ),
      ],
    );
  }
}

class _AssetFormSheet extends StatefulWidget {
  const _AssetFormSheet({
    required this.mutationService,
    required this.imagePickerService,
    required this.state,
    required this.onSaved,
    this.asset,
  });

  final AssetMutationService mutationService;
  final AssetImagePickerService imagePickerService;
  final AssetState state;
  final VoidCallback onSaved;
  final Asset? asset;

  @override
  State<_AssetFormSheet> createState() => _AssetFormSheetState();
}

class _AssetFormSheetState extends State<_AssetFormSheet> {
  late final TextEditingController _name;
  late final TextEditingController _purchasePrice;
  late final TextEditingController _purchaseDate;
  late final TextEditingController _currentValue;
  late final TextEditingController _valuationDate;
  late final TextEditingController _warrantyUntil;
  late final TextEditingController _lastUsedDate;
  late final TextEditingController _soldDate;
  late final TextEditingController _salePrice;
  late final TextEditingController _tags;
  late final TextEditingController _image;
  late final TextEditingController _notes;
  late String _category;
  late AssetStatus _status;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final draft = widget.asset == null
        ? AssetDraft.empty(
            today: widget.mutationService.today,
            category: widget.state.categories.isEmpty
                ? '其他'
                : widget.state.categories.first.name,
          )
        : AssetDraft.fromAsset(widget.asset!);
    _name = TextEditingController(text: draft.name);
    _purchasePrice = TextEditingController(text: draft.purchasePrice);
    _purchaseDate = TextEditingController(text: draft.purchaseDate);
    _currentValue = TextEditingController(text: draft.currentValue);
    _valuationDate = TextEditingController(text: draft.valuationDate);
    _warrantyUntil = TextEditingController(text: draft.warrantyUntil);
    _lastUsedDate = TextEditingController(text: draft.lastUsedDate);
    _soldDate = TextEditingController(text: draft.soldDate);
    _salePrice = TextEditingController(text: draft.salePrice);
    _tags = TextEditingController(text: draft.tags);
    _image = TextEditingController(text: draft.image);
    _notes = TextEditingController(text: draft.notes);
    _category = draft.category;
    _status = draft.status;
  }

  @override
  void dispose() {
    _name.dispose();
    _purchasePrice.dispose();
    _purchaseDate.dispose();
    _currentValue.dispose();
    _valuationDate.dispose();
    _warrantyUntil.dispose();
    _lastUsedDate.dispose();
    _soldDate.dispose();
    _salePrice.dispose();
    _tags.dispose();
    _image.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await widget.imagePickerService
          .pickCompressedImageDataUrl();
      if (image == null) return;
      setState(() => _image.text = image);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('图片选择失败，请换一张照片')));
    }
  }

  void _clearImage() {
    setState(() => _image.text = '');
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.mutationService.saveAsset(
        AssetDraft(
          name: _name.text,
          category: _category,
          status: _status,
          purchasePrice: _purchasePrice.text,
          purchaseDate: _purchaseDate.text,
          currentValue: _currentValue.text,
          valuationDate: _valuationDate.text,
          warrantyUntil: _warrantyUntil.text,
          lastUsedDate: _lastUsedDate.text,
          soldDate: _soldDate.text,
          salePrice: _salePrice.text,
          tags: _tags.text,
          image: _image.text,
          notes: _notes.text,
        ),
        editingId: widget.asset?.id,
      );
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.saveFailed)));
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.state.categories
        .map((category) => category.name)
        .toSet();
    final categoryOptions = categories.isEmpty
        ? <String>{_category}
        : categories;
    return Column(
      children: [
        _AssetImagePickerField(
          controller: _image,
          onPick: _pickImage,
          onClear: _clearImage,
        ),
        _TextField(
          controller: _name,
          label: AppStrings.assetName,
          keyName: 'asset-name-field',
        ),
        _Dropdown<String>(
          label: AppStrings.category,
          value: categoryOptions.contains(_category)
              ? _category
              : categoryOptions.first,
          items: categoryOptions.toList(),
          labelFor: (value) => value,
          onChanged: (value) => setState(() => _category = value),
        ),
        _Dropdown<AssetStatus>(
          label: AppStrings.status,
          value: _status,
          items: AssetStatus.values,
          labelFor: (value) => value.zhLabel,
          onChanged: (value) => setState(() => _status = value),
        ),
        _TextField(
          controller: _purchasePrice,
          label: AppStrings.purchasePrice,
          keyName: 'asset-purchase-price-field',
          keyboardType: TextInputType.number,
        ),
        DateWheelField(
          controller: _purchaseDate,
          label: AppStrings.purchaseDate,
          fallbackDate: widget.mutationService.today,
        ),
        _TextField(
          controller: _currentValue,
          label: AppStrings.currentValue,
          keyboardType: TextInputType.number,
        ),
        DateWheelField(
          controller: _valuationDate,
          label: AppStrings.valuationDate,
          fallbackDate: widget.mutationService.today,
          allowClear: true,
        ),
        DateWheelField(
          controller: _warrantyUntil,
          label: AppStrings.warrantyUntil,
          fallbackDate: widget.mutationService.today,
          allowClear: true,
        ),
        DateWheelField(
          controller: _lastUsedDate,
          label: AppStrings.lastUsedDate,
          fallbackDate: widget.mutationService.today,
          allowClear: true,
        ),
        DateWheelField(
          controller: _soldDate,
          label: AppStrings.soldDate,
          fallbackDate: widget.mutationService.today,
          allowClear: true,
        ),
        _TextField(
          controller: _salePrice,
          label: AppStrings.salePrice,
          keyboardType: TextInputType.number,
        ),
        _TextField(controller: _tags, label: AppStrings.tags),
        _TextField(controller: _image, label: AppStrings.imageUrl),
        _TextField(controller: _notes, label: AppStrings.notes, maxLines: 3),
        const SizedBox(height: AppSpacing.x4),
        SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('asset-save-button'),
              onPressed: _saving ? null : _save,
              child: Text(_saving ? AppStrings.saving : AppStrings.saveAsset),
            ),
          ),
        ),
      ],
    );
  }
}

class _AssetFormPage extends StatelessWidget {
  const _AssetFormPage({
    required this.mutationService,
    required this.imagePickerService,
    required this.state,
    required this.onSaved,
    this.asset,
  });

  final AssetMutationService mutationService;
  final AssetImagePickerService imagePickerService;
  final AssetState state;
  final VoidCallback onSaved;
  final Asset? asset;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final title = asset == null ? AppStrings.addAsset : AppStrings.editAsset;
    return Scaffold(
      key: const Key('asset-form-page'),
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.background,
        foregroundColor: theme.text,
        elevation: 0,
        title: Text(
          title,
          style: TextStyle(color: theme.text, fontWeight: FontWeight.w800),
        ),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.pageGradient,
          ),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            key: const Key('asset-sheet-scroll-view'),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              theme.isMinimal ? 28 : AppSpacing.x4,
              AppSpacing.x3,
              theme.isMinimal ? 28 : AppSpacing.x4,
              AppSpacing.x6,
            ),
            children: [
              _AssetFormSheet(
                mutationService: mutationService,
                imagePickerService: imagePickerService,
                state: state,
                asset: asset,
                onSaved: onSaved,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssetImagePickerField extends StatelessWidget {
  const _AssetImagePickerField({
    required this.controller,
    required this.onPick,
    required this.onClear,
  });

  final TextEditingController controller;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x4),
      child: DashboardCard(
        padding: AppSpacing.x3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '资产图片',
              style: TextStyle(color: theme.text, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.x3),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) =>
                  _AssetImagePreview(image: value.text),
            ),
            const SizedBox(height: AppSpacing.x3),
            Wrap(
              spacing: AppSpacing.x2,
              runSpacing: AppSpacing.x2,
              children: [
                FilledButton.icon(
                  key: const Key('asset-pick-image-button'),
                  onPressed: onPick,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('选择照片'),
                ),
                TextButton.icon(
                  key: const Key('asset-clear-image-button'),
                  onPressed: onClear,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('清除图片'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetImagePreview extends StatelessWidget {
  const _AssetImagePreview({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final provider = assetImageProvider(image);
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.cardRadius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.surfaceRaised,
            border: theme.cardBorder,
          ),
          child: provider == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image_outlined, color: theme.muted, size: 36),
                      const SizedBox(height: AppSpacing.x2),
                      Text('选择照片后在此预览', style: TextStyle(color: theme.muted)),
                    ],
                  ),
                )
              : Image(
                  key: const Key('asset-image-preview'),
                  image: provider,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text('图片无法预览', style: TextStyle(color: theme.muted)),
                  ),
                ),
        ),
      ),
    );
  }
}

ImageProvider? assetImageProvider(String value) {
  final raw = value.trim();
  if (raw.isEmpty) return null;
  final dataMatch = RegExp(
    r'^data:image/[a-z0-9.+-]+;base64,(.*)$',
    caseSensitive: false,
  ).firstMatch(raw);
  if (dataMatch != null) {
    try {
      return MemoryImage(
        base64Decode(dataMatch.group(1)!.replaceAll(RegExp(r'\s+'), '')),
      );
    } catch (_) {
      return null;
    }
  }
  if (raw.startsWith('https://')) return NetworkImage(raw);
  return null;
}

class _AssetFilters extends StatelessWidget {
  const _AssetFilters({
    required this.state,
    required this.query,
    required this.onQueryChanged,
  });

  final AssetState state;
  final AssetFilterQuery query;
  final ValueChanged<AssetFilterQuery> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return DashboardCard(
      child: Column(
        children: [
          TextField(
            key: const Key('asset-search-field'),
            style: TextStyle(color: AppColors.text),
            decoration: InputDecoration(
              labelText: AppStrings.searchAssets,
              labelStyle: TextStyle(color: theme.muted),
              filled: theme.isMinimal || theme.isPink,
              fillColor: theme.surfaceRaised,
              contentPadding: EdgeInsets.symmetric(
                horizontal: theme.isMinimal ? 18 : AppSpacing.x3,
                vertical: theme.isMinimal ? 16 : 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: theme.inputBorderSide,
                borderRadius: BorderRadius.circular(theme.isPink ? 18 : 10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: theme.focusedBorderSide,
                borderRadius: BorderRadius.circular(theme.isPink ? 18 : 10),
              ),
            ),
            onChanged: (value) => onQueryChanged(query.copyWith(text: value)),
          ),
          const SizedBox(height: AppSpacing.x3),
          Wrap(
            spacing: AppSpacing.x2,
            runSpacing: AppSpacing.x2,
            children: [
              _FilterChipMenu<String>(
                label: _categoryLabel(query.category),
                selected: query.category != 'all',
                options: [
                  const _FilterOption('all', AppStrings.allCategories),
                  ...state.categories.map(
                    (category) => _FilterOption(category.name, category.name),
                  ),
                ],
                onSelected: (value) =>
                    onQueryChanged(query.copyWith(category: value)),
              ),
              _FilterChipMenu<AssetStatusFilter>(
                label: AssetStatusFilterX.fromStatus(query.status).label,
                selected: query.status != null,
                options: [
                  for (final statusFilter in AssetStatusFilter.values)
                    _FilterOption(statusFilter, statusFilter.label),
                ],
                onSelected: (value) => onQueryChanged(
                  query.copyWith(
                    status: value.status,
                    clearStatus: value == AssetStatusFilter.all,
                  ),
                ),
              ),
              _FilterChipMenu<AssetPriceFilter>(
                label: _priceLabel(query.price),
                selected: query.price != AssetPriceFilter.all,
                options: const [
                  _FilterOption(AssetPriceFilter.all, AppStrings.allPrices),
                  _FilterOption(
                    AssetPriceFilter.under1000,
                    AppStrings.under1000,
                  ),
                  _FilterOption(
                    AssetPriceFilter.between1000And5000,
                    AppStrings.between1000And5000,
                  ),
                  _FilterOption(AssetPriceFilter.over5000, AppStrings.over5000),
                ],
                onSelected: (value) =>
                    onQueryChanged(query.copyWith(price: value)),
              ),
              _FilterChipMenu<AssetDateFilter>(
                label: _dateLabel(query.date),
                selected: query.date != AssetDateFilter.all,
                options: const [
                  _FilterOption(AssetDateFilter.all, AppStrings.allTime),
                  _FilterOption(
                    AssetDateFilter.withinYear,
                    AppStrings.withinYear,
                  ),
                  _FilterOption(AssetDateFilter.overYear, AppStrings.overYear),
                ],
                onSelected: (value) =>
                    onQueryChanged(query.copyWith(date: value)),
              ),
              _FilterChipMenu<AssetReminderFilter>(
                label: _reminderLabel(query.reminder),
                selected: query.reminder != AssetReminderFilter.all,
                options: const [
                  _FilterOption(
                    AssetReminderFilter.all,
                    AppStrings.allReminders,
                  ),
                  _FilterOption(
                    AssetReminderFilter.warranty,
                    AppStrings.warrantyFilter,
                  ),
                  _FilterOption(
                    AssetReminderFilter.idle,
                    AppStrings.idleFilter,
                  ),
                ],
                onSelected: (value) =>
                    onQueryChanged(query.copyWith(reminder: value)),
              ),
              _FilterChipMenu<AssetValueFilter>(
                label: _valueLabel(query.value),
                selected: query.value != AssetValueFilter.all,
                options: const [
                  _FilterOption(AssetValueFilter.all, AppStrings.allValues),
                  _FilterOption(
                    AssetValueFilter.valued,
                    AppStrings.valuedAssets,
                  ),
                  _FilterOption(
                    AssetValueFilter.unvalued,
                    AppStrings.unvaluedAssets,
                  ),
                ],
                onSelected: (value) =>
                    onQueryChanged(query.copyWith(value: value)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _categoryLabel(String category) {
    return category == 'all' ? AppStrings.allCategories : category;
  }
}

class _FilterChipMenu<T> extends StatelessWidget {
  const _FilterChipMenu({
    required this.label,
    required this.selected,
    required this.options,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final List<_FilterOption<T>> options;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final chipBackground = theme.isMinimal && selected
        ? theme.accent
        : theme.secondaryActionBackground;
    final chipForeground = theme.isMinimal && selected
        ? theme.onAccent
        : theme.secondaryActionForeground;
    return PopupMenuButton<T>(
      onSelected: onSelected,
      color: theme.isMinimal ? AppColors.surface : AppColors.surfaceRaised,
      constraints: const BoxConstraints(minWidth: 150),
      itemBuilder: (context) => [
        for (final option in options)
          PopupMenuItem<T>(
            value: option.value,
            height: 44,
            child: Text(
              option.label,
              style: TextStyle(
                color: theme.isMinimal ? theme.text : AppColors.text,
                fontWeight: theme.isMinimal ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
      ],
      child: Chip(
        key: Key('asset-filter-chip-$label'),
        label: Text(label),
        backgroundColor: chipBackground,
        side: theme.hasPhysicalBorders
            ? BorderSide(color: AppColors.border)
            : BorderSide.none,
        padding: EdgeInsets.symmetric(
          horizontal: theme.isMinimal ? 12 : 8,
          vertical: theme.isMinimal ? 10 : 6,
        ),
        labelStyle: TextStyle(
          color: theme.isMinimal ? chipForeground : AppColors.goldLight,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FilterOption<T> {
  const _FilterOption(this.value, this.label);

  final T value;
  final String label;
}

class _AssetCard extends StatelessWidget {
  const _AssetCard({
    required this.asset,
    required this.statsService,
    required this.decimalDigits,
    required this.onTap,
  });

  final Asset asset;
  final AssetStatsService statsService;
  final int decimalDigits;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(theme.cardRadius),
      onTap: onTap,
      child: DashboardCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AssetThumb(asset: asset),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          asset.name,
                          key: Key('asset-card-title-${asset.id}'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        formatDailyCost(
                          statsService.dailyCost(asset),
                          decimalDigits: decimalDigits,
                        ),
                        style: theme.numberStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _Pill(asset.status.zhLabel),
                      _Pill(asset.category),
                      for (final tag in asset.tags.take(3)) _Pill('#$tag'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      _AssetMetaText(
                        '${AppStrings.purchasePrice} ${formatMoney(asset.purchasePrice, decimalDigits: decimalDigits)}',
                      ),
                      _AssetMetaText('使用天数 ${statsService.usedDays(asset)} 天'),
                      _AssetMetaText(
                        '${AppStrings.purchaseDate} ${asset.purchaseDate}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetMetaText extends StatelessWidget {
  const _AssetMetaText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.25),
    );
  }
}

class _AssetThumb extends StatelessWidget {
  const _AssetThumb({required this.asset});

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    final initial = asset.name.isEmpty ? '?' : asset.name.characters.first;
    final theme = context.appTheme;
    final provider = assetImageProvider(asset.image);
    final fallback = Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.goldLight, AppColors.gold]),
        borderRadius: BorderRadius.circular(theme.cardRadius),
        boxShadow: theme.primaryShadow,
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: theme.onAccent,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
    if (provider == null) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(theme.cardRadius),
      child: SizedBox(
        width: 52,
        height: 52,
        child: Image(
          key: Key('asset-card-image-${asset.id}'),
          image: provider,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fallback,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(999),
        border: theme.cardBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          text,
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ),
    );
  }
}

class _EmptyAssets extends StatelessWidget {
  const _EmptyAssets({
    required this.message,
    this.onAdd,
    this.onImportRequested,
  });

  final String message;
  final VoidCallback? onAdd;
  final VoidCallback? onImportRequested;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.x5),
        child: Column(
          children: [
            Text(message, style: TextStyle(color: AppColors.muted)),
            if (onAdd != null || onImportRequested != null) ...[
              const SizedBox(height: AppSpacing.x3),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.x2,
                runSpacing: AppSpacing.x2,
                children: [
                  if (onAdd != null)
                    FilledButton(
                      key: const Key('empty-add-asset-button'),
                      onPressed: onAdd,
                      child: const Text('新增第一条资产'),
                    ),
                  if (onImportRequested != null)
                    OutlinedButton(
                      key: const Key('empty-import-button'),
                      onPressed: onImportRequested,
                      child: const Text('导入旧备份'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AssetListError extends StatelessWidget {
  const _AssetListError({required this.onRetry});

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
              Text(
                AppStrings.assetLoadFailed,
                style: TextStyle(color: AppColors.text),
              ),
              const SizedBox(height: AppSpacing.x4),
              FilledButton(
                onPressed: onRetry,
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showAssetDetail(
  BuildContext context,
  Asset asset,
  AssetState state,
  AssetStatsService statsService,
  AssetMutationService mutationService,
  AssetImagePickerService imagePickerService,
  int decimalDigits,
  VoidCallback onChanged,
) {
  final theme = AppThemeScope.tokensOf(context);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(theme.sheetRadius),
      ),
    ),
    builder: (context) => _AssetDetailSheet(
      asset: asset,
      state: state,
      statsService: statsService,
      mutationService: mutationService,
      imagePickerService: imagePickerService,
      decimalDigits: decimalDigits,
      onChanged: onChanged,
    ),
  );
}

class _AssetDetailSheet extends StatelessWidget {
  const _AssetDetailSheet({
    required this.asset,
    required this.state,
    required this.statsService,
    required this.mutationService,
    required this.imagePickerService,
    required this.decimalDigits,
    required this.onChanged,
  });

  final Asset asset;
  final AssetState state;
  final AssetStatsService statsService;
  final AssetMutationService mutationService;
  final AssetImagePickerService imagePickerService;
  final int decimalDigits;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      maxChildSize: 0.92,
      minChildSize: 0.45,
      builder: (context, controller) {
        return ListView(
          key: const Key('asset-sheet-scroll-view'),
          controller: controller,
          padding: EdgeInsets.all(theme.isMinimal ? 28 : AppSpacing.x4),
          children: [
            Text(
              asset.name,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.x2),
            Wrap(
              spacing: AppSpacing.x2,
              runSpacing: AppSpacing.x2,
              children: [
                FilledButton(
                  key: const Key('edit-asset-button'),
                  onPressed: () {
                    Navigator.pop(context);
                    _showAssetForm(
                      context,
                      mutationService: mutationService,
                      imagePickerService: imagePickerService,
                      state: state,
                      asset: asset,
                      onSaved: onChanged,
                    );
                  },
                  child: const Text(AppStrings.editAsset),
                ),
                OutlinedButton(
                  key: const Key('delete-asset-button'),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _confirmDeleteAsset(
                      context,
                      mutationService,
                      asset.id,
                      onChanged,
                    );
                  },
                  child: const Text(AppStrings.deleteAsset),
                ),
                OutlinedButton(
                  key: const Key('add-event-button'),
                  onPressed: () {
                    Navigator.pop(context);
                    _showEventForm(
                      context,
                      mutationService: mutationService,
                      assetId: asset.id,
                      onSaved: onChanged,
                    );
                  },
                  child: const Text(AppStrings.addEvent),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x3),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _Pill(asset.status.zhLabel),
                _Pill(asset.category),
                for (final tag in asset.tags) _Pill('#$tag'),
              ],
            ),
            const SizedBox(height: AppSpacing.x4),
            DashboardCard(
              child: Column(
                children: [
                  _DetailRow(
                    AppStrings.purchasePrice,
                    formatMoney(
                      asset.purchasePrice,
                      decimalDigits: decimalDigits,
                    ),
                  ),
                  _DetailRow(
                    AppStrings.valuation,
                    formatMoney(
                      asset.currentValue,
                      decimalDigits: decimalDigits,
                    ),
                  ),
                  _DetailRow(
                    AppStrings.maintenanceCost,
                    formatMoney(
                      statsService.maintenanceCost(asset),
                      decimalDigits: decimalDigits,
                    ),
                  ),
                  _DetailRow(
                    AppStrings.realCost,
                    formatMoney(
                      statsService.realCost(asset),
                      decimalDigits: decimalDigits,
                    ),
                  ),
                  _DetailRow(
                    '日均成本',
                    formatDailyCost(
                      statsService.dailyCost(asset),
                      decimalDigits: decimalDigits,
                    ),
                  ),
                  _DetailRow('使用天数', '${statsService.usedDays(asset)} 天'),
                  _DetailRow(AppStrings.purchaseDate, asset.purchaseDate),
                  _DetailRow(
                    AppStrings.valuationDate,
                    _valueOrEmpty(asset.valuationDate),
                  ),
                  _DetailRow(
                    AppStrings.warrantyUntil,
                    _valueOrEmpty(asset.warrantyUntil),
                  ),
                  _DetailRow(
                    AppStrings.lastUsedDate,
                    _valueOrEmpty(asset.lastUsedDate),
                  ),
                  _DetailRow(
                    AppStrings.soldDate,
                    _valueOrEmpty(asset.soldDate),
                  ),
                  _DetailRow(
                    AppStrings.salePrice,
                    formatMoney(asset.salePrice, decimalDigits: decimalDigits),
                  ),
                ],
              ),
            ),
            if (asset.notes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.x4),
              Text(
                AppStrings.notes,
                style: TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.x2),
              Text(
                asset.notes,
                style: TextStyle(color: AppColors.muted, height: 1.45),
              ),
            ],
            const SizedBox(height: AppSpacing.x4),
            Text(
              AppStrings.lifecycle,
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.x2),
            if (asset.events.isEmpty)
              Text(
                AppStrings.notFilled,
                style: TextStyle(color: AppColors.muted),
              )
            else
              ...asset.events.map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.x2),
                  child: DashboardCard(
                    padding: AppSpacing.x3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${event.type} · ${event.date}',
                          key: Key('asset-event-title-${event.id}'),
                          style: TextStyle(
                            color: AppColors.goldLight,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (event.amount != 0)
                          Text(
                            formatMoney(
                              event.amount,
                              decimalDigits: decimalDigits,
                            ),
                            style: TextStyle(color: AppColors.text),
                          ),
                        if (event.notes.isNotEmpty)
                          Text(
                            event.notes,
                            style: TextStyle(color: AppColors.muted),
                          ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            key: Key('delete-event-${event.id}'),
                            onPressed: () async {
                              try {
                                await mutationService.deleteEvent(
                                  asset.id,
                                  event.id,
                                );
                                if (context.mounted) Navigator.pop(context);
                                onChanged();
                              } catch (_) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(AppStrings.saveFailed),
                                  ),
                                );
                              }
                            },
                            child: const Text(AppStrings.deleteEvent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EventFormSheet extends StatefulWidget {
  const _EventFormSheet({
    required this.mutationService,
    required this.assetId,
    required this.onSaved,
  });

  final AssetMutationService mutationService;
  final String assetId;
  final VoidCallback onSaved;

  @override
  State<_EventFormSheet> createState() => _EventFormSheetState();
}

class _EventFormSheetState extends State<_EventFormSheet> {
  late final TextEditingController _date;
  late final TextEditingController _amount;
  late final TextEditingController _notes;
  var _type = '维修';
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _date = TextEditingController(text: widget.mutationService.today);
    _amount = TextEditingController();
    _notes = TextEditingController();
  }

  @override
  void dispose() {
    _date.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.mutationService.addEvent(
        widget.assetId,
        AssetEventDraft(
          type: _type,
          date: _date.text,
          amount: _amount.text,
          notes: _notes.text,
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.saveFailed)));
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: AppStrings.addEvent,
      child: Column(
        children: [
          _Dropdown<String>(
            label: AppStrings.eventType,
            value: _type,
            items: const ['购买', '维修', '保养', '估值', '使用', '出售', '报废', '备注'],
            labelFor: (value) => value,
            onChanged: (value) => setState(() => _type = value),
          ),
          DateWheelField(
            controller: _date,
            label: AppStrings.eventDate,
            fallbackDate: widget.mutationService.today,
          ),
          _TextField(
            controller: _amount,
            label: AppStrings.eventAmount,
            keyName: 'event-amount-field',
            keyboardType: TextInputType.number,
          ),
          _TextField(
            controller: _notes,
            label: AppStrings.notes,
            keyName: 'event-notes-field',
          ),
          const SizedBox(height: AppSpacing.x4),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('event-save-button'),
              onPressed: _saving ? null : _save,
              child: Text(_saving ? AppStrings.saving : AppStrings.saveEvent),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.86,
      maxChildSize: 0.94,
      minChildSize: 0.42,
      builder: (context, controller) {
        return ListView(
          key: const Key('asset-sheet-scroll-view'),
          controller: controller,
          padding: EdgeInsets.all(theme.isMinimal ? 28 : AppSpacing.x4),
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.x4),
            child,
          ],
        );
      },
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    this.keyName,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String? keyName;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x3),
      child: TextField(
        key: keyName == null ? null : Key(keyName!),
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(color: AppColors.text),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: theme.muted),
          enabledBorder: OutlineInputBorder(
            borderSide: theme.inputBorderSide,
            borderRadius: BorderRadius.circular(theme.isPink ? 18 : 10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: theme.focusedBorderSide,
            borderRadius: BorderRadius.circular(theme.isPink ? 18 : 10),
          ),
        ),
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.labelFor,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T value) labelFor;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x3),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        dropdownColor: AppColors.surfaceRaised,
        style: TextStyle(color: AppColors.text),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: theme.muted),
          enabledBorder: OutlineInputBorder(
            borderSide: theme.inputBorderSide,
            borderRadius: BorderRadius.circular(theme.isPink ? 18 : 10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: theme.focusedBorderSide,
            borderRadius: BorderRadius.circular(theme.isPink ? 18 : 10),
          ),
        ),
        items: [
          for (final item in items)
            DropdownMenuItem<T>(value: item, child: Text(labelFor(item))),
        ],
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: AppColors.muted)),
          ),
          Text(
            value,
            style: theme.numberStyle(
              fontSize: 14,
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String _valueOrEmpty(String value) =>
    value.isEmpty ? AppStrings.notFilled : value;

void _showAssetForm(
  BuildContext context, {
  required AssetMutationService mutationService,
  required AssetImagePickerService imagePickerService,
  required AssetState state,
  required VoidCallback onSaved,
  Asset? asset,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => _AssetFormPage(
        mutationService: mutationService,
        imagePickerService: imagePickerService,
        state: state,
        asset: asset,
        onSaved: onSaved,
      ),
      fullscreenDialog: true,
    ),
  );
}

void _showEventForm(
  BuildContext context, {
  required AssetMutationService mutationService,
  required String assetId,
  required VoidCallback onSaved,
}) {
  final theme = AppThemeScope.tokensOf(context);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(theme.sheetRadius),
      ),
    ),
    builder: (context) => _EventFormSheet(
      mutationService: mutationService,
      assetId: assetId,
      onSaved: onSaved,
    ),
  );
}

Future<void> _confirmDeleteAsset(
  BuildContext context,
  AssetMutationService mutationService,
  String assetId,
  VoidCallback onDeleted,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        AppStrings.confirmDelete,
        style: TextStyle(color: AppColors.text),
      ),
      content: Text(
        AppStrings.deleteAsset,
        style: TextStyle(color: AppColors.muted),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(AppStrings.deleteAsset),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await mutationService.deleteAsset(assetId);
  onDeleted();
}

String _priceLabel(AssetPriceFilter value) {
  return switch (value) {
    AssetPriceFilter.all => AppStrings.allPrices,
    AssetPriceFilter.under1000 => AppStrings.under1000,
    AssetPriceFilter.between1000And5000 => AppStrings.between1000And5000,
    AssetPriceFilter.over5000 => AppStrings.over5000,
  };
}

String _dateLabel(AssetDateFilter value) {
  return switch (value) {
    AssetDateFilter.all => AppStrings.allTime,
    AssetDateFilter.withinYear => AppStrings.withinYear,
    AssetDateFilter.overYear => AppStrings.overYear,
  };
}

String _reminderLabel(AssetReminderFilter value) {
  return switch (value) {
    AssetReminderFilter.all => AppStrings.allReminders,
    AssetReminderFilter.warranty => AppStrings.warrantyFilter,
    AssetReminderFilter.idle => AppStrings.idleFilter,
  };
}

String _valueLabel(AssetValueFilter value) {
  return switch (value) {
    AssetValueFilter.all => AppStrings.allValues,
    AssetValueFilter.valued => AppStrings.valuedAssets,
    AssetValueFilter.unvalued => AppStrings.unvaluedAssets,
  };
}
