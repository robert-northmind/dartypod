import 'provider.dart';

/// Error thrown when a circular dependency is detected during resolution.
class PodCycleError implements Exception {
  /// The cycle chain, including the provider that closed the loop.
  final List<Provider<Object?>> cycle;

  PodCycleError(List<Provider<Object?>> cycle)
      : cycle = List<Provider<Object?>>.unmodifiable(cycle);

  /// Human-readable provider names in the cycle chain.
  List<String> get chain =>
      cycle.map((provider) => provider.debugLabel).toList(growable: false);

  @override
  String toString() =>
      'PodCycleError: Circular dependency detected: ${chain.join(' -> ')}';
}
