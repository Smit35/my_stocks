import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock_model.dart';
import '../models/time_series_model.dart';
import '../../core/constants/api_constants.dart';

class TwelveDataApi {
  final http.Client _client;

  TwelveDataApi({http.Client? client}) : _client = client ?? http.Client();

  Future<List<StockModel>> searchSymbols(String query) async {
    try {
      final url = ApiConstants.symbolSearchUrl(query);
      print('Searching stocks with URL: $url'); // Debug log
      
      final response = await _client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('Search response status: ${response.statusCode}'); // Debug log
      print('Search response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['data'] != null) {
          final stocks = (data['data'] as List)
              .map((item) => StockModel.fromTwelveDataSearch(item))
              .toList();
          print('Found ${stocks.length} stocks'); // Debug log
          return stocks;
        } else if (data['message'] != null) {
          print('API message: ${data['message']}'); // Debug log
        }
      }
      
      return [];
    } catch (e) {
      print('Search error: $e'); // Debug log
      throw Exception('Failed to search symbols: $e');
    }
  }

  Future<StockModel> getStockPrice(StockModel stock) async {
    try {
      // Try with exchange first if available
      String url;
      if (stock.exchange != null && stock.exchange!.isNotEmpty) {
        url = ApiConstants.quoteUrlWithExchange(stock.symbol, stock.exchange!);
      } else {
        url = ApiConstants.quoteUrl(stock.symbol);
      }
      
      print('Getting stock price with URL: $url'); // Debug log
      
      final response = await _client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('Price response status: ${response.statusCode}'); // Debug log
      print('Price response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['price'] != null || data['close'] != null) {
          return StockModel.fromTwelveDataPrice(data, stock);
        }
      }
      
      return stock;
    } catch (e) {
      print('Price fetch error: $e'); // Debug log
      throw Exception('Failed to get stock price: $e');
    }
  }

  Future<List<StockModel>> getMultipleStockPrices(List<StockModel> stocks) async {
    if (stocks.isEmpty) return [];
    
    final symbols = stocks.map((s) => s.symbol).join(',');
    
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.quote}?symbol=$symbols&apikey=${ApiConstants.apiKey}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updatedStocks = <StockModel>[];
        
        if (data is Map<String, dynamic>) {
          // Single stock response
          if (stocks.length == 1) {
            updatedStocks.add(StockModel.fromTwelveDataPrice(data, stocks.first));
          }
        } else if (data is List) {
          // Multiple stocks response
          for (int i = 0; i < data.length && i < stocks.length; i++) {
            updatedStocks.add(StockModel.fromTwelveDataPrice(data[i], stocks[i]));
          }
        }
        
        return updatedStocks.isNotEmpty ? updatedStocks : stocks;
      }
      
      return stocks;
    } catch (e) {
      // Return original stocks if API fails
      return stocks;
    }
  }

  Future<List<TimeSeriesModel>> getTimeSeries(String symbol, String interval) async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConstants.timeSeriesUrl(symbol, interval)),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['values'] != null) {
          final timeSeries = <TimeSeriesModel>[];
          
          (data['values'] as Map<String, dynamic>).forEach((datetime, values) {
            timeSeries.add(TimeSeriesModel.fromTwelveData(datetime, values));
          });
          
          // Sort by datetime ascending
          timeSeries.sort((a, b) => a.datetime.compareTo(b.datetime));
          return timeSeries;
        }
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to get time series: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}