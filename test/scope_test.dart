import 'package:dartypod/dartypod.dart';
import 'package:test/test.dart';

void main() {
  group('SingletonScope', () {
    test('has name "singleton"', () {
      const scope = SingletonScope();
      expect(scope.name, equals('singleton'));
    });

    test('has no parent', () {
      const scope = SingletonScope();
      expect(scope.parent, isNull);
    });

    test('const instances are identical', () {
      const scope1 = SingletonScope();
      const scope2 = SingletonScope();
      expect(identical(scope1, scope2), isTrue);
    });
  });

  group('TransientScope', () {
    test('has name "transient"', () {
      const scope = TransientScope();
      expect(scope.name, equals('transient'));
    });

    test('has no parent', () {
      const scope = TransientScope();
      expect(scope.parent, isNull);
    });

    test('const instances are identical', () {
      const scope1 = TransientScope();
      const scope2 = TransientScope();
      expect(identical(scope1, scope2), isTrue);
    });
  });

  group('CustomScope', () {
    test('has custom name', () {
      const scope = CustomScope('request');
      expect(scope.name, equals('request'));
    });

    test('has no parent by default', () {
      const scope = CustomScope('request');
      expect(scope.parent, isNull);
    });

    test('can have parent scope', () {
      const parentScope = CustomScope('session');
      const childScope = CustomScope('request', parent: parentScope);

      expect(childScope.parent, equals(parentScope));
    });

    test('supports deep hierarchy', () {
      const rootScope = SingletonScope();
      const sessionScope = CustomScope('session', parent: rootScope);
      const requestScope = CustomScope('request', parent: sessionScope);

      expect(requestScope.parent, equals(sessionScope));
      expect(sessionScope.parent, equals(rootScope));
      expect(rootScope.parent, isNull);
    });
  });
}
