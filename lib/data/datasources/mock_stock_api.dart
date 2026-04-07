import 'dart:math';
import '../models/stock_model.dart';

class MockStockApi {
  // Realistic Indian stock prices (approximate current prices)
  static final Map<String, Map<String, dynamic>> _stockPrices = {
    'RELIANCE': {
      'price': 2847.50,
      'change': 45.20,
      'percentage': 1.61,
      'name': 'Reliance Industries Limited',
      'sector': 'Oil & Gas',
      'marketCap': 'Large Cap',
    },
    'TCS': {
      'price': 3298.90,
      'change': 78.15,
      'percentage': 2.43,
      'name': 'Tata Consultancy Services Limited',
      'sector': 'Information Technology',
      'marketCap': 'Large Cap',
    },
    'HDFCBANK': {
      'price': 1472.35,
      'change': -12.45,
      'percentage': -0.84,
      'name': 'HDFC Bank Limited',
      'sector': 'Banking',
      'marketCap': 'Large Cap',
    },
    'INFY': {
      'price': 1419.50,
      'change': -6.30,
      'percentage': -0.44,
      'name': 'Infosys Limited',
      'sector': 'Information Technology',
      'marketCap': 'Large Cap',
    },
    'HINDUNILVR': {
      'price': 2375.00,
      'change': 8.25,
      'percentage': 0.35,
      'name': 'Hindustan Unilever Limited',
      'sector': 'FMCG',
      'marketCap': 'Large Cap',
    },
    'ITC': {
      'price': 441.60,
      'change': 228.00,
      'percentage': 14.4,
      'name': 'ITC Limited',
      'sector': 'FMCG',
      'marketCap': 'Large Cap',
    },
    'ICICIBANK': {
      'price': 1038.75,
      'change': 15.60,
      'percentage': 1.53,
      'name': 'ICICI Bank Limited',
      'sector': 'Banking',
      'marketCap': 'Large Cap',
    },
    'BHARTIARTL': {
      'price': 1547.30,
      'change': -18.90,
      'percentage': -1.21,
      'name': 'Bharti Airtel Limited',
      'sector': 'Telecommunications',
      'marketCap': 'Large Cap',
    },
    'SBIN': {
      'price': 825.45,
      'change': 12.85,
      'percentage': 1.58,
      'name': 'State Bank of India',
      'sector': 'Banking',
      'marketCap': 'Large Cap',
    },
    'BAJFINANCE': {
      'price': 6789.20,
      'change': -145.30,
      'percentage': -2.10,
      'name': 'Bajaj Finance Limited',
      'sector': 'Financial Services',
      'marketCap': 'Large Cap',
    },
    'LT': {
      'price': 3654.80,
      'change': 89.45,
      'percentage': 2.51,
      'name': 'Larsen & Toubro Limited',
      'sector': 'Construction',
      'marketCap': 'Large Cap',
    },
    'HCLTECH': {
      'price': 1287.95,
      'change': -23.15,
      'percentage': -1.77,
      'name': 'HCL Technologies Limited',
      'sector': 'Information Technology',
      'marketCap': 'Large Cap',
    },
    'ASIANPAINT': {
      'price': 2456.70,
      'change': 34.20,
      'percentage': 1.41,
      'name': 'Asian Paints Limited',
      'sector': 'Paints',
      'marketCap': 'Large Cap',
    },
    'MARUTI': {
      'price': 10847.25,
      'change': -287.50,
      'percentage': -2.58,
      'name': 'Maruti Suzuki India Limited',
      'sector': 'Automobile',
      'marketCap': 'Large Cap',
    },
    'KOTAKBANK': {
      'price': 1698.40,
      'change': 25.75,
      'percentage': 1.54,
      'name': 'Kotak Mahindra Bank Limited',
      'sector': 'Banking',
      'marketCap': 'Large Cap',
    },
    'TITAN': {
      'price': 3245.90,
      'change': -67.80,
      'percentage': -2.05,
      'name': 'Titan Company Limited',
      'sector': 'Jewellery',
      'marketCap': 'Large Cap',
    },
    'AXISBANK': {
      'price': 1154.30,
      'change': 18.45,
      'percentage': 1.63,
      'name': 'Axis Bank Limited',
      'sector': 'Banking',
      'marketCap': 'Large Cap',
    },
    'ULTRACEMCO': {
      'price': 11234.50,
      'change': 178.90,
      'percentage': 1.62,
      'name': 'UltraTech Cement Limited',
      'sector': 'Cement',
      'marketCap': 'Large Cap',
    },
    'WIPRO': {
      'price': 567.85,
      'change': -8.45,
      'percentage': -1.47,
      'name': 'Wipro Limited',
      'sector': 'Information Technology',
      'marketCap': 'Large Cap',
    },
    'NESTLEIND': {
      'price': 2187.45,
      'change': 45.30,
      'percentage': 2.11,
      'name': 'Nestle India Limited',
      'sector': 'FMCG',
      'marketCap': 'Large Cap',
    },
    'ACC': {
      'price': 2061.70,
      'change': 24.85,
      'percentage': 1.22,
      'name': 'ACC Limited',
      'sector': 'Cement',
      'marketCap': 'Large Cap',
    },
    'ADANIPORTS': {
      'price': 1287.60,
      'change': -15.20,
      'percentage': -1.17,
      'name': 'Adani Ports and SEZ Limited',
      'sector': 'Infrastructure',
      'marketCap': 'Large Cap',
    },
    'POWERGRID': {
      'price': 325.75,
      'change': 4.85,
      'percentage': 1.51,
      'name': 'Power Grid Corporation of India Limited',
      'sector': 'Power',
      'marketCap': 'Large Cap',
    },
    'NTPC': {
      'price': 287.40,
      'change': -3.65,
      'percentage': -1.25,
      'name': 'NTPC Limited',
      'sector': 'Power',
      'marketCap': 'Large Cap',
    },
    'JSWSTEEL': {
      'price': 745.30,
      'change': 18.95,
      'percentage': 2.61,
      'name': 'JSW Steel Limited',
      'sector': 'Steel',
      'marketCap': 'Large Cap',
    },
    'TATAMOTORS': {
      'price': 789.50,
      'change': -12.30,
      'percentage': -1.53,
      'name': 'Tata Motors Limited',
      'sector': 'Automobile',
      'marketCap': 'Large Cap',
    },
    'TECHM': {
      'price': 1654.80,
      'change': 34.70,
      'percentage': 2.14,
      'name': 'Tech Mahindra Limited',
      'sector': 'Information Technology',
      'marketCap': 'Large Cap',
    },
    'SUNPHARMA': {
      'price': 1687.95,
      'change': -28.40,
      'percentage': -1.66,
      'name': 'Sun Pharmaceutical Industries Limited',
      'sector': 'Pharmaceuticals',
      'marketCap': 'Large Cap',
    },
    'DRREDDY': {
      'price': 1287.60,
      'change': 45.85,
      'percentage': 3.69,
      'name': 'Dr Reddys Laboratories Limited',
      'sector': 'Pharmaceuticals',
      'marketCap': 'Large Cap',
    },
    'DIVISLAB': {
      'price': 5847.30,
      'change': -98.45,
      'percentage': -1.66,
      'name': 'Divi\'s Laboratories Limited',
      'sector': 'Pharmaceuticals',
      'marketCap': 'Large Cap',
    },
    'CIPLA': {
      'price': 1456.75,
      'change': 23.80,
      'percentage': 1.66,
      'name': 'Cipla Limited',
      'sector': 'Pharmaceuticals',
      'marketCap': 'Large Cap',
    },
    'TATASTEEL': {
      'price': 145.60,
      'change': 3.25,
      'percentage': 2.28,
      'name': 'Tata Steel Limited',
      'sector': 'Steel',
      'marketCap': 'Large Cap',
    },
    'TATAPOWER': {
      'price': 425.80,
      'change': -8.90,
      'percentage': -2.05,
      'name': 'Tata Power Company Limited',
      'sector': 'Power',
      'marketCap': 'Large Cap',
    },
    'TATACONSUM': {
      'price': 1087.45,
      'change': 15.60,
      'percentage': 1.46,
      'name': 'Tata Consumer Products Limited',
      'sector': 'FMCG',
      'marketCap': 'Large Cap',
    },
  };

