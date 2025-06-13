import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

/// Represents a single column definition for the AppTable.
class AppTableColumn {
  final String title;
  final String dataKey; // Key to access data in the row map
  final double? width; // Optional fixed width for the column
  final Alignment alignment;
  final TextAlign textAlign;

  AppTableColumn({
    required this.title,
    required this.dataKey,
    this.width,
    this.alignment = Alignment.centerLeft,
    this.textAlign = TextAlign.left,
  });
}

/// A customizable data table with a Cupertino-inspired design.
class AppTable<T> extends StatelessWidget {
  final List<AppTableColumn> columns;
  final List<Map<String, dynamic>> data; // Each map represents a row
  final Widget? caption;
  final BoxDecoration? headerDecoration;
  final BoxDecoration? rowDecoration;
  final BoxDecoration? cellDecoration;
  final TextStyle? headerTextStyle;
  final TextStyle? cellTextStyle;
  final double headerHeight;
  final double rowHeight;
  final EdgeInsets cellPadding;

  const AppTable({
    super.key,
    required this.columns,
    required this.data,
    this.caption,
    this.headerDecoration,
    this.rowDecoration,
    this.cellDecoration,
    this.headerTextStyle,
    this.cellTextStyle,
    this.headerHeight = 48.0,
    this.rowHeight = 48.0,
    this.cellPadding = const EdgeInsets.symmetric(
      horizontal: AppDimensions.spacingM,
      vertical: AppDimensions.spacingS,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeaderTextStyle =
        headerTextStyle ??
        AppTextStyles.bodyBold.copyWith(color: AppColors.mediumGray);
    final effectiveCellTextStyle =
        cellTextStyle ??
        AppTextStyles.body.copyWith(color: AppColors.foregroundDark);
    final effectiveHeaderDecoration =
        headerDecoration ??
        BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.borderGray, width: 0.5),
          ),
        );
    final effectiveRowDecoration =
        rowDecoration ??
        BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.borderGray, width: 0.5),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header Row
        Container(
          height: headerHeight,
          decoration: effectiveHeaderDecoration,
          child: Row(
            children:
                columns.map((col) {
                  Widget child = Padding(
                    padding: cellPadding,
                    child: Text(
                      col.title,
                      style: effectiveHeaderTextStyle,
                      textAlign: col.textAlign,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                  if (col.width != null) {
                    return SizedBox(
                      width: col.width,
                      child: Align(alignment: col.alignment, child: child),
                    );
                  }
                  return Expanded(
                    child: Align(alignment: col.alignment, child: child),
                  );
                }).toList(),
          ),
        ),
        // Data Rows
        if (data.isEmpty)
          Container(
            height: rowHeight * 3, // Show some space if no data
            alignment: Alignment.center,
            child: Text(
              'No data available',
              style: AppTextStyles.body.copyWith(color: AppColors.mediumGray),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // If the table is inside another scrollable
            itemCount: data.length,
            itemBuilder: (context, rowIndex) {
              final rowData = data[rowIndex];
              return Container(
                height: rowHeight,
                decoration: effectiveRowDecoration,
                child: Row(
                  children:
                      columns.map((col) {
                        Widget cellContent = Text(
                          rowData[col.dataKey]?.toString() ?? '',
                          style: effectiveCellTextStyle,
                          textAlign: col.textAlign,
                          overflow: TextOverflow.ellipsis,
                        );

                        Widget child = Padding(
                          padding: cellPadding,
                          child: cellContent,
                        );

                        if (col.width != null) {
                          return SizedBox(
                            width: col.width,
                            child: Align(
                              alignment: col.alignment,
                              child: child,
                            ),
                          );
                        }
                        return Expanded(
                          child: Align(alignment: col.alignment, child: child),
                        );
                      }).toList(),
                ),
              );
            },
          ),
        // Caption
        if (caption != null)
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.spacingM),
            child: DefaultTextStyle(
              style: AppTextStyles.caption.copyWith(
                color: AppColors.mediumGray,
              ),
              child: caption!,
            ),
          ),
      ],
    );
  }
}

// Example Usage (can be placed in a different file or a storybook):
/*
class MyTablePage extends StatelessWidget {
  const MyTablePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<AppTableColumn> columns = [
      AppTableColumn(title: 'ID', dataKey: 'id', width: 80),
      AppTableColumn(title: 'Name', dataKey: 'name'),
      AppTableColumn(title: 'Role', dataKey: 'role', alignment: Alignment.centerRight, textAlign: TextAlign.right),
    ];

    final List<Map<String, dynamic>> data = [
      {'id': 1, 'name': 'John Doe', 'role': 'Developer'},
      {'id': 2, 'name': 'Jane Smith', 'role': 'Designer'},
      {'id': 3, 'name': 'Peter Jones', 'role': 'Manager'},
    ];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Table Example')),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacingL),
          child: AppTable(
            columns: columns,
            data: data,
            caption: Text('List of team members.'),
          ),
        ),
      ),
    );
  }
}
*/
