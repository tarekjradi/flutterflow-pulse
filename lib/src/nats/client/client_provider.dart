import 'package:dart_nats/dart_nats.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';

/// A singleton class for managing NATS client connections.
class ClientProvider {
  /// Private singleton instance
  static ClientProvider? _instance;

  /// The underlying NATS client instance
  static Client? _client;

  /// Static getter for accessing the NATS client
  static Client? get client => _client;

  /// Map to store active subscriptions by channel name
  final Map<String, Subscription> _subscriptions = {};

  /// Map to store the StreamSubscription for each channel
  final Map<String, StreamSubscription<Message>> _streamSubscriptions = {};

  /// Private constructor to prevent direct instantiation
  ClientProvider._();

  /// Factory constructor that returns the singleton instance
  factory ClientProvider() {
    _instance ??= ClientProvider._();
    return _instance!;
  }

  /// Initializes the NATS client connection
  Future<void> initialize({
    required String authToken,
    required List<String> servers,
    Duration timeout = const Duration(seconds: 5),
    int retryCount = 3,
    Duration retryInterval = const Duration(seconds: 30),
  }) async {
    if (_client == null) {
      _client = Client();

      // Check if there's already an active connection
      if (_client!.connected) {
        if (kDebugMode) {
          print('NATS client is already connected');
        }
        return;
      }

      // Create connection options with token auth
      final options = ConnectOption(authToken: authToken);

      // Try connecting to servers in order
      for (final serverUrl in servers) {
        try {
          await _client!.connect(
            Uri.parse(serverUrl),
            timeout: timeout.inSeconds,
            connectOption: options,
            retry: true,
            retryCount: retryCount,
            retryInterval: retryInterval.inSeconds,
          );
          if (kDebugMode) {
            print('Connected to NATS server: $serverUrl');
          }
          break;
        } catch (e) {
          if (kDebugMode) {
            print('Failed to connect to $serverUrl: $e');
          }
          if (serverUrl == servers.last) {
            throw Exception('Failed to connect to all NATS servers');
          }
          continue;
        }
      }
    }
  }

  /// Get a subscription for a channel if it exists
  Subscription? getSubscription(String channel) {
    return _subscriptions[channel];
  }

  /// Check if a subscription exists for a channel
  bool hasSubscription(String channel) {
    return _subscriptions.containsKey(channel);
  }

  /// Subscribe to a channel with a message handler
  /// Returns the subscription object
  Future<Subscription> subscribe(
      String channel, Function(Map<String, dynamic>) messageHandler) async {
    // Check if subscription already exists
    if (_subscriptions.containsKey(channel)) {
      if (kDebugMode) {
        print('Returning existing subscription for channel: $channel');
      }
      return _subscriptions[channel]!;
    }

    // Create a new subscription
    if (_client == null || !_client!.connected) {
      throw Exception('NATS client is not initialized or not connected');
    }

    final subscription = _client!.sub(channel);
    _subscriptions[channel] = subscription;

    // Set up the message handler
    final streamSubscription = subscription.stream.listen(
      (msg) {
        // Convert message bytes to string
        final messageText = String.fromCharCodes(msg.data ?? []);
        if (kDebugMode) {
          print('Raw message received on $channel: $messageText');
        }

        try {
          // Parse the message
          final messageData = json.decode(messageText) as Map<String, dynamic>;
          // Call the handler
          messageHandler(messageData);
        } catch (e) {
          if (kDebugMode) {
            print('Error processing message: $e');
          }
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print('Subscription error: $error');
        }
      },
      onDone: () {
        if (kDebugMode) {
          print('Subscription completed for channel: $channel');
        }
        _subscriptions.remove(channel);
        _streamSubscriptions.remove(channel);
      },
      cancelOnError: false,
    );

    // Store the StreamSubscription for later cancellation
    _streamSubscriptions[channel] = streamSubscription;

    if (kDebugMode) {
      print('Subscribed to: $channel');
    }

    return subscription;
  }

  /// Unsubscribe from a channel
  Future<bool> unsubscribe(String channel) async {
    if (!_subscriptions.containsKey(channel)) {
      if (kDebugMode) {
        print('No subscription found for channel: $channel');
      }
      return false;
    }

    try {
      // Cancel the stream subscription instead of calling unsubscribe
      await _streamSubscriptions[channel]!.cancel();

      // Remove from tracking maps
      _subscriptions.remove(channel);
      _streamSubscriptions.remove(channel);

      if (kDebugMode) {
        print('Unsubscribed from: $channel');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Unsubscribe error: $e');
      }
      return false;
    }
  }

  /// Unsubscribe from all channels
  Future<void> unsubscribeAll() async {
    final channels = _subscriptions.keys.toList();

    for (final channel in channels) {
      await unsubscribe(channel);
    }

    if (kDebugMode) {
      print('Unsubscribed from all channels');
    }
  }

  /// Disposes of the NATS client connection
  Future<void> dispose() async {
    // First unsubscribe from all channels
    await unsubscribeAll();

    // Then close the client
    if (_client != null) {
      try {
        await _client!.close();
        if (kDebugMode) {
          print('Disconnected from NATS Broker');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error while disconnecting: $e');
        }
        rethrow;
      }
    }
  }
}
