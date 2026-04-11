import 'package:equatable/equatable.dart';

class CryptoModel extends Equatable {
  final String symbol;
  final String name;
  final double price;
  final double? change24h;
  final double? changePercent24h;
  final double? volume24h;
  final String? iconUrl;
  final DateTime lastUpdated;

  const CryptoModel({
    required this.symbol,
    required this.name,
    required this.price,
    this.change24h,
    this.changePercent24h,
    this.volume24h,
    this.iconUrl,
    required this.lastUpdated,
  });

  factory CryptoModel.fromCoinbaseProTicker(Map<String, dynamic> json, String productId) {
    return CryptoModel(
      symbol: productId.split('-').first,
      name: _getCryptoName(productId.split('-').first),
      price: double.parse(json['price'] ?? '0'),
      change24h: json['open_24h'] != null && json['price'] != null
          ? double.parse(json['price']) - double.parse(json['open_24h'])
          : null,
      changePercent24h: json['open_24h'] != null && json['price'] != null
          ? ((double.parse(json['price']) - double.parse(json['open_24h'])) /
                  double.parse(json['open_24h'])) *
              100
          : null,
      volume24h: json['volume_24h'] != null ? double.parse(json['volume_24h']) : null,
      iconUrl: _getCryptoIcon(productId.split('-').first),
      lastUpdated: DateTime.now(),
    );
  }

  static String _getCryptoName(String symbol) {
    const cryptoNames = {
      'BTC': 'Bitcoin',
      'ETH': 'Ethereum',
      'USDT': 'Tether',
      'XRP': 'XRP',
      'USDC': 'USD Coin',
      'SOL': 'Solana',
      'DOGE': 'Dogecoin',
      'ADA': 'Cardano',
      'LINK': 'Chainlink',
      'DOT': 'Polkadot',
    };
    return cryptoNames[symbol] ?? symbol;
  }

  static String _getCryptoIcon(String symbol) {
    return 'https://cryptoicons.org/api/icon/${symbol.toLowerCase()}/50';
  }

  CryptoModel copyWith({
    String? symbol,
    String? name,
    double? price,
    double? change24h,
    double? changePercent24h,
    double? volume24h,
    String? iconUrl,
    DateTime? lastUpdated,
  }) {
    return CryptoModel(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      price: price ?? this.price,
      change24h: change24h ?? this.change24h,
      changePercent24h: changePercent24h ?? this.changePercent24h,
      volume24h: volume24h ?? this.volume24h,
      iconUrl: iconUrl ?? this.iconUrl,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  String get formattedPrice {
    return '\$${_formatNumberWithCommas(price.toStringAsFixed(2))}';
  }
  
  String _formatNumberWithCommas(String number) {
    // Split the number into parts (before and after decimal)
    List<String> parts = number.split('.');
    String wholePart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '00';
    
    // Add commas to the whole part
    String formattedWhole = '';
    for (int i = 0; i < wholePart.length; i++) {
      if (i > 0 && (wholePart.length - i) % 3 == 0) {
        formattedWhole += ',';
      }
      formattedWhole += wholePart[i];
    }
    
    return '$formattedWhole.$decimalPart';
  }

  String get formattedChange {
    if (change24h == null) return '';
    final sign = change24h! >= 0 ? '+' : '';
    return '$sign\$${change24h!.toStringAsFixed(2)}';
  }

  String get formattedChangePercent {
    if (changePercent24h == null) return '';
    final sign = changePercent24h! >= 0 ? '+' : '';
    return '$sign${changePercent24h!.toStringAsFixed(2)}%';
  }

  bool get isPositive => changePercent24h != null && changePercent24h! >= 0;

  @override
  List<Object?> get props => [
        symbol,
        name,
        price,
        change24h,
        changePercent24h,
        volume24h,
        iconUrl,
        lastUpdated,
      ];
}