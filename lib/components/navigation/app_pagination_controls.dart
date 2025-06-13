import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

class AppPaginationControls extends StatelessWidget {
  final int currentPage; // 0-indexed
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final int displayPageCount; // Number of page numbers to display directly

  const AppPaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.displayPageCount =
        5, // e.g., 1, 2, 3, ..., 10 or 1, ..., 4, 5, 6, ..., 10
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox.shrink(); // No pagination needed for 0 or 1 page
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment:
          CrossAxisAlignment.center, // Added for vertical alignment
      children: _buildPaginationItems(context),
    );
  }

  List<Widget> _buildPaginationItems(BuildContext context) {
    final List<Widget> items = [];

    // Previous Button
    items.add(
      _PaginationButton(
        // icon: CupertinoIcons.chevron_left, // Icon is now part of the label logic
        label: 'Previous',
        enabled: currentPage > 0,
        onPressed: () => onPageChanged(currentPage - 1),
        isPrevious: true,
      ),
    );
    items.add(
      const SizedBox(width: AppDimensions.spacingS),
    ); // Corrected: spacingSmall -> spacingS

    // Page Number Buttons
    items.addAll(_generatePageNumbers(context));

    items.add(
      const SizedBox(width: AppDimensions.spacingS),
    ); // Corrected: spacingSmall -> spacingS
    // Next Button
    items.add(
      _PaginationButton(
        // icon: CupertinoIcons.chevron_right, // Icon is now part of the label logic
        label: 'Next',
        enabled: currentPage < totalPages - 1,
        onPressed: () => onPageChanged(currentPage + 1),
        isPrevious: false,
      ),
    );

    return items;
  }

  // Refined logic for generating page numbers with ellipsis
  List<Widget> _generatePageNumbers(BuildContext context) {
    final List<Widget> pageWidgets = [];
    const int wingSize =
        1; // Number of pages to show on each side of current page, plus current page itself makes 2*wingSize + 1 items typically
    const int pagesToAlwaysShow = 2; // Show first and last page always
    const int maxPagesOverall =
        5; // Max items in the middle part (e.g. 1 ... 3 4 5 ... 10) -> 1, ..., c-1, c, c+1, ..., N. displayPageCount is similar

    if (totalPages <= maxPagesOverall) {
      // If total pages are few, show all of them
      for (int i = 0; i < totalPages; i++) {
        pageWidgets.add(
          _PageNumberButton(
            page: i,
            currentPage: currentPage,
            onPageChanged: onPageChanged,
          ),
        );
        if (i < totalPages - 1) {
          pageWidgets.add(
            const SizedBox(width: AppDimensions.spacingXs),
          ); // Corrected: spacingXxs -> spacingXs
        }
      }
      return pageWidgets;
    }

    // Add first page
    pageWidgets.add(
      _PageNumberButton(
        page: 0,
        currentPage: currentPage,
        onPageChanged: onPageChanged,
      ),
    );
    pageWidgets.add(const SizedBox(width: AppDimensions.spacingXs));

    // Calculate start and end for the middle segment of pages
    int start = currentPage - wingSize;
    int end = currentPage + wingSize;

    bool frontEllipsis = false;
    bool backEllipsis = false;

    if (start > 1) {
      // Greater than 1 because page 0 is already added, and we need space for ellipsis if start is not 1
      frontEllipsis = true;
    }
    if (end < totalPages - 2) {
      // Less than totalPages - 2 because page totalPages-1 will be added, and we need space for ellipsis
      backEllipsis = true;
    }

    if (frontEllipsis) {
      // Adjust start if we are too close to the beginning to show full wing
      // And we need to show ellipsis after page 0
      if (currentPage < maxPagesOverall - pagesToAlwaysShow) {
        // e.g. current is 2, total 10, max 5. 2 < 5-2=3. Show 0,1,2,3,...,9
        start = 1;
        end = maxPagesOverall - pagesToAlwaysShow - 1; // -1 because 0-indexed
        backEllipsis = true; // ensure back ellipsis if we cap the end
        frontEllipsis = false; // No front ellipsis if we start from 1
      } else {
        pageWidgets.add(const _Ellipsis());
        pageWidgets.add(const SizedBox(width: AppDimensions.spacingXs));
      }
    } else {
      start =
          1; // Start from page 1 if no front ellipsis (page 0 is already there)
    }

    if (backEllipsis) {
      // Adjust end if we are too close to the end to show full wing
      if (currentPage >
          totalPages - (maxPagesOverall - pagesToAlwaysShow) - 1) {
        // e.g. current is 7, total 9, max 5. 7 > 9-(5-2)-1 = 5. Show 0,...,5,6,7,8,9
        end = totalPages - 2;
        start =
            totalPages -
            (maxPagesOverall - pagesToAlwaysShow) -
            1; // -1 because 0-indexed
        frontEllipsis = true; // ensure front ellipsis if we cap the start
        backEllipsis = false; // No back ellipsis if we end at totalPages-2
        // Add front ellipsis if start is not 1 and not already added
        if (start > 1 && pageWidgets.whereType<_Ellipsis>().isEmpty) {
          pageWidgets.add(const _Ellipsis());
          pageWidgets.add(const SizedBox(width: AppDimensions.spacingXs));
        }
      }
    } else {
      end =
          totalPages -
          2; // End at page totalPages - 2 if no back ellipsis (page totalPages-1 is added later)
    }

    for (int i = start; i <= end; i++) {
      if (i >= 0 && i < totalPages) {
        // Ensure page is valid
        pageWidgets.add(
          _PageNumberButton(
            page: i,
            currentPage: currentPage,
            onPageChanged: onPageChanged,
          ),
        );
        if (i < end) {
          // Add spacing if not the last in this loop
          pageWidgets.add(const SizedBox(width: AppDimensions.spacingXs));
        }
      }
    }

    if (backEllipsis && end < totalPages - 2) {
      if (pageWidgets.last is! _Ellipsis) {
        pageWidgets.add(const SizedBox(width: AppDimensions.spacingXs));
        pageWidgets.add(const _Ellipsis());
      }
    }

    // Add last page (if not already included and totalPages > 1)
    if (totalPages > 1) {
      // Check if last page is already effectively added or very close to `end`
      bool lastPageAlreadyShown = false;
      if (pageWidgets.last is _PageNumberButton) {
        if ((pageWidgets.last as _PageNumberButton).page == totalPages - 1) {
          lastPageAlreadyShown = true;
        }
      }
      if (!lastPageAlreadyShown) {
        pageWidgets.add(const SizedBox(width: AppDimensions.spacingXs));
        pageWidgets.add(
          _PageNumberButton(
            page: totalPages - 1,
            currentPage: currentPage,
            onPageChanged: onPageChanged,
          ),
        );
      }
    }

    return pageWidgets;
  }
}

