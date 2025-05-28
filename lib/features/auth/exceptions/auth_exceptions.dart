class InvalidDataException implements Exception {
  final String message;
  InvalidDataException([this.message = 'Invalid data']);

  @override
  String toString() => message;
}

class UserAlreadyExistsException implements Exception {
  final String message;
  UserAlreadyExistsException([this.message = 'User already exists']);

  @override
  String toString() => message;
}

class InvalidCredentialsException implements Exception {
  final String message;
  InvalidCredentialsException([this.message = 'Invalid credentials']);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Unauthorized']);

  @override
  String toString() => message;
}

class SignupFailedException implements Exception {
  final String message;
  SignupFailedException([this.message = 'Signup failed']);

  @override
  String toString() => message;
}

class LoginFailedException implements Exception {
  final String message;
  LoginFailedException([this.message = 'Login failed']);

  @override
  String toString() => message;
}

class UserNotFoundException implements Exception {
  final String message;
  UserNotFoundException([this.message = 'User not found']);

  @override
  String toString() => message;
}

class IncorrectPasswordException implements Exception {
  final String message;
  IncorrectPasswordException([this.message = 'Current password is incorrect']);

  @override
  String toString() => message;
}

class PasswordChangeFailedException implements Exception {
  final String message;
  PasswordChangeFailedException([this.message = 'Failed to change password']);

  @override
  String toString() => message;
}
