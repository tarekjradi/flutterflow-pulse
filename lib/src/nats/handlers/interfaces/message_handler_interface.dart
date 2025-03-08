import 'package:flutter/material.dart';

/// Interface for message handlers
abstract class MessageHandlerInterface {
  /// Handle a specific message type
  void handle(BuildContext context, Map<String, dynamic> messageData);
}
