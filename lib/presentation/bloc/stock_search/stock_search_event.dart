import 'package:equatable/equatable.dart';

abstract class StockSearchEvent extends Equatable {
  const StockSearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchStocks extends StockSearchEvent {
  final String query;

  const SearchStocks(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends StockSearchEvent {}