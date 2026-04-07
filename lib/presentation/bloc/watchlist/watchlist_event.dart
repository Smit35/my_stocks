import 'package:equatable/equatable.dart';

abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

class LoadWatchlists extends WatchlistEvent {
  final String userId;

  const LoadWatchlists(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateWatchlist extends WatchlistEvent {
  final String name;
  final String userId;

  const CreateWatchlist(this.name, this.userId);

  @override
  List<Object?> get props => [name, userId];
}

class SelectWatchlist extends WatchlistEvent {
  final String watchlistId;

  const SelectWatchlist(this.watchlistId);

  @override
  List<Object?> get props => [watchlistId];
}

class AddStockToWatchlist extends WatchlistEvent {
  final String watchlistId;
  final String stockSymbol;

  const AddStockToWatchlist(this.watchlistId, this.stockSymbol);

  @override
  List<Object?> get props => [watchlistId, stockSymbol];
}

class RemoveStockFromWatchlist extends WatchlistEvent {
  final String watchlistId;
  final String stockSymbol;

  const RemoveStockFromWatchlist(this.watchlistId, this.stockSymbol);

  @override
  List<Object?> get props => [watchlistId, stockSymbol];
}

class RenameWatchlist extends WatchlistEvent {
  final String watchlistId;
  final String newName;

  const RenameWatchlist(this.watchlistId, this.newName);

  @override
  List<Object?> get props => [watchlistId, newName];
}

class DeleteWatchlist extends WatchlistEvent {
  final String watchlistId;

  const DeleteWatchlist(this.watchlistId);

  @override
  List<Object?> get props => [watchlistId];
}

class RefreshStockPrices extends WatchlistEvent {
  final String watchlistId;

  const RefreshStockPrices(this.watchlistId);

  @override
  List<Object?> get props => [watchlistId];
}