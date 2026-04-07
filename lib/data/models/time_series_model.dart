import 'package:equatable/equatable.dart';

class TimeSeriesModel extends Equatable {
  final DateTime datetime;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;

  const TimeSeriesModel({
    required this.datetime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  TimeSeriesModel copyWith({
    DateTime? datetime,
    double? open,
    double? high,
    double? low,
    double? close,
    int? volume,
  }) {
    return TimeSeriesModel(
      datetime: datetime ?? this.datetime,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'datetime': datetime.toIso8601String(),
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
    };
  }

  factory TimeSeriesModel.fromJson(Map<String, dynamic> json) {
    return TimeSeriesModel(
      datetime: DateTime.parse(json['datetime']),
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      volume: json['volume'] as int,
    );
  }

  factory TimeSeriesModel.fromTwelveData(String datetime, Map<String, dynamic> json) {
    return TimeSeriesModel(
      datetime: DateTime.parse(datetime),
      open: double.tryParse(json['1. open']?.toString() ?? '0') ?? 0.0,
      high: double.tryParse(json['2. high']?.toString() ?? '0') ?? 0.0,
      low: double.tryParse(json['3. low']?.toString() ?? '0') ?? 0.0,
      close: double.tryParse(json['4. close']?.toString() ?? '0') ?? 0.0,
      volume: int.tryParse(json['5. volume']?.toString() ?? '0') ?? 0,
    );
  }

  @override
  List<Object?> get props => [datetime, open, high, low, close, volume];
}