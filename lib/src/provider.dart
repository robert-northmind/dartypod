import 'disposable.dart';
import 'pod_resolver.dart';
import 'scope.dart';

/// A provider that knows how to create instances of type [T].
class Provider<T> {
  final T Function(PodResolver pod) _builder;
  final void Function(T instance)? _dispose;
  final ProviderScope scope;

  /// Creates a provider with a builder function.
  ///
  /// [builder] - Function that creates instances of [T], receiving the Pod for
  /// resolving dependencies.
  /// [scope] - Controls instance lifecycle. Defaults to [SingletonScope].
  /// [dispose] - Optional custom dispose function. If not provided and the
  /// instance implements [Disposable], its dispose method will be called.
  Provider(
    T Function(PodResolver pod) builder, {
    this.scope = const SingletonScope(),
    void Function(T)? dispose,
  })  : _builder = builder,
        _dispose = dispose;

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
