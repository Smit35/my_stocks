import '../datasources/local_storage.dart';
import '../datasources/twelve_data_api.dart';
import '../datasources/mock_stock_api.dart';
import '../models/stock_model.dart';
import '../models/time_series_model.dart';

class StockRepository {
  final TwelveDataApi _api;

  StockRepository({TwelveDataApi? api}) : _api = api ?? TwelveDataApi();

  Future<List<StockModel>> searchStocks(String query) async {
    if (query.trim().isEmpty) return [];
    
    try {
      final stocks = await _api.searchSymbols(query);
      
      // If API returns results, use them
      if (stocks.isNotEmpty) {
        return stocks;
      }
      
      // If no API results, provide local suggestions for popular Indian stocks
      return _getLocalSuggestions(query);
    } catch (e) {
      // If API fails, fall back to local suggestions
      return _getLocalSuggestions(query);
    }
  }

  List<StockModel> _getLocalSuggestions(String query) {
    final popularStocks = [
      {'symbol': 'RELIANCE', 'name': 'Reliance Industries Limited', 'exchange': 'NSE', 'keywords': 'reliance industries oil gas petrochemical'},
      {'symbol': 'TCS', 'name': 'Tata Consultancy Services Limited', 'exchange': 'NSE', 'keywords': 'tata consultancy services tcs it software'},
      {'symbol': 'HDFCBANK', 'name': 'HDFC Bank Limited', 'exchange': 'NSE', 'keywords': 'hdfc bank banking finance'},
      {'symbol': 'INFY', 'name': 'Infosys Limited', 'exchange': 'NSE', 'keywords': 'infosys it software technology'},
      {'symbol': 'HINDUNILVR', 'name': 'Hindustan Unilever Limited', 'exchange': 'NSE', 'keywords': 'hindustan unilever hul fmcg consumer'},
      {'symbol': 'ITC', 'name': 'ITC Limited', 'exchange': 'NSE', 'keywords': 'itc tobacco cigarette fmcg hotels'},
      {'symbol': 'ICICIBANK', 'name': 'ICICI Bank Limited', 'exchange': 'NSE', 'keywords': 'icici bank banking finance'},
      {'symbol': 'BHARTIARTL', 'name': 'Bharti Airtel Limited', 'exchange': 'NSE', 'keywords': 'bharti airtel telecom mobile'},
      {'symbol': 'SBIN', 'name': 'State Bank of India', 'exchange': 'NSE', 'keywords': 'sbi state bank banking finance'},
      {'symbol': 'BAJFINANCE', 'name': 'Bajaj Finance Limited', 'exchange': 'NSE', 'keywords': 'bajaj finance nbfc lending'},
      {'symbol': 'LT', 'name': 'Larsen & Toubro Limited', 'exchange': 'NSE', 'keywords': 'larsen toubro construction engineering'},
      {'symbol': 'HCLTECH', 'name': 'HCL Technologies Limited', 'exchange': 'NSE', 'keywords': 'hcl technologies it software'},
      {'symbol': 'ASIANPAINT', 'name': 'Asian Paints Limited', 'exchange': 'NSE', 'keywords': 'asian paints paint coating'},
      {'symbol': 'MARUTI', 'name': 'Maruti Suzuki India Limited', 'exchange': 'NSE', 'keywords': 'maruti suzuki car automobile auto'},
      {'symbol': 'KOTAKBANK', 'name': 'Kotak Mahindra Bank Limited', 'exchange': 'NSE', 'keywords': 'kotak mahindra bank banking finance'},
      {'symbol': 'TITAN', 'name': 'Titan Company Limited', 'exchange': 'NSE', 'keywords': 'titan jewellery watches tata'},
      {'symbol': 'AXISBANK', 'name': 'Axis Bank Limited', 'exchange': 'NSE', 'keywords': 'axis bank banking finance'},
      {'symbol': 'ULTRACEMCO', 'name': 'UltraTech Cement Limited', 'exchange': 'NSE', 'keywords': 'ultratech cement construction birla'},
      {'symbol': 'WIPRO', 'name': 'Wipro Limited', 'exchange': 'NSE', 'keywords': 'wipro it software technology'},
      {'symbol': 'NESTLEIND', 'name': 'Nestle India Limited', 'exchange': 'NSE', 'keywords': 'nestle fmcg food maggi'},
      {'symbol': 'ADANIPORTS', 'name': 'Adani Ports and SEZ Limited', 'exchange': 'NSE', 'keywords': 'adani ports logistics infrastructure'},
      {'symbol': 'POWERGRID', 'name': 'Power Grid Corporation of India Limited', 'exchange': 'NSE', 'keywords': 'power grid electricity transmission'},
      {'symbol': 'NTPC', 'name': 'NTPC Limited', 'exchange': 'NSE', 'keywords': 'ntpc power electricity generation'},
      {'symbol': 'JSWSTEEL', 'name': 'JSW Steel Limited', 'exchange': 'NSE', 'keywords': 'jsw steel metal iron'},
      {'symbol': 'TATAMOTORS', 'name': 'Tata Motors Limited', 'exchange': 'NSE', 'keywords': 'tata motors car automobile auto'},
      {'symbol': 'TECHM', 'name': 'Tech Mahindra Limited', 'exchange': 'NSE', 'keywords': 'tech mahindra it software technology'},
      {'symbol': 'SUNPHARMA', 'name': 'Sun Pharmaceutical Industries Limited', 'exchange': 'NSE', 'keywords': 'sun pharma pharmaceutical medicine drug'},
      {'symbol': 'DRREDDY', 'name': 'Dr Reddys Laboratories Limited', 'exchange': 'NSE', 'keywords': 'dr reddy pharma pharmaceutical medicine'},
      {'symbol': 'DIVISLAB', 'name': 'Divi\'s Laboratories Limited', 'exchange': 'NSE', 'keywords': 'divis lab pharma pharmaceutical'},
      {'symbol': 'CIPLA', 'name': 'Cipla Limited', 'exchange': 'NSE', 'keywords': 'cipla pharma pharmaceutical medicine'},
    ];

    final queryLower = query.toLowerCase().trim();
    
    // First try exact matches, then partial matches, then keyword matches
    final exactMatches = <Map<String, String>>[];
    final partialMatches = <Map<String, String>>[];
    final keywordMatches = <Map<String, String>>[];

    for (final stock in popularStocks) {
      final symbol = stock['symbol']!.toLowerCase();
      final name = stock['name']!.toLowerCase();
      final keywords = stock['keywords']!.toLowerCase();

      // Exact symbol match
      if (symbol == queryLower) {
        exactMatches.add(stock);
      }
      // Symbol starts with query
      else if (symbol.startsWith(queryLower)) {
        partialMatches.add(stock);
      }
      // Symbol contains query
      else if (symbol.contains(queryLower)) {
        partialMatches.add(stock);
      }
      // Name contains query
      else if (name.contains(queryLower)) {
        partialMatches.add(stock);
      }
      // Keywords contain query
      else if (keywords.contains(queryLower)) {
        keywordMatches.add(stock);
      }
    }

    // Combine results with exact matches first
    final allMatches = [...exactMatches, ...partialMatches, ...keywordMatches];
    
    // Remove duplicates and limit results
    final uniqueMatches = <Map<String, String>>[];
    final seenSymbols = <String>{};
    
    for (final stock in allMatches) {
      if (!seenSymbols.contains(stock['symbol']) && uniqueMatches.length < 10) {
        uniqueMatches.add(stock);
        seenSymbols.add(stock['symbol']!);
      }
    }

    return uniqueMatches.map((stock) => StockModel(
      symbol: stock['symbol']!,
      name: stock['name']!,
      currentPrice: 0.0,
      changeAmount: 0.0,
      changePercentage: 0.0,
      lastUpdated: DateTime.now(),
      exchange: stock['exchange'],
    )).toList();
  }

