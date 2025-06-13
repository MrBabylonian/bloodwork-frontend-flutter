import 'package:flutter/cupertino.dart';
import 'dart:async';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

enum AppToastType { info, success, warning, error }

class AppToast {
  static OverlayEntry? _overlayEntry;
  static Timer? _timer;

  static void show({
    required BuildContext context,
    required String message,
    String? title,
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 3),
    EdgeInsets margin = const EdgeInsets.all(AppDimensions.spacingL),
  }) {
    // Dismiss any existing toast
    dismiss(now: true);

    // Overlay.of(context) should not be null if called from a valid context
    // within a MaterialApp/CupertinoApp.
    OverlayState overlayState = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: margin.bottom,
          left: margin.left,
          right: margin.right,
          child: CupertinoToastWidget(
            title: title,
            message: message,
            type: type,
            onDismiss: () => dismiss(now: true),
          ),
        );
      },
    );

    overlayState.insert(_overlayEntry!);

    _timer = Timer(duration, () {
      dismiss();
    });
  }

  static void dismiss({bool now = false}) {
    if (now) {
      _timer?.cancel();
      _timer = null;
      if (_overlayEntry != null) {
        _overlayEntry!.remove();
        _overlayEntry = null;
      }
    } else {
      // If not 'now', the timer will handle dismissal.
      // This is mainly for programmatic dismissal before timer ends.
      if (_timer?.isActive ?? false) {
        _timer!.cancel();
      }
      if (_overlayEntry != null) {
        _overlayEntry!.remove();
        _overlayEntry = null;
      }
    }
  }
}

class CupertinoToastWidget extends StatefulWidget {
  final String? title;
  final String message;
  final AppToastType type;
  final VoidCallback onDismiss;

  const CupertinoToastWidget({
    super.key,
    this.title,
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<CupertinoToastWidget> createState() => _CupertinoToastWidgetState();
}

class _CupertinoToastWidgetState extends State<CupertinoToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));
    _positionAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case AppToastType.success:
        return AppColors.successGreen.withValues(alpha: 0.9);
      case AppToastType.warning:
        return AppColors.warningOrange.withValues(alpha: 0.9);
      case AppToastType.error:
        return AppColors.destructiveRed.withValues(alpha: 0.9);
      case AppToastType.info:
        return CupertinoColors.secondarySystemFill.withValues(
          alpha: 0.95,
        ); // Darker for visibility
    }
  }

  Color _getForegroundColor() {
    switch (widget.type) {
      case AppToastType.success:
      case AppToastType.warning:
      case AppToastType.error:
        return AppColors.white;
      case AppToastType.info:
        return AppColors.foregroundDark;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case AppToastType.success:
        return CupertinoIcons.checkmark_circle_fill;
      case AppToastType.warning:
        return CupertinoIcons.exclamationmark_triangle_fill;
      case AppToastType.error:
        return CupertinoIcons.xmark_circle_fill;
      case AppToastType.info:
        return CupertinoIcons.info_circle_fill;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = _getBackgroundColor();
    final Color foregroundColor = _getForegroundColor();
    final IconData iconData = _getIcon();

    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _positionAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingM,
          ), // Ensure it doesn't touch screen edges
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingM,
            vertical: AppDimensions.spacingS,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      iconData,
                      color: foregroundColor,
                      size: AppDimensions.iconSizeMedium,
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.title != null && widget.title!.isNotEmpty)
                            Text(
                              widget.title!,
                              style: AppTextStyles.bodyBold.copyWith(
                                color: foregroundColor,
                              ),
                            ),
                          Text(
                            widget.message,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: foregroundColor,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                onPressed: widget.onDismiss,
                child: Icon(
                  CupertinoIcons.xmark,
                  color: foregroundColor.withValues(alpha: 0.7),
                  size: AppDimensions.iconSizeSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Example Usage:
/*
CupertinoButton(
  child: Text('Show Info Toast'),
  onPressed: () {
    AppToast.show(
      context: context,
      title: 'Information',
      message: 'This is an informational message.',
      type: AppToastType.info,
    );
  },
),
CupertinoButton(
  child: Text('Show Success Toast'),
  onPressed: () {
    AppToast.show(
      context: context,
      title: 'Success!',
      message: 'The operation was completed successfully.',
      type: AppToastType.success,
      duration: Duration(seconds: 5),
    );
  },
),
CupertinoButton(
  child: Text('Show Error Toast'),
  onPressed: () {
    AppToast.show(
      context: context,
      title: 'Error Occurred',
      message: 'Something went wrong. Please try again later. This is a longer message to test wrapping and overflow.',
      type: AppToastType.error,
    );
  },
),
*/
