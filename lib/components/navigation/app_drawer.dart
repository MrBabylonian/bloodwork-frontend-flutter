import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  final Widget? title;
  final Widget? description;
  final Widget? header;
  final Widget? footer;
  final List<Widget> children;
  final bool showDragHandle;

  const AppDrawer({
    super.key,
    this.title,
    this.description,
    this.header,
    this.footer,
    required this.children,
    this.showDragHandle = true,
  });

  @override
  Widget build(BuildContext context) {
    final appThemeData = AppTheme.of(context).currentTheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.spacingXxl),
      constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
      decoration: BoxDecoration(
        color: appThemeData.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusLarge),
          topRight: Radius.circular(AppDimensions.radiusLarge),
        ),
        border: Border(
          top: BorderSide(color: AppColors.borderGray, width: 0.5),
          left: BorderSide(color: AppColors.borderGray, width: 0.5),
          right: BorderSide(color: AppColors.borderGray, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDragHandle)
            Container(
              width: 100,
              height: AppDimensions.spacingXs,
              margin: const EdgeInsets.symmetric(
                vertical: AppDimensions.spacingS,
              ),
              decoration: BoxDecoration(
                color: AppColors.mediumGray, // Used for muted color
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
            ),
          if (header != null) header!,
          if (title != null || description != null)
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) title!,
                  if (description != null) ...[
                    const SizedBox(height: AppDimensions.spacingXs),
                    description!,
                  ],
                ],
              ),
            ),
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingM,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}

class AppDrawerHeader extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign textAlign;

  const AppDrawerHeader({
    super.key,
    required this.children,
    this.crossAxisAlignment =
        CrossAxisAlignment.center, // Default to center like mock's text-center
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children:
            children.isNotEmpty
                ? List.generate(children.length * 2 - 1, (index) {
                  if (index.isEven) {
                    return children[index ~/ 2];
                  } else {
                    return const SizedBox(height: AppDimensions.spacingS);
                  }
                })
                : [],
      ),
    );
  }
}

class AppDrawerFooter extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const AppDrawerFooter({
    super.key,
    required this.children,
    this.mainAxisAlignment =
        MainAxisAlignment.start, // Default, mock is "flex flex-col"
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children:
            children.isNotEmpty
                ? List.generate(children.length * 2 - 1, (index) {
                  if (index.isEven) {
                    return children[index ~/ 2];
                  } else {
                    return const SizedBox(
                      height: AppDimensions.spacingS, // gap-2 is 8px
                    );
                  }
                })
                : [],
      ),
    );
  }
}

class AppDrawerTitle extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;

  const AppDrawerTitle(this.text, {super.key, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.title3.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.foregroundDark,
      ),
      textAlign: textAlign,
    );
  }
}

class AppDrawerDescription extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;

  const AppDrawerDescription(this.text, {super.key, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.mediumGray),
      textAlign: textAlign,
    );
  }
}

// DrawerTrigger and DrawerClose are context-dependent and will be handled by
// the showAppDrawer function and the usage of Navigator.pop(context) respectively.
// DrawerPortal and DrawerOverlay are implicitly handled by showModalBottomSheet.
