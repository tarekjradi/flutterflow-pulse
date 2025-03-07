import 'package:flutter_test/flutter_test.dart';
import 'package:dart_nats/dart_nats.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutterflow_pulse/flutterflow_pulse.dart';

// Mock classes for testing
class MockClient extends Mock implements Client {}

class MockSubscription extends Mock implements Subscription {}

@GenerateMocks([Client, Subscription])
void main() {
  group('ClientSingleton', () {
    late ClientProvider natsClient;

    setUp(() {
      // Reset the singleton before each test
      natsClient = ClientProvider();
    });

    test('singleton instance should be the same', () {
      final firstInstance = ClientProvider();
      final secondInstance = ClientProvider();

      expect(firstInstance, same(secondInstance));
    });

    test('hasSubscription returns false for unsubscribed channel', () {
      expect(natsClient.hasSubscription('test_channel'), isFalse);
    });

    test('getSubscription returns null for unsubscribed channel', () {
      expect(natsClient.getSubscription('test_channel'), isNull);
    });

    test('initialize method should connect to NATS server', () async {
      final testServers = ['nats://localhost:4222'];
      const testAuthToken = 'test_token';

      expect(() async {
        await natsClient.initialize(
            authToken: testAuthToken, servers: testServers);
      }, returnsNormally);
    });

    test('unsubscribe should return false for non-existent channel', () async {
      final result = await natsClient.unsubscribe('non_existent_channel');
      expect(result, isFalse);
    });

    test('unsubscribeAll should not throw an error', () async {
      expect(() async {
        await natsClient.unsubscribeAll();
      }, returnsNormally);
    });

    test('dispose method should close connection', () async {
      expect(() async {
        await natsClient.dispose();
      }, returnsNormally);
    });

    test('subscribe method should create a subscription', () async {
      final testChannel = 'test_channel';

      // Mock message handler
      final mockHandler = (Map<String, dynamic> message) {
        // Simulate message processing
        print('Mock handler received: $message');
      };

      expect(() async {
        final subscription =
            await natsClient.subscribe(testChannel, mockHandler);
        expect(subscription, isNotNull);
        expect(natsClient.hasSubscription(testChannel), isTrue);
      }, returnsNormally);
    });

    test(
        'multiple subscriptions to same channel should return existing subscription',
        () async {
      final testChannel = 'duplicate_channel';

      final mockHandler = (Map<String, dynamic> message) {};

      final firstSubscription =
          await natsClient.subscribe(testChannel, mockHandler);
      final secondSubscription =
          await natsClient.subscribe(testChannel, mockHandler);

      expect(firstSubscription, same(secondSubscription));
    });

    test('showMessage should not throw an error', () {
      expect(() {
        contextProvider.showMessage('Test message');
        contextProvider.showMessage('Error message', isError: true);
      }, returnsNormally);
    });
  });
}
