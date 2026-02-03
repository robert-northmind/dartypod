import 'package:dartypod/dartypod.dart';
import 'package:test/test.dart';

class SimpleService {
  static int instanceCount = 0;
  final int id;

  SimpleService() : id = ++instanceCount;

  static void resetCount() => instanceCount = 0;
}

class DependentService {
  final SimpleService dependency;
  DependentService(this.dependency);
}

class DisposableService implements Disposable {
  bool disposed = false;

  @override
  void dispose() {
    disposed = true;
  }
}

void main() {
  setUp(() {
    SimpleService.resetCount();
  });

  group('Pod.resolve', () {
    test('creates instance from provider', () {
      final pod = Pod();
      final provider = Provider<SimpleService>((pod) => SimpleService());

      final instance = pod.resolve(provider);

      expect(instance, isA<SimpleService>());
    });

    test('caches singleton instances', () {
      final pod = Pod();
      final provider = Provider<SimpleService>((pod) => SimpleService());

      final instance1 = pod.resolve(provider);
      final instance2 = pod.resolve(provider);

      expect(identical(instance1, instance2), isTrue);
      expect(SimpleService.instanceCount, equals(1));
    });

    test('creates new instance each time for transient scope', () {
      final pod = Pod();
      final provider = Provider<SimpleService>(
        (pod) => SimpleService(),
        scope: const TransientScope(),
      );

      final instance1 = pod.resolve(provider);
      final instance2 = pod.resolve(provider);

      expect(identical(instance1, instance2), isFalse);
      expect(SimpleService.instanceCount, equals(2));
    });

    test('caches custom scope instances', () {
      final pod = Pod();
      const customScope = CustomScope('request');
      final provider = Provider<SimpleService>(
        (pod) => SimpleService(),
        scope: customScope,
      );

      final instance1 = pod.resolve(provider);
      final instance2 = pod.resolve(provider);

      expect(identical(instance1, instance2), isTrue);
    });

    test('resolves dependencies', () {
      final pod = Pod();
      final simpleProvider = Provider<SimpleService>((pod) => SimpleService());
      final dependentProvider = Provider<DependentService>(
        (pod) => DependentService(pod.resolve(simpleProvider)),
      );

      final dependent = pod.resolve(dependentProvider);

      expect(dependent.dependency, isA<SimpleService>());
    });

    test('shares singleton across dependent providers', () {
      final pod = Pod();
      final simpleProvider = Provider<SimpleService>((pod) => SimpleService());
      final dependent1Provider = Provider<DependentService>(
        (pod) => DependentService(pod.resolve(simpleProvider)),
      );
      final dependent2Provider = Provider<DependentService>(
        (pod) => DependentService(pod.resolve(simpleProvider)),
      );

      final dependent1 = pod.resolve(dependent1Provider);
      final dependent2 = pod.resolve(dependent2Provider);

      expect(identical(dependent1.dependency, dependent2.dependency), isTrue);
      expect(SimpleService.instanceCount, equals(1));
    });
  });

  group('Pod.overrideProvider', () {
    test('uses override builder instead of original', () {
      final pod = Pod();
      final provider = Provider<SimpleService>((pod) => SimpleService());
      final mockService = SimpleService();

      pod.overrideProvider(provider, (_) => mockService);
      final instance = pod.resolve(provider);

      expect(identical(instance, mockService), isTrue);
    });

    test('override affects dependent providers', () {
      final pod = Pod();
      final simpleProvider = Provider<SimpleService>((pod) => SimpleService());
      final dependentProvider = Provider<DependentService>(
        (pod) => DependentService(pod.resolve(simpleProvider)),
      );
      final mockService = SimpleService();

      pod.overrideProvider(simpleProvider, (_) => mockService);
      final dependent = pod.resolve(dependentProvider);

      expect(identical(dependent.dependency, mockService), isTrue);
    });

    test('override caches for singleton scope', () {
      final pod = Pod();
      var callCount = 0;
      final provider = Provider<SimpleService>((pod) => SimpleService());

      pod.overrideProvider(provider, (_) {
        callCount++;
        return SimpleService();
      });

      pod.resolve(provider);
      pod.resolve(provider);

      expect(callCount, equals(1));
    });

    test('override creates new instance for transient scope', () {
      final pod = Pod();
      var callCount = 0;
      final provider = Provider<SimpleService>(
        (pod) => SimpleService(),
        scope: const TransientScope(),
      );

      pod.overrideProvider(provider, (_) {
        callCount++;
        return SimpleService();
      });

      pod.resolve(provider);
      pod.resolve(provider);

      expect(callCount, equals(2));
    });

    test('disposes existing cached instance when overriding', () {
      final pod = Pod();
      final provider = Provider<DisposableService>((pod) => DisposableService());

      final original = pod.resolve(provider);
      pod.overrideProvider(provider, (_) => DisposableService());

      expect(original.disposed, isTrue);
    });
  });

  group('Pod.removeOverride', () {
    test('reverts to original builder', () {
      final pod = Pod();
      final provider = Provider<SimpleService>((pod) => SimpleService());
      final mockService = SimpleService();

      pod.overrideProvider(provider, (_) => mockService);
      pod.removeOverride(provider);
      final instance = pod.resolve(provider);

      expect(identical(instance, mockService), isFalse);
    });

    test('disposes cached override instance', () {
      final pod = Pod();
      final provider = Provider<DisposableService>((pod) => DisposableService());

      pod.overrideProvider(provider, (_) => DisposableService());
      final overrideInstance = pod.resolve(provider);
      pod.removeOverride(provider);

      expect(overrideInstance.disposed, isTrue);
    });

    test('does nothing if no override exists', () {
      final pod = Pod();
      final provider = Provider<SimpleService>((pod) => SimpleService());

      // Should not throw
      pod.removeOverride(provider);
    });
  });

  group('Pod.clearScope', () {
    test('clears cached instances for scope', () {
      final pod = Pod();
      const customScope = CustomScope('request');
      final provider = Provider<SimpleService>(
        (pod) => SimpleService(),
        scope: customScope,
      );

      final instance1 = pod.resolve(provider);
      pod.clearScope(customScope);
      final instance2 = pod.resolve(provider);

      expect(identical(instance1, instance2), isFalse);
    });

    test('disposes cleared instances', () {
      final pod = Pod();
      const customScope = CustomScope('request');
      final provider = Provider<DisposableService>(
        (pod) => DisposableService(),
        scope: customScope,
      );

      final instance = pod.resolve(provider);
      pod.clearScope(customScope);

      expect(instance.disposed, isTrue);
    });

    test('clears child scopes when parent is cleared', () {
      final pod = Pod();
      const parentScope = CustomScope('session');
      const childScope = CustomScope('request', parent: parentScope);

      final parentProvider = Provider<SimpleService>(
        (pod) => SimpleService(),
        scope: parentScope,
      );
      final childProvider = Provider<SimpleService>(
        (pod) => SimpleService(),
        scope: childScope,
      );

      final parentInstance1 = pod.resolve(parentProvider);
      final childInstance1 = pod.resolve(childProvider);

      pod.clearScope(parentScope);

      final parentInstance2 = pod.resolve(parentProvider);
      final childInstance2 = pod.resolve(childProvider);

      expect(identical(parentInstance1, parentInstance2), isFalse);
      expect(identical(childInstance1, childInstance2), isFalse);
    });

    test('does not clear parent when child is cleared', () {
      final pod = Pod();
      const parentScope = CustomScope('session');
      const childScope = CustomScope('request', parent: parentScope);

      final parentProvider = Provider<SimpleService>(
        (pod) => SimpleService(),
        scope: parentScope,
      );
      final childProvider = Provider<SimpleService>(
        (pod) => SimpleService(),
        scope: childScope,
      );

      final parentInstance1 = pod.resolve(parentProvider);
      final childInstance1 = pod.resolve(childProvider);

      pod.clearScope(childScope);

      final parentInstance2 = pod.resolve(parentProvider);
      final childInstance2 = pod.resolve(childProvider);

      expect(identical(parentInstance1, parentInstance2), isTrue);
      expect(identical(childInstance1, childInstance2), isFalse);
    });

    test('clears deeply nested child scopes', () {
      final pod = Pod();
      const rootScope = CustomScope('root');
      const level1Scope = CustomScope('level1', parent: rootScope);
      const level2Scope = CustomScope('level2', parent: level1Scope);

      final level2Provider = Provider<SimpleService>(
        (pod) => SimpleService(),
        scope: level2Scope,
      );

      final instance1 = pod.resolve(level2Provider);
      pod.clearScope(rootScope);
      final instance2 = pod.resolve(level2Provider);

      expect(identical(instance1, instance2), isFalse);
    });
  });

  group('Pod.dispose', () {
    test('disposes all cached instances', () {
      final pod = Pod();
      final provider1 = Provider<DisposableService>((pod) => DisposableService());
      final provider2 = Provider<DisposableService>((pod) => DisposableService());

      final instance1 = pod.resolve(provider1);
      final instance2 = pod.resolve(provider2);

      pod.dispose();

      expect(instance1.disposed, isTrue);
      expect(instance2.disposed, isTrue);
    });

    test('clears cache after disposal', () {
      final pod = Pod();
      final provider = Provider<SimpleService>((pod) => SimpleService());

      final instance1 = pod.resolve(provider);
      pod.dispose();
      final instance2 = pod.resolve(provider);

      expect(identical(instance1, instance2), isFalse);
    });

    test('clears overrides after disposal', () {
      final pod = Pod();
      final provider = Provider<SimpleService>((pod) => SimpleService());
      final mockService = SimpleService();

      pod.overrideProvider(provider, (_) => mockService);
      pod.dispose();
      final instance = pod.resolve(provider);

      expect(identical(instance, mockService), isFalse);
    });
  });
}
