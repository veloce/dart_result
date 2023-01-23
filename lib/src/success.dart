import 'package:meta/meta.dart';

import 'result.dart';

/// A success, storing a [Success] value.
@immutable
class Success<T> extends Result<T, Never> {
  final T value;

  const Success(this.value);

  @override
  bool get isFailure => false;

  @override
  bool get isSuccess => true;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Success<T> && o.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success: $value';
}
