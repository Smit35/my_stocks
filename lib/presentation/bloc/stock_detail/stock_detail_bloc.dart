import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/stock_repository.dart';
import '../../../data/models/stock_model.dart';
import 'stock_detail_event.dart';
import 'stock_detail_state.dart';

class StockDetailBloc extends Bloc<StockDetailEvent, StockDetailState> {
  final StockRepository _stockRepository;
  Timer? _refreshTimer;
  StockModel? _currentStock;

  StockDetailBloc({required StockRepository stockRepository})
      : _stockRepository = stockRepository,
        super(StockDetailInitial()) {
    on<LoadStockDetail>(_onLoadStockDetail);
    on<ChangeTimeframe>(_onChangeTimeframe);
    on<RefreshStockDetail>(_onRefreshStockDetail);
  }

  Future<void> _onLoadStockDetail(
    LoadStockDetail event,
    Emitter<StockDetailState> emit,
  ) async {
    emit(StockDetailLoading());
    _currentStock = event.stock;

    try {
      // Get fresh stock price
      final updatedStock = await _stockRepository.updateStockPrice(event.stock);
      
      // Get time series data
      final timeSeries = await _stockRepository.getTimeSeries(
        event.stock.symbol,
        '1day',
      );

      emit(StockDetailLoaded(
        stock: updatedStock,
        timeSeries: timeSeries,
        selectedTimeframe: '1D',
      ));

      _startAutoRefresh();
    } catch (e) {
      emit(StockDetailError('Failed to load stock detail: ${e.toString()}'));
    }
  }

  Future<void> _onChangeTimeframe(
    ChangeTimeframe event,
    Emitter<StockDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is StockDetailLoaded && _currentStock != null) {
      emit(currentState.copyWith(
        selectedTimeframe: event.timeframe,
        isRefreshing: true,
      ));

      try {
        String interval;
        switch (event.timeframe) {
          case '1D':
            interval = '1day';
            break;
          case '1W':
            interval = '1week';
            break;
          case '1M':
            interval = '1month';
            break;
          default:
            interval = '1day';
        }

        final timeSeries = await _stockRepository.getTimeSeries(
          _currentStock!.symbol,
          interval,
        );

        emit(currentState.copyWith(
          timeSeries: timeSeries,
          selectedTimeframe: event.timeframe,
          isRefreshing: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(isRefreshing: false));
      }
    }
  }

  Future<void> _onRefreshStockDetail(
    RefreshStockDetail event,
    Emitter<StockDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is StockDetailLoaded && _currentStock != null) {
      emit(currentState.copyWith(isRefreshing: true));

      try {
        final updatedStock = await _stockRepository.updateStockPrice(_currentStock!);
        
        emit(currentState.copyWith(
          stock: updatedStock,
          isRefreshing: false,
        ));
        
        _currentStock = updatedStock;
      } catch (e) {
        emit(currentState.copyWith(isRefreshing: false));
      }
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      add(RefreshStockDetail());
    });
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}