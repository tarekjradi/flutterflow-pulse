import 'package:flutter/foundation.dart';
import '../client/client_provider.dart';
import '../handlers/message_handler.dart';
import '../handlers/interfaces/message_handler_interface.dart';

/// SubscriptionService handles subscribing to channels
/// and delegates message processing.
class SubscriptionService {
  /// Singleton instance
  static final SubscriptionService _instance = SubscriptionService._internal();

  /// Factory constructor
  factory SubscriptionService() {
    return _instance;
  }

  /// Private constructor
  SubscriptionService._internal() {
    // Initialize the message handler
    _messageHandler = MessageHandler();
  }

  /// The message handler instance
  late MessageHandler _messageHandler;

  /// Register a specific handler for a function type
  void registerHandler(String functionType, MessageHandlerInterface handler) {
    _messageHandler.registerHandler(functionType, handler);
  }

  /// Subscribes to a channel using the singleton pattern.
  /// This ensures only one subscription exists per channel.
  ///
  /// Returns a Map with status information and the subscription if successful.
  Future<Map<String, dynamic>> subscribeToChannel(
    String channel, {
    bool Function(String? authToken)? authValidator,
  }) async {
    try {
      // Optional custom auth validation
      if (authValidator != null) {
        final authToken = authValidator(null); // Implement your auth check
        if (!authToken) {
          return {
            'status': 'error',
            'error': 'Authentication failed',
          };
        }
      }

      // Check if we already have a subscription for this channel
      if (ClientProvider().hasSubscription(channel)) {
        return {
          'status': 'already_subscribed',
          'subject': channel,
          'subscription': ClientProvider().getSubscription(channel),
        };
      }

      // Create a new subscription with message handling
      final subscription = await ClientProvider().subscribe(
        channel,
        (messageData) => _messageHandler.processMessage(messageData),
      );

      return {
        'status': 'subscribed',
        'subject': channel,
        'subscription': subscription,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Subscribe error: $e');
      }
      return {
        'status': 'error',
        'error': e.toString(),
      };
    }
  }

  /// Unsubscribes from a specific channel
  Future<bool> unsubscribeFromChannel(String channel) async {
    return await ClientProvider().unsubscribe(channel);
  }

  /// Unsubscribes from all channels
  Future<void> unsubscribeFromAllChannels() async {
    await ClientProvider().unsubscribeAll();
  }
}

/// The public function that FlutterFlow will call
Future<dynamic> subscribeChannel(String channel) async {
  return await SubscriptionService().subscribeToChannel(channel);
}
