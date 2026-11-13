import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/sleep_timer_controller.dart';

class SleepTimerSheet extends StatefulWidget {
  const SleepTimerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      useSafeArea: true,
      builder: (_) => const SleepTimerSheet(),
    );
  }

  @override
  State<SleepTimerSheet> createState() => _SleepTimerSheetState();
}

class _SleepTimerSheetState extends State<SleepTimerSheet> {
  final SleepTimerController controller = Get.find<SleepTimerController>();
  int _hours = 0;
  int _minutes = 30;

  static const List<int> _presets = [15, 30, 45, 60, 90, 120];

  void _start(Duration duration) {
    controller.start(duration);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          22,
          14,
          22,
          22 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.bedtime_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sleep Timer',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Set a time to stop your music.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Obx(() {
              final active = controller.isActive.value;
              final remaining = controller.remainingTime.value;
              if (!active && remaining == null) {
                return const SizedBox.shrink();
              }
              final finished = !active && remaining == Duration.zero;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 22),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: AppColors.primary,
                      size: 25,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            finished ? 'Timer finished' : 'Timer active',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            finished
                                ? 'Playback has been paused.'
                                : 'Music stops when the countdown ends.',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (active && remaining != null)
                      Text(
                        controller.formatRemaining(remaining),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
              );
            }),
            const Text(
              'QUICK DURATION',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: _presets.map((minutes) {
                return _DurationChip(
                  label: minutes >= 60
                      ? '${minutes ~/ 60}h${minutes % 60 == 0 ? '' : ' 30m'}'
                      : '${minutes} min',
                  onTap: () => _start(Duration(minutes: minutes)),
                );
              }).toList(),
            ),
            const SizedBox(height: 26),
            const Text(
              'CUSTOM DURATION',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DurationDropdown<int>(
                    value: _hours,
                    label: 'Hours',
                    items: List.generate(13, (index) => index),
                    onChanged: (value) => setState(() => _hours = value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DurationDropdown<int>(
                    value: _minutes,
                    label: 'Minutes',
                    items: List.generate(60, (index) => index),
                    onChanged: (value) => setState(() => _minutes = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _hours == 0 && _minutes == 0
                    ? null
                    : () => _start(
                          Duration(hours: _hours, minutes: _minutes),
                        ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  disabledBackgroundColor: AppColors.surfaceElevated,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Start Timer',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            Obx(() {
              if (!controller.isActive.value) {
                return const SizedBox(height: 8);
              }
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      controller.cancel();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('Cancel Timer'),
                  ),
                ),
              );
            }),
          ],
        ),
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _DurationDropdown<T> extends StatelessWidget {
  const _DurationDropdown({
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final String label;
  final List<T> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: AppColors.surfaceElevated,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString().padLeft(2, '0')),
            ),
          )
          .toList(),
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    );
  }
}
