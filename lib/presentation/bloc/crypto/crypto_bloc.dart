import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/crypto_model.dart';
import '../../../data/repositories/crypto_repository.dart';
import 'crypto_event.dart';
import 'crypto_state.dart';

class CryptoBloc extends Bloc<CryptoEvent, CryptoState> {
  final CryptoRepository cryptoRepository;
  StreamSubscription<List<CryptoModel>>? _cryptoSubscription;

  CryptoBloc({required this.cryptoRepository}) : super(const CryptoInitial()) {
    on<StartCryptoStream>(_onStartCryptoStream);
    on<StopCryptoStream>(_onStopCryptoStream);
    on<CryptoDataUpdated>(_onCryptoDataUpdated);
  }

  Future<void> _onStartCryptoStream(
    StartCryptoStream event,
    Emitter<CryptoState> emit,
  ) async {
    try {
      emit(const CryptoLoading());
      
      await cryptoRepository.startListening();
      
      _cryptoSubscription = cryptoRepository.getCryptoStream().listen(
        (cryptos) => add(CryptoDataUpdated(cryptos)),
      );
      
    } catch (error) {
      emit(CryptoError('Failed to start crypto stream: $error'));
    }
  }

  Future<void> _onStopCryptoStream(
    StopCryptoStream event,
    Emitter<CryptoState> emit,
  ) async {
    await _cryptoSubscription?.cancel();
    _cryptoSubscription = null;
    await cryptoRepository.stopListening();
    emit(const CryptoInitial());
  }

  void _onCryptoDataUpdated(
    CryptoDataUpdated event,
    Emitter<CryptoState> emit,
  ) {
    final cryptos = event.cryptos.cast<CryptoModel>();
    emit(CryptoLoaded(
      cryptos: cryptos,
      isConnected: cryptoRepository.isConnected,
    ));
  }

  @override
  Future<void> close() {
    _cryptoSubscription?.cancel();
    cryptoRepository.dispose();
    return super.close();
  }
}