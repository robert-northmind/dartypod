import 'provider.dart';

/// Abstract interface for resolving dependencies.
///
/// This interface is implemented by [Pod] and can be used in provider
/// builders to resolve other dependencies while maintaining type safety.
abstract class PodResolver {
  /// Resolves an instance from the given provider.
  T resolve<T>(Provider<T> provider);
}
