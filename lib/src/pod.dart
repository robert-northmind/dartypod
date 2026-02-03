import 'provider.dart';
import 'scope.dart';

/// The main dependency injection container.
class Pod {
  final Map<Provider, dynamic> _cache = {};
  final Map<Provider, dynamic Function(Pod)> _overrides = {};

  /// Resolves an instance from the given provider.
  ///
  /// For [SingletonScope] providers, the instance is cached and reused.
  /// For [TransientScope] providers, a new instance is created each time.
  /// For [CustomScope] providers, instances are cached per scope.
  T resolve<T>(Provider<T> provider) {
    // Check for override first
    if (_overrides.containsKey(provider)) {
      final builder = _overrides[provider]!;
      // Overrides follow the same scoping rules
      if (provider.scope is TransientScope) {
        return builder(this) as T;
      }
      if (_cache.containsKey(provider)) {
        return _cache[provider] as T;
      }
      final instance = builder(this) as T;
      _cache[provider] = instance;
      return instance;
    }

    // Transient scope always creates new instance
    if (provider.scope is TransientScope) {
      return provider.build(this);
    }

    // Check cache for singleton and custom scopes
    if (_cache.containsKey(provider)) {
      return _cache[provider] as T;
    }

    // Create and cache new instance
    final instance = provider.build(this);
    _cache[provider] = instance;
    return instance;
  }

  /// Overrides a provider with a custom builder for testing.
  void overrideProvider<T>(Provider<T> provider, T Function(Pod) builder) {
    // Clear any cached instance when overriding
    if (_cache.containsKey(provider)) {
      final instance = _cache[provider];
      provider.disposeInstance(instance as T);
      _cache.remove(provider);
    }
    _overrides[provider] = builder;
  }

  /// Removes an override for a provider.
  void removeOverride<T>(Provider<T> provider) {
    // Clear cached override instance
    if (_overrides.containsKey(provider) && _cache.containsKey(provider)) {
      final instance = _cache[provider];
      provider.disposeInstance(instance as T);
      _cache.remove(provider);
    }
    _overrides.remove(provider);
  }

  /// Clears cached instances for a scope.
  ///
  /// For hierarchical scopes, this also clears all child scopes.
  void clearScope(ProviderScope scope) {
    final toRemove = <Provider>[];

    for (final entry in _cache.entries) {
      final provider = entry.key;
      if (_scopeMatches(provider.scope, scope)) {
        provider.disposeInstance(entry.value);
        toRemove.add(provider);
      }
    }

    for (final provider in toRemove) {
      _cache.remove(provider);
    }
  }

  /// Checks if [providerScope] matches [targetScope] or is a child of it.
  bool _scopeMatches(ProviderScope providerScope, ProviderScope targetScope) {
    // Direct match
    if (identical(providerScope, targetScope)) {
      return true;
    }

    // Check if providerScope is a descendant of targetScope
    ProviderScope? current = providerScope.parent;
    while (current != null) {
      if (identical(current, targetScope)) {
        return true;
      }
      current = current.parent;
    }

    return false;
  }

  /// Disposes all cached instances and clears the cache.
  void dispose() {
    for (final entry in _cache.entries) {
      entry.key.disposeInstance(entry.value);
    }
    _cache.clear();
    _overrides.clear();
  }
}
