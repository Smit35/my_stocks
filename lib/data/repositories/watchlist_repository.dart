import '../datasources/local_storage.dart';
import '../models/watchlist_model.dart';

class WatchlistRepository {
  Future<WatchlistModel> createWatchlist(String name, String userId) async {
    final watchlist = WatchlistModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      userId: userId,
      stockSymbols: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await LocalStorage.saveWatchlist(watchlist);
    return watchlist;
  }

  List<WatchlistModel> getUserWatchlists(String userId) {
    return LocalStorage.getUserWatchlists(userId);
  }

  WatchlistModel? getWatchlist(String watchlistId) {
    return LocalStorage.getWatchlist(watchlistId);
  }

  Future<WatchlistModel> addStockToWatchlist(String watchlistId, String stockSymbol) async {
    final watchlist = LocalStorage.getWatchlist(watchlistId);
    if (watchlist == null) {
      throw Exception('Watchlist not found');
    }

    final updatedWatchlist = watchlist.addStock(stockSymbol);
    await LocalStorage.saveWatchlist(updatedWatchlist);
    return updatedWatchlist;
  }

  Future<WatchlistModel> removeStockFromWatchlist(String watchlistId, String stockSymbol) async {
    final watchlist = LocalStorage.getWatchlist(watchlistId);
    if (watchlist == null) {
      throw Exception('Watchlist not found');
    }

    final updatedWatchlist = watchlist.removeStock(stockSymbol);
    await LocalStorage.saveWatchlist(updatedWatchlist);
    return updatedWatchlist;
  }

  Future<void> updateWatchlist(WatchlistModel watchlist) async {
    await LocalStorage.saveWatchlist(watchlist);
  }

  Future<void> deleteWatchlist(String watchlistId) async {
    await LocalStorage.deleteWatchlist(watchlistId);
  }

  Future<WatchlistModel> renameWatchlist(String watchlistId, String newName) async {
    final watchlist = LocalStorage.getWatchlist(watchlistId);
    if (watchlist == null) {
      throw Exception('Watchlist not found');
    }

    final updatedWatchlist = watchlist.copyWith(
      name: newName,
      updatedAt: DateTime.now(),
    );
    
    await LocalStorage.saveWatchlist(updatedWatchlist);
    return updatedWatchlist;
  }

  bool isStockInWatchlist(String watchlistId, String stockSymbol) {
    final watchlist = LocalStorage.getWatchlist(watchlistId);
    if (watchlist == null) return false;
    
    return watchlist.stockSymbols.contains(stockSymbol);
  }
}