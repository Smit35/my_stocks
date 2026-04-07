import 'package:equatable/equatable.dart';
import '../../../data/models/stock_model.dart';

abstract class StockSearchState extends Equatable {
  const StockSearchState();

  @override
  List<Object?> get props => [];
}

class StockSearchInitial extends StockSearchState {}

class StockSearchLoading extends StockSearchState {}

class StockSearchLoaded extends StockSearchState {
  final List<StockModel> stocks;
  final String query;

  const StockSearchLoaded({
    required this.stocks,
    required this.query,
  });

  @override
  List<Object?> get props => [stocks, query];
}

class StockSearchEmpty extends StockSearchState {
  final String query;

  const StockSearchEmpty(this.query);

  @override
  List<Object?> get props => [query];
}

class StockSearchError extends StockSearchState {
  final String message;

  const StockSearchError(this.message);

  @override
  List<Object?> get props => [message];
}