  static StockModel getUpdatedStock(StockModel stock) {
    final data = _stockPrices[stock.symbol.toUpperCase()];
    if (data == null) {
      // Return with small random fluctuation if no data available
      final random = Random();
      final changePercent = (random.nextDouble() - 0.5) * 4; // -2% to +2%
      final currentPrice = stock.currentPrice > 0 ? stock.currentPrice : 100.0;
      final newPrice = currentPrice * (1 + changePercent / 100);
      final changeAmount = newPrice - currentPrice;
      
      return stock.copyWith(
        currentPrice: double.parse(newPrice.toStringAsFixed(2)),
        changeAmount: double.parse(changeAmount.toStringAsFixed(2)),
        changePercentage: double.parse(changePercent.toStringAsFixed(2)),
        lastUpdated: DateTime.now(),
      );
    }

    // Add small random fluctuation to make it more realistic
    final random = Random();
    final fluctuation = (random.nextDouble() - 0.5) * 0.2; // ±0.1% fluctuation
    final basePrice = data['price'] as double;
    final baseChange = data['change'] as double;
    final basePercentage = data['percentage'] as double;
    
    final price = basePrice * (1 + fluctuation / 100);
    final change = baseChange * (1 + fluctuation / 100);
    final percentage = basePercentage * (1 + fluctuation / 100);

    return stock.copyWith(
      currentPrice: double.parse(price.toStringAsFixed(2)),
      changeAmount: double.parse(change.toStringAsFixed(2)),
      changePercentage: double.parse(percentage.toStringAsFixed(2)),
      lastUpdated: DateTime.now(),
      name: stock.name.isEmpty ? data['name'] as String : stock.name,
    );
  }

