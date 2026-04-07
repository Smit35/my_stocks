import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/light_theme.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/watchlist/watchlist_bloc.dart';
import '../../bloc/watchlist/watchlist_event.dart';
import '../../bloc/watchlist/watchlist_state.dart';
import '../../bloc/stock_search/stock_search_bloc.dart';
import '../../bloc/stock_search/stock_search_event.dart';
import '../../bloc/stock_search/stock_search_state.dart';
import '../../widgets/new_stock_item_card.dart';
import '../../widgets/stock_search_item.dart';
import 'add_stock_screen.dart';
import 'edit_watchlist_screen.dart';

class NewWatchlistScreen extends StatefulWidget {
  const NewWatchlistScreen({super.key});

  @override
  State<NewWatchlistScreen> createState() => _NewWatchlistScreenState();
}

class _NewWatchlistScreenState extends State<NewWatchlistScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightTheme.backgroundColor,
      body: GestureDetector(
        onTap: () {
          _searchFocusNode.unfocus();
        },
        child: SafeArea(
          child: Column(
            children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Watchlist',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white, size: 20),
                      onPressed: () => _showCreateWatchlistDialog(context),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: LightTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'search for a ticker',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: const TextStyle(fontSize: 14),
                  onChanged: (query) {
                    setState(() {
                      _isSearching = query.trim().isNotEmpty;
                    });
                    
                    if (query.trim().isNotEmpty) {
                      context.read<StockSearchBloc>().add(SearchStocks(query));
                    } else {
                      context.read<StockSearchBloc>().add(ClearSearch());
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Watchlist Tabs
            BlocBuilder<WatchlistBloc, WatchlistState>(
              builder: (context, state) {
                if (state is WatchlistLoaded) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        // Watchlist tabs on the left
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: state.watchlists.map((watchlist) {
                                final isSelected = state.selectedWatchlist?.id == watchlist.id;
                                
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (!isSelected) {
                                        context.read<WatchlistBloc>().add(SelectWatchlist(watchlist.id));
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      child: Text(
                                        watchlist.name,
                                        style: TextStyle(
                                          color: isSelected ? Colors.black : Colors.grey[600],
                                          fontSize: 16,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        
                        // Menu and sort icons on the right
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(Icons.menu, color: Colors.grey[600], size: 16),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(Icons.swap_vert, color: Colors.grey[600], size: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Stock Count and Actions (only when not searching)
            if (!_isSearching) 
              BlocBuilder<WatchlistBloc, WatchlistState>(
                builder: (context, state) {
                  if (state is WatchlistLoaded && state.selectedWatchlist != null) {
                    return Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            '${state.stocks.length} stocks',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          // Add stock button
                          GestureDetector(
                            onTap: () {
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
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: LightTheme.positiveColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Edit watchlist button
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: BlocProvider.of<WatchlistBloc>(context),
                                    child: EditWatchlistScreen(
                                      watchlist: state.selectedWatchlist!,
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.edit_outlined,
                                color: Colors.grey[600],
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

            // Stock List or Search Results
            Expanded(
              child: _isSearching ? _buildSearchResults() : _buildWatchlistContent(),
            ),
            ],
          ),
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.grid_view, false),
            _buildNavItem(Icons.trending_up, false),
            _buildNavItem(Icons.bookmark_border, true),
            _buildNavItem(Icons.search, false),
            _buildNavItem(Icons.person_outline, false),
          ],
        ),
      ),

    );
  }

  Widget _buildNavItem(IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (icon == Icons.person_outline) {
          _showLogoutDialog();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: isSelected ? Colors.black : Colors.grey[400],
          size: 24,
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Perform logout
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pop(context); // Close dialog
              // Navigate to login screen
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.visibility_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No Watchlists',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first watchlist to start tracking stocks',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showCreateWatchlistDialog(context),
            child: const Text('Create Watchlist'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStocks() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_chart_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No stocks in this watchlist',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add stocks',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<StockSearchBloc, StockSearchState>(
      builder: (context, state) {
        if (state is StockSearchLoading) {
          return const Center(
            child: CircularProgressIndicator(color: LightTheme.primaryColor),
          );
        }

        if (state is StockSearchLoaded) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.stocks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final stock = state.stocks[index];
              return StockSearchItem(
                stock: stock,
                onTap: () {
                  final watchlistState = context.read<WatchlistBloc>().state;
                  if (watchlistState is WatchlistLoaded && watchlistState.selectedWatchlist != null) {
                    // Add stock to watchlist
                    context.read<WatchlistBloc>().add(
                      AddStockToWatchlist(watchlistState.selectedWatchlist!.id, stock.symbol),
                    );
                    
                    // Clear search and reset to watchlist view
                    _searchController.clear();
                    setState(() {
                      _isSearching = false;
                    });
                    context.read<StockSearchBloc>().add(ClearSearch());
                    
                    // Show confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${stock.symbol} added to ${watchlistState.selectedWatchlist!.name}'),
                        backgroundColor: LightTheme.positiveColor,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          );
        }

        if (state is StockSearchEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No stocks found for "${state.query}"',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Try searching for Indian stock symbols like RELIANCE, TCS, or INFY',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        if (state is StockSearchError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Search Error',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildWatchlistContent() {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, state) {
        if (state is WatchlistLoading) {
          return const Center(
            child: CircularProgressIndicator(color: LightTheme.primaryColor),
          );
        }

        if (state is WatchlistEmpty) {
          return _buildEmptyState();
        }

        if (state is WatchlistLoaded) {
          if (state.stocks.isEmpty) {
            return _buildEmptyStocks();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.stocks.length,
            itemBuilder: (context, index) {
              final stock = state.stocks[index];
              return NewStockItemCard(
                stock: stock,
                onTap: () {
                  Navigator.of(context).pushNamed('/stock-detail', arguments: stock);
                },
              );
            },
          );
        }

        if (state is WatchlistError) {
          return Center(
            child: Text(
              'Error: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showCreateWatchlistDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create Watchlist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Watchlist name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

}