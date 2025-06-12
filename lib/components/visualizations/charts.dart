import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

/// Data point for medical metrics.
class MedicalDataPoint {
  /// Creates a medical data point with the specified properties.
  const MedicalDataPoint({
    required this.value,
    required this.date,
    this.normalRangeMin,
    this.normalRangeMax,
    this.label,
  });

  /// The measured value.
  final double value;

  /// The date of the measurement.
  final DateTime date;

  /// Optional minimum of normal range.
  final double? normalRangeMin;

  /// Optional maximum of normal range.
  final double? normalRangeMax;

  /// Optional label for the data point.
  final String? label;

  /// Check if this value is within normal range.
  bool get isWithinNormalRange {
    if (normalRangeMin == null || normalRangeMax == null) {
      return true;
    }
    // Ensure non-null before comparison if they are nullable
    return value >= normalRangeMin! && value <= normalRangeMax!;
  }
}

/// A line chart component for visualizing medical data over time.
class MedicalLineChart extends StatelessWidget {
  /// Creates a medical line chart with the specified properties.
  const MedicalLineChart({
    super.key,
    required this.dataPoints,
    required this.title,
    this.unit = '',
    this.normalRangeLabel = 'Range normale',
    this.height = 240,
    this.showNormalRange = true,
    this.showDots = true,
    this.lineColor = AppColors.primaryBlue,
    this.normalRangeFillColor,
  });

  /// The data points to display in the chart.
  final List<MedicalDataPoint> dataPoints;

  /// The title of the chart.
  final String title;

  /// The unit of measurement (e.g., "mg/dL").
  final String unit;

  /// Label for the normal range area.
  final String normalRangeLabel;

  /// Height of the chart.
  final double height;

  /// Whether to show the normal range area.
  final bool showNormalRange;

  /// Whether to show dots at each data point.
  final bool showDots;

  /// Color of the data line.
  final Color lineColor;

