import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/stock_model.dart';
import '../models/watchlist_model.dart';

class LocalStorage {
  static const String userBox = 'users';
  static const String stockBox = 'stocks';
  static const String watchlistBox = 'watchlists';
  static const String currentUserKey = 'current_user_id';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(StockModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(WatchlistModelAdapter());
    }

    // Open boxes
    await Hive.openBox<UserModel>(userBox);
    await Hive.openBox<StockModel>(stockBox);
    await Hive.openBox<WatchlistModel>(watchlistBox);
    await Hive.openBox(currentUserKey);
  }

  // User operations
  static Box<UserModel> get users => Hive.box<UserModel>(userBox);
  static Box get currentUser => Hive.box(currentUserKey);

  static Future<void> saveUser(UserModel user) async {
    await users.put(user.id, user);
  }

  static UserModel? getUser(String userId) {
    return users.get(userId);
  }

  static Future<void> setCurrentUser(String userId) async {
    await currentUser.put('user_id', userId);
  }

  static String? getCurrentUserId() {
    return currentUser.get('user_id');
  }

  static Future<void> removeCurrentUser() async {
    await currentUser.delete('user_id');
  }

  // Stock operations
  static Box<StockModel> get stocks => Hive.box<StockModel>(stockBox);

  static Future<void> saveStock(StockModel stock) async {
    await stocks.put(stock.symbol, stock);
  }

  static StockModel? getStock(String symbol) {
    return stocks.get(symbol);
  }

  static Future<void> saveStocks(List<StockModel> stockList) async {
    final Map<String, StockModel> stockMap = {
      for (var stock in stockList) stock.symbol: stock
    };
    await stocks.putAll(stockMap);
  }

  static List<StockModel> getStocks(List<String> symbols) {
    return symbols
        .map((symbol) => stocks.get(symbol))
        .where((stock) => stock != null)
        .cast<StockModel>()
        .toList();
  }

  // Watchlist operations
  static Box<WatchlistModel> get watchlists => Hive.box<WatchlistModel>(watchlistBox);

  static Future<void> saveWatchlist(WatchlistModel watchlist) async {
    await watchlists.put(watchlist.id, watchlist);
  }

  static WatchlistModel? getWatchlist(String watchlistId) {
    return watchlists.get(watchlistId);
  }

  static List<WatchlistModel> getUserWatchlists(String userId) {
    return watchlists.values
        .where((watchlist) => watchlist.userId == userId)
        .toList();
  }

  static Future<void> deleteWatchlist(String watchlistId) async {
    await watchlists.delete(watchlistId);
  }

  static Future<void> clearAll() async {
    await users.clear();
    await stocks.clear();
    await watchlists.clear();
    await currentUser.clear();
  }

  static Future<void> dispose() async {
    await Hive.close();
  }
}