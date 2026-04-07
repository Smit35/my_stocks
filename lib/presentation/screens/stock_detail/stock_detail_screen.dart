import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/light_theme.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/datasources/mock_stock_api.dart';
import '../../bloc/stock_detail/stock_detail_bloc.dart';
import '../../bloc/stock_detail/stock_detail_event.dart';

class StockDetailScreen extends StatefulWidget {
  final StockModel stock;

  const StockDetailScreen({
    super.key,
    required this.stock,
  });

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  String selectedTimeframe = '1D';
  late StockModel currentStock;

  @override
  void initState() {
    super.initState();
    currentStock = MockStockApi.getUpdatedStock(widget.stock);
    context.read<StockDetailBloc>().add(LoadStockDetail(currentStock));
  }

  @override
  Widget build(BuildContext context) {
    final stockInfo = MockStockApi.getStockInfo(currentStock.symbol);
    
    return Scaffold(
      backgroundColor: LightTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: LightTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Text(
              '${currentStock.symbol} ',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              child: Text(
                stockInfo['name']
                    ?.toString()
                    .split(' ')
                    .take(2)
                    .join(' ') ??
                    currentStock.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildStockDetail(context),
    );
  }

  Widget _buildStockDetail(BuildContext context) {
    final stockInfo = MockStockApi.getStockInfo(currentStock.symbol);
    final isPositive = currentStock.changeAmount >= 0;
    final changeColor = isPositive ? LightTheme.positiveColor : LightTheme.negativeColor;
    final chartData = MockStockApi.getChartData(currentStock.symbol, selectedTimeframe);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '₹',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                      TextSpan(
                        text: currentStock.currentPrice.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          height: 1.0,
                        ),
                      ),
                      TextSpan(
                        text:
                        '.${(currentStock.currentPrice % 1 * 100).toInt().toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${isPositive ? '+' : ''}₹${currentStock.changeAmount.toStringAsFixed(0)} (${currentStock.changePercentage.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: changeColor,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildInfoTag(stockInfo['sector']?.toString() ?? 'INDUSTRIAL'),
                    const SizedBox(width: 6),
                    _buildInfoTag(stockInfo['marketCap']?.toString() ?? 'LARGE CAP'),
                  ],
                ),
              ],
            ),
          ),
          // Chart Section
          Container(
            height: 150,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildChart(chartData, changeColor),
          ),
          
          // Time Period Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['1D', '1W', '1M', '3M', '6M', 'YTD', '1Y'].map((period) {
                final isSelected = selectedTimeframe == period;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTimeframe = period;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? LightTheme.positiveColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      period,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTab('Overview', true),
                const SizedBox(width: 32),
                _buildTab('F&O', false),
                const SizedBox(width: 32),
                _buildTab('News', false),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Your Position Section
          _buildPositionSection(),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Wallet ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LightTheme.positiveColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Trade',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildInfoTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildChart(List<Map<String, dynamic>> chartData, Color lineColor) {
    if (chartData.isEmpty) {
      return Center(
        child: Text(
          'Chart data loading...',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    // Create a simple line chart representation
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: SimpleLinePainter(chartData, lineColor),
        child: const SizedBox(
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool isSelected) {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.black : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 2,
          width: 40,
          color: isSelected ? Colors.black : Colors.transparent,
        ),
      ],
    );
  }

  Widget _buildPositionSection() {
    // Mock portfolio data
    const shares = 28;
    const avgCost = 400.2;
    const marketValue = shares * 441.60;
    const totalReturn = marketValue - (shares * avgCost);
    const returnPercentage = (totalReturn / (shares * avgCost)) * 100;
    const todayReturn = 1400.4;
    const todayReturnPercentage = 0.34;
    const portfolioDiversity = 5.16;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Position',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SHARES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '$shares',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MARKET VALUE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${NumberFormat('#,##0.0').format(marketValue)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AVG. COST',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${avgCost.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PORTFOLIO DIVERSITY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${portfolioDiversity.toStringAsFixed(2)}%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Today's and Total Return in single row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Return',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+₹${todayReturn.toStringAsFixed(1)} (+${todayReturnPercentage.toStringAsFixed(2)}%)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: LightTheme.positiveColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Return',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+₹${totalReturn.toStringAsFixed(1)} (+${returnPercentage.toStringAsFixed(2)}%)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: LightTheme.positiveColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Simple line chart painter
class SimpleLinePainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final Color lineColor;

  SimpleLinePainter(this.data, this.lineColor);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dashPaint = Paint()
      ..color = Colors.grey.withOpacity(0.4)
      ..strokeWidth = 1;

    final dashWidth = 6;
    final dashSpace = 4;
    double startX = 0;
    final centerY = size.height / 2;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, centerY),
        Offset(startX + dashWidth, centerY),
        dashPaint,
      );
      startX += dashWidth + dashSpace;
    }
    double minPrice = data.first['price'];
    double maxPrice = data.first['price'];

    for (final point in data) {
      final price = point['price'];
      if (price < minPrice) minPrice = price;
      if (price > maxPrice) maxPrice = price;
    }

    final range = maxPrice - minPrice;
    if (range == 0) return;

    final path = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalized = (data[i]['price'] - minPrice) / range;
      final y = size.height - (normalized * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}