import 'package:dart_result/dart_result.dart';
import 'package:test/test.dart';

void main() {
  group('Success', () {
    test('Should have a value 0', () {
      final success = Success<int>(0);
      expect(success.value, 0);
    });

    test('Two identical Successes should be equal', () {
      final success1 = Success<int>(0);
      final success2 = Success<int>(0);

      expect(success1, success2);
    });

    test('Two identical Successes should have the same hashCode', () {
      final success1 = Success<int>(0);
      final success2 = Success<int>(0);

      expect(success1.hashCode, success2.hashCode);
    });

    test('Can print to string', () {
      final success = Success<int>(0);
      expect(success.toString(), 'Success: 0');
    });
  });
}
