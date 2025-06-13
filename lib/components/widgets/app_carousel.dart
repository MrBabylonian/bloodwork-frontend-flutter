import 'package:flutter/cupertino.dart';
import 'dart:async';

// Corrected import paths to be relative
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

// TODO: Consider if a more advanced carousel package is needed for features like
// infinite scroll, autoplay, complex animations, etc. For now, a basic PageView
// with custom controls will be implemented.

class AppCarousel extends StatefulWidget {
  final List<Widget> items;
  final double? height;
  final bool showIndicator;
  final bool showNavigationButtons;
  final Duration autoPlayInterval;
  final bool autoPlay;

  const AppCarousel({
    super.key,
    required this.items,
    this.height,
    this.showIndicator = true,
    this.showNavigationButtons = true,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 5),
  });

  @override
  State<AppCarousel> createState() => _AppCarouselState();
}

class _AppCarouselState extends State<AppCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel(); // Cancel any existing timer
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (widget.items.isEmpty) return;
      int nextPage = (_currentPage + 1) % widget.items.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    if (widget.autoPlay) {
      // Restart timer on manual interaction
      _startAutoPlay();
    }
  }

  void _previousPage() {
    if (widget.items.isEmpty || _currentPage == 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    if (widget.items.isEmpty || _currentPage == widget.items.length - 1) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return SizedBox(
        height: widget.height ?? 200,
      ); // Placeholder for empty carousel
    }

    return SizedBox(
      height: widget.height ?? 200, // Default height if not provided
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: widget.items,
          ),
          if (widget.showIndicator)
            Positioned(
              bottom:
                  AppDimensions
                      .spacingS, // Corrected: paddingSmall -> spacingS (or spacingM depending on desired size)
              child: _buildPageIndicator(),
            ),
          if (widget.showNavigationButtons) _buildNavigationControls(),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.items.length, (index) {
        return Container(
          width:
              AppDimensions
                  .spacingS, // Corrected: iconSizeXs -> spacingS (or a small specific dimension like 8.0)
          height: AppDimensions.spacingS, // Corrected: iconSizeXs -> spacingS
          margin: const EdgeInsets.symmetric(
            horizontal:
                AppDimensions.spacingXs, // Corrected: spacingXxs -> spacingXs
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                _currentPage == index
                    ? AppColors
                        .primaryBlue // Corrected: primary -> primaryBlue
                    : AppColors
                        .mediumGray, // Corrected: grey400 -> mediumGray (or lightGray)
          ),
        );
      }),
    );
  }

  Widget _buildNavigationControls() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CupertinoButton(
              onPressed: _currentPage > 0 ? _previousPage : null,
              padding: const EdgeInsets.all(
                AppDimensions.spacingS,
              ), // Corrected: paddingSmall -> spacingS
              child: Icon(
                CupertinoIcons.chevron_left,
                color:
                    _currentPage > 0
                        ? AppColors.primaryBlue
                        : AppColors
                            .mediumGray, // Corrected: primary -> primaryBlue, grey500 -> mediumGray
                size:
                    AppDimensions
                        .iconSizeMedium, // Corrected: iconSizeLarge -> iconSizeMedium (or specific value)
              ),
            ),
            CupertinoButton(
              onPressed:
                  _currentPage < widget.items.length - 1 ? _nextPage : null,
              padding: const EdgeInsets.all(
                AppDimensions.spacingS,
              ), // Corrected: paddingSmall -> spacingS
              child: Icon(
                CupertinoIcons.chevron_right,
                color:
                    _currentPage < widget.items.length - 1
                        ? AppColors
                            .primaryBlue // Corrected: primary -> primaryBlue
                        : AppColors
                            .mediumGray, // Corrected: grey500 -> mediumGray
                size:
                    AppDimensions
                        .iconSizeMedium, // Corrected: iconSizeLarge -> iconSizeMedium
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example Usage (to be placed in a screen/page):
/*
class MyCarouselPage extends StatelessWidget {
  const MyCarouselPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Carousel Example'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            AppCarousel(
              height: 250,
              autoPlay: true,
              items: [
                Container(color: CupertinoColors.activeBlue, child: const Center(child: Text('Page 1', style: TextStyle(color: CupertinoColors.white, fontSize: 24)))),
                Container(color: CupertinoColors.activeGreen, child: const Center(child: Text('Page 2', style: TextStyle(color: CupertinoColors.white, fontSize: 24)))),
                Container(color: CupertinoColors.activeOrange, child: const Center(child: Text('Page 3', style: TextStyle(color: CupertinoColors.white, fontSize: 24)))),
                Container(color: CupertinoColors.systemPink, child: const Center(child: Text('Page 4', style: TextStyle(color: CupertinoColors.white, fontSize: 24)))),
              ],
            ),
            const SizedBox(height: 20),
            // Other content
          ],
        ),
      ),
    );
  }
}
*/
