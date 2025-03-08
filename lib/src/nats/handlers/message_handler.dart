import 'package:flutter/foundation.dart';
import '../context/context_provider.dart';
import '../handlers/interfaces/message_handler_interface.dart';

/// MessageHandler is responsible for processing incoming messages
/// and delegating to the appropriate specialized handlers.
class MessageHandler {
  // Singleton instance of message handler types
  final Map<String, MessageHandlerInterface> _handlers = {};

  /// Register a handler for a specific message type
  void registerHandler(String type, MessageHandlerInterface handler) {
    _handlers[type] = handler;
  }

  /// Process incoming messages based on their function type
  void processMessage(Map<String, dynamic> messageData) {
    // Check for valid context
    final context = contextProvider.context;
    if (context == null || !contextProvider.hasValidContext) {
      if (kDebugMode) {
        print('No valid context available for handling message');
      }
      return;
    }

    // Extract the action type from the message
    final String? function = messageData['function'] as String?;
    if (function == null) {
      if (kDebugMode) {
        print('Message missing function field');
      }
      return;
    }

    // Find and execute the appropriate handler
    final handler = _handlers[function];
    if (handler != null) {
      try {
        handler.handle(context, messageData);
      } catch (e) {
        if (kDebugMode) {
          print('Error processing message for function $function: $e');
        }
        contextProvider.showMessage('Error processing message', isError: true);
      }
    } else {
      if (kDebugMode) {
        print('No handler found for function type: $function');
      }
      contextProvider.showMessage('Unknown message type', isError: true);
    }
  }
}
