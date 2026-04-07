import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/stock_model.dart';
import 'package:intl/intl.dart';

class StockItemCard extends StatelessWidget {
  final StockModel stock;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const StockItemCard({
    super.key,
    required this.stock,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final changeColor = stock.isPositive ? AppTheme.positiveColor : AppTheme.negativeColor;
    final changeIcon = stock.isPositive ? Icons.trending_up : Icons.trending_down;
    
    return Card(
      color: AppTheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Stock Symbol Avatar
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                radius: 24,
                child: Text(
                  stock.symbol.length >= 2 
                      ? stock.symbol.substring(0, 2).toUpperCase()
                      : stock.symbol.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Stock Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.symbol,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stock.name.isNotEmpty ? stock.name : stock.symbol,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (stock.exchange?.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        stock.exchange!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Price Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    stock.currentPrice > 0 
                        ? NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(stock.currentPrice)
                        : '--',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (stock.currentPrice > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: changeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            changeIcon,
                            size: 12,
                            color: changeColor,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${stock.changePercentage.toStringAsFixed(2)}%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: changeColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              // More Options
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppTheme.textTertiary, size: 16),
                color: AppTheme.cardColor,
                onSelected: (value) {
                  if (value == 'remove') {
                    onRemove();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle_outline, color: AppTheme.negativeColor, size: 18),
                        SizedBox(width: 8),
                        Text('Remove', style: TextStyle(color: AppTheme.negativeColor, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}