class _PageNumberButton extends StatelessWidget {
  final int page;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const _PageNumberButton({
    required this.page,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = page == currentPage;
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(
        horizontal:
            AppDimensions.spacingS, // Corrected: paddingSmall -> spacingS
        vertical:
            AppDimensions
                .spacingXs, // Corrected: paddingXs -> spacingXs (or spacingS for more height)
      ),
      minSize:
          AppDimensions
              .buttonHeightSmall, // Ensure a decent tap target, using a theme dimension
      color:
          isActive
              ? AppColors.primaryBlue
              : null, // Corrected: primary -> primaryBlue
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusSmall,
      ), // Added consistent border radius
      onPressed: () => onPageChanged(page),
      child: Text(
        '${page + 1}', // Display 1-indexed page number
        style:
            isActive
                ? AppTextStyles.buttonPrimary.copyWith(
                  color: AppColors.white,
                ) // Corrected: AppTextStyles.button(context) -> buttonPrimary, CupertinoColors.white -> AppColors.white
                : AppTextStyles.buttonPrimary.copyWith(
                  color: AppColors.primaryBlue,
                ), // Corrected: AppTextStyles.button(context) -> buttonPrimary, AppColors.primary -> primaryBlue
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  // final IconData icon; // Removed, icons are conditional based on label/isPrevious
  final String label;
  final bool enabled;
  final VoidCallback onPressed;
  // final bool isIconOnly; // Removed, assuming buttons always have text or are prev/next with icons
  final bool isPrevious;

  const _PaginationButton({
    // required this.icon, // Removed
    required this.label,
    required this.enabled,
    required this.onPressed,
    // this.isIconOnly = false, // Removed
    required this.isPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        enabled
            ? AppColors.primaryBlue
            : AppColors
                .mediumGray; // Corrected: primary -> primaryBlue, grey500 -> mediumGray
    final textStyle = AppTextStyles.buttonPrimary.copyWith(
      color: color,
    ); // Corrected: button(context) -> buttonPrimary

    List<Widget> children = [];
    final iconData =
        isPrevious ? CupertinoIcons.chevron_left : CupertinoIcons.chevron_right;

    if (isPrevious) {
      children.add(
        Icon(
          iconData,
          color: color,
          size: AppDimensions.iconSizeSmall,
        ), // Corrected: iconSizeMedium -> iconSizeSmall (or iconSizeS)
      );
      children.add(
        const SizedBox(width: AppDimensions.spacingXs),
      ); // Corrected: spacingXxs -> spacingXs
      children.add(Text(label, style: textStyle));
    } else {
      children.add(Text(label, style: textStyle));
      children.add(
        const SizedBox(width: AppDimensions.spacingXs),
      ); // Corrected: spacingXxs -> spacingXs
      children.add(
        Icon(
          iconData,
          color: color,
          size: AppDimensions.iconSizeSmall,
        ), // Corrected: iconSizeMedium -> iconSizeSmall
      );
    }

    return CupertinoButton(
      padding: const EdgeInsets.symmetric(
        horizontal:
            AppDimensions.spacingM, // Corrected: paddingMedium -> spacingM
        vertical: AppDimensions.spacingS, // Corrected: paddingSmall -> spacingS
      ),
      onPressed: enabled ? onPressed : null,
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _Ellipsis extends StatelessWidget {
  const _Ellipsis();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingXs,
      ), // Corrected: paddingXs -> spacingXs
      child: Text(
        '...',
        style: AppTextStyles.body.copyWith(
          color: AppColors.mediumGray,
        ), // Corrected: body(context) -> body, textDisabled -> mediumGray
      ),
    );
  }
}

// Example Usage:
/*
class MyPaginationPage extends StatefulWidget {
  const MyPaginationPage({super.key});

  @override
  State<MyPaginationPage> createState() => _MyPaginationPageState();
}

class _MyPaginationPageState extends State<MyPaginationPage> {
  int _currentPage = 0;
  final int _totalPages = 20;

  void _handlePageChanged(int newPage) {
    setState(() {
      _currentPage = newPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Pagination Example'),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Current Page: ${_currentPage + 1} / $_totalPages', style: AppTextStyles.title1), // Corrected: title(context) -> title1 (or other appropriate static style)
              const SizedBox(height: AppDimensions.spacingL), // Corrected: spacingLarge -> spacingL
              AppPaginationControls(
                currentPage: _currentPage,
                totalPages: _totalPages,
                onPageChanged: _handlePageChanged,
                displayPageCount: 5, // Or 7 for more numbers
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
