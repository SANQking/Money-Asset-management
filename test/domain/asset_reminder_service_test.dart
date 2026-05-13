import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/models/app_settings.dart';
import 'package:mobile/domain/models/asset_reminder.dart';
import 'package:mobile/domain/services/asset_normalizer.dart';
import 'package:mobile/domain/services/asset_reminder_service.dart';

void main() {
  test('computes warranty reminder boundaries', () {
    final normalizer = AssetNormalizer(idFactory: () => 'id');
    final state = normalizer.normalizeState({
      'assets': [
        {'id': 'inside', 'name': '保修内', 'warrantyUntil': '2026-06-01'},
        {'id': 'outside', 'name': '保修外', 'warrantyUntil': '2026-08-01'},
        {'id': 'expired', 'name': '已过期', 'warrantyUntil': '2026-05-01'},
        {'id': 'invalid', 'name': '非法日期', 'warrantyUntil': 'bad-date'},
      ],
    });

    final reminders = const AssetReminderService(
      today: '2026-05-13',
    ).remindersFor(state.assets, const AppSettings(maintenanceCycleDays: 3650));

    expect(
      reminders
          .where((item) => item.type == AssetReminderType.warranty)
          .map((item) => item.asset.id),
      ['inside'],
    );
  });

  test('computes idle reminder boundary and ignores sold assets', () {
    final normalizer = AssetNormalizer(idFactory: () => 'id');
    final state = normalizer.normalizeState({
      'assets': [
        {'id': 'at-boundary', 'lastUsedDate': '2025-11-14'},
        {'id': 'over-boundary', 'lastUsedDate': '2025-11-13'},
        {'id': 'sold', 'status': 'sold', 'lastUsedDate': '2025-01-01'},
      ],
    });

    final reminders = const AssetReminderService(
      today: '2026-05-13',
    ).remindersFor(state.assets, const AppSettings(maintenanceCycleDays: 3650));

    expect(
      reminders
          .where((item) => item.type == AssetReminderType.idle)
          .map((item) => item.asset.id),
      ['over-boundary'],
    );
  });

  test(
    'computes maintenance from latest maintenance, repair or purchase date',
    () {
      final normalizer = AssetNormalizer(idFactory: () => 'id');
      final state = normalizer.normalizeState({
        'assets': [
          {
            'id': 'maintenance',
            'purchaseDate': '2025-01-01',
            'events': [
              {'type': '维修', 'date': '2025-10-01'},
              {'type': '保养', 'date': '2025-12-01'},
            ],
          },
          {'id': 'purchase', 'purchaseDate': '2025-01-01'},
          {'id': 'not-due', 'purchaseDate': '2026-01-01'},
        ],
      });

      final reminders = const AssetReminderService(today: '2026-05-30')
          .remindersFor(
            state.assets,
            const AppSettings(maintenanceCycleDays: 180),
          );

      expect(
        reminders
            .where((item) => item.type == AssetReminderType.maintenance)
            .map((item) => item.asset.id),
        ['maintenance', 'purchase'],
      );
      expect(
        reminders
            .where((item) => item.type == AssetReminderType.maintenance)
            .map((item) => item.days),
        [0, 334],
      );
    },
  );

  test('respects global reminder type switches', () {
    final normalizer = AssetNormalizer(idFactory: () => 'id');
    final state = normalizer.normalizeState({
      'assets': [
        {
          'id': 'asset',
          'purchaseDate': '2025-01-01',
          'lastUsedDate': '2025-01-01',
          'warrantyUntil': '2026-06-01',
        },
      ],
    });

    final reminders = const AssetReminderService(today: '2026-05-13')
        .remindersFor(
          state.assets,
          const AppSettings(
            warrantyReminderEnabled: false,
            idleReminderEnabled: false,
            maintenanceReminderEnabled: false,
          ),
        );

    expect(reminders, isEmpty);
  });
}
