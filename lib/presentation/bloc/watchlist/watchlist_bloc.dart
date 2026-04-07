import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/watchlist_repository.dart';
import '../../../data/repositories/stock_repository.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/models/watchlist_model.dart';
import 'watchlist_event.dart';
import 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final WatchlistRepository _watchlistRepository;
  final StockRepository _stockRepository;
  Timer? _refreshTimer;

  WatchlistBloc({
    required WatchlistRepository watchlistRepository,
    required StockRepository stockRepository,
  })  : _watchlistRepository = watchlistRepository,
        _stockRepository = stockRepository,
        super(WatchlistInitial()) {
    on<LoadWatchlists>(_onLoadWatchlists);
    on<CreateWatchlist>(_onCreateWatchlist);
    on<SelectWatchlist>(_onSelectWatchlist);
    on<AddStockToWatchlist>(_onAddStockToWatchlist);
    on<RemoveStockFromWatchlist>(_onRemoveStockFromWatchlist);
    on<RenameWatchlist>(_onRenameWatchlist);
    on<DeleteWatchlist>(_onDeleteWatchlist);
    on<RefreshStockPrices>(_onRefreshStockPrices);
  }

  Future<void> _onLoadWatchlists(
    LoadWatchlists event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(WatchlistLoading());

    try {
      final watchlists = _watchlistRepository.getUserWatchlists(event.userId);
      
      if (watchlists.isEmpty) {
        emit(WatchlistEmpty());
      } else {
        final selectedWatchlist = watchlists.first;
        final stocks = await _loadWatchlistStocks(selectedWatchlist);
        
        emit(WatchlistLoaded(
          watchlists: watchlists,
          selectedWatchlist: selectedWatchlist,
          stocks: stocks,
        ));

        _startAutoRefresh(selectedWatchlist.id);
      }
    } catch (e) {
      emit(WatchlistError('Failed to load watchlists: ${e.toString()}'));
    }
  }

  Future<void> _onCreateWatchlist(
    CreateWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    try {
      final newWatchlist = await _watchlistRepository.createWatchlist(
        event.name,
        event.userId,
      );

      final watchlists = _watchlistRepository.getUserWatchlists(event.userId);

      emit(WatchlistLoaded(
        watchlists: watchlists,
        selectedWatchlist: newWatchlist,
        stocks: [],
      ));
    } catch (e) {
      emit(WatchlistError('Failed to create watchlist: ${e.toString()}'));
    }
  }

  Future<void> _onSelectWatchlist(
    SelectWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    final currentState = state;
    if (currentState is WatchlistLoaded) {
      final selectedWatchlist = currentState.watchlists
          .firstWhere((w) => w.id == event.watchlistId);

      emit(currentState.copyWith(
        selectedWatchlist: selectedWatchlist,
        isRefreshing: true,
      ));

      final stocks = await _loadWatchlistStocks(selectedWatchlist);

      emit(currentState.copyWith(
        selectedWatchlist: selectedWatchlist,
        stocks: stocks,
        isRefreshing: false,
      ));

      _startAutoRefresh(selectedWatchlist.id);
    }
  }

  Future<void> _onAddStockToWatchlist(
    AddStockToWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    try {
      final updatedWatchlist = await _watchlistRepository.addStockToWatchlist(
        event.watchlistId,
        event.stockSymbol,
      );

      final currentState = state;
      if (currentState is WatchlistLoaded) {
        // Show loading state while fetching new stock data
        emit(currentState.copyWith(isRefreshing: true));

        final updatedWatchlists = currentState.watchlists
            .map((w) => w.id == updatedWatchlist.id ? updatedWatchlist : w)
            .toList();

        // Force refresh to get latest stock data including the newly added stock
        final stocks = await _loadWatchlistStocks(updatedWatchlist, forceRefresh: true);

        emit(currentState.copyWith(
          watchlists: updatedWatchlists,
          selectedWatchlist: updatedWatchlist,
          stocks: stocks,
          isRefreshing: false,
        ));
      }
    } catch (e) {
      emit(WatchlistError('Failed to add stock: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveStockFromWatchlist(
    RemoveStockFromWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    try {
      final updatedWatchlist = await _watchlistRepository.removeStockFromWatchlist(
        event.watchlistId,
        event.stockSymbol,
      );

      final currentState = state;
      if (currentState is WatchlistLoaded) {
        final updatedWatchlists = currentState.watchlists
            .map((w) => w.id == updatedWatchlist.id ? updatedWatchlist : w)
            .toList();

        final stocks = await _loadWatchlistStocks(updatedWatchlist);

        emit(currentState.copyWith(
          watchlists: updatedWatchlists,
          selectedWatchlist: updatedWatchlist,
          stocks: stocks,
        ));
      }
    } catch (e) {
      emit(WatchlistError('Failed to remove stock: ${e.toString()}'));
    }
  }

  Future<void> _onRenameWatchlist(
    RenameWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    try {
      final updatedWatchlist = await _watchlistRepository.renameWatchlist(
        event.watchlistId,
        event.newName,
      );

      final currentState = state;
      if (currentState is WatchlistLoaded) {
        final updatedWatchlists = currentState.watchlists
            .map((w) => w.id == updatedWatchlist.id ? updatedWatchlist : w)
            .toList();

        emit(currentState.copyWith(
          watchlists: updatedWatchlists,
          selectedWatchlist: updatedWatchlist,
        ));
      }
    } catch (e) {
      emit(WatchlistError('Failed to rename watchlist: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteWatchlist(
    DeleteWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    try {
      await _watchlistRepository.deleteWatchlist(event.watchlistId);

      final currentState = state;
      if (currentState is WatchlistLoaded) {
        final updatedWatchlists = currentState.watchlists
            .where((w) => w.id != event.watchlistId)
            .toList();

        if (updatedWatchlists.isEmpty) {
          emit(WatchlistEmpty());
        } else {
          final selectedWatchlist = updatedWatchlists.first;
          final stocks = await _loadWatchlistStocks(selectedWatchlist);

          emit(WatchlistLoaded(
            watchlists: updatedWatchlists,
            selectedWatchlist: selectedWatchlist,
            stocks: stocks,
          ));
        }
      }
    } catch (e) {
      emit(WatchlistError('Failed to delete watchlist: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshStockPrices(
    RefreshStockPrices event,
    Emitter<WatchlistState> emit,
  ) async {
    final currentState = state;
    if (currentState is WatchlistLoaded) {
      emit(currentState.copyWith(isRefreshing: true));

      final watchlist = currentState.watchlists
          .firstWhere((w) => w.id == event.watchlistId);

      final stocks = await _loadWatchlistStocks(watchlist, forceRefresh: true);

      emit(currentState.copyWith(
        stocks: stocks,
        isRefreshing: false,
      ));
    }
  }

  Future<List<StockModel>> _loadWatchlistStocks(
    WatchlistModel watchlist, {
    bool forceRefresh = false,
  }) async {
    if (watchlist.stockSymbols.isEmpty) return [];

    List<StockModel> stocks = [];

    if (!forceRefresh) {
      stocks = _stockRepository.getCachedStocks(watchlist.stockSymbols);
    }

    if (stocks.isEmpty || forceRefresh) {
      // Create stock models for symbols that don't exist in cache
      final missingSymbols = watchlist.stockSymbols
          .where((symbol) => !stocks.any((s) => s.symbol == symbol))
          .toList();

      final missingStocks = missingSymbols.map((symbol) => StockModel(
            symbol: symbol,
            name: symbol,
            currentPrice: 0.0,
            changeAmount: 0.0,
            changePercentage: 0.0,
            lastUpdated: DateTime.now(),
          )).toList();

      stocks.addAll(missingStocks);

      // Update all stocks with fresh prices
      try {
        stocks = await _stockRepository.updateMultipleStockPrices(stocks);
      } catch (e) {
        // Use cached data if API fails
      }
    }

    return stocks;
  }

  void _startAutoRefresh(String watchlistId) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      add(RefreshStockPrices(watchlistId));
    });
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}