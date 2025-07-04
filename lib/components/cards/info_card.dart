import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

/// A card component for displaying information in a contained, elevated surface.
///
/// This component provides a consistent card layout with customizable header,
/// content, and optional actions. Suitable for displaying discrete pieces
/// of information or grouped content.
class InfoCard extends StatelessWidget {
  /// Creates an info card with the specified properties.
  const InfoCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.headerActions,
    this.footerActions,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor = AppColors.backgroundWhite,
    this.hasShadow = true,
    this.border,
  });

  /// Main content of the card
  final Widget child;

  /// Optional title displayed in the header
  final Widget? title;

  /// Optional subtitle displayed below the title in the header
  final Widget? subtitle;

  /// Optional widgets to display in the header, typically actions
  final List<Widget>? headerActions;

  /// Optional widgets to display in the footer, typically buttons
  final List<Widget>? footerActions;

  /// Custom padding for the card's content
  final EdgeInsetsGeometry? padding;

  /// Custom margin around the card
  final EdgeInsetsGeometry? margin;

  /// Custom border radius for the card
  final BorderRadius? borderRadius;

  /// Background color of the card
  final Color backgroundColor;

  /// Whether the card should have a shadow
  final bool hasShadow;

  /// Custom border for the card
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: AppDimensions.spacingL),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow:
            hasShadow
                ? [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
        border: border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Card header with title, subtitle and actions
          if (title != null ||
              (headerActions != null && headerActions!.isNotEmpty)) ...[
            Padding(
              padding: const EdgeInsets.all(AppDimensions.contentPadding),
              child: Row(
                children: [
                  if (title != null) ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DefaultTextStyle(
                            style:
                                Theme.of(context).textTheme.titleLarge ??
                                const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                            child: title!,
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: AppDimensions.spacingXs),
                            DefaultTextStyle(
                              style:
                                  Theme.of(context).textTheme.bodyMedium ??
                                  const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                              child: subtitle!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (headerActions != null && headerActions!.isNotEmpty)
                    ...headerActions!,
                ],
              ),
            ),
            Container(height: 1, color: AppColors.borderGray),
          ],

          // Card content
          Padding(
            padding:
                padding ?? const EdgeInsets.all(AppDimensions.contentPadding),
            child: child,
          ),

          // Card footer actions
          if (footerActions != null && footerActions!.isNotEmpty) ...[
            Container(height: 1, color: AppColors.borderGray),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children:
                    footerActions!.asMap().entries.map((entry) {
                      final index = entry.key;
                      final action = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          left: index > 0 ? AppDimensions.spacingM : 0,
                        ),
                        child: action,
                      );
                    }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
