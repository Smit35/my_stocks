import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/stock_repository.dart';
import 'stock_search_event.dart';
import 'stock_search_state.dart';

class StockSearchBloc extends Bloc<StockSearchEvent, StockSearchState> {
  final StockRepository _stockRepository;
  Timer? _debounceTimer;

  StockSearchBloc({required StockRepository stockRepository})
      : _stockRepository = stockRepository,
        super(StockSearchInitial()) {
    on<SearchStocks>(_onSearchStocks);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchStocks(
    SearchStocks event,
    Emitter<StockSearchState> emit,
  ) async {
    _debounceTimer?.cancel();
    
    if (event.query.trim().isEmpty) {
      emit(StockSearchInitial());
      return;
    }

    // Create a completer to handle the debounced search
    final completer = Completer<void>();
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      completer.complete();
    });

    // Wait for the debounce timer
    await completer.future;

    // Check if the emitter is still valid (handler hasn't completed)
    if (emit.isDone) return;

    emit(StockSearchLoading());

    try {
      final stocks = await _stockRepository.searchStocks(event.query);
      
      if (emit.isDone) return; // Check again before emitting
      
      if (stocks.isEmpty) {
        emit(StockSearchEmpty(event.query));
      } else {
        emit(StockSearchLoaded(stocks: stocks, query: event.query));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(StockSearchError('Failed to search stocks: ${e.toString()}'));
      }
    }
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<StockSearchState> emit,
  ) async {
    _debounceTimer?.cancel();
    emit(StockSearchInitial());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}