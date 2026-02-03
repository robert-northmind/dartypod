import 'package:dartypod/dartypod.dart';

// Example services
abstract class HttpClient {
  String get(String url);
}

class HttpClientImpl implements HttpClient, Disposable {
  bool _disposed = false;

  @override
  String get(String url) {
    if (_disposed) throw StateError('HttpClient has been disposed');
    return 'Response from $url';
  }

  @override
  void dispose() {
    _disposed = true;
    print('HttpClient disposed');
  }
}

class MockHttpClient implements HttpClient {
  @override
  String get(String url) => 'Mock response from $url';
}

abstract class ApiService {
  String fetchUser(int id);
}

class ApiServiceImpl implements ApiService {
  final HttpClient client;

  ApiServiceImpl({required this.client});

  @override
  String fetchUser(int id) {
    return client.get('/api/users/$id');
  }
}

// Define providers (typically top-level constants)
final httpClientProvider = Provider<HttpClient>(
  (pod) => HttpClientImpl(),
);

final apiServiceProvider = Provider<ApiService>(
  (pod) => ApiServiceImpl(
    client: pod.resolve(httpClientProvider),
  ),
);

// Example with transient scope
final requestIdProvider = Provider<String>(
  (pod) => DateTime.now().millisecondsSinceEpoch.toString(),
  scope: const TransientScope(),
);

// Example with custom scope
const sessionScope = CustomScope('session');

final sessionDataProvider = Provider<Map<String, dynamic>>(
  (pod) => <String, dynamic>{},
  scope: sessionScope,
);

void main() {
  print('=== Basic Usage ===\n');

  final pod = Pod();

  // Resolve dependencies
  final apiService = pod.resolve(apiServiceProvider);
  print('User data: ${apiService.fetchUser(1)}');

  // Singleton behavior - same instance returned
  final apiService2 = pod.resolve(apiServiceProvider);
  print('Same instance: ${identical(apiService, apiService2)}');

  print('\n=== Transient Scope ===\n');

  // Transient scope - new instance each time
  final requestId1 = pod.resolve(requestIdProvider);
  final requestId2 = pod.resolve(requestIdProvider);
  print('Request ID 1: $requestId1');
  print('Request ID 2: $requestId2');
  print('Different instances: ${requestId1 != requestId2}');

  print('\n=== Testing with Overrides ===\n');

  // Create a fresh pod for testing
  final testPod = Pod();

  // Override for testing
  testPod.overrideProvider(httpClientProvider, (_) => MockHttpClient());

  final testApiService = testPod.resolve(apiServiceProvider);
  print('Mock response: ${testApiService.fetchUser(1)}');

  // For a fresh pod without overrides, use a new Pod instance
  // (This is the typical pattern - use separate Pod per test)
  final freshPod = Pod();
  final realApiService = freshPod.resolve(apiServiceProvider);
  print('Real response: ${realApiService.fetchUser(1)}');
  freshPod.dispose();

  print('\n=== Custom Scopes ===\n');

  final scopedPod = Pod();

  // Session data persists within scope
  final sessionData1 = scopedPod.resolve(sessionDataProvider);
  sessionData1['userId'] = 42;

  final sessionData2 = scopedPod.resolve(sessionDataProvider);
  print('Session data preserved: ${sessionData2['userId']}');

  // Clear scope to reset
  scopedPod.clearScope(sessionScope);
  final sessionData3 = scopedPod.resolve(sessionDataProvider);
  print('After clear, userId: ${sessionData3['userId']}');

  print('\n=== Disposal ===\n');

  // Dispose all cached instances
  pod.dispose();
  print('Pod disposed - all cached instances cleaned up');

  testPod.dispose();
  scopedPod.dispose();
}
