import 'package:flutter/cupertino.dart';

class AuthLoadingWidget extends StatelessWidget {
  const AuthLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(radius: 20),
            SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
