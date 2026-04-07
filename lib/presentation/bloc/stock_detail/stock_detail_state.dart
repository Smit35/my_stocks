import 'package:equatable/equatable.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/models/time_series_model.dart';

abstract class StockDetailState extends Equatable {
  const StockDetailState();

  @override
  List<Object?> get props => [];
}

class StockDetailInitial extends StockDetailState {}

class StockDetailLoading extends StockDetailState {}

class StockDetailLoaded extends StockDetailState {
  final StockModel stock;
  final List<TimeSeriesModel> timeSeries;
  final String selectedTimeframe;
  final bool isRefreshing;

  const StockDetailLoaded({
    required this.stock,
    required this.timeSeries,
    required this.selectedTimeframe,
    this.isRefreshing = false,
  });

  StockDetailLoaded copyWith({
    StockModel? stock,
    List<TimeSeriesModel>? timeSeries,
    String? selectedTimeframe,
    bool? isRefreshing,
  }) {
    return StockDetailLoaded(
      stock: stock ?? this.stock,
      timeSeries: timeSeries ?? this.timeSeries,
      selectedTimeframe: selectedTimeframe ?? this.selectedTimeframe,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [stock, timeSeries, selectedTimeframe, isRefreshing];
}

class StockDetailError extends StockDetailState {
  final String message;

  const StockDetailError(this.message);

  @override
  List<Object?> get props => [message];
}