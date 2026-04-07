import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'watchlist_model.g.dart';

@HiveType(typeId: 2)
class WatchlistModel extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String userId;
  
  @HiveField(3)
  final List<String> stockSymbols;
  
  @HiveField(4)
  final DateTime createdAt;
  
  @HiveField(5)
  final DateTime updatedAt;

  const WatchlistModel({
    required this.id,
    required this.name,
    required this.userId,
    required this.stockSymbols,
    required this.createdAt,
    required this.updatedAt,
  });

  WatchlistModel copyWith({
    String? id,
    String? name,
    String? userId,
    List<String>? stockSymbols,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WatchlistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      stockSymbols: stockSymbols ?? this.stockSymbols,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  WatchlistModel addStock(String symbol) {
    if (stockSymbols.contains(symbol)) return this;
    
    return copyWith(
      stockSymbols: [...stockSymbols, symbol],
      updatedAt: DateTime.now(),
    );
  }

  WatchlistModel removeStock(String symbol) {
    return copyWith(
      stockSymbols: stockSymbols.where((s) => s != symbol).toList(),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'stockSymbols': stockSymbols,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory WatchlistModel.fromJson(Map<String, dynamic> json) {
    return WatchlistModel(
      id: json['id'],
      name: json['name'],
      userId: json['userId'],
      stockSymbols: List<String>.from(json['stockSymbols']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [id, name, userId, stockSymbols, createdAt, updatedAt];
}