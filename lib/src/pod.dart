import 'errors.dart';
import 'pod_resolver.dart';
import 'provider.dart';
import 'scope.dart';

/// The main dependency injection container.
class Pod implements PodResolver {
  final Map<Provider<Object?>, Object?> _cache = {};
  final Map<Provider<Object?>, Object? Function(Pod)> _overrides = {};
  final List<Provider<Object?>> _resolvingStack = [];
  final Set<Provider<Object?>> _resolvingSet = {};

  /// Resolves an instance from the given provider.
  ///
  /// For [SingletonScope] providers, the instance is cached and reused.
  /// For [TransientScope] providers, a new instance is created each time.
  /// For [CustomScope] providers, instances are cached per scope.
  ///
  /// Throws [PodCycleError] if a circular dependency is detected.
  @override
  T resolve<T>(Provider<T> provider) {
    // Check for override first
    if (_overrides.containsKey(provider)) {
      final builder = _overrides[provider]!;
      // Overrides follow the same scoping rules
      if (provider.scope is TransientScope) {
        return _buildWithCycleCheck(provider, () => builder(this) as T);
      }
      if (_cache.containsKey(provider)) {
        return _cache[provider] as T;
      }
      final instance = _buildWithCycleCheck(provider, () => builder(this) as T);
      _cache[provider] = instance;
      return instance;
    }

    // Transient scope always creates new instance
    if (provider.scope is TransientScope) {
      return _buildWithCycleCheck(provider, () => provider.build(this));
    }

    // Check cache for singleton and custom scopes
    if (_cache.containsKey(provider)) {
      return _cache[provider] as T;
    }

    // Create and cache new instance
    final instance = _buildWithCycleCheck(provider, () => provider.build(this));
    _cache[provider] = instance;
    return instance;
  }

  T _buildWithCycleCheck<T>(Provider<T> provider, T Function() build) {
    final resolvingProvider = provider as Provider<Object?>;
    if (_resolvingSet.contains(resolvingProvider)) {
      throw _createCycleError(resolvingProvider);
    }

    _resolvingSet.add(resolvingProvider);
    _resolvingStack.add(resolvingProvider);

    try {
      return build();
    } finally {
      _resolvingStack.removeLast();
      _resolvingSet.remove(resolvingProvider);
    }
  }

  PodCycleError _createCycleError(Provider<Object?> provider) {
    final startIndex = _resolvingStack.indexOf(provider);
    if (startIndex == -1) {
      return PodCycleError([..._resolvingStack, provider]);
    }
    return PodCycleError([..._resolvingStack.sublist(startIndex), provider]);
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
    final toRemove = <Provider<Object?>>[];
    // Memoize scope match results to avoid repeated parent chain traversals
    // when multiple providers share the same scope.
    final scopeMatchCache = <ProviderScope, bool>{};

    for (final entry in _cache.entries) {
      final provider = entry.key;
      final providerScope = provider.scope;

      // Check cache first, compute only if needed
      final matches = scopeMatchCache[providerScope] ??=
          _scopeMatches(providerScope, scope);

      if (matches) {
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
