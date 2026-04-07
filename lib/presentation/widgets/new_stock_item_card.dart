import 'package:flutter/material.dart';
import '../../core/theme/light_theme.dart';
import '../../data/models/stock_model.dart';
import 'package:intl/intl.dart';

class NewStockItemCard extends StatelessWidget {
  final StockModel stock;
  final VoidCallback onTap;

  const NewStockItemCard({
    super.key,
    required this.stock,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = stock.changeAmount >= 0;
    final changeColor =
    isPositive ? LightTheme.positiveColor : LightTheme.negativeColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[100]!, width: 1),
          ),

          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: isPositive
                ? [
              Colors.green.withOpacity(0.12),
              Colors.green.withOpacity(0.05),
              Colors.transparent,
            ]
                : [
              Colors.red.withOpacity(0.12),
              Colors.red.withOpacity(0.05),
              Colors.transparent,
            ],
            stops: const [0.0, 0.3, 0.75],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              /// LEFT SECTION
              Expanded(
                child: Row(
                  children: [
                    _buildStockLogo(),
                    const SizedBox(width: 8),

                    /// Stock Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                stock.symbol,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 6),

                              /// NSE badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  stock.exchange ?? 'NSE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 2),

                          Text(
                            _getShortName(
                                stock.name.isNotEmpty
                                    ? stock.name
                                    : stock.symbol),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    stock.currentPrice > 0
                        ? '₹${_formatPrice(stock.currentPrice)}'
                        : '--',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (stock.currentPrice > 0)
                    Text(
                      '${isPositive ? '+' : ''}${stock.changePercentage.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: changeColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockLogo() {
    final logoColor = _getLogoColor(stock.symbol);
    final logoText = _getLogoText(stock.symbol);
    
    return Container(
      width: 36, // ⬅️ reduced
      height: 36,
      decoration: BoxDecoration(
        color: logoColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          logoText,
          style: TextStyle(
            color: Colors.white,
            fontSize: logoText.length > 3 ? 9 : 11,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Color _getLogoColor(String symbol) {
    // Brand colors for Indian companies
    switch (symbol.toUpperCase()) {
      case 'ACC':
        return const Color(0xFFE53E3E); // ACC Red
      case 'INFY':
        return const Color(0xFF007CC3); // Infosys Blue  
      case 'ITC':
        return const Color(0xFF8B4513); // ITC Brown
      case 'HUL':
      case 'HINDUNILVR':
        return const Color(0xFF0A74DA); // Unilever Blue
      case 'TCS':
        return const Color(0xFF0052CC); // TCS Blue
      case 'RELIANCE':
        return const Color(0xFF003580); // Reliance Navy Blue
      case 'HDFCBANK':
        return const Color(0xFF004B87); // HDFC Blue
      case 'ICICIBANK':
        return const Color(0xFFED6C02); // ICICI Orange
      case 'AXISBANK':
        return const Color(0xFF800080); // Axis Purple
      case 'SBIN':
        return const Color(0xFF1B5E20); // SBI Green
      case 'KOTAKBANK':
        return const Color(0xFF003A70); // Kotak Blue
      case 'BHARTIARTL':
        return const Color(0xFFE31837); // Airtel Red
      case 'BAJFINANCE':
        return const Color(0xFF0066CC); // Bajaj Blue
      case 'LT':
        return const Color(0xFF003A70); // L&T Blue
      case 'HCLTECH':
        return const Color(0xFF1F4788); // HCL Blue
      case 'ASIANPAINT':
        return const Color(0xFFE31837); // Asian Paints Red
      case 'MARUTI':
        return const Color(0xFFE31837); // Maruti Red
      case 'TITAN':
        return const Color(0xFFFFD700); // Titan Gold
      case 'ULTRACEMCO':
        return const Color(0xFF8B4513); // UltraTech Brown
      case 'WIPRO':
        return const Color(0xFF4CAF50); // Wipro Green
      case 'NESTLEIND':
        return const Color(0xFFE31837); // Nestle Red
      case 'ADANIPORTS':
        return const Color(0xFF1565C0); // Adani Blue
      case 'POWERGRID':
        return const Color(0xFF2E7D32); // PowerGrid Green
      case 'NTPC':
        return const Color(0xFF1B5E20); // NTPC Green
      case 'JSWSTEEL':
        return const Color(0xFF424242); // JSW Gray
      case 'TATAMOTORS':
        return const Color(0xFF1565C0); // Tata Blue
      case 'TATASTEEL':
        return const Color(0xFF1565C0); // Tata Blue
      case 'TATAPOWER':
        return const Color(0xFF1565C0); // Tata Blue
      case 'TATACONSUM':
        return const Color(0xFF1565C0); // Tata Blue
      case 'TECHM':
        return const Color(0xFF9C27B0); // Tech Mahindra Purple
      case 'SUNPHARMA':
        return const Color(0xFFFF9800); // Sun Pharma Orange
      case 'DRREDDY':
        return const Color(0xFFE91E63); // Dr Reddy's Pink
      case 'DIVISLAB':
        return const Color(0xFF3F51B5); // Divi's Blue
      case 'CIPLA':
        return const Color(0xFF4CAF50); // Cipla Green
      default:
        // Generate color based on first character
        final firstChar = symbol.isNotEmpty ? symbol[0].codeUnitAt(0) : 65;
        final colors = [
          const Color(0xFF1976D2), // Blue
          const Color(0xFF388E3C), // Green  
          const Color(0xFFD32F2F), // Red
          const Color(0xFF7B1FA2), // Purple
          const Color(0xFFFF8F00), // Orange
          const Color(0xFF5D4037), // Brown
          const Color(0xFF455A64), // Blue Gray
          const Color(0xFFE91E63), // Pink
        ];
        return colors[firstChar % colors.length];
    }
  }

  String _getLogoText(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'ACC':
        return 'ACC';
      case 'INFY':
        return 'infy';
      case 'ITC':
        return 'ITC';
      case 'HUL':
      case 'HINDUNILVR':
        return 'HUL';
      case 'TCS':
        return 'TCS';
      default:
        return symbol.length >= 3 ? symbol.substring(0, 3) : symbol;
    }
  }

  String _getShortName(String fullName) {
    if (fullName.length <= 20) return fullName;
    
    // Common abbreviations for Indian companies
    final abbreviations = {
      'Limited': 'Ltd.',
      'Industries': 'Ind.',
      'Corporation': 'Corp.',
      'Technologies': 'Tech.',
      'Consultancy': 'Cons.',
      'Services': 'Serv.',
    };
    
    String shortened = fullName;
    abbreviations.forEach((full, abbr) {
      shortened = shortened.replaceAll(full, abbr);
    });
    
    if (shortened.length > 20) {
      return '${shortened.substring(0, 17)}...';
    }
    
    return shortened;
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return NumberFormat('#,##0.00').format(price);
    }
    return price.toStringAsFixed(2);
  }
}