import 'package:dart_result/dart_result.dart';

void main() async {
  final okResult = await fetchFromServer(withError: false);
  final username = okResult.fold(
    (user) => user.username,
    (failure) => 'ERROR: $failure',
  );
  print(username); // john

  final errorResult = await fetchFromServer(withError: true);
  final usernameNotOk = errorResult.fold(
    (user) => user.username,
    (failure) => 'ERROR: $failure',
  );
  print(usernameNotOk); // ERROR: Some Failure happened

  print(okResult.failure); // null
  print(okResult.getOrNull?.username); // john

  final helloUser = await fetchFromServer(withError: false)
      .then((resp) => resp.map((r) => 'hello ${r.username}'));
  print(helloUser); // Success: hello john
}

Future<Result<User, Failure>> fetchFromServer({
  required bool withError,
}) async {
  await Future<void>.delayed(const Duration(milliseconds: 100));
  if (withError) {
    return Result.failure(SomeFailure());
  } else {
    return const Result.success(User(username: 'john'));
  }
}

class User {
  final String username;

  const User({required this.username});
}

abstract class Failure {
  String get message;

  @override
  String toString() {
    return message;
  }
}

class SomeFailure extends Failure {
  @override
  final String message = 'Some Failure happened';
}
