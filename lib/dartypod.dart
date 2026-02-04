/// A minimal Service Locator with compile-time safe provider references,
/// enabling clean dependency injection patterns in Dart.
///
/// Dartypod provides compile-time safe dependency injection through provider
/// references rather than runtime type lookup.
///
/// ## Basic Usage
///
/// ```dart
/// // Define providers
/// final httpClientProvider = Provider<HttpClient>((pod) => HttpClientImpl());
///
/// final apiServiceProvider = Provider<ApiService>((pod) {
///   return ApiServiceImpl(client: pod.resolve(httpClientProvider));
/// });
///
/// // Resolve dependencies
/// final pod = Pod();
/// final apiService = pod.resolve(apiServiceProvider);
/// ```
///
/// ## Testing with Overrides
///
/// ```dart
/// final pod = Pod();
/// pod.overrideProvider(httpClientProvider, (_) => MockHttpClient());
/// final apiService = pod.resolve(apiServiceProvider); // Uses mock
/// ```
library;

export 'src/disposable.dart';
export 'src/pod.dart';
export 'src/pod_resolver.dart';
export 'src/provider.dart';
export 'src/scope.dart';
