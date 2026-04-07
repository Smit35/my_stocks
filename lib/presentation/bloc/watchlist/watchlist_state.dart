import 'package:equatable/equatable.dart';
import '../../../data/models/watchlist_model.dart';
import '../../../data/models/stock_model.dart';

abstract class WatchlistState extends Equatable {
  const WatchlistState();

  @override
  List<Object?> get props => [];
}

class WatchlistInitial extends WatchlistState {}

class WatchlistLoading extends WatchlistState {}

class WatchlistLoaded extends WatchlistState {
  final List<WatchlistModel> watchlists;
  final WatchlistModel? selectedWatchlist;
  final List<StockModel> stocks;
  final bool isRefreshing;

  const WatchlistLoaded({
    required this.watchlists,
    this.selectedWatchlist,
    required this.stocks,
    this.isRefreshing = false,
  });

  WatchlistLoaded copyWith({
    List<WatchlistModel>? watchlists,
    WatchlistModel? selectedWatchlist,
    List<StockModel>? stocks,
    bool? isRefreshing,
  }) {
    return WatchlistLoaded(
      watchlists: watchlists ?? this.watchlists,
      selectedWatchlist: selectedWatchlist ?? this.selectedWatchlist,
      stocks: stocks ?? this.stocks,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [watchlists, selectedWatchlist, stocks, isRefreshing];
}

class WatchlistEmpty extends WatchlistState {}

class WatchlistError extends WatchlistState {
  final String message;

  const WatchlistError(this.message);

  @override
  List<Object?> get props => [message];
}