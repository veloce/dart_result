import 'dart:async';
import 'package:meta/meta.dart';

/// `AsyncResult<S, E>` represents an asynchronous computation.
typedef AsyncResult<S, F extends Object> = Future<Result<S, F>>;

/// A value that represents either a success or a failure.
abstract class Result<S, F extends Object> {
  const Result();

  const factory Result.success(S value) = Success;

  const factory Result.failure(F error) = Failure;

  /// Try to execute `run`. If no error occurs, then return [Success].
  /// Otherwise return [Failure] containing the result of `onError`.
  static Result<T, E> tryCatch<T, E extends Object>(
      T Function() run, E Function(Object o, StackTrace s) onError) {
    try {
      return Success(run());
    } catch (e, s) {
      return Failure(onError(e, s));
    }
  }

  /// Try to await `run`. If no error occurs, then return [Success].
  /// Otherwise return [Failure] containing the result of `onError`.
  static AsyncResult<T, E> tryCatchAsync<T, E extends Object>(
      FutureOr<T> Function() run,
      E Function(Object o, StackTrace s) onError) async {
    try {
      final value = await run();
      return Result.success(value);
    } catch (e, s) {
      return Result.failure(onError(e, s));
    }
  }

  /// Returns `true` if [Result] is [Failure].
  bool get isFailure;

  /// Returns `true` if [Result] is [Success].
  bool get isSuccess;

  /// Gets this [Success] result or `null` if this is a [Failure].
  Success<S, F>? get success;

  /// Gets the value of [Failure] result or null if result is a [Success].
  Failure<S, F>? get failure;

  /// Gets the value from this [Success] or `null` if this is a [Failure].
  S? get getOrNull;

  /// Returns the value from this [Success] or the result of `orElse()` if this is a [Failure].
  S getOrElse(S Function() orElse);

  /// Returns the value of [Success]
  ///
  /// Will throw the [Failure] if this is not a [Success].
  S getOrThrow();

  /// Returns the value of [Failure]
  ///
  /// Will throw an [Exception] if this is not a [Failure].
  F getFailureOrThrow();

  /// Applies `onSuccess` if this is a [Success] or `onFailure` if this is a [Failure].
  U fold<U>(U Function(S value) onSuccess, U Function(F failure) onFailure);

  /// Execute `onSuccess` in case of [Success] or `onFailure` in case of [Failure].
  void match({
    void Function(S value)? onSuccess,
    void Function(F failure)? onFailure,
  });

  /// Maps a [Result<S, F>] to [Result<U, F>] by applying a function
  /// to a contained [Success] value, leaving an [Failure] value untouched.
  ///
  /// This function can be used to compose the results of two functions.
  Result<U, F> map<U>(U Function(S) f);

  /// Apply a function to a contained [Success] value
  ///
  /// Equivalent to `match(onSuccess: (value) { // do sth with value })`
  void forEach(void Function(S) f);

  /// Maps a [Result<S, F>] to [Result<S, E>] by applying a function
  /// to a contained [Failure] value, leaving an [Success] value untouched.
  ///
  /// This function can be used to pass through a successful result
  /// while applying transformation to [Failure].
  Result<S, E> mapFailure<E extends Object>(E Function(F) f);

  /// Maps a [Result<S, F>] to [Result<U, F>] by applying a function
  /// to a contained [Success] value and unwrapping the produced result,
  /// leaving an [Failure] value untouched.
  ///
  /// Use this method to avoid a nested result when your transformation
  /// produces another [Result] type.
  Result<U, F> flatMap<U>(covariant Result<U, F> Function(S) f);
}

/// A success, storing a [Success] value.
@immutable
class Success<S, F extends Object> extends Result<S, F> {
  final S value;

  const Success(this.value);

  @override
  bool get isFailure => false;

  @override
  bool get isSuccess => true;

  @override
  Success<S, F>? get success => this;

  @override
  Failure<S, F>? get failure => null;

  @override
  S? get getOrNull => value;

  @override
  S getOrElse(S Function() orElse) => value;

  @override
  S getOrThrow() {
    return value;
  }

  @override
  F getFailureOrThrow() {
    throw Exception(
      'Tried to obtain the error value from a success.',
    );
  }

  @override
  U fold<U>(U Function(S value) onSuccess, U Function(F error) onFailure) {
    return onSuccess(value);
  }

  @override
  void match({
    void Function(S value)? onSuccess,
    void Function(F error)? onFailure,
  }) {
    if (onSuccess != null) {
      onSuccess(value);
    }
  }

  @override
  Result<U, F> map<U>(U Function(S) f) => Success(f(value));

  @override
  void forEach(void Function(S) f) => f(value);

  @override
  Result<S, E> mapFailure<E extends Object>(E Function(F) f) => Success(value);

  @override
  Result<U, F> flatMap<U>(covariant Result<U, F> Function(S) f) => f(value);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Success<S, F> && o.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success: $value';
}

/// A failure, storing a [Failure] value.
@immutable
class Failure<S, F extends Object> extends Result<S, F> {
  final F error;

  const Failure(this.error);

  @override
  bool get isFailure => true;

  @override
  bool get isSuccess => false;

  @override
  Success<S, F>? get success => null;

  @override
  Failure<S, F>? get failure => this;

  @override
  S? get getOrNull => null;

  @override
  S getOrElse(S Function() orElse) => orElse();

  @override
  S getOrThrow() {
    throw error;
  }

  @override
  F getFailureOrThrow() {
    return error;
  }

  @override
  U fold<U>(U Function(S value) onSuccess, U Function(F error) onFailure) {
    return onFailure(error);
  }

  @override
  void match({
    void Function(S value)? onSuccess,
    void Function(F error)? onFailure,
  }) {
    if (onFailure != null) {
      onFailure(error);
    }
  }

  @override
  Result<U, F> map<U>(U Function(S) f) => Failure(error);

  @override
  void forEach(void Function(S) f) {}

  @override
  Result<S, E> mapFailure<E extends Object>(E Function(F) f) =>
      Failure(f(error));

  @override
  Result<U, F> flatMap<U>(covariant Result<U, F> Function(S) f) =>
      Failure(error);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Failure<S, F> && o.error == error;
  }

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure: $error';
}
