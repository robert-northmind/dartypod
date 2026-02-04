import 'package:dartypod/dartypod.dart';
import 'package:test/test.dart';

class MockService {
  final String name;
  MockService(this.name);
}

class DisposableService implements Disposable {
  bool disposed = false;

  @override
  void dispose() {
    disposed = true;
  }
}

void main() {
  group('Provider', () {
    test('creates instance using builder', () {
      final provider = Provider<MockService>((pod) => MockService('test'));
      final pod = Pod();

      final instance = provider.build(pod);

      expect(instance, isA<MockService>());
      expect(instance.name, equals('test'));
    });

    test('defaults to SingletonScope', () {
      final provider = Provider<MockService>((pod) => MockService('test'));

      expect(provider.scope, isA<SingletonScope>());
    });

    test('accepts custom scope', () {
      final customScope = CustomScope('custom');
      final provider = Provider<MockService>(
        (pod) => MockService('test'),
        scope: customScope,
      );

      expect(provider.scope, equals(customScope));
    });

    test('disposeInstance calls Disposable.dispose', () {
      final provider =
          Provider<DisposableService>((pod) => DisposableService());
      final instance = DisposableService();

      provider.disposeInstance(instance);

      expect(instance.disposed, isTrue);
    });

    test('disposeInstance calls custom dispose function', () {
      var customDisposeCallled = false;
      final provider = Provider<MockService>(
        (pod) => MockService('test'),
        dispose: (instance) => customDisposeCallled = true,
      );
      final instance = MockService('test');

      provider.disposeInstance(instance);

      expect(customDisposeCallled, isTrue);
    });

    test('custom dispose takes precedence over Disposable', () {
      var customDisposeCalled = false;
      final provider = Provider<DisposableService>(
        (pod) => DisposableService(),
        dispose: (instance) => customDisposeCalled = true,
      );
      final instance = DisposableService();

      provider.disposeInstance(instance);

      expect(customDisposeCalled, isTrue);
      expect(instance.disposed, isFalse);
    });

    test(
        'disposeInstance does nothing for non-Disposable without custom dispose',
        () {
      final provider = Provider<MockService>((pod) => MockService('test'));
      final instance = MockService('test');

      // Should not throw
      provider.disposeInstance(instance);
    });
  });
}
