import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/light_theme.dart';
import '../../../data/models/watchlist_model.dart';
import '../../../data/models/stock_model.dart';
import '../../bloc/watchlist/watchlist_bloc.dart';
import '../../bloc/watchlist/watchlist_event.dart';
import '../../bloc/watchlist/watchlist_state.dart';

class EditWatchlistScreen extends StatefulWidget {
  final WatchlistModel watchlist;

  const EditWatchlistScreen({
    super.key,
    required this.watchlist,
  });

  @override
  State<EditWatchlistScreen> createState() => _EditWatchlistScreenState();
}

class _EditWatchlistScreenState extends State<EditWatchlistScreen> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.watchlist.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: LightTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit WatchList',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black),
            onPressed: () => _showDeleteWatchlistDialog(),
          ),
        ],
      ),
      body: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) {
          if (state is WatchlistLoaded) {
            final stocks = state.stocks;
            
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Watchlist Name Field
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'watch list name',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: LightTheme.primaryColor, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: LightTheme.primaryColor, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: LightTheme.primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Stock List
                  Expanded(
                    child: stocks.isEmpty 
                      ? const Center(
                          child: Text(
                            'No stocks in this watchlist',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: stocks.length,
                          itemBuilder: (context, index) {
                            final stock = stocks[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 1),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                                ),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.drag_handle,
                                  color: Colors.grey,
                                ),
                                title: Text(
                                  stock.name.isNotEmpty ? stock.name : stock.symbol,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.grey),
                                  onPressed: () {
                                    context.read<WatchlistBloc>().add(
                                      RemoveStockFromWatchlist(widget.watchlist.id, stock.symbol),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _saveWatchlist(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LightTheme.positiveColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          
          return const Center(
            child: CircularProgressIndicator(color: LightTheme.primaryColor),
          );
        },
      ),
    );
  }

  void _saveWatchlist() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a watchlist name'),
          backgroundColor: LightTheme.negativeColor,
        ),
      );
      return;
    }

    // Update watchlist name
    context.read<WatchlistBloc>().add(
      RenameWatchlist(widget.watchlist.id, _nameController.text.trim()),
    );

    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_nameController.text.trim()} updated successfully'),
        backgroundColor: LightTheme.positiveColor,
      ),
    );
  }

  void _showDeleteWatchlistDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Watchlist'),
        content: Text('Are you sure you want to delete "${widget.watchlist.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<WatchlistBloc>().add(DeleteWatchlist(widget.watchlist.id));
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close edit screen
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}