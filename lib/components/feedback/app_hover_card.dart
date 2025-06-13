import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

/// A card that appears when hovering over a trigger widget.
///
/// This component is equivalent to the hover-card.tsx from the React mock,
/// providing hover-triggered popup content.
class AppHoverCard extends StatefulWidget {
  /// Creates a hover card.
  const AppHoverCard({
    super.key,
    required this.trigger,
    required this.content,
    this.hoverDelay = const Duration(milliseconds: 300),
    this.hideDelay = const Duration(milliseconds: 150),
    this.offset = const Offset(0, 8),
    this.preferredPosition = AppHoverCardPosition.bottom,
    this.maxWidth = 300.0,
    this.backgroundColor,
    this.borderRadius,
  });

  /// The widget that triggers the hover card when hovered.
  final Widget trigger;

  /// The content to display in the hover card.
  final Widget content;

  /// Delay before showing the hover card.
  final Duration hoverDelay;

  /// Delay before hiding the hover card.
  final Duration hideDelay;

  /// Offset from the trigger widget.
  final Offset offset;

  /// Preferred position relative to the trigger.
  final AppHoverCardPosition preferredPosition;

  /// Maximum width of the hover card.
  final double maxWidth;

  /// Background color of the hover card.
  final Color? backgroundColor;

  /// Border radius of the hover card.
  final BorderRadius? borderRadius;

  @override
  State<AppHoverCard> createState() => _AppHoverCardState();
}

/// Position options for the hover card.
enum AppHoverCardPosition { top, bottom, left, right }

class _AppHoverCardState extends State<AppHoverCard>
    with TickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  Timer? _showTimer;
  Timer? _hideTimer;
  final GlobalKey _triggerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    _animationController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onHoverEnter() {
    _hideTimer?.cancel();

    if (!_isHovered) {
      _isHovered = true;
      _showTimer = Timer(widget.hoverDelay, _showHoverCard);
    }
  }

  void _onHoverExit() {
    _showTimer?.cancel();

    if (_isHovered) {
      _isHovered = false;
      _hideTimer = Timer(widget.hideDelay, _hideHoverCard);
    }
  }

  void _showHoverCard() {
    if (!_isHovered || _overlayEntry != null) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
  }

  void _hideHoverCard() {
    if (_isHovered || _overlayEntry == null) return;

    _animationController.reverse().then((_) {
      _removeOverlay();
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox? renderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return OverlayEntry(builder: (_) => const SizedBox.shrink());
    }

    final triggerSize = renderBox.size;
    final triggerPosition = renderBox.localToGlobal(Offset.zero);
    final cardPosition = _calculateCardPosition(triggerPosition, triggerSize);

    return OverlayEntry(
      builder:
          (context) => Positioned(
            left: cardPosition.dx,
            top: cardPosition.dy,
            child: MouseRegion(
              onEnter: (_) => _onHoverEnter(),
              onExit: (_) => _onHoverExit(),
              child: AnimatedBuilder(
                animation: _animationController,
                builder:
                    (context, child) => Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: widget.maxWidth,
                          ),
                          decoration: BoxDecoration(
                            color:
                                widget.backgroundColor ??
                                AppColors.backgroundWhite,
                            borderRadius:
                                widget.borderRadius ??
                                BorderRadius.circular(
                                  AppDimensions.radiusMedium,
                                ),
                            border: Border.all(color: AppColors.borderGray),
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.black.withValues(
                                  alpha: 0.1,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: widget.content,
                        ),
                      ),
                    ),
              ),
            ),
          ),
    );
  }

  Offset _calculateCardPosition(Offset triggerPosition, Size triggerSize) {
    final screenSize = MediaQuery.of(context).size;
    double x = triggerPosition.dx;
    double y = triggerPosition.dy;

    switch (widget.preferredPosition) {
      case AppHoverCardPosition.top:
        x += triggerSize.width / 2 - (widget.maxWidth / 2);
        y -= widget.offset.dy;
        break;
      case AppHoverCardPosition.bottom:
        x += triggerSize.width / 2 - (widget.maxWidth / 2);
        y += triggerSize.height + widget.offset.dy;
        break;
      case AppHoverCardPosition.left:
        x -= widget.maxWidth + widget.offset.dx;
        y += triggerSize.height / 2;
        break;
      case AppHoverCardPosition.right:
        x += triggerSize.width + widget.offset.dx;
        y += triggerSize.height / 2;
        break;
    }

    // Ensure the card stays within screen bounds
    x = x.clamp(
      AppDimensions.paddingMedium,
      screenSize.width - widget.maxWidth - AppDimensions.paddingMedium,
    );
    y = y.clamp(
      AppDimensions.paddingMedium,
      screenSize.height - 200 - AppDimensions.paddingMedium,
    );

    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      key: _triggerKey,
      onEnter: (_) => _onHoverEnter(),
      onExit: (_) => _onHoverExit(),
      child: widget.trigger,
    );
  }
}

/// A simple hover card with text content.
class AppSimpleHoverCard extends StatelessWidget {
  /// Creates a simple hover card with text.
  const AppSimpleHoverCard({
    super.key,
    required this.trigger,
    required this.title,
    this.description,
    this.hoverDelay = const Duration(milliseconds: 300),
    this.hideDelay = const Duration(milliseconds: 150),
    this.preferredPosition = AppHoverCardPosition.bottom,
  });

  /// The widget that triggers the hover card.
  final Widget trigger;

  /// The title text to display.
  final String title;

  /// Optional description text.
  final String? description;

  /// Delay before showing the hover card.
  final Duration hoverDelay;

  /// Delay before hiding the hover card.
  final Duration hideDelay;

  /// Preferred position relative to the trigger.
  final AppHoverCardPosition preferredPosition;

  @override
  Widget build(BuildContext context) {
    return AppHoverCard(
      trigger: trigger,
      hoverDelay: hoverDelay,
      hideDelay: hideDelay,
      preferredPosition: preferredPosition,
      content: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.foregroundDark,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: AppDimensions.paddingSmall),
              Text(
                description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
