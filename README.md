# dartypod

A minimal Service Locator with compile-time safe provider references, enabling clean dependency injection patterns in Dart.

Dartypod provides compile-time safe dependency injection through provider references rather than runtime type lookup.

## Features

- **Zero dependencies** - No external runtime dependencies
- **Compile-time safety** - Provider references instead of runtime type lookup
- **Flexible scoping** - Singleton, transient, and custom hierarchical scopes
- **Easy testing** - Built-in override support for mocking
- **Automatic disposal** - Supports `Disposable` interface and custom dispose callbacks

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  dartypod: ^0.1.0
```

Then run:

```bash
dart pub get
```

## Usage

### Define Providers

```dart
import 'package:dartypod/dartypod.dart';

// Simple provider (singleton by default)
final httpClientProvider = Provider<HttpClient>(
  (_) => HttpClientImpl(),
);

// Provider with dependency
final apiServiceProvider = Provider<ApiService>(
  (pod) => ApiServiceImpl(
    client: pod.resolve(httpClientProvider),
  ),
);
```

### Resolve Dependencies

```dart
void main() {
  final pod = Pod();

  final apiService = pod.resolve(apiServiceProvider);
  // Use apiService...

  // Don't forget to dispose when done
  pod.dispose();
}
```

### Scopes

#### Singleton (default)

Instances are cached and reused:

```dart
final provider = Provider<MyService>((pod) => MyService());
// Same instance returned every time
```

#### Transient

New instance created every time:

```dart
final provider = Provider<MyService>(
  (pod) => MyService(),
  scope: const TransientScope(),
);
// Different instance each time
```

#### Custom Scopes

Create hierarchical scopes for advanced use cases:

```dart
const sessionScope = CustomScope('session');
const requestScope = CustomScope('request', parent: sessionScope);

final sessionProvider = Provider<SessionData>(
  (pod) => SessionData(),
  scope: sessionScope,
);

// Clear a scope (also clears child scopes)
pod.clearScope(sessionScope);
```

### Testing with Overrides

```dart
void main() {
  final pod = Pod();

  // Override with mock
  pod.overrideProvider(httpClientProvider, (_) => MockHttpClient());

  // Now apiService uses MockHttpClient
  final apiService = pod.resolve(apiServiceProvider);

  // Remove override to restore original
  pod.removeOverride(httpClientProvider);
}
```

### Disposal

Implement `Disposable` for automatic cleanup:

```dart
class MyService implements Disposable {
  @override
  void dispose() {
    // Cleanup resources
  }
}
```

Or provide a custom dispose callback:

```dart
final provider = Provider<MyService>(
  (pod) => MyService(),
  dispose: (instance) => instance.close(),
);
```

Call `pod.dispose()` to clean up all cached instances.

## API Reference

### Pod

- `resolve<T>(Provider<T> provider)` - Get instance from provider
- `overrideProvider<T>(provider, builder)` - Override for testing
- `removeOverride<T>(provider)` - Remove override
- `clearScope(scope)` - Clear cached instances for scope
- `dispose()` - Dispose all cached instances

### Provider<T>

- `Provider(builder, {scope, dispose})` - Create a provider
- `build(pod)` - Build new instance (used internally)
- `disposeInstance(instance)` - Dispose instance (used internally)

### ProviderScope

- `SingletonScope` - Cache and reuse (default)
- `TransientScope` - Always create new
- `CustomScope(name, {parent})` - Custom with optional hierarchy

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for how to get started.

## License

MIT
