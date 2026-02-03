/// Interface for objects that require cleanup when no longer needed.
abstract class Disposable {
  /// Releases any resources held by this object.
  void dispose();
}
