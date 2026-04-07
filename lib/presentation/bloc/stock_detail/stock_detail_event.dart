import 'package:equatable/equatable.dart';
import '../../../data/models/stock_model.dart';

abstract class StockDetailEvent extends Equatable {
  const StockDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadStockDetail extends StockDetailEvent {
  final StockModel stock;

  const LoadStockDetail(this.stock);

  @override
  List<Object?> get props => [stock];
}

class ChangeTimeframe extends StockDetailEvent {
  final String timeframe;

  const ChangeTimeframe(this.timeframe);

  @override
  List<Object?> get props => [timeframe];
}

class RefreshStockDetail extends StockDetailEvent {}