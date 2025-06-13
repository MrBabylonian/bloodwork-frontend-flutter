import 'package:flutter/cupertino.dart';

Future<T?> showAppDrawer<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  bool useRootNavigator = false,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  // bool shouldScaleBackground = true, // Not directly supported by Cupertino modal popups
}) {
  // The `vaul` library used in the mock scales the background page.
  // `showCupertinoModalPopup` doesn't do this by default.

  return showCupertinoModalPopup<T>(
    context: context,
    builder: (BuildContext popupContext) {
      // The builder for showCupertinoModalPopup typically expects a Cupertino-styled widget.
      // The AppDrawer itself is already styled, so we can return it directly after being built.
      return builder(popupContext);
    },
    filter: null, // No image filter needed for a simple drawer
    barrierColor:
        barrierColor ??
        CupertinoColors.black.withValues(alpha: 0.54), // Default barrier color
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
    // Note: showCupertinoModalPopup does not have a direct `shape` or `backgroundColor` parameter
    // for the popup itself like showModalBottomSheet. The AppDrawer widget returned by the builder
    // is responsible for its own background color and shape (rounded corners).
    // Elevation is also not a direct parameter here; shadows would be part of AppDrawer's styling if desired.
  );
}

// Example Usage (to be placed in a widget that can show the drawer):
/*
CupertinoButton(
  child: Text('Open Drawer'),
  onPressed: () {
    showAppDrawer(
      context: context,
      builder: (BuildContext drawerContext) {
        return AppDrawer(
          title: AppDrawerTitle('Drawer Title'),
          description: AppDrawerDescription('This is a description for the drawer.'),
          children: [
            CupertinoListTile(
              title: Text('Menu Item 1'),
              onTap: () => Navigator.pop(drawerContext),
            ),
            CupertinoListTile(
              title: Text('Menu Item 2'),
              onTap: () => Navigator.pop(drawerContext),
            ),
          ],
          footer: AppDrawerFooter(
            children: [
              CupertinoButton.filled(
                child: Text('Close'),
                onPressed: () => Navigator.pop(drawerContext),
              ),
            ],
          ),
        );
      },
    );
  },
)
*/