  Future<StockModel> updateStockPrice(StockModel stock) async {
    try {
      final updatedStock = await _api.getStockPrice(stock);
      // Check if API returned meaningful data
      if (updatedStock.currentPrice > 0) {
        await LocalStorage.saveStock(updatedStock);
        return updatedStock;
      } else {
        throw Exception('API returned no price data');
      }
    } catch (e) {
      print('API failed, using mock data for ${stock.symbol}: $e');
      // Use mock data when API fails
      final mockStock = MockStockApi.getUpdatedStock(stock);
      await LocalStorage.saveStock(mockStock);
      return mockStock;
    }
  }

  Future<List<StockModel>> updateMultipleStockPrices(List<StockModel> stocks) async {
    if (stocks.isEmpty) return [];
    
    try {
      final updatedStocks = await _api.getMultipleStockPrices(stocks);
      // Check if any stock has meaningful price data
      final hasValidData = updatedStocks.any((stock) => stock.currentPrice > 0);
      
      if (hasValidData) {
        await LocalStorage.saveStocks(updatedStocks);
        return updatedStocks;
      } else {
        throw Exception('API returned no valid price data');
      }
    } catch (e) {
      print('Multiple stock API failed, using mock data: $e');
      // Use mock data for all stocks when API fails
      final mockStocks = MockStockApi.getUpdatedStocks(stocks);
      await LocalStorage.saveStocks(mockStocks);
      return mockStocks;
    }
  }

  Future<List<TimeSeriesModel>> getTimeSeries(String symbol, String interval) async {
    try {
      return await _api.getTimeSeries(symbol, interval);
    } catch (e) {
      throw Exception('Failed to get time series: $e');
    }
  }

  StockModel? getCachedStock(String symbol) {
    return LocalStorage.getStock(symbol);
  }

  List<StockModel> getCachedStocks(List<String> symbols) {
    return LocalStorage.getStocks(symbols);
  }

  Future<void> saveStock(StockModel stock) async {
    await LocalStorage.saveStock(stock);
  }

  void dispose() {
    _api.dispose();
  }
}