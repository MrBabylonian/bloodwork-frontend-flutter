import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

/// Represents a single item in the AppBreadcrumbs widget.
class BreadcrumbItem {
  final String text;
  final VoidCallback? onTap;
  final IconData? icon;

  BreadcrumbItem({required this.text, this.onTap, this.icon});
}

/// A Cupertino-styled breadcrumbs navigation widget.
class AppBreadcrumbs extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final IconData separatorIcon;
  final TextStyle? activeTextStyle;
  final TextStyle? inactiveTextStyle;
  final Color? separatorColor;

  const AppBreadcrumbs({
    super.key,
    required this.items,
    this.separatorIcon = CupertinoIcons.chevron_right,
    this.activeTextStyle,
    this.inactiveTextStyle,
    this.separatorColor,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final effectiveActiveTextStyle =
        activeTextStyle ??
        AppTextStyles.bodySmall.copyWith(
          color: AppColors.foregroundDark,
          fontWeight:
              FontWeight.normal, // Changed from FontWeight.w600 to normal
        );
    final effectiveInactiveTextStyle =
        inactiveTextStyle ??
        AppTextStyles.bodySmall.copyWith(color: AppColors.mediumGray);
    final effectiveSeparatorColor = separatorColor ?? AppColors.mediumGray;

    List<Widget> breadcrumbWidgets = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final bool isLastItem = i == items.length - 1;

      Widget textWidget = Text(
        item.text,
        style:
            isLastItem ? effectiveActiveTextStyle : effectiveInactiveTextStyle,
        overflow: TextOverflow.ellipsis,
      );

      if (item.icon != null) {
        textWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size:
                  (isLastItem
                      ? effectiveActiveTextStyle.fontSize
                      : effectiveInactiveTextStyle.fontSize) ??
                  AppDimensions.iconSizeSmall,
              color:
                  isLastItem
                      ? effectiveActiveTextStyle.color
                      : effectiveInactiveTextStyle.color,
            ),
            const SizedBox(width: AppDimensions.spacingXs / 2),
            Flexible(child: textWidget),
          ],
        );
      }

      if (item.onTap != null && !isLastItem) {
        breadcrumbWidgets.add(
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: item.onTap,
            child: textWidget,
          ),
        );
      } else {
        breadcrumbWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.spacingXs / 2,
            ), // Align with button tap target
            child: textWidget,
          ),
        );
      }

      if (!isLastItem) {
        breadcrumbWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingXs / 2,
            ),
            child: Icon(
              separatorIcon,
              size: AppDimensions.iconSizeSmall,
              color: effectiveSeparatorColor,
            ),
          ),
        );
      }
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: breadcrumbWidgets,
    );
  }
}

// Example Usage:
/*
class MyBreadcrumbsPage extends StatefulWidget {
  const MyBreadcrumbsPage({super.key});

  @override
  State<MyBreadcrumbsPage> createState() => _MyBreadcrumbsPageState();
}

class _MyBreadcrumbsPageState extends State<MyBreadcrumbsPage> {
  String _currentPage = "Details";

  void _navigateTo(String page) {
    setState(() {
      _currentPage = page;
    });
    // In a real app, you would use Navigator.push or your routing solution
    print("Navigating to $page");
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Breadcrumbs Example'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBreadcrumbs(
                items: [
                  BreadcrumbItem(text: 'Home', onTap: () => _navigateTo('Home'), icon: CupertinoIcons.home),
                  BreadcrumbItem(text: 'Products', onTap: () => _navigateTo('Products'), icon: CupertinoIcons.collections),
                  BreadcrumbItem(text: 'Electronics', onTap: () => _navigateTo('Electronics')),
                  BreadcrumbItem(text: _currentPage, icon: CupertinoIcons.tag_fill), // Current page, no onTap
                ],
              ),
              const SizedBox(height: AppDimensions.spacingL),
              Text("Current Page: $_currentPage", style: AppTextStyles.title2),
            ],
          ),
        ),
      ),
    );
  }
}
*/
