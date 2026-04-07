class ApiConstants {
  static const String baseUrl = 'https://api.twelvedata.com';
  static const String apiKey = '077de3d82dc84e7685e26fcd73b75ae2';
  
  // Endpoints
  static const String symbolSearch = '$baseUrl/symbol_search';
  static const String price = '$baseUrl/price';
  static const String quote = '$baseUrl/quote';
  static const String timeSeries = '$baseUrl/time_series';
  
  // Parameters with Indian market focus - Fixed URLs
  static String priceUrl(String symbol) => '$price?symbol=$symbol&apikey=$apiKey';
  static String quoteUrl(String symbol) => '$quote?symbol=$symbol&apikey=$apiKey';
  static String quoteUrlWithExchange(String symbol, String exchange) => '$quote?symbol=$symbol&exchange=$exchange&apikey=$apiKey';
  static String symbolSearchUrl(String query) => '$symbolSearch?symbol=$query&apikey=$apiKey';
  static String timeSeriesUrl(String symbol, String interval) => 
      '$timeSeries?symbol=$symbol&interval=$interval&apikey=$apiKey&outputsize=50';
}