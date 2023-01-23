import 'failure.dart';
import 'success.dart';

/// A value that represents either a success or a failure, including an
/// associated value in each case.
abstract class Result<S, F> {
  const Result();

  const factory Result.success(S value) = Success;

  const factory Result.failure(F error) = Failure;

  /// Try to execute `run`. If no error occurs, then return [Success].
  /// Otherwise return [Failure] containing the result of `onError`.
  factory Result.tryCatch(
      S Function() run, F Function(Object o, StackTrace s) onError) {
    try {
      return Success(run());
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      return Failure(onError(e, s));
    }
  }

  /// Returns true if [Result] is [Failure].
  bool get isFailure;

  /// Returns true if [Result] is [Success].
  bool get isSuccess;

  /// Gets this [Success] result or `null` if this is a [Failure].
  Success<S>? get success => isSuccess ? (this as Success<S>) : null;

  /// Gets the value of [Failure] result or null if result is a [Success].
  Failure<F>? get failure => isFailure ? (this as Failure<F>) : null;

  /// Gets the value from this [Success] or `null` if this is a [Failure].
  S? get getOrNull => isSuccess ? (this as Success<S>).value : null;

  /// Returns the value from this [Success] or the result of `orElse` if this is a [Failure].
  S getOrElse(S Function() orElse) =>
      isSuccess ? (this as Success<S>).value : orElse();

  S getOrThrow() {
    if (isSuccess) {
      return (this as Success<S>).value;
    }

    throw Exception(
      'Tried to obtain the value from a failure.',
    );
  }

  /// Returns the value of [Failure]
  ///
  /// Will throw an [Exception] if this is not a [Failure].
  F getFailureOrThrow() {
    if (isFailure) {
      return (this as Failure<F>).error;
    }

    throw Exception(
      'Tried to obtain the error value from a success.',
    );
  }

  /// Applies `onSuccess` if this is a [Failure] or `onFailure` if this is a [Success].
  U fold<U>({
    required U Function(S success) onSuccess,
    required U Function(F failure) onFailure,
  }) {
    if (isSuccess) {
      return onSuccess((this as Success<S>).value);
    } else {
      return onFailure((this as Failure<F>).error);
    }
  }

  /// Maps a [Result<S, F>] to [Result<U, F>] by applying a function
  /// to a contained [Success] value, leaving an [Failure] value untouched.
  ///
  /// This function can be used to compose the results of two functions.
  Result<U, F> map<U>(U Function(S) transform) {
    if (isSuccess) {
      return Success(transform((this as Success<S>).value));
    } else {
      return Failure((this as Failure<F>).error);
    }
  }

  /// Maps a [Result<S, F>] to [Result<S, E>] by applying a function
  /// to a contained [Failure] value, leaving an [Success] value untouched.
  ///
  /// This function can be used to pass through a successful result
  /// while applying transformation to [Failure].
  Result<S, E> mapFailure<E>(E Function(F) transform) {
    if (isSuccess) {
      return Success((this as Success<S>).value);
    } else {
      return Failure(transform((this as Failure<F>).error));
    }
  }

  /// Maps a [Result<S, F>] to [Result<U, F>] by applying a function
  /// to a contained [Success] value and unwrapping the produced result,
  /// leaving an [Failure] value untouched.
  ///
  /// Use this method to avoid a nested result when your transformation
  /// produces another [Result] type.
  Result<U, F> flatMap<U>(Result<U, F> Function(S) transform) {
    if (isSuccess) {
      return transform((this as Success<S>).value);
    } else {
      return Failure((this as Failure<F>).error);
    }
  }
}
