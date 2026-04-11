import '../datasources/crypto_websocket_service.dart';
import '../models/crypto_model.dart';

class CryptoRepository {
  final CryptoWebSocketService _webSocketService;

  CryptoRepository() : _webSocketService = CryptoWebSocketService();

  Stream<List<CryptoModel>> getCryptoStream() {
    return _webSocketService.cryptoStream;
  }

  Future<void> startListening({List<String>? symbols}) async {
    await _webSocketService.connect(symbols: symbols);
  }

  Future<void> stopListening() async {
    await _webSocketService.disconnect();
  }

  bool get isConnected => _webSocketService.isConnected;

  void dispose() {
    _webSocketService.dispose();
  }
}