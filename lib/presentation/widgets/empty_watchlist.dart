import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class EmptyWatchlist extends StatelessWidget {
  final VoidCallback onCreateWatchlist;

  const EmptyWatchlist({
    super.key,
    required this.onCreateWatchlist,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.visibility_outlined,
            size: 120,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 32),
          Text(
            'No Watchlists',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Create your first watchlist to start tracking your favorite stocks',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onCreateWatchlist,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Create Watchlist'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}