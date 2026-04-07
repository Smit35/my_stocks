import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/watchlist/watchlist_bloc.dart';
import '../../bloc/watchlist/watchlist_event.dart';
import '../../bloc/watchlist/watchlist_state.dart';
import '../../bloc/stock_search/stock_search_bloc.dart';
import '../../widgets/stock_item_card.dart';
import '../../widgets/watchlist_header.dart';
import '../../widgets/empty_watchlist.dart';
import 'add_stock_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: const Text('My Watchlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
      body: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) {
          if (state is WatchlistLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (state is WatchlistEmpty) {
            return EmptyWatchlist(
              onCreateWatchlist: () => _showCreateWatchlistDialog(context),
            );
          }

          if (state is WatchlistLoaded) {
            return Column(
              children: [
                WatchlistHeader(
                  watchlists: state.watchlists,
                  selectedWatchlist: state.selectedWatchlist,
                  onWatchlistChanged: (watchlistId) {
                    context.read<WatchlistBloc>().add(SelectWatchlist(watchlistId));
                  },
                  onCreateWatchlist: () => _showCreateWatchlistDialog(context),
                  onRenameWatchlist: (watchlistId) => _showRenameWatchlistDialog(context, watchlistId),
                  onDeleteWatchlist: (watchlistId) => _showDeleteWatchlistDialog(context, watchlistId),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      if (state.selectedWatchlist != null) {
                        context.read<WatchlistBloc>().add(
                          RefreshStockPrices(state.selectedWatchlist!.id),
                        );
                      }
                    },
                    child: state.stocks.isEmpty
                        ? _buildEmptyStocks(context, state)
                        : _buildStocksList(context, state),
                  ),
                ),
              ],
            );
          }

          if (state is WatchlistError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.negativeColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) {
          if (state is WatchlistLoaded && state.selectedWatchlist != null) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: BlocProvider.of<StockSearchBloc>(context),
                      child: AddStockScreen(
                        watchlistId: state.selectedWatchlist!.id,
                      ),
                    ),
                  ),
                );
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyStocks(BuildContext context, WatchlistLoaded state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 64),
              Icon(
                Icons.add_chart_outlined,
                size: 64,
                color: AppTheme.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'No stocks in this watchlist',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the + button to add stocks',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStocksList(BuildContext context, WatchlistLoaded state) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.stocks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final stock = state.stocks[index];
        return StockItemCard(
          stock: stock,
          onTap: () {
            Navigator.of(context).pushNamed('/stock-detail', arguments: stock);
          },
          onRemove: () {
            context.read<WatchlistBloc>().add(
              RemoveStockFromWatchlist(
                state.selectedWatchlist!.id,
                stock.symbol,
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateWatchlistDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Create Watchlist', style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Watchlist name',
            hintStyle: TextStyle(color: AppTheme.textTertiary),
          ),
          style: const TextStyle(color: AppTheme.textPrimary),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context.read<WatchlistBloc>().add(
                    CreateWatchlist(controller.text.trim(), authState.user.id),
                  );
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Create', style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
  }

  void _showRenameWatchlistDialog(BuildContext context, String watchlistId) {
    final controller = TextEditingController();
    final watchlist = context.read<WatchlistBloc>().state;
    
    if (watchlist is WatchlistLoaded) {
      final selectedWatchlist = watchlist.watchlists.firstWhere((w) => w.id == watchlistId);
      controller.text = selectedWatchlist.name;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Rename Watchlist', style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Watchlist name',
            hintStyle: TextStyle(color: AppTheme.textTertiary),
          ),
          style: const TextStyle(color: AppTheme.textPrimary),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<WatchlistBloc>().add(
                  RenameWatchlist(watchlistId, controller.text.trim()),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Rename', style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
  }

  void _showDeleteWatchlistDialog(BuildContext context, String watchlistId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Delete Watchlist', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'Are you sure you want to delete this watchlist?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              context.read<WatchlistBloc>().add(DeleteWatchlist(watchlistId));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.negativeColor)),
          ),
        ],
      ),
    );
  }
}