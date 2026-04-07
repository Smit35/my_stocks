import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/watchlist_model.dart';

class WatchlistHeader extends StatelessWidget {
  final List<WatchlistModel> watchlists;
  final WatchlistModel? selectedWatchlist;
  final Function(String) onWatchlistChanged;
  final VoidCallback onCreateWatchlist;
  final Function(String) onRenameWatchlist;
  final Function(String) onDeleteWatchlist;

  const WatchlistHeader({
    super.key,
    required this.watchlists,
    required this.selectedWatchlist,
    required this.onWatchlistChanged,
    required this.onCreateWatchlist,
    required this.onRenameWatchlist,
    required this.onDeleteWatchlist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  selectedWatchlist?.name ?? 'Watchlist',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
                color: AppTheme.cardColor,
                onSelected: (value) {
                  switch (value) {
                    case 'create':
                      onCreateWatchlist();
                      break;
                    case 'rename':
                      if (selectedWatchlist != null) {
                        onRenameWatchlist(selectedWatchlist!.id);
                      }
                      break;
                    case 'delete':
                      if (selectedWatchlist != null) {
                        onDeleteWatchlist(selectedWatchlist!.id);
                      }
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'create',
                    child: Row(
                      children: [
                        Icon(Icons.add, color: AppTheme.textPrimary),
                        SizedBox(width: 8),
                        Text('Create Watchlist', style: TextStyle(color: AppTheme.textPrimary)),
                      ],
                    ),
                  ),
                  if (selectedWatchlist != null) ...[
                    const PopupMenuItem(
                      value: 'rename',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: AppTheme.textPrimary),
                          SizedBox(width: 8),
                          Text('Rename', style: TextStyle(color: AppTheme.textPrimary)),
                        ],
                      ),
                    ),
                    if (watchlists.length > 1)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: AppTheme.negativeColor),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: AppTheme.negativeColor)),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ],
          ),
          if (watchlists.length > 1) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: watchlists.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final watchlist = watchlists[index];
                  final isSelected = selectedWatchlist?.id == watchlist.id;
                  
                  return FilterChip(
                    label: Text(
                      watchlist.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryColor,
                    backgroundColor: AppTheme.surfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                      ),
                    ),
                    onSelected: (_) {
                      if (!isSelected) {
                        onWatchlistChanged(watchlist.id);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}