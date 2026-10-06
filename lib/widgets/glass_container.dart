import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable glassmorphic container widget providing frosted blur,
/// translucent layered gradient, rim illumination border, and soft depth shadows.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? tintColor;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? customShadows;
  final VoidCallback? onTap;
  final Clip clipBehavior;
  final Gradient? customGradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 20.0,
    this.blur = 16.0,
    this.opacity = 0.65,
    this.tintColor,
    this.borderColor,
    this.borderWidth = 1.2,
    this.customShadows,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
    this.customGradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultTintColor = isDark
        ? const Color(0xFF0F172A)
        : Colors.white;

    final effectiveTintColor = tintColor ?? defaultTintColor;

    final defaultGradient = customGradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  effectiveTintColor.withValues(alpha: opacity),
                  effectiveTintColor.withValues(alpha: (opacity * 0.7).clamp(0.0, 1.0)),
                ]
              : [
                  effectiveTintColor.withValues(alpha: opacity),
                  effectiveTintColor.withValues(alpha: (opacity * 0.45).clamp(0.0, 1.0)),
                ],
        );

    final defaultBorderColor = borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.75));

    final effectiveShadows = customShadows ??
        [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : const Color(0xFF64748B).withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.15)
                : const Color(0xFF00897B).withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        gradient: defaultGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: defaultBorderColor,
          width: borderWidth,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: content,
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: effectiveShadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      ),
    );
  }
}

/// Ambient background widget that creates glowing color orbs
/// to give depth and stunning illumination beneath glassmorphic layers.
class AmbientBackgroundMesh extends StatelessWidget {
  final Widget child;

  const AmbientBackgroundMesh({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Base Background
        Positioned.fill(
          child: Container(
            color: isDark ? const Color(0xFF030712) : const Color(0xFFF1F5F9),
          ),
        ),

        // Glowing Ambient Orb 1 (Top Left - Emerald Teal)
        Positioned(
          top: -80,
          left: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        const Color(0xFF00897B).withValues(alpha: 0.28),
                        Colors.transparent,
                      ]
                    : [
                        const Color(0xFF00BFA5).withValues(alpha: 0.22),
                        Colors.transparent,
                      ],
              ),
            ),
          ),
        ),

        // Glowing Ambient Orb 2 (Top Right - Sky / Cyan)
        Positioned(
          top: 140,
          right: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        const Color(0xFF0284C7).withValues(alpha: 0.22),
                        Colors.transparent,
                      ]
                    : [
                        const Color(0xFF38BDF8).withValues(alpha: 0.20),
                        Colors.transparent,
                      ],
              ),
            ),
          ),
        ),

        // Glowing Ambient Orb 3 (Bottom Left - Violet / Indigo)
        Positioned(
          bottom: 60,
          left: -40,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        const Color(0xFF6366F1).withValues(alpha: 0.18),
                        Colors.transparent,
                      ]
                    : [
                        const Color(0xFF818CF8).withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
              ),
            ),
          ),
        ),

        // Child Content
        Positioned.fill(child: child),
      ],
    );
  }
}
