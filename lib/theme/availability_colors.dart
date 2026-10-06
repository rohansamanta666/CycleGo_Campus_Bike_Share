import 'package:flutter/material.dart';

/// Custom ThemeExtension for bike availability status colors.
/// Provides distinct colors for plenty (>=5), low (1-4), and empty (0) states
/// in both light and dark themes.
@immutable
class AvailabilityColors extends ThemeExtension<AvailabilityColors> {
  final Color plenty;
  final Color onPlenty;
  final Color plentyContainer;
  final Color onPlentyContainer;

  final Color low;
  final Color onLow;
  final Color lowContainer;
  final Color onLowContainer;

  final Color empty;
  final Color onEmpty;
  final Color emptyContainer;
  final Color onEmptyContainer;

  const AvailabilityColors({
    required this.plenty,
    required this.onPlenty,
    required this.plentyContainer,
    required this.onPlentyContainer,
    required this.low,
    required this.onLow,
    required this.lowContainer,
    required this.onLowContainer,
    required this.empty,
    required this.onEmpty,
    required this.emptyContainer,
    required this.onEmptyContainer,
  });

  /// Light theme availability palette
  static const light = AvailabilityColors(
    plenty: Color(0xFF15803D), // Forest green
    onPlenty: Colors.white,
    plentyContainer: Color(0xFFDCFCE7),
    onPlentyContainer: Color(0xFF14532D),
    low: Color(0xFFD97706), // Warm amber
    onLow: Colors.white,
    lowContainer: Color(0xFFFEF3C7),
    onLowContainer: Color(0xFF78350F),
    empty: Color(0xFFDC2626), // Crimson red
    onEmpty: Colors.white,
    emptyContainer: Color(0xFFFEE2E2),
    onEmptyContainer: Color(0xFF7F1D1D),
  );

  /// Dark theme availability palette with adjusted luminance for dark backgrounds
  static const dark = AvailabilityColors(
    plenty: Color(0xFF4ADE80), // Bright emerald
    onPlenty: Color(0xFF052E16),
    plentyContainer: Color(0xFF14532D),
    onPlentyContainer: Color(0xFFBBF7D0),
    low: Color(0xFFFBBF24), // Vibrant amber
    onLow: Color(0xFF451A03),
    lowContainer: Color(0xFF78350F),
    onLowContainer: Color(0xFFFDE68A),
    empty: Color(0xFFF87171), // Vibrant coral red
    onEmpty: Color(0xFF450A0A),
    emptyContainer: Color(0xFF7F1D1D),
    onEmptyContainer: Color(0xFFFECACA),
  );

  @override
  AvailabilityColors copyWith({
    Color? plenty,
    Color? onPlenty,
    Color? plentyContainer,
    Color? onPlentyContainer,
    Color? low,
    Color? onLow,
    Color? lowContainer,
    Color? onLowContainer,
    Color? empty,
    Color? onEmpty,
    Color? emptyContainer,
    Color? onEmptyContainer,
  }) {
    return AvailabilityColors(
      plenty: plenty ?? this.plenty,
      onPlenty: onPlenty ?? this.onPlenty,
      plentyContainer: plentyContainer ?? this.plentyContainer,
      onPlentyContainer: onPlentyContainer ?? this.onPlentyContainer,
      low: low ?? this.low,
      onLow: onLow ?? this.onLow,
      lowContainer: lowContainer ?? this.lowContainer,
      onLowContainer: onLowContainer ?? this.onLowContainer,
      empty: empty ?? this.empty,
      onEmpty: onEmpty ?? this.onEmpty,
      emptyContainer: emptyContainer ?? this.emptyContainer,
      onEmptyContainer: onEmptyContainer ?? this.onEmptyContainer,
    );
  }

  @override
  AvailabilityColors lerp(ThemeExtension<AvailabilityColors>? other, double t) {
    if (other is! AvailabilityColors) return this;
    return AvailabilityColors(
      plenty: Color.lerp(plenty, other.plenty, t)!,
      onPlenty: Color.lerp(onPlenty, other.onPlenty, t)!,
      plentyContainer: Color.lerp(plentyContainer, other.plentyContainer, t)!,
      onPlentyContainer: Color.lerp(
        onPlentyContainer,
        other.onPlentyContainer,
        t,
      )!,
      low: Color.lerp(low, other.low, t)!,
      onLow: Color.lerp(onLow, other.onLow, t)!,
      lowContainer: Color.lerp(lowContainer, other.lowContainer, t)!,
      onLowContainer: Color.lerp(onLowContainer, other.onLowContainer, t)!,
      empty: Color.lerp(empty, other.empty, t)!,
      onEmpty: Color.lerp(onEmpty, other.onEmpty, t)!,
      emptyContainer: Color.lerp(emptyContainer, other.emptyContainer, t)!,
      onEmptyContainer: Color.lerp(
        onEmptyContainer,
        other.onEmptyContainer,
        t,
      )!,
    );
  }
}
