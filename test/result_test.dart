import 'package:dart_result/dart_result.dart';
import 'package:test/test.dart';

import 'utils/mock_error.dart';

void main() {
  group('Result:', () {
    test('tryCatch constructor with success', () {
      final result =
          Result.tryCatch(() => 'John Doe', (error, _) => error.toString());

      expect(result.getOrNull, 'John Doe');
    });

    test('tryCatch constructor with failure', () {
      final result = Result.tryCatch(
        () => throw Exception('error'),
        (error, _) => error.toString(),
      );

      expect(result.failure?.error, 'Exception: error');
    });

    test('tryCatchAsync success', () async {
      final result = await Result.tryCatchAsync(
          () async => Future<void>.delayed(const Duration(milliseconds: 100))
              .then((_) => 'John Doe'),
          (error, _) => error.toString());

      expect(result.getOrNull, 'John Doe');
    });

    test('tryCatchAsync failure', () async {
      final result = await Result.tryCatchAsync(
        () async => throw Exception('error'),
        (error, _) => error.toString(),
      );

      expect(result.failure?.error, 'Exception: error');
    });

    test('getOrThrow()', () {
      final result = getUser(value: true);

      expect(result.getOrThrow(), 'John Doe');

      final resultFailed = getUser(value: false);

      expect(resultFailed.getOrThrow, throwsA(const MockError(404)));
    });

    test('getFailureOrThrow()', () {
      final resultFailed = getUser(value: false);

      expect(resultFailed.getFailureOrThrow(), const MockError(404));

      final result = getUser(value: true);

      expect(result.getFailureOrThrow, throwsA(isA<Exception>()));
    });

    test('fold with success', () {
      final result = getUser(value: true);

      expect(result.fold((success) => success, (_) => 'default'), 'John Doe');
    });

    test('fold with failure', () {
      final result = getUser(value: false);

      expect(result.fold((success) => success, (_) => 'default'), 'default');
    });

    test('match with failed', () {
      final failedResult = getUser(value: false);

      String? onSuccessResult;
      Object? onFailureResult;
      failedResult.match(
        onSuccess: (value) => onSuccessResult = value,
        onFailure: (error) => onFailureResult = error,
      );
      expect(onSuccessResult, isNull);
      expect(onFailureResult, const MockError(404));
    });

    test('match with success', () {
      final successResult = getUser(value: true);

      String? onSuccessResult;
      Object? onFailureResult;
      successResult.match(
        onSuccess: (value) => onSuccessResult = value,
        onFailure: (error) => onFailureResult = error,
      );
      expect(onSuccessResult, 'John Doe');
      expect(onFailureResult, isNull);
    });

    test('forEach with failure', () {
      final result = getUser(value: false);
      String? test;
      result.forEach((value) => test = value);
      expect(test, isNull);
    });

    test('forEach with success', () {
      final result = getUser(value: true);
      String? test;
      result.forEach((value) => test = value);
      expect(test, 'John Doe');
    });

    test('Apply map transformation to successful operation results', () {
      final result = getUser(value: true);
      final user = result.map<String>((i) => i.toUpperCase()).getOrNull;

      expect(user, 'JOHN DOE');
    });

    test('Apply map transformation to failed operation results', () {
      final result = getUser(value: false);
      final error = result.map<String>((i) => i.toUpperCase()).failure;

      expect(error, const Failure<String, MockError>(MockError(404)));
    });

    test('Apply mapFailure transformation to failure type', () {
      final error =
          getUser(value: false).mapFailure<int>((i) => i.code).failure;

      expect(error, const Failure<String, int>(404));
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
        const TypeMatcher<Success<int, MockError>>(),
      );
    });

    test('flatMap does not apply transformation to Failure', () {
      Result<int, MockError> getNextInteger() => const Failure(MockError(451));

      final nextIntegerUnboxedResults =
          getNextInteger().flatMap((p0) => Success(p0 + 1));

      expect(
        nextIntegerUnboxedResults,
        const TypeMatcher<Failure<int, MockError>>(),
      );
    });
  });

  group('Success', () {
    test('Should have a value 0', () {
      const success = Success<int, Never>(0);
      expect(success.value, 0);
    });

    test('Two identical Successes should be equal', () {
      const success1 = Success<int, Never>(0);
      const success2 = Success<int, Never>(0);

      expect(success1, success2);
    });

    test('Two identical Successes should have the same hashCode', () {
      const success1 = Success<int, Never>(0);
      const success2 = Success<int, Never>(0);

      expect(success1.hashCode, success2.hashCode);
    });

    test('Can print to string', () {
      const success = Success<int, Never>(0);
      expect(success.toString(), 'Success: 0');
    });
  });

  group('Failure', () {
    test('Should return _TestError', () {
      const failure = Failure<Never, MockError>(MockError(1));
      expect(failure.error.code, 1);
    });

    test('Two identical Failures should be equal', () {
      const failure1 = Failure<Never, MockError>(MockError(1));
      const failure2 = Failure<Never, MockError>(MockError(1));

      expect(failure1, failure2);
    });

    test('Two identical Failures should have the same hashCode', () {
      const failure1 = Failure<Never, MockError>(MockError(1));
      const failure2 = Failure<Never, MockError>(MockError(1));

      expect(failure1.hashCode, failure2.hashCode);
    });

    test('Can print to string', () {
      const failure = Failure<Never, MockError>(MockError(1));
      expect(failure.toString(), 'Failure: MockError(code: 1)');
    });
  });
}

Result<String, MockError> getUser({required bool value}) =>
    value ? const Success('John Doe') : const Failure(MockError(404));
