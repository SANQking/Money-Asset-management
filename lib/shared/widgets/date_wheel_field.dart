import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';

const _firstPickerDate = 1970;
const _lastPickerDate = 2100;

class DateWheelField extends StatelessWidget {
  const DateWheelField({
    super.key,
    required this.controller,
    required this.label,
    required this.fallbackDate,
    this.allowClear = false,
  });

  final TextEditingController controller;
  final String label;
  final String fallbackDate;
  final bool allowClear;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x3),
      child: TextField(
        key: Key('date-field-$label'),
        controller: controller,
        readOnly: true,
        showCursor: false,
        style: TextStyle(color: AppColors.text),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: theme.muted),
          suffixIcon: Icon(Icons.expand_more, color: theme.muted),
          enabledBorder: OutlineInputBorder(
            borderSide: theme.inputBorderSide,
            borderRadius: BorderRadius.circular(theme.isPink ? 18 : 10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: theme.focusedBorderSide,
            borderRadius: BorderRadius.circular(theme.isPink ? 18 : 10),
          ),
        ),
        onTap: () async {
          FocusScope.of(context).unfocus();
          final next = await showDateWheelPicker(
            context,
            title: label,
            value: controller.text,
            fallbackDate: fallbackDate,
            allowClear: allowClear,
          );
          if (next != null) {
            controller.text = next;
          }
        },
      ),
    );
  }
}

Future<String?> showDateWheelPicker(
  BuildContext context, {
  required String title,
  required String value,
  required String fallbackDate,
  required bool allowClear,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _DateWheelPickerSheet(
      title: title,
      value: value,
      fallbackDate: fallbackDate,
      allowClear: allowClear,
    ),
  );
}

class _DateWheelPickerSheet extends StatefulWidget {
  const _DateWheelPickerSheet({
    required this.title,
    required this.value,
    required this.fallbackDate,
    required this.allowClear,
  });

  final String title;
  final String value;
  final String fallbackDate;
  final bool allowClear;

  @override
  State<_DateWheelPickerSheet> createState() => _DateWheelPickerSheetState();
}

class _DateWheelPickerSheetState extends State<_DateWheelPickerSheet> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _initialDate();
  }

  DateTime _initialDate() {
    final parsedValue = _parseIsoDate(widget.value);
    final parsedFallback = _parseIsoDate(widget.fallbackDate);
    return _clampDate(parsedValue ?? parsedFallback ?? _today());
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final pickerBackground = theme.isBlackGold
        ? theme.surface
        : theme.background;
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: pickerBackground,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(theme.sheetRadius),
          ),
          boxShadow: theme.cardShadow,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            theme.isMinimal ? 28 : AppSpacing.x4,
            AppSpacing.x4,
            theme.isMinimal ? 28 : AppSpacing.x4,
            AppSpacing.x4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    AssetDateUtils.isoDate(_selectedDate),
                    key: const Key('date-wheel-current-value'),
                    style: theme.numberStyle(
                      fontSize: 14,
                      color: theme.accentLight,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x3),
              SizedBox(
                height: 216,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: theme.isBlackGold
                        ? Brightness.dark
                        : Brightness.light,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: theme.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    key: const Key('date-wheel-picker'),
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: _selectedDate,
                    minimumDate: DateTime(_firstPickerDate),
                    maximumDate: DateTime(_lastPickerDate, 12, 31),
                    backgroundColor: pickerBackground,
                    selectionOverlayBuilder:
                        (
                          context, {
                          required columnCount,
                          required selectedIndex,
                        }) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.accent.withValues(
                                alpha: theme.isMinimal ? 0.06 : 0.12,
                              ),
                              borderRadius: BorderRadius.circular(
                                theme.isPink ? 18 : 10,
                              ),
                            ),
                          );
                        },
                    onDateTimeChanged: (date) {
                      setState(() => _selectedDate = _clampDate(date));
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.x3),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: AppSpacing.x2,
                runSpacing: AppSpacing.x2,
                children: [
                  if (widget.allowClear)
                    TextButton(
                      key: const Key('date-wheel-clear-button'),
                      onPressed: () => Navigator.pop(context, ''),
                      child: const Text('清空'),
                    ),
                  TextButton(
                    key: const Key('date-wheel-cancel-button'),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  FilledButton(
                    key: const Key('date-wheel-confirm-button'),
                    onPressed: () => Navigator.pop(
                      context,
                      AssetDateUtils.isoDate(_selectedDate),
                    ),
                    child: const Text('确认'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

DateTime? _parseIsoDate(String value) {
  final raw = value.trim();
  if (raw.isEmpty) return null;
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(raw);
  if (match == null) return null;
  final year = int.tryParse(match.group(1)!);
  final month = int.tryParse(match.group(2)!);
  final day = int.tryParse(match.group(3)!);
  if (year == null || month == null || day == null) return null;
  final parsed = DateTime(year, month, day);
  if (parsed.year != year || parsed.month != month || parsed.day != day) {
    return null;
  }
  return parsed;
}

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime _clampDate(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  final min = DateTime(_firstPickerDate);
  final max = DateTime(_lastPickerDate, 12, 31);
  if (normalized.isBefore(min)) return min;
  if (normalized.isAfter(max)) return max;
  return normalized;
}
