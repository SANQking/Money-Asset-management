import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/theme/app_theme.dart';
import 'package:mobile/app/l10n/app_strings.dart';
import 'package:mobile/domain/models/app_settings.dart';
import 'package:mobile/domain/models/asset_state.dart';
import 'package:mobile/domain/models/backup_record.dart';
import 'package:mobile/domain/repositories/asset_state_repository.dart';
import 'package:mobile/domain/services/asset_normalizer.dart';
import 'package:mobile/domain/services/asset_stats_service.dart';
import 'package:mobile/features/assets/asset_filter_service.dart';
import 'package:mobile/features/assets/asset_image_picker_service.dart';
import 'package:mobile/features/assets/asset_list_page.dart';
import 'package:mobile/features/assets/asset_mutation_service.dart';

void main() {
  testWidgets('shows empty asset state', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AssetListPage(
          repository: _FakeAssetStateRepository(
            state: const AssetState(
              assets: [],
              categories: [],
              settings: AppSettings(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.assetsTitle), findsOneWidget);
    expect(find.text(AppStrings.noAssets), findsOneWidget);
  });

  testWidgets('renders asset cards and opens detail sheet', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AssetListPage(
          repository: _FakeAssetStateRepository(state: _sampleState()),
          statsService: const AssetStatsService(today: '2026-05-13'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('相机'), findsOneWidget);
    expect(find.text('摄影'), findsWidgets);
    expect(find.text('使用中'), findsOneWidget);
    expect(find.text('#旅行'), findsOneWidget);
    expect(find.text('¥23/天'), findsOneWidget);
    expect(find.text('购买价 ¥3,000'), findsOneWidget);
    expect(find.text('使用天数 132 天'), findsOneWidget);
    expect(find.text('购买日期 2026-01-01'), findsOneWidget);

    await tester.tap(find.text('相机'));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.assetDetail), findsNothing);
    await tester.scrollUntilVisible(
      find.byKey(const Key('asset-event-title-event-1')),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.lifecycle), findsOneWidget);
    expect(find.byKey(const Key('asset-event-title-event-1')), findsOneWidget);
    expect(find.text('全画幅'), findsOneWidget);
  });

  testWidgets('filters list by search and popup filters', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AssetListPage(
          repository: _FakeAssetStateRepository(state: _sampleState()),
          filterService: const AssetFilterService(today: '2026-05-13'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('asset-search-field')), '笔记本');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('asset-card-title-laptop')), findsOneWidget);
    expect(find.text('相机'), findsNothing);

    await tester.enterText(find.byKey(const Key('asset-search-field')), '');
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.allStatuses));
    await tester.pumpAndSettle();
    await tester.tap(find.text('已出售').last);
    await tester.pumpAndSettle();

    expect(find.text('鼠标'), findsOneWidget);
    expect(find.text('相机'), findsNothing);

    await tester.tap(find.byKey(const Key('asset-filter-chip-已出售')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.allStatuses).last);
    await tester.pumpAndSettle();

    expect(find.text('相机'), findsOneWidget);
    expect(find.text('笔记本'), findsOneWidget);
    expect(find.text('鼠标'), findsOneWidget);

    await tester.tap(find.text(AppStrings.allValues));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.unvaluedAssets).last);
    await tester.pumpAndSettle();

    expect(find.text('鼠标'), findsOneWidget);
    expect(find.text('相机'), findsNothing);
    expect(find.text('笔记本'), findsNothing);
  });

  testWidgets('shows error state and retries loading', (tester) async {
    final repository = _FakeAssetStateRepository(
      state: _sampleState(),
      failFirstLoad: true,
    );

    await tester.pumpWidget(_wrap(AssetListPage(repository: repository)));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.assetLoadFailed), findsOneWidget);
    await tester.tap(find.text(AppStrings.retry));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.assetsTitle), findsOneWidget);
    expect(repository.loadCount, 2);
  });

  testWidgets('adds asset and refreshes the list', (tester) async {
    final repository = _FakeAssetStateRepository(
      state: const AssetState(
        assets: [],
        categories: [],
        settings: AppSettings(),
      ),
    );

    await tester.pumpWidget(
      _wrap(
        AssetListPage(
          repository: repository,
          mutationService: _mutationService(repository, ids: ['new-asset']),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add-asset-button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('asset-name-field')), '新相机');
    await tester.enterText(
      find.byKey(const Key('asset-purchase-price-field')),
      '1999',
    );
    await _tapSaveAsset(tester);
    await tester.pumpAndSettle();

    expect(repository.state.assets.single.name, '新相机');
    expect(find.text('新相机'), findsOneWidget);
    expect(find.text('¥1,999/天'), findsOneWidget);
  });

  testWidgets('edits asset from detail sheet and refreshes card', (
    tester,
  ) async {
    final repository = _FakeAssetStateRepository(state: _sampleState());

    await tester.pumpWidget(
      _wrap(
        AssetListPage(
          repository: repository,
          mutationService: _mutationService(repository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('相机'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('edit-asset-button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('asset-name-field')), '相机 Pro');
    await tester.enterText(
      find.byKey(const Key('asset-purchase-price-field')),
      '3500',
    );
    await _tapSaveAsset(tester);
    await tester.pumpAndSettle();

    expect(repository.state.assets.first.name, '相机 Pro');
    expect(find.text('相机 Pro'), findsOneWidget);
    expect(find.text('相机'), findsNothing);
  });

  testWidgets('deletes asset after confirmation', (tester) async {
    final repository = _FakeAssetStateRepository(state: _sampleState());

    await tester.pumpWidget(
      _wrap(
        AssetListPage(
          repository: repository,
          mutationService: _mutationService(repository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('相机'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete-asset-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.deleteAsset).last);
    await tester.pumpAndSettle();

    expect(
      repository.state.assets.any((asset) => asset.id == 'camera'),
      isFalse,
    );
    expect(find.text('相机'), findsNothing);
  });

  testWidgets('adds lifecycle event from detail sheet', (tester) async {
    final repository = _FakeAssetStateRepository(state: _sampleState());

    await tester.pumpWidget(
      _wrap(
        AssetListPage(
          repository: repository,
          mutationService: _mutationService(repository, ids: ['event-new']),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('相机'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-event-button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('event-amount-field')), '120');
    await tester.enterText(find.byKey(const Key('event-notes-field')), '清洁维护');
    await tester.tap(find.byKey(const Key('event-save-button')));
    await tester.pumpAndSettle();

    final camera = repository.state.assets.firstWhere(
      (asset) => asset.id == 'camera',
    );
    expect(camera.events.map((event) => event.id), contains('event-new'));

    await tester.tap(find.text('相机'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('asset-event-title-event-new')),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('清洁维护'), findsOneWidget);
  });

  testWidgets(
    'asset form date fields use wheel picker and optional dates clear',
    (tester) async {
      final repository = _FakeAssetStateRepository(
        state: const AssetState(
          assets: [],
          categories: [],
          settings: AppSettings(),
        ),
      );

      await tester.pumpWidget(
        _wrap(
          AssetListPage(
            repository: repository,
            mutationService: _mutationService(repository, ids: ['new-asset']),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add-asset-button')));
      await tester.pumpAndSettle();

      await _scrollTo(tester, find.byKey(const Key('date-field-购买日期')));
      await tester.tap(find.byKey(const Key('date-field-购买日期')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('date-wheel-picker')), findsOneWidget);
      expect(find.byKey(const Key('date-wheel-clear-button')), findsNothing);
      await tester.tap(find.byKey(const Key('date-wheel-confirm-button')));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, '2026-05-13'), findsOneWidget);

      await _scrollTo(tester, find.byKey(const Key('date-field-估值日期')));
      await tester.tap(find.byKey(const Key('date-field-估值日期')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('date-wheel-clear-button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('date-wheel-confirm-button')));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, '2026-05-13'), findsNWidgets(2));

      await tester.tap(find.byKey(const Key('date-field-估值日期')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('date-wheel-clear-button')));
      await tester.pumpAndSettle();

      final valuationField = tester.widget<TextField>(
        find.byKey(const Key('date-field-估值日期')),
      );
      expect(valuationField.controller?.text, isEmpty);
    },
  );

  testWidgets(
    'asset form picks compressed image, previews it and saves data url',
    (tester) async {
      const dataUrl = 'data:image/png;base64,AQID';
      final repository = _FakeAssetStateRepository(
        state: const AssetState(
          assets: [],
          categories: [],
          settings: AppSettings(),
        ),
      );

      await tester.pumpWidget(
        _wrap(
          AssetListPage(
            repository: repository,
            mutationService: _mutationService(repository, ids: ['new-asset']),
            imagePickerService: const _FakeImagePickerService(dataUrl),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add-asset-button')));
      await tester.pumpAndSettle();

      expect(find.text('选择照片后在此预览'), findsOneWidget);
      final emptyPreview = tester.widget<AspectRatio>(
        find.ancestor(
          of: find.text('选择照片后在此预览'),
          matching: find.byType(AspectRatio),
        ),
      );
      expect(emptyPreview.aspectRatio, 1);
      await _scrollTo(tester, find.byKey(const Key('asset-pick-image-button')));
      await tester.tap(find.byKey(const Key('asset-pick-image-button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('asset-image-preview')), findsOneWidget);
      final imagePreview = tester.widget<AspectRatio>(
        find.ancestor(
          of: find.byKey(const Key('asset-image-preview')),
          matching: find.byType(AspectRatio),
        ),
      );
      expect(imagePreview.aspectRatio, 1);

      await tester.enterText(find.byKey(const Key('asset-name-field')), '图片资产');
      await tester.enterText(
        find.byKey(const Key('asset-purchase-price-field')),
        '1999',
      );
      await _tapSaveAsset(tester);
      await tester.pumpAndSettle();

      expect(repository.state.assets.single.image, dataUrl);
      expect(
        find.byKey(const Key('asset-card-image-new-asset')),
        findsOneWidget,
      );

      await tester.tap(find.text('图片资产'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('edit-asset-button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('asset-image-preview')), findsOneWidget);

      await _scrollTo(
        tester,
        find.byKey(const Key('asset-clear-image-button')),
      );
      await tester.tap(find.byKey(const Key('asset-clear-image-button')));
      await tester.pumpAndSettle();
      expect(find.text('选择照片后在此预览'), findsOneWidget);
      await _tapSaveAsset(tester);
      await tester.pumpAndSettle();

      expect(repository.state.assets.single.image, isEmpty);
      expect(find.byKey(const Key('asset-card-image-new-asset')), findsNothing);
    },
  );

  testWidgets(
    'asset form opens as a full screen page for smoother keyboard use',
    (tester) async {
      final repository = _FakeAssetStateRepository(
        state: const AssetState(
          assets: [],
          categories: [],
          settings: AppSettings(),
        ),
      );

      await tester.pumpWidget(
        _wrap(
          AssetListPage(
            repository: repository,
            mutationService: _mutationService(repository, ids: ['new-asset']),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add-asset-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('asset-form-page')), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);

      await _scrollTo(tester, find.byKey(const Key('asset-name-field')));
      await tester.tap(
        find.byKey(const Key('asset-name-field')),
        warnIfMissed: false,
      );
      await tester.pump();
      await _scrollTo(tester, find.byKey(const Key('asset-save-button')));

      expect(find.byKey(const Key('asset-form-page')), findsOneWidget);
      expect(find.byKey(const Key('asset-save-button')), findsOneWidget);
    },
  );

  testWidgets('event date uses wheel picker before saving lifecycle event', (
    tester,
  ) async {
    final repository = _FakeAssetStateRepository(state: _sampleState());

    await tester.pumpWidget(
      _wrap(
        AssetListPage(
          repository: repository,
          mutationService: _mutationService(repository, ids: ['event-new']),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('相机'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-event-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('date-field-事件日期')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('date-wheel-picker')), findsOneWidget);
    expect(find.byKey(const Key('date-wheel-clear-button')), findsNothing);
    await tester.tap(find.byKey(const Key('date-wheel-confirm-button')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('event-amount-field')), '120');
    await tester.tap(find.byKey(const Key('event-save-button')));
    await tester.pumpAndSettle();

    final camera = repository.state.assets.firstWhere(
      (asset) => asset.id == 'camera',
    );
    final event = camera.events.firstWhere((event) => event.id == 'event-new');
    expect(event.date, '2026-05-13');
  });

  testWidgets(
    'minimal theme gives search and each filter chip independent backgrounds',
    (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          AssetListPage(
            repository: _FakeAssetStateRepository(state: _sampleState()),
            filterService: const AssetFilterService(today: '2026-05-13'),
          ),
          theme: 'minimal',
        ),
      );
      await tester.pumpAndSettle();

      final searchField = tester.widget<TextField>(
        find.byKey(const Key('asset-search-field')),
      );
      final decoration = searchField.decoration!;
      expect(decoration.fillColor, const Color(0xFFF7F7F7));
      expect(decoration.enabledBorder, isA<OutlineInputBorder>());
      expect(
        (decoration.enabledBorder! as OutlineInputBorder).borderSide,
        BorderSide.none,
      );

      for (final label in [
        AppStrings.allCategories,
        AppStrings.allStatuses,
        AppStrings.allPrices,
        AppStrings.allTime,
        AppStrings.allReminders,
        AppStrings.allValues,
      ]) {
        final chip = tester.widget<Chip>(
          find.byKey(Key('asset-filter-chip-$label')),
        );
        expect(chip.backgroundColor, const Color(0xFFF1F1F1));
        expect(chip.side, BorderSide.none);
        expect(chip.labelStyle?.color, const Color(0xFF000000));
      }

      await tester.tap(find.text(AppStrings.allStatuses));
      await tester.pumpAndSettle();
      await tester.tap(find.text('已出售').last);
      await tester.pumpAndSettle();

      final selectedChip = tester.widget<Chip>(
        find.byKey(const Key('asset-filter-chip-已出售')),
      );
      expect(selectedChip.backgroundColor, const Color(0xFF000000));
      expect(selectedChip.labelStyle?.color, const Color(0xFFFFFFFF));
    },
  );

  testWidgets(
    'date wheel picker follows minimal, black gold and pink theme tokens',
    (tester) async {
      for (final entry in [
        (
          theme: 'minimal',
          background: const Color(0xFFFFFFFF),
          radius: 20.0,
          accent: const Color(0xFF000000),
        ),
        (
          theme: 'blackGold',
          background: const Color(0xFF1A1712),
          radius: 18.0,
          accent: const Color(0xFFD4AF37),
        ),
        (
          theme: 'pink',
          background: const Color(0xFFFFF5F7),
          radius: 28.0,
          accent: const Color(0xFFFF6B8B),
        ),
      ]) {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();

        final repository = _FakeAssetStateRepository(
          state: AssetState(
            assets: const [],
            categories: const [],
            settings: AppSettings(theme: entry.theme),
          ),
        );
        await tester.pumpWidget(
          _wrapWithTheme(
            AssetListPage(
              repository: repository,
              mutationService: _mutationService(repository),
            ),
            theme: entry.theme,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('add-asset-button')),
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();
        await _scrollTo(tester, find.byKey(const Key('date-field-购买日期')));
        await tester.tap(find.byKey(const Key('date-field-购买日期')));
        await tester.pumpAndSettle();

        final sheetDecoration = tester.widget<DecoratedBox>(
          find
              .ancestor(
                of: find.byKey(const Key('date-wheel-picker')),
                matching: find.byType(DecoratedBox),
              )
              .last,
        );
        final box = sheetDecoration.decoration as BoxDecoration;
        expect(box.color, entry.background);
        expect((box.borderRadius! as BorderRadius).topLeft.x, entry.radius);

        final confirm = tester.widget<FilledButton>(
          find.byKey(const Key('date-wheel-confirm-button')),
        );
        final style =
            confirm.style ??
            Theme.of(
              tester.element(
                find.byKey(const Key('date-wheel-confirm-button')),
              ),
            ).filledButtonTheme.style;
        expect(style?.backgroundColor?.resolve(<WidgetState>{}), entry.accent);

        await tester.tap(find.byKey(const Key('date-wheel-cancel-button')));
        await tester.pumpAndSettle();
      }
    },
  );

  testWidgets('shows save error when repository write fails', (tester) async {
    final repository = _FakeAssetStateRepository(
      state: const AssetState(
        assets: [],
        categories: [],
        settings: AppSettings(),
      ),
      failReplace: true,
    );

    await tester.pumpWidget(
      _wrap(
        AssetListPage(
          repository: repository,
          mutationService: _mutationService(repository, ids: ['new-asset']),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add-asset-button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('asset-name-field')), '失败资产');
    await _tapSaveAsset(tester);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.saveFailed), findsOneWidget);
    expect(repository.state.assets, isEmpty);
  });
}

AssetState _sampleState() {
  final normalizer = AssetNormalizer(idFactory: () => 'id');
  return normalizer.normalizeState({
    'assets': [
      {
        'id': 'camera',
        'name': '相机',
        'category': '摄影',
        'status': 'active',
        'purchasePrice': 3000,
        'purchaseDate': '2026-01-01',
        'currentValue': 2400,
        'warrantyUntil': '2026-06-01',
        'tags': ['旅行', '镜头'],
        'notes': '全画幅',
        'events': [
          {'id': 'event-1', 'type': '维修', 'date': '2024-06-01', 'amount': 100},
        ],
      },
      {
        'id': 'laptop',
        'name': '笔记本',
        'category': '数码',
        'status': 'idle',
        'purchasePrice': 8000,
        'purchaseDate': '2024-01-01',
        'currentValue': 5000,
      },
      {
        'id': 'mouse',
        'name': '鼠标',
        'category': '数码',
        'status': 'sold',
        'purchasePrice': 99,
        'purchaseDate': '2025-01-01',
        'salePrice': 50,
        'currentValue': 0,
      },
    ],
    'categories': [
      {'name': '摄影', 'color': '#123456'},
      {'name': '数码', 'color': '#4299e1'},
    ],
  });
}

Widget _wrap(Widget child) {
  return _wrapWithTheme(child);
}

Widget _wrapWithTheme(Widget child, {String theme = 'blackGold'}) {
  final controller = _TestThemeController(theme);
  return AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      return AppThemeScope(
        controller: controller,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: controller.tokens.toThemeData(),
          home: child,
        ),
      );
    },
  );
}

Future<void> _tapSaveAsset(WidgetTester tester) async {
  final saveButton = find.byKey(const Key('asset-save-button'));
  for (var i = 0; i < 8 && _isBelowViewport(tester, saveButton); i += 1) {
    await tester.drag(
      find.byKey(const Key('asset-sheet-scroll-view')),
      const Offset(0, -220),
    );
    await tester.pumpAndSettle();
  }
  await tester.tap(find.byKey(const Key('asset-save-button')));
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 10; i += 1) {
    if (finder.evaluate().isNotEmpty && !_isBelowViewport(tester, finder)) {
      return;
    }
    await tester.drag(
      find.byKey(const Key('asset-sheet-scroll-view')),
      const Offset(0, -220),
    );
    await tester.pumpAndSettle();
  }
}

bool _isBelowViewport(WidgetTester tester, Finder finder) {
  final rect = tester.getRect(finder);
  return rect.bottom >
      tester.view.physicalSize.height / tester.view.devicePixelRatio;
}

AssetMutationService _mutationService(
  _FakeAssetStateRepository repository, {
  List<String> ids = const [],
}) {
  var index = 0;
  return AssetMutationService(
    repository: repository,
    normalizer: AssetNormalizer(now: DateTime(2026, 5, 13)),
    clock: () => DateTime(2026, 5, 13),
    idFactory: () => ids.isEmpty ? 'id-${index++}' : ids[index++],
  );
}

class _FakeAssetStateRepository implements AssetStateRepository {
  _FakeAssetStateRepository({
    required this.state,
    this.failFirstLoad = false,
    this.failReplace = false,
  });

  AssetState state;
  final bool failFirstLoad;
  final bool failReplace;
  var loadCount = 0;

  @override
  Future<AppSettings> loadSettings() async => state.settings;

  @override
  Future<AssetState> loadState() async {
    loadCount += 1;
    if (failFirstLoad && loadCount == 1) {
      throw StateError('failed');
    }
    return state;
  }

  @override
  Future<List<BackupRecord>> loadBackups() async => const [];

  @override
  Future<BackupRecord> backupAssets({
    String label = 'Manual asset backup',
  }) async {
    return BackupRecord(id: 'backup', at: 'now', label: label, data: '{}');
  }

  @override
  Future<void> clearAssets({bool backupCurrent = false}) async {}

  @override
  Future<void> restoreBackup(BackupRecord backup) async {}

  @override
  Future<void> deleteBackup(String id) async {}

  @override
  Future<void> replaceState(AssetState state) async {
    if (failReplace) {
      throw StateError('replace failed');
    }
    this.state = state;
  }
}

class _FakeImagePickerService implements AssetImagePickerService {
  const _FakeImagePickerService(this.result);

  final String? result;

  @override
  Future<String?> pickCompressedImageDataUrl() async => result;
}

class _TestThemeController extends AppThemeController {
  _TestThemeController(String theme)
    : super(
        _FakeAssetStateRepository(
          state: AssetState(
            assets: const [],
            categories: const [],
            settings: AppSettings(theme: theme),
          ),
        ),
      ) {
    load();
  }
}
