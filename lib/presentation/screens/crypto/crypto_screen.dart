import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/light_theme.dart';
import '../../bloc/crypto/crypto_bloc.dart';
import '../../bloc/crypto/crypto_event.dart';
import '../../bloc/crypto/crypto_state.dart';
import '../../widgets/crypto_item_card.dart';

class CryptoScreen extends StatefulWidget {
  const CryptoScreen({super.key});

  @override
  State<CryptoScreen> createState() => _CryptoScreenState();
}

class _CryptoScreenState extends State<CryptoScreen> {
  int _selectedNavIndex = 1;

  @override
  void initState() {
    super.initState();
    context.read<CryptoBloc>().add(const StartCryptoStream());
  }

  @override
  void dispose() {
    context.read<CryptoBloc>().add(const StopCryptoStream());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    'Live Crypto',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                  const Spacer(),
                  BlocBuilder<CryptoBloc, CryptoState>(
                    builder: (context, state) {
                      bool isConnected = false;
                      if (state is CryptoLoaded) {
                        isConnected = state.isConnected;
                      }
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isConnected ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isConnected ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isConnected ? 'Live' : 'Offline',
                              style: TextStyle(
                                color: isConnected ? Colors.green : Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Header info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: LightTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Real-time cryptocurrency prices via WebSocket',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // Crypto List
            Expanded(
              child: BlocBuilder<CryptoBloc, CryptoState>(
                builder: (context, state) {
                  if (state is CryptoLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: LightTheme.primaryColor),
                          SizedBox(height: 16),
                          Text(
                            'Connecting to live crypto feed...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is CryptoLoaded) {
                    if (state.cryptos.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.currency_bitcoin,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Waiting for crypto data...',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Live prices will appear here shortly',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.cryptos.length,
                      itemBuilder: (context, index) {
                        final crypto = state.cryptos[index];
                        return CryptoItemCard(
                          crypto: crypto,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${crypto.name} - ${crypto.formattedPrice}'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }

                  if (state is CryptoError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Connection Error',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<CryptoBloc>().add(const StartCryptoStream());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LightTheme.primaryColor,
                            ),
                            child: const Text(
                              'Retry',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.currency_bitcoin,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Tap to start live crypto feed',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<CryptoBloc>().add(const StartCryptoStream());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LightTheme.primaryColor,
                          ),
                          child: const Text(
                            'Start Live Feed',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
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
            _buildNavItem(Icons.grid_view, 0),
            _buildNavItem(Icons.trending_up, 1),
            _buildNavItem(Icons.bookmark_border, 2),
            _buildNavItem(Icons.search, 3),
            _buildNavItem(Icons.person_outline, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedNavIndex == index;
    
    return GestureDetector(
      onTap: () {
        if (index == 2) {
          Navigator.of(context).pop();
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
}