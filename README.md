# Result

## Features

`Result` is a type that represents either [Success](lib/src/success.dart) or [Failure](lib/src/failure.dart).

## Requirements

- Dart: 2.17.3+

## Example

```dart
final okResult = await fetchFromServer();
final username = okResult.fold(
  onSuccess: (user) => user.username,
  onFailure: (failure) => 'ERROR: $failure',
);
print(username); // john

print(okResult.failure); // null
print(okResult.getOrNull?.username); // john

final helloUser = await fetchFromServer(withError: false)
    .then((resp) => resp.map((r) => 'hello ${r.username}'));
print(helloUser); // Success: hello john
```
