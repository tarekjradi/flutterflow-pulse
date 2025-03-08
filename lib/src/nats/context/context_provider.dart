import 'package:flutter/material.dart';

/// A singleton to manage and provide access to the BuildContext across the app
class ContextProvider {
  // Singleton instance
  static final ContextProvider _instance = ContextProvider._internal();

  // Factory constructor
  factory ContextProvider() {
    return _instance;
  }

  // Private constructor
  ContextProvider._internal();

  // Store the current context
  BuildContext? _currentContext;

  // Current page name - useful for tracking which page we're on
  String? _currentPageName;

  // Setter for the context
  void setContext(BuildContext context, {String? pageName}) {
    _currentContext = context;
    if (pageName != null) {
      _currentPageName = pageName;
    }
  }

  // Getter for the context
  BuildContext? get context => _currentContext;

  // Getter for the current page name
  String? get currentPageName => _currentPageName;

  // Check if we have a valid context
  bool get hasValidContext =>
      _currentContext != null && _currentContext!.mounted;

  /// Show a message using the current context
  void showMessage(String message, {bool isError = false}) {
    if (hasValidContext) {
      ScaffoldMessenger.of(_currentContext!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      debugPrint('Message (no context): $message');
    }
  }

  /// Navigate to a named route using the current context
  void navigateTo(String routeName, {Map<String, dynamic>? queryParameters}) {
    if (hasValidContext) {
      /* Uncomment and modify based on your navigation library
      _currentContext!.pushNamed(
        routeName,
        queryParameters: queryParameters ?? {},
      );
      */
      debugPrint('Navigating to: $routeName');
    } else {
      debugPrint('Cannot navigate to "$routeName" - no valid context');
    }
  }
}

// Easy access to the singleton
final ContextProvider contextProvider = ContextProvider();

// Helper method to set the context from any widget
void setCurrentContext(BuildContext context, {String? pageName}) {
  contextProvider.setContext(context, pageName: pageName);
}

// Get the current context from anywhere
BuildContext? getCurrentContext() {
  return contextProvider.context;
}

// Initialize the context provider (call this in main.dart)
Future<void> initializeContextProvider() async {
  debugPrint('Context Provider initialized');
}
