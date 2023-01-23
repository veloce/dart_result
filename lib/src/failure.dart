import 'package:meta/meta.dart';

import 'result.dart';

/// A failure, storing a [Failure] value.
@immutable
class Failure<F> extends Result<Never, F> {
  final F error;

  const Failure(this.error);

  @override
  bool get isFailure => true;

  @override
  bool get isSuccess => false;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Failure<F> && o.error == error;
  }

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure: $error';
}
