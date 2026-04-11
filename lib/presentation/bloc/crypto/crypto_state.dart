import 'package:equatable/equatable.dart';
import '../../../data/models/crypto_model.dart';

abstract class CryptoState extends Equatable {
  const CryptoState();

  @override
  List<Object> get props => [];
}

class CryptoInitial extends CryptoState {
  const CryptoInitial();
}

class CryptoLoading extends CryptoState {
  const CryptoLoading();
}

class CryptoLoaded extends CryptoState {
  final List<CryptoModel> cryptos;
  final bool isConnected;

  const CryptoLoaded({
    required this.cryptos,
    required this.isConnected,
  });

  @override
  List<Object> get props => [cryptos, isConnected];
}

class CryptoError extends CryptoState {
  final String message;

  const CryptoError(this.message);

  @override
  List<Object> get props => [message];
}