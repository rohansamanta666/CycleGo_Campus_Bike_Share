import 'package:flutter/material.dart';

import 'glass_container.dart';

class ProgressStepper extends StatelessWidget {
  final int currentStep; // 1 to 4

  const ProgressStepper({super.key, required this.currentStep});

  static const List<Map<String, dynamic>> _steps = [
    {'title': 'Station', 'icon': Icons.location_on_outlined},
    {'title': 'Reserve', 'icon': Icons.lock_clock_outlined},
    {'title': 'Ride', 'icon': Icons.directions_bike_outlined},
    {'title': 'Return', 'icon': Icons.where_to_vote_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return GlassContainer(
      borderRadius: 20,
      blur: 16,
      opacity: isDark ? 0.65 : 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RENTAL JOURNEY',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: colorScheme.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Step $currentStep of 4',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(_steps.length * 2 - 1, (index) {
              if (index.isOdd) {
                // Connecting line between steps
                final stepIndexBefore = index ~/ 2 + 1;
                final isPassed = currentStep > stepIndexBefore;
                return Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isPassed
                          ? colorScheme.primary
                          : (isDark ? Colors.white12 : Colors.black12),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: isPassed
                          ? [
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }

              // Step Node
              final stepNumber = index ~/ 2 + 1;
              final stepData = _steps[stepNumber - 1];
              final isCompleted = currentStep > stepNumber;
              final isCurrent = currentStep == stepNumber;

              Color circleBg;
              Color circleFg;
              Widget iconWidget;

              if (isCompleted) {
                circleBg = colorScheme.primary;
                circleFg = Colors.white;
                iconWidget = const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                );
              } else if (isCurrent) {
                circleBg = colorScheme.primaryContainer;
                circleFg = colorScheme.primary;
                iconWidget = Icon(
                  stepData['icon'] as IconData,
                  size: 14,
                  color: circleFg,
                );
              } else {
                circleBg = isDark
                    ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                    : const Color(0xFFE2E8F0).withValues(alpha: 0.8);
                circleFg = colorScheme.onSurfaceVariant.withValues(alpha: 0.6);
                iconWidget = Text(
                  '$stepNumber',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: circleFg,
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: circleBg,
                      border: Border.all(
                        color: isCurrent
                            ? colorScheme.primary
                            : isCompleted
                            ? colorScheme.primary
                            : (isDark ? Colors.white12 : Colors.black12),
                        width: isCurrent ? 2.2 : 1.0,
                      ),
                      boxShadow: isCurrent || isCompleted
                          ? [
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: iconWidget,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    stepData['title'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                      color: isCurrent
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