  /// Fill color for the normal range area.
  final Color? normalRangeFillColor;

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Nessun dato disponibile')),
      );
    }

    double minY = double.infinity;
    double maxY = double.negativeInfinity;
    double? normalRangeMinGlobal;
    double? normalRangeMaxGlobal;

    for (final point in dataPoints) {
      if (point.value < minY) minY = point.value;
      if (point.value > maxY) maxY = point.value;

      if (point.normalRangeMin != null) {
        if (normalRangeMinGlobal == null ||
            point.normalRangeMin! < normalRangeMinGlobal) {
          normalRangeMinGlobal = point.normalRangeMin;
        }
      }
      if (point.normalRangeMax != null) {
        if (normalRangeMaxGlobal == null ||
            point.normalRangeMax! > normalRangeMaxGlobal) {
          normalRangeMaxGlobal = point.normalRangeMax;
        }
      }
    }

    if (dataPoints.isNotEmpty) {
      final padding =
          (maxY - minY).abs() * 0.1; // Use abs() in case minY == maxY
      minY =
          (minY - padding).isNaN
              ? 0
              : (minY - padding); // Handle NaN if minY and maxY were equal
      maxY = (maxY + padding).isNaN ? 10 : (maxY + padding); // Handle NaN

      if (minY == maxY) {
        // Ensure there's a range if all values are the same
        minY -= 1;
        maxY += 1;
      }
    } else {
      // Default range if no data points
      minY = 0;
      maxY = 10;
    }

    if (normalRangeMinGlobal != null && normalRangeMinGlobal < minY) {
      minY = normalRangeMinGlobal;
    }
    if (normalRangeMaxGlobal != null && normalRangeMaxGlobal > maxY) {
      maxY = normalRangeMaxGlobal;
    }
    // Ensure minY is not greater than maxY after adjustments
    if (minY > maxY) {
      minY = maxY - 1; // Or some other sensible default
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
          child: Row(
            children: [
              Text(title, style: AppTextStyles.title3),
              const SizedBox(width: AppDimensions.spacingXs),
              Text(
                unit,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(
                show: true,
                drawVerticalLine: false,
                // horizontalInterval: 10, // Consider making this dynamic or removing if not needed
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    // interval: 1, // Consider making this dynamic based on dataPoints.length
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < dataPoints.length) {
                        // Show fewer labels if too many data points
                        if (dataPoints.length > 10 &&
                            index % (dataPoints.length ~/ 5) != 0 &&
                            index != dataPoints.length - 1 &&
                            index != 0) {
                          // return const SizedBox.shrink(); // Skips labels to prevent clutter
                        }
                        final date = dataPoints[index].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${date.day}/${date.month}',
                            style: AppTextStyles.caption,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    // interval: (maxY - minY) / 5, // Example: 5 labels
                    getTitlesWidget: (value, meta) {
                      // Prevents showing title for minY if it's the same as a grid line
                      if (value == meta.min) return const SizedBox.shrink();
                      return Text(
                        value.toStringAsFixed(0),
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.left,
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.borderGray,
                    width: AppDimensions.borderWidth,
                  ),
                  left: BorderSide(
                    color: AppColors.borderGray,
                    width: AppDimensions.borderWidth,
                  ),
                ),
              ),
              minX: 0,
              maxX:
                  dataPoints.isEmpty
                      ? 1
                      : dataPoints.length.toDouble() - 1, // Ensure maxX > minX
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                if (showNormalRange &&
                    normalRangeMinGlobal != null &&
                    normalRangeMaxGlobal != null)
                  LineChartBarData(
                    spots: [
                      FlSpot(0, normalRangeMaxGlobal),
                      FlSpot(
                        dataPoints.isEmpty
                            ? 1
                            : dataPoints.length.toDouble() - 1,
                        normalRangeMaxGlobal,
                      ),
                    ],
                    isCurved: false,
                    barWidth: 0,
                    color: const Color(0x00000000), // Transparent
                    belowBarData: BarAreaData(
                      show: true,
                      color:
                          normalRangeFillColor ??
                          _getTransparentColor(AppColors.successGreen, 0.1),
                      cutOffY: normalRangeMinGlobal,
                      applyCutOffY: true,
                    ),
                    dotData: const FlDotData(show: false),
                  ),
                LineChartBarData(
                  spots: List.generate(dataPoints.length, (i) {
                    return FlSpot(i.toDouble(), dataPoints[i].value);
                  }),
                  isCurved: true,
                  barWidth: 3,
                  color: lineColor,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: showDots,
                    getDotPainter: (spot, percent, bar, index) {
                      final isWithinRange =
                          dataPoints[index].isWithinNormalRange;
                      return FlDotCirclePainter(
                        radius: 4,
                        color:
                            isWithinRange
                                ? AppColors.successGreen
                                : AppColors.destructiveRed,
                        strokeWidth: 2,
                        strokeColor: AppColors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (LineBarSpot spot) {
                    // Changed to getTooltipColor
                    return _getTransparentColor(AppColors.foregroundDark, 0.8);
                  },
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots
                        .map((spot) {
                          final index = spot.x.toInt();
                          if (index < 0 || index >= dataPoints.length) {
                            return null;
                          } // Boundary check
                          final point = dataPoints[index];
                          return LineTooltipItem(
                            '${point.value.toStringAsFixed(1)} $unit',
                            AppTextStyles.caption.copyWith(
                              color: AppColors.white,
                            ),
                            children: [
                              if (point.label != null)
                                TextSpan(
                                  text: '\n${point.label}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.white,
                                    fontSize:
                                        AppTextStyles.caption.fontSize! * 0.85,
                                  ),
                                ),
                            ],
                          );
                        })
                        .whereType<LineTooltipItem>()
                        .toList(); // Filter out nulls
                  },
                ),
              ),
            ),
          ),
        ),
        if (showNormalRange &&
            normalRangeMinGlobal != null &&
            normalRangeMaxGlobal != null)
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.spacingM),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color:
                        normalRangeFillColor ??
                        _getTransparentColor(AppColors.successGreen, 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingXs),
                Text(
                  '$normalRangeLabel: $normalRangeMinGlobal - $normalRangeMaxGlobal $unit',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _getTransparentColor(Color baseColor, double opacity) {
    return Color.fromRGBO(
      baseColor.r.toInt(),
      baseColor.g.toInt(),
      baseColor.b.toInt(),
      opacity,
    );
  }
}
