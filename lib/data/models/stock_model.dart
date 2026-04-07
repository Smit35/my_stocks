import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'stock_model.g.dart';

@HiveType(typeId: 1)
class StockModel extends Equatable {
  @HiveField(0)
  final String symbol;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final double currentPrice;
  
  @HiveField(3)
  final double changeAmount;
  
  @HiveField(4)
  final double changePercentage;
  
  @HiveField(5)
  final DateTime lastUpdated;
  
  @HiveField(6)
  final String? exchange;

  const StockModel({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.changeAmount,
    required this.changePercentage,
    required this.lastUpdated,
    this.exchange,
  });

  StockModel copyWith({
    String? symbol,
    String? name,
    double? currentPrice,
    double? changeAmount,
    double? changePercentage,
    DateTime? lastUpdated,
    String? exchange,
  }) {
    return StockModel(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      currentPrice: currentPrice ?? this.currentPrice,
      changeAmount: changeAmount ?? this.changeAmount,
      changePercentage: changePercentage ?? this.changePercentage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      exchange: exchange ?? this.exchange,
    );
  }

  bool get isPositive => changeAmount >= 0;

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'currentPrice': currentPrice,
      'changeAmount': changeAmount,
      'changePercentage': changePercentage,
      'lastUpdated': lastUpdated.toIso8601String(),
      'exchange': exchange,
    };
  }

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      symbol: json['symbol'],
      name: json['name'],
      currentPrice: (json['currentPrice'] as num).toDouble(),
      changeAmount: (json['changeAmount'] as num).toDouble(),
      changePercentage: (json['changePercentage'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      exchange: json['exchange'],
    );
  }

  factory StockModel.fromTwelveDataSearch(Map<String, dynamic> json) {
    return StockModel(
      symbol: json['symbol'] ?? '',
      name: json['instrument_name'] ?? json['name'] ?? '',
      currentPrice: 0.0,
      changeAmount: 0.0,
      changePercentage: 0.0,
      lastUpdated: DateTime.now(),
      exchange: json['exchange'] ?? '',
    );
  }

  factory StockModel.fromTwelveDataPrice(Map<String, dynamic> json, StockModel existing) {
    // Try multiple possible price fields from TwelveData API
    double price = 0.0;
    if (json['price'] != null) {
      price = double.tryParse(json['price'].toString()) ?? 0.0;
    } else if (json['close'] != null) {
      price = double.tryParse(json['close'].toString()) ?? 0.0;
    } else if (json['last_price'] != null) {
      price = double.tryParse(json['last_price'].toString()) ?? 0.0;
    }
    
    // Try multiple possible previous close fields
    double previousClose = 0.0;
    if (json['previous_close'] != null) {
      previousClose = double.tryParse(json['previous_close'].toString()) ?? 0.0;
    } else if (json['prev_close'] != null) {
      previousClose = double.tryParse(json['prev_close'].toString()) ?? 0.0;
    }
    
    // Use existing price if no previous close is available
    if (previousClose == 0.0 && existing.currentPrice > 0) {
      previousClose = existing.currentPrice;
    }
    
    final changeAmount = price - previousClose;
    final changePercentage = previousClose != 0 ? (changeAmount / previousClose) * 100 : 0.0;

    return existing.copyWith(
      currentPrice: price,
      changeAmount: changeAmount,
      changePercentage: changePercentage,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        symbol,
        name,
        currentPrice,
        changeAmount,
        changePercentage,
        lastUpdated,
        exchange,
      ];
}