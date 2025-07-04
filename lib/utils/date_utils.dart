import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Returns a locale-aware short date string (e.g. 31/12/2024 or 12/31/2024)
/// based on the user's current device locale.
String formatShortDate(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMd(locale).format(date);
}
