import 'package:flutter/material.dart';
import '../../core/theme/light_theme.dart';
import '../../data/models/crypto_model.dart';

class CryptoItemCard extends StatelessWidget {
  final CryptoModel crypto;
  final VoidCallback? onTap;

  const CryptoItemCard({
    super.key,
    required this.crypto,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            // Crypto Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: LightTheme.surfaceColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: crypto.iconUrl != null
                    ? Image.network(
                        crypto.iconUrl!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildFallbackIcon();
                        },
                      )
                    : _buildFallbackIcon(),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Crypto Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        crypto.symbol,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          crypto.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Price and Change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  crypto.formattedPrice,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                if (crypto.changePercent24h != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: crypto.isPositive ? LightTheme.positiveColor : LightTheme.negativeColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      crypto.formattedChangePercent,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: LightTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          crypto.symbol.substring(0, 1),
          style: TextStyle(
            color: LightTheme.primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}