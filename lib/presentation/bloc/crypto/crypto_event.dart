import 'package:equatable/equatable.dart';

abstract class CryptoEvent extends Equatable {
  const CryptoEvent();

  @override
  List<Object> get props => [];
}

class StartCryptoStream extends CryptoEvent {
  const StartCryptoStream();
}

class StopCryptoStream extends CryptoEvent {
  const StopCryptoStream();
}

class CryptoDataUpdated extends CryptoEvent {
  final List<dynamic> cryptos;

  const CryptoDataUpdated(this.cryptos);

  @override
  List<Object> get props => [cryptos];
}