  static List<StockModel> getUpdatedStocks(List<StockModel> stocks) {
    return stocks.map((stock) => getUpdatedStock(stock)).toList();
  }

  // Generate mock chart data for stock detail screen
  static List<Map<String, dynamic>> getChartData(String symbol, String period) {
    final data = _stockPrices[symbol.toUpperCase()];
    final currentPrice = data?['price'] as double? ?? 1000.0;
    
    final random = Random(symbol.hashCode); // Consistent data for same symbol
    final points = <Map<String, dynamic>>[];
    
    int dataPoints;
    DateTime startDate;
    
    switch (period) {
      case '1D':
        dataPoints = 24;
        startDate = DateTime.now().subtract(const Duration(hours: 24));
        break;
      case '1W':
        dataPoints = 7;
        startDate = DateTime.now().subtract(const Duration(days: 7));
        break;
      case '1M':
        dataPoints = 30;
        startDate = DateTime.now().subtract(const Duration(days: 30));
        break;
      case '3M':
        dataPoints = 90;
        startDate = DateTime.now().subtract(const Duration(days: 90));
        break;
      case '6M':
        dataPoints = 180;
        startDate = DateTime.now().subtract(const Duration(days: 180));
        break;
      case 'YTD':
        dataPoints = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
        startDate = DateTime(DateTime.now().year, 1, 1);
        break;
      case '1Y':
        dataPoints = 365;
        startDate = DateTime.now().subtract(const Duration(days: 365));
        break;
      default:
        dataPoints = 30;
        startDate = DateTime.now().subtract(const Duration(days: 30));
    }

    double price = currentPrice * 0.8; // Start from 80% of current price
    
    for (int i = 0; i < dataPoints; i++) {
      final date = startDate.add(Duration(
        days: period == '1D' ? 0 : i,
        hours: period == '1D' ? i : 0,
      ));
      
      // Create realistic price movement
      final change = (random.nextDouble() - 0.5) * 0.05; // ±2.5% per period
      price *= (1 + change);
      
      // Ensure price trends towards current price at the end
      if (i > dataPoints * 0.8) {
        final targetTrend = (currentPrice - price) / (dataPoints - i);
        price += targetTrend * 0.3;
      }
      
      points.add({
        'timestamp': date.millisecondsSinceEpoch,
        'price': double.parse(price.toStringAsFixed(2)),
      });
    }
    
    return points;
  }

  static Map<String, dynamic> getStockInfo(String symbol) {
    final data = _stockPrices[symbol.toUpperCase()];
    return data ?? {
      'name': symbol,
      'sector': 'Unknown',
      'marketCap': 'Large Cap',
    };
  }
}