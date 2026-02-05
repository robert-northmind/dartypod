import 'disposable.dart';
import 'pod_resolver.dart';
import 'scope.dart';

/// A provider that knows how to create instances of type [T].
class Provider<T> {
  /// Optional debug-friendly name for diagnostics.
  final String? debugName;
  final T Function(PodResolver pod) _builder;
  final void Function(T instance)? _dispose;
  final ProviderScope scope;

  /// Creates a provider with a builder function.
  ///
  /// [builder] - Function that creates instances of [T], receiving the Pod for
  /// resolving dependencies.
  /// [debugName] - Optional name used in diagnostics (e.g. cycle errors).
  /// [scope] - Controls instance lifecycle. Defaults to [SingletonScope].
  /// [dispose] - Optional custom dispose function. If not provided and the
  /// instance implements [Disposable], its dispose method will be called.
  Provider(
    T Function(PodResolver pod) builder, {
    this.debugName,
    this.scope = const SingletonScope(),
    void Function(T)? dispose,
  })  : _builder = builder,
        _dispose = dispose;

  /// Debug-friendly label for this provider.
  ///
  /// Returns [debugName] if set, otherwise falls back to `Provider<T>`.
  String get debugLabel {
    final name = debugName;
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return 'Provider<$T>';
  }

  /// Builds a new instance using the provided pod for dependency resolution.
  T build(PodResolver pod) => _builder(pod);

  /// Disposes the given instance.
  ///
  /// If a custom dispose function was provided, it will be called.
  /// Otherwise, if the instance implements [Disposable], its dispose method
  /// will be called.
  void disposeInstance(T instance) {
    final dispose = _dispose;
    if (dispose != null) {
      dispose(instance);
    } else if (instance is Disposable) {
      instance.dispose();
    }
  }
}
