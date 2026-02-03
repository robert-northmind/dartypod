/// Base class for provider scopes that control instance lifecycle.
abstract class ProviderScope {
  const ProviderScope();

  /// The name of this scope for identification.
  String get name;

  /// The parent scope, if any. Used for hierarchical scope clearing.
  ProviderScope? get parent => null;
}

/// Singleton scope - instances are cached and reused.
class SingletonScope extends ProviderScope {
  const SingletonScope();

  @override
  String get name => 'singleton';
}

/// Transient scope - a new instance is created on every resolve.
class TransientScope extends ProviderScope {
  const TransientScope();

  @override
  String get name => 'transient';
}

/// Custom scope with optional parent for hierarchical relationships.
class CustomScope extends ProviderScope {
  final String _name;
  final ProviderScope? _parent;

  const CustomScope(this._name, {ProviderScope? parent}) : _parent = parent;

  @override
  String get name => _name;

  @override
  ProviderScope? get parent => _parent;
}
