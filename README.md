# FlutterFlow Pulse

[![pub package](https://img.shields.io/pub/v/flutterflow_pulse.svg)](https://pub.dev/packages/flutterflow_pulse)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Seamlessly connect NATS JetStream listeners to your FlutterFlow UI, enabling real-time data updates and dynamic interface changes.

## Overview

FlutterFlow Pulse is a lightweight, easy-to-integrate package that brings real-time capabilities to FlutterFlow applications through NATS JetStream. Create responsive, event-driven UIs that react instantly to backend changes without complex setup.

## Features

- 🔄 **Real-time data streaming** - Connect to NATS JetStream channels with ease
- 🧩 **Plug-and-play with FlutterFlow** - Simple integration with your existing FlutterFlow projects
- 🔌 **Reliable connection management** - Automatic reconnection and subscription handling
- 🛡️ **Type-safe message handling** - Process different message types with dedicated handlers
- 📱 **Context-aware updates** - Update your UI based on the current app state and screen

## Installation

```yaml
dependencies:
  flutterflow_pulse: ^0.0.1
```

Run this command:

```bash
flutter pub get
```

## Quick Start

### 1. Initialize the connection

```dart
import 'package:flutterflow_pulse/flutterflow_pulse.dart';

Future<void> initializeNatsConnection() async {
  await ClientProvider().initialize(
    authToken: 'your_auth_token',
    servers: ['nats://your-server:4222'],
  );
  
  // Initialize the context provider for UI updates
  await initializeContextProvider();
}
```

### 2. Set up context in your main widget

```dart
@override
Widget build(BuildContext context) {
  // Make sure to set context in your main navigation scaffold
  setCurrentContext(context, pageName: 'HomePage');
  
  return Scaffold(
    // Your app content
  );
}
```

### 3. Create a message handler

```dart
import 'package:flutter/material.dart';
import 'package:flutterflow_pulse/flutterflow_pulse.dart';

class UpdateUIHandler implements MessageHandlerInterface {
  @override
  void handle(BuildContext context, Map<String, dynamic> messageData) {
    // Extract data from the message
    final String? message = messageData['message'] as String?;
    
    if (message != null) {
      // Update UI using the context
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
```

### 4. Register handler and subscribe to a channel

```dart
void setupRealTimeUpdates() {
  // Register handlers for different message types
  SubscriptionService().registerHandler('update_ui', UpdateUIHandler());
  
  // Subscribe to a channel
  SubscriptionService().subscribeToChannel('app.updates');
}
```

## Advanced Usage

### Custom Authentication Validation

```dart
await SubscriptionService().subscribeToChannel(
  'secure.channel',
  authValidator: (token) {
    // Implement custom validation logic
    return token != null && token.isNotEmpty;
  },
);
```

### Creating Custom Handlers

Implement the `MessageHandlerInterface` to create custom handlers for different message types:

```dart
class NavigationHandler implements MessageHandlerInterface {
  @override
  void handle(BuildContext context, Map<String, dynamic> messageData) {
    final String? route = messageData['route'] as String?;
    final Map<String, dynamic>? params = 
        messageData['params'] as Map<String, dynamic>?;
    
    if (route != null) {
      contextProvider.navigateTo(route, queryParameters: params);
    }
  }
}
```

### Unsubscribing

```dart
// Unsubscribe from a specific channel
await SubscriptionService().unsubscribeFromChannel('app.updates');

// Unsubscribe from all channels (e.g., when logging out)
await SubscriptionService().unsubscribeFromAllChannels();
```

## Architecture

![Class Diagram](https://github.com/tarekjradi/flutterflow-pulse/blob/main/class-diagram.png)

The package follows a modular design pattern:

- **ClientProvider**: Manages the NATS connection and subscription lifecycle
- **ContextProvider**: Provides context-aware UI updates
- **SubscriptionService**: Handles channel subscriptions and message routing
- **MessageHandler**: Delegates incoming messages to the appropriate handlers

## Example

A complete example is available in the [example](https://github.com/tarekjradi/flutterflow-pulse/tree/main/example) directory.

## FlutterFlow Integration

To integrate with FlutterFlow:

1. Add the package as a dependency in your FlutterFlow project
2. Add the initialization code to your app's startup
3. Set up context providers in your main navigation pages
4. Create custom actions in FlutterFlow to subscribe to channels

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.