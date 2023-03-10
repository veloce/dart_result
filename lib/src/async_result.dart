import 'dart:async';

import 'result.dart';

/// `AsyncResult<S, E>` represents an asynchronous computation.
extension AsyncResultExtension<S, F extends Object> on AsyncResult<S, F> {
  /// Returns a new [Result], mapping any [Success] value
  /// using the given transformation and unwrapping the produced [Result].
  AsyncResult<W, F> flatMap<W extends Object>(
    FutureOr<Result<W, F>> Function(S success) fn,
  ) {
    return then((result) => result.fold(fn, Failure.new));
  }

  /// Apply a function to a contained [Success] value
  ///
  /// Equivalent to `match(onSuccess: (value) { // do sth with value })`
  Future<void> forEach(void Function(S) f) {
    return then((result) => result.forEach(f));
  }

  /// Returns a new [AsyncResult], mapping any [Success] value
  /// using the given transformation.
  AsyncResult<W, F> map<W extends Object>(W Function(S success) fn) {
    return then((result) => result.map(fn));
  }

  /// Returns a new [Result], mapping any [Error] value
  /// using the given transformation.
  AsyncResult<S, W> mapFailure<W extends Object>(W Function(F error) fn) {
    return then((result) => result.mapFailure(fn));
  }

  /// Returns the Future result of onSuccess for the encapsulated value
  /// if this instance represents [Success] or the result of onError function
  /// for the encapsulated value if it is [Error].
  Future<W> fold<W>(
    W Function(S value) onSuccess,
    W Function(F error) onFailure,
  ) {
    return then<W>((result) => result.fold(onSuccess, onFailure));
  }

  /// Execute `onSuccess` in case of [Success] or `onFailure` in case of [Failure].
  Future<void> match({
    void Function(S value)? onSuccess,
    void Function(F failure)? onFailure,
  }) {
    return then(
        (result) => result.match(onSuccess: onSuccess, onFailure: onFailure));
  }

  /// Returns the future value of [S] if any.
  Future<S?> get getOrNull => then((result) => result.getOrNull);

  /// Returns true if the current result is an [Failure].
  Future<bool> get isFailure => then((result) => result.isFailure);

  /// Returns true if the current result is a [Success].
  Future<bool> get isSuccess => then((result) => result.isSuccess);

  /// Returns the future success value.
  ///
  /// Will throw the [Failure] if this is not a [Success].
  Future<S> getOrThrow() => then((result) => result.getOrThrow());

  /// Returns the future value of [Failure].
  ///
  /// Will throw an [Exception] if this is not a [Failure].
  Future<F> getFailureOrThrow() => then((result) => result.getFailureOrThrow());

  /// Returns the encapsulated value if this instance represents [Success]
  /// or the result of `onFailure` function for
  /// the encapsulated a [Failure] value.
  Future<S> getOrElse(S Function() orElse) {
    return then((result) => result.getOrElse(orElse));
  }
}
