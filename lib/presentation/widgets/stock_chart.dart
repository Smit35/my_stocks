import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/time_series_model.dart';

class StockChart extends StatelessWidget {
  final List<TimeSeriesModel> timeSeries;
  final bool isPositive;
  final bool isLoading;

  const StockChart({
    super.key,
    required this.timeSeries,
    required this.isPositive,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (timeSeries.isEmpty) {
      return const Center(
        child: Text(
          'No chart data available',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    final chartColor = isPositive ? AppTheme.positiveColor : AppTheme.negativeColor;
    
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: _getChartSpots(),
                  isCurved: true,
                  color: chartColor,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: chartColor.withOpacity(0.1),
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '₹${value.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: _getXAxisInterval(),
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < timeSeries.length) {
                        final date = timeSeries[value.toInt()].datetime;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _formatXAxisLabel(date),
                            style: const TextStyle(
                              color: AppTheme.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                drawVerticalLine: false,
                horizontalInterval: _getYAxisInterval(),
                getDrawingHorizontalLine: (value) {
                  return const FlLine(
                    color: AppTheme.surfaceColor,
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: AppTheme.cardColor.withOpacity(0.9),
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      if (spot.x.toInt() >= 0 && spot.x.toInt() < timeSeries.length) {
                        final dataPoint = timeSeries[spot.x.toInt()];
                        return LineTooltipItem(
                          '₹${spot.y.toStringAsFixed(2)}\n${_formatTooltipDate(dataPoint.datetime)}',
                          const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }
                      return null;
                    }).toList();
                  },
                ),
                handleBuiltInTouches: true,
              ),
              minY: _getMinY() * 0.995,
              maxY: _getMaxY() * 1.005,
            ),
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: AppTheme.backgroundColor.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<FlSpot> _getChartSpots() {
    return timeSeries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.close);
    }).toList();
  }

  double _getMinY() {
    if (timeSeries.isEmpty) return 0;
    return timeSeries.map((e) => e.low).reduce((a, b) => a < b ? a : b);
  }

  double _getMaxY() {
    if (timeSeries.isEmpty) return 100;
    return timeSeries.map((e) => e.high).reduce((a, b) => a > b ? a : b);
  }

  double _getYAxisInterval() {
    final range = _getMaxY() - _getMinY();
    return range / 5; // Show 5 horizontal lines
  }

  double _getXAxisInterval() {
    if (timeSeries.length <= 5) return 1;
    return (timeSeries.length / 4).floorToDouble(); // Show about 4 labels
  }

  String _formatXAxisLabel(DateTime date) {
    if (timeSeries.length <= 7) {
      // For small datasets (like daily data), show day/month
      return '${date.day}/${date.month}';
    } else if (timeSeries.length <= 30) {
      // For medium datasets, show day/month
      return '${date.day}/${date.month}';
    } else {
      // For larger datasets, show month/year
      return '${date.month}/${date.year.toString().substring(2)}';
    }
  }

  String _formatTooltipDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}