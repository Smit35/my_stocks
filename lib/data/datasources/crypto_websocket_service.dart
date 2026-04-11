import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/crypto_model.dart';

class CryptoWebSocketService {
  WebSocketChannel? _channel;
  final StreamController<List<CryptoModel>> _cryptoStreamController = StreamController<List<CryptoModel>>.broadcast();
  final Map<String, CryptoModel> _cryptoData = {};
  bool _isConnected = false;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  int _reconnectAttempts = 0;
  
  static const String _coinbaseProWsUrl = 'wss://ws-feed.exchange.coinbase.com';
  // Only use symbols that are actually available on Coinbase Pro
  static const List<String> _defaultSymbols = [
    'BTC-USD',
    'ETH-USD',
    'USDT-USD',
    'XRP-USD',
    'USDC-USD',
    'SOL-USD',
    'DOGE-USD',
    'ADA-USD',
    'LINK-USD',
    'DOT-USD',
  ];

  Stream<List<CryptoModel>> get cryptoStream => _cryptoStreamController.stream;

  bool get isConnected => _isConnected;

  Future<void> connect({List<String>? symbols}) async {
    try {
      await disconnect();
      
      log('Connecting to Coinbase Pro WebSocket...');
      _channel = WebSocketChannel.connect(
        Uri.parse(_coinbaseProWsUrl),
        protocols: ['wss'],
      );
      
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleConnectionClosed,
      );

      // Wait a moment for connection to establish
      await Future.delayed(const Duration(milliseconds: 500));

      final subscribeMessage = {
        'type': 'subscribe',
        'product_ids': symbols ?? _defaultSymbols,
        'channels': [
          'ticker',
        ],
      };

      _channel!.sink.add(jsonEncode(subscribeMessage));
      _isConnected = true;
      _reconnectAttempts = 0;
      
      // Start ping timer to keep connection alive
      _startPingTimer();
      
      log('Crypto WebSocket connected and subscribed to Coinbase Pro');
    } catch (e) {
      log('Error connecting to crypto WebSocket: $e');
      _isConnected = false;
      _scheduleReconnect();
    }
  }
  
  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _channel != null) {
        try {
          _channel!.sink.add(jsonEncode({'type': 'heartbeat'}));
        } catch (e) {
          log('Error sending ping: $e');
          _handleConnectionClosed();
        }
      }
    });
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      
      if (data['type'] == 'ticker') {
        final productId = data['product_id'] as String;
        final crypto = CryptoModel.fromCoinbaseProTicker(data, productId);
        
        _cryptoData[productId] = crypto;
        
        // Maintain display order
        final preferredOrder = ['BTC', 'ETH', 'USDT', 'XRP', 'USDC', 'SOL', 'DOGE', 'ADA', 'LINK', 'DOT'];
        final cryptoList = <CryptoModel>[];
        
        // Add available cryptos in preferred order
        for (final symbol in preferredOrder) {
          final crypto = _cryptoData.values.where((c) => c.symbol == symbol).firstOrNull;
          if (crypto != null) {
            cryptoList.add(crypto);
          }
        }
        
        // Add any remaining cryptos that aren't in the preferred order
        for (final crypto in _cryptoData.values) {
          if (!preferredOrder.contains(crypto.symbol)) {
            cryptoList.add(crypto);
          }
        }
        
        _cryptoStreamController.add(cryptoList);
        
        log('Updated ${crypto.symbol}: ${crypto.formattedPrice}');
      } else if (data['type'] == 'subscriptions') {
        log('Subscribed to channels: ${data['channels']}');
      } else if (data['type'] == 'error') {
        log('WebSocket error: ${data['message']}');
      }
    } catch (e) {
      log('Error parsing WebSocket message: $e');
    }
  }

  void _handleError(dynamic error) {
    log('WebSocket error: $error');
    _isConnected = false;
    _scheduleReconnect();
  }

  void _handleConnectionClosed() {
    log('WebSocket connection closed');
    _isConnected = false;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    
    _reconnectAttempts++;
    final delay = Duration(seconds: (2 * _reconnectAttempts).clamp(2, 30));
    
    _reconnectTimer = Timer(delay, () {
      if (!_isConnected && _reconnectAttempts < 10) {
        log('Attempting to reconnect... (attempt ${_reconnectAttempts})');
        connect();
      } else if (_reconnectAttempts >= 10) {
        log('Max reconnection attempts reached. Stopped trying.');
        _reconnectAttempts = 0;
      }
    });
  }

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _isConnected = false;
    
    if (_channel != null) {
      try {
        await _channel!.sink.close();
      } catch (e) {
        log('Error closing WebSocket: $e');
      }
      _channel = null;
    }
    
    log('Crypto WebSocket disconnected');
  }

  void dispose() {
    disconnect();
    _cryptoStreamController.close();
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
  }
}