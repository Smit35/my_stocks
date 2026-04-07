import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/light_theme.dart';
import '../../bloc/stock_search/stock_search_bloc.dart';
import '../../bloc/stock_search/stock_search_event.dart';
import '../../bloc/stock_search/stock_search_state.dart';
import '../../bloc/watchlist/watchlist_bloc.dart';
import '../../bloc/watchlist/watchlist_event.dart';
import '../../widgets/stock_search_item.dart';

class AddStockScreen extends StatefulWidget {
  final String watchlistId;

  const AddStockScreen({
    super.key,
    required this.watchlistId,
  });

  @override
  State<AddStockScreen> createState() => _AddStockScreenState();
}

class _AddStockScreenState extends State<AddStockScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: LightTheme.backgroundColor,
        title: const Text('Add Stock'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search stocks (e.g., RELIANCE, TCS)',
                hintStyle: const TextStyle(color: LightTheme.textTertiary),
                prefixIcon: const Icon(Icons.search, color: LightTheme.textTertiary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: LightTheme.textTertiary),
                        onPressed: () {
                          _searchController.clear();
                          context.read<StockSearchBloc>().add(ClearSearch());
                        },
                      )
                    : null,
              ),
              style: const TextStyle(color: LightTheme.textPrimary),
              onChanged: (query) {
                setState(() {}); // Update UI for clear button
                if (query.trim().isNotEmpty) {
                  context.read<StockSearchBloc>().add(SearchStocks(query));
                } else {
                  context.read<StockSearchBloc>().add(ClearSearch());
                }
              },
            ),
          ),
          
          // Search Results
          Expanded(
            child: BlocBuilder<StockSearchBloc, StockSearchState>(
              builder: (context, state) {
                if (state is StockSearchInitial) {
                  return _buildSearchSuggestions();
                }

                if (state is StockSearchLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: LightTheme.primaryColor),
                  );
                }

                if (state is StockSearchLoaded) {
                  return _buildSearchResults(state.stocks);
                }

                if (state is StockSearchEmpty) {
                  return _buildEmptyState('No stocks found for "${state.query}"');
                }

                if (state is StockSearchError) {
                  return _buildErrorState(state.message);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    final suggestions = [
      {'symbol': 'RELIANCE', 'name': 'Reliance Industries'},
      {'symbol': 'TCS', 'name': 'Tata Consultancy Services'},
      {'symbol': 'HDFCBANK', 'name': 'HDFC Bank'},
      {'symbol': 'INFY', 'name': 'Infosys'},
      {'symbol': 'ITC', 'name': 'ITC Limited'},
      {'symbol': 'HINDUNILVR', 'name': 'Hindustan Unilever'},
      {'symbol': 'ICICIBANK', 'name': 'ICICI Bank'},
      {'symbol': 'BHARTIARTL', 'name': 'Bharti Airtel'},
      {'symbol': 'SBIN', 'name': 'State Bank of India'},
      {'symbol': 'BAJFINANCE', 'name': 'Bajaj Finance'},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Icon(Icons.trending_up, color: LightTheme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Popular Indian Stocks',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: LightTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Tap any stock below or search for specific stocks',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: LightTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        ...suggestions.map(
          (stock) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              color: LightTheme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: LightTheme.primaryColor,
                  child: Text(
                    stock['symbol']!.substring(0, 2),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                title: Text(
                  stock['symbol']!,
                  style: const TextStyle(
                    color: LightTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  stock['name']!,
                  style: const TextStyle(color: LightTheme.textSecondary),
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: LightTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.add, color: LightTheme.primaryColor, size: 16),
                ),
                onTap: () {
                  _searchController.text = stock['symbol']!;
                  context.read<StockSearchBloc>().add(SearchStocks(stock['symbol']!));
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: LightTheme.surfaceColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: LightTheme.primaryColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Search by stock symbol (e.g., RELIANCE) or company name (e.g., Reliance Industries)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: LightTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(List stocks) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: stocks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final stock = stocks[index];
        return StockSearchItem(
          stock: stock,
          onTap: () {
            // Add stock to watchlist
            context.read<WatchlistBloc>().add(
              AddStockToWatchlist(widget.watchlistId, stock.symbol),
            );
            
            // Show confirmation
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${stock.symbol} added to watchlist'),
                backgroundColor: LightTheme.positiveColor,
                duration: const Duration(seconds: 2),
              ),
            );
            
            // Go back
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: LightTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: LightTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for Indian stock symbols like RELIANCE, TCS, or INFY',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: LightTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: LightTheme.negativeColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Search Error',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: LightTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: LightTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}