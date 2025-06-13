import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

/// Toast notification types.
enum AppSonnerType { info, success, warning, error }

/// Position where toasts should appear.
enum AppSonnerPosition {
  topLeft,
  topCenter,
  topRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

/// A toast notification item.
class AppSonnerToast {
  /// Creates a toast notification.
  AppSonnerToast({
    required this.id,
    required this.message,
    this.title,
    this.type = AppSonnerType.info,
    this.duration = const Duration(seconds: 4),
    this.action,
    this.onDismiss,
    this.icon,
    this.showCloseButton = true,
  });

  /// Unique identifier for the toast.
  final String id;

  /// The main message to display.
  final String message;

  /// Optional title for the toast.
  final String? title;

  /// Type of the toast.
  final AppSonnerType type;

  /// How long the toast should be visible.
  final Duration duration;

  /// Optional action widget (like a button).
  final Widget? action;

  /// Callback when the toast is dismissed.
  final VoidCallback? onDismiss;

  /// Custom icon to display.
  final IconData? icon;

  /// Whether to show the close button.
  final bool showCloseButton;
}

/// A modern toast notification system.
///
/// This component is equivalent to the sonner.tsx from the React mock,
/// providing a clean and modern toast notification system.
class AppSonner extends StatefulWidget {
  /// Creates a Sonner toast system.
  const AppSonner({
    super.key,
    this.position = AppSonnerPosition.bottomRight,
    this.maxToasts = 5,
    this.offset = const Offset(16, 16),
    this.spacing = 8.0,
  });

  /// Position where toasts should appear.
  final AppSonnerPosition position;

  /// Maximum number of toasts to show at once.
  final int maxToasts;

  /// Offset from the screen edge.
  final Offset offset;

  /// Spacing between toasts.
  final double spacing;

  @override
  State<AppSonner> createState() => _AppSonnerState();

  /// Global instance for easy access.
  static _AppSonnerState? _instance;

  /// Show a toast notification.
  static void show(AppSonnerToast toast) {
    _instance?._showToast(toast);
  }

  /// Show a simple info toast.
  static void info(String message, {String? title}) {
    show(
      AppSonnerToast(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: message,
        title: title,
        type: AppSonnerType.info,
      ),
    );
  }

  /// Show a success toast.
  static void success(String message, {String? title}) {
    show(
      AppSonnerToast(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: message,
        title: title,
        type: AppSonnerType.success,
      ),
    );
  }

  /// Show a warning toast.
  static void warning(String message, {String? title}) {
    show(
      AppSonnerToast(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: message,
        title: title,
        type: AppSonnerType.warning,
      ),
    );
  }

  /// Show an error toast.
  static void error(String message, {String? title}) {
    show(
      AppSonnerToast(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: message,
        title: title,
        type: AppSonnerType.error,
      ),
    );
  }

  /// Dismiss a specific toast.
  static void dismiss(String id) {
    _instance?._dismissToast(id);
  }

  /// Dismiss all toasts.
  static void dismissAll() {
    _instance?._dismissAllToasts();
  }
}

class _AppSonnerState extends State<AppSonner> with TickerProviderStateMixin {
  final List<AppSonnerToast> _toasts = [];
  final Map<String, AnimationController> _animationControllers = {};
  final Map<String, Timer> _timers = {};

  @override
  void initState() {
    super.initState();
    AppSonner._instance = this;
  }

  @override
  void dispose() {
    for (final controller in _animationControllers.values) {
      controller.dispose();
    }
    for (final timer in _timers.values) {
      timer.cancel();
    }
    AppSonner._instance = null;
    super.dispose();
  }

  void _showToast(AppSonnerToast toast) {
    setState(() {
      _toasts.insert(0, toast);

      // Remove excess toasts
      while (_toasts.length > widget.maxToasts) {
        final removedToast = _toasts.removeLast();
        _cleanupToast(removedToast.id);
      }
    });

    // Create animation controller
    final controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationControllers[toast.id] = controller;
    controller.forward();

    // Set dismiss timer
    _timers[toast.id] = Timer(toast.duration, () {
      _dismissToast(toast.id);
    });
  }

  void _dismissToast(String id) {
    final controller = _animationControllers[id];
    if (controller != null) {
      controller.reverse().then((_) {
        setState(() {
          _toasts.removeWhere((toast) => toast.id == id);
        });
        _cleanupToast(id);
      });
    }
  }

