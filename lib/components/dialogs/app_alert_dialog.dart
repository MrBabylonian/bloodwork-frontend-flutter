// ignore_for_file: use_super_parameters

import 'package:flutter/cupertino.dart';

class AppAlertDialog extends StatelessWidget {
  final Widget? title;
  final Widget? content;
  final List<Widget> actions;

  const AppAlertDialog({
    Key? key,
    this.title,
    this.content,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: title,
      content: content,
      actions: actions,
    );
  }
}

class AppAlertDialogAction extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isDefaultAction;
  final bool isDestructiveAction;

  const AppAlertDialogAction({
    Key? key,
    required this.child,
    this.onPressed,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoDialogAction(
      onPressed: onPressed,
      isDefaultAction: isDefaultAction,
      isDestructiveAction: isDestructiveAction,
      child: child,
    );
  }
}

// Helper function to show the dialog
Future<T?> showAppAlertDialog<T>({
  required BuildContext context,
  Widget? title,
  Widget? content,
  required List<Widget> actions,
  bool barrierDismissible = false,
}) {
  return showCupertinoDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return AppAlertDialog(title: title, content: content, actions: actions);
    },
  );
}
