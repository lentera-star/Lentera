import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';

class SocketService {
  WebSocketChannel? _channel;
  final _controller = StreamController<dynamic>.broadcast();

  // Connect to WebSocket
  void connect(String url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    
    _channel!.stream.listen(
      (message) {
        _controller.add(message);
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket closed');
      },
    );
  }

  // Send message
  void send(dynamic message) {
    _channel?.sink.add(message);
  }

  // Get stream
  Stream<dynamic> get stream => _controller.stream;

  // Disconnect
  void disconnect() {
    _channel?.sink.close();
    _controller.close();
  }

  // Check connection status
  bool get isConnected => _channel != null;
}
