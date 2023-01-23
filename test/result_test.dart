import 'package:dart_result/dart_result.dart';
import 'package:test/test.dart';

import 'utils/mock_error.dart';

void main() {
  group('Result:', () {
    test('tryCatch constructor with success', () {
      final result = Result<String, String>.tryCatch(
          () => 'John Doe', (error, _) => error.toString());

      expect(result.getOrNull, 'John Doe');
    });

    test('tryCatch constructor with failure', () {
      final result = Result<String, String>.tryCatch(
        () => throw Exception('error'),
        (error, _) => error.toString(),
      );

      expect(result.failure?.error, 'Exception: error');
    });

    test('getOrThrow()', () {
      final result = getUser(value: true);

      expect(result.getOrThrow(), 'John Doe');
    });

    test('getFailureOrThrow()', () {
      final result = getUser(value: false);

      expect(result.getFailureOrThrow(), const MockError(404));
    });

    test('Throw Exception when getting value without checking if isSuccess',
        () {
      final result = getUser(value: false);

      expect(result.getOrThrow, throwsException);
    });

    test(
        'Throw Exception when accessing failure value without checking if isFailure',
        () {
      final result = getUser(value: true);

      expect(result.getFailureOrThrow, throwsException);
    });

    test('fold with success', () {
      final result = getUser(value: true);

      expect(
          result.fold(
              onSuccess: (success) => success, onFailure: (_) => 'default'),
          'John Doe');
    });

    test('fold with failure', () {
      final result = getUser(value: false);

      expect(
          result.fold(
              onSuccess: (success) => success, onFailure: (_) => 'default'),
          'default');
    });

    test('Apply map transformation to successful operation results', () {
      final result = getUser(value: true);
      final user = result.map<String>((i) => i.toUpperCase()).getOrNull;

      expect(user, 'JOHN DOE');
    });

    test('Apply map transformation to failed operation results', () {
      final result = getUser(value: false);
      final error = result.map<String>((i) => i.toUpperCase()).failure;

      expect(error, const Failure(MockError(404)));
    });

    test('Apply mapFailure transformation to failure type', () {
      final error =
          getUser(value: false).mapFailure<int>((i) => i.code).failure;

      expect(error, const Failure(404));
    });

    test('Returns successful result without applying mapFailure transformation',
        () {
      final maybeError = getUser(value: true).mapFailure<int>((i) => i.code);

      expect(maybeError.isSuccess, true);
    });

    test('Apply flatMap transformation to successful operation results', () {
      Result<int, MockError> getNextInteger() => const Success(1);

      final nextIntegerUnboxedResults =
          getNextInteger().flatMap((p0) => Success(p0 + 1));

      expect(
        nextIntegerUnboxedResults,
        const TypeMatcher<Success<int>>(),
      );
    });

    test('flatMap does not apply transformation to Failure', () {
      Result<int, MockError> getNextInteger() => const Failure(MockError(451));

      final nextIntegerUnboxedResults =
          getNextInteger().flatMap((p0) => Success(p0 + 1));

      expect(
        nextIntegerUnboxedResults,
        const TypeMatcher<Failure<MockError>>(),
      );
    });
  });
}

Result<String, MockError> getUser({required bool value}) {
  if (value) {
    return const Success('John Doe');
  } else {
    return const Failure(MockError(404));
  }
}