  void _dismissAllToasts() {
    for (final toast in List.from(_toasts)) {
      _dismissToast(toast.id);
    }
  }

  void _cleanupToast(String id) {
    _animationControllers[id]?.dispose();
    _animationControllers.remove(id);
    _timers[id]?.cancel();
    _timers.remove(id);
  }

  @override
  Widget build(BuildContext context) {
    if (_toasts.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: _isTop() ? widget.offset.dy : null,
      bottom: _isBottom() ? widget.offset.dy : null,
      left: _isLeft() ? widget.offset.dx : null,
      right: _isRight() ? widget.offset.dx : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: _getCrossAxisAlignment(),
        children: _toasts.map((toast) => _buildToast(toast)).toList(),
      ),
    );
  }

  Widget _buildToast(AppSonnerToast toast) {
    final controller = _animationControllers[toast.id];
    if (controller == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: controller,
      builder:
          (context, child) => Transform.translate(
            offset: Offset(
              _getSlideOffset().dx * (1 - controller.value),
              _getSlideOffset().dy * (1 - controller.value),
            ),
            child: Opacity(
              opacity: controller.value,
              child: Container(
                margin: EdgeInsets.only(bottom: widget.spacing),
                child: _AppSonnerToastWidget(
                  toast: toast,
                  onDismiss: () => _dismissToast(toast.id),
                ),
              ),
            ),
          ),
    );
  }

  bool _isTop() => widget.position.name.startsWith('top');
  bool _isBottom() => widget.position.name.startsWith('bottom');
  bool _isLeft() => widget.position.name.endsWith('Left');
  bool _isRight() => widget.position.name.endsWith('Right');

  CrossAxisAlignment _getCrossAxisAlignment() {
    if (_isLeft()) return CrossAxisAlignment.start;
    if (_isRight()) return CrossAxisAlignment.end;
    return CrossAxisAlignment.center;
  }

  Offset _getSlideOffset() {
    if (_isLeft()) return const Offset(-100, 0);
    if (_isRight()) return const Offset(100, 0);
    if (_isTop()) return const Offset(0, -100);
    return const Offset(0, 100);
  }
}

class _AppSonnerToastWidget extends StatelessWidget {
  const _AppSonnerToastWidget({required this.toast, required this.onDismiss});

  final AppSonnerToast toast;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: _getBorderColor()),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Row(
          children: [
            // Icon
            Icon(_getIcon(), color: _getIconColor(), size: 20),
            const SizedBox(width: AppDimensions.paddingMedium),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (toast.title != null) ...[
                    Text(
                      toast.title!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.foregroundDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    toast.message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),

            // Action
            if (toast.action != null) ...[
              const SizedBox(width: AppDimensions.paddingMedium),
              toast.action!,
            ],

            // Close button
            if (toast.showCloseButton) ...[
              const SizedBox(width: AppDimensions.paddingSmall),
              GestureDetector(
                onTap: onDismiss,
                child: const Icon(
                  CupertinoIcons.xmark,
                  size: 16,
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    if (toast.icon != null) return toast.icon!;

    switch (toast.type) {
      case AppSonnerType.info:
        return CupertinoIcons.info_circle;
      case AppSonnerType.success:
        return CupertinoIcons.checkmark_circle;
      case AppSonnerType.warning:
        return CupertinoIcons.exclamationmark_triangle;
      case AppSonnerType.error:
        return CupertinoIcons.xmark_circle;
    }
  }

  Color _getIconColor() {
    switch (toast.type) {
      case AppSonnerType.info:
        return AppColors.primaryBlue;
      case AppSonnerType.success:
        return AppColors.successGreen;
      case AppSonnerType.warning:
        return AppColors.warningOrange;
      case AppSonnerType.error:
        return AppColors.destructiveRed;
    }
  }

  Color _getBorderColor() {
    switch (toast.type) {
      case AppSonnerType.info:
        return AppColors.primaryBlue.withValues(alpha: 0.2);
      case AppSonnerType.success:
        return AppColors.successGreen.withValues(alpha: 0.2);
      case AppSonnerType.warning:
        return AppColors.warningOrange.withValues(alpha: 0.2);
      case AppSonnerType.error:
        return AppColors.destructiveRed.withValues(alpha: 0.2);
    }
  }
}
