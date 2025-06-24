import 'dart:convert';
import 'package:client/core/constants/api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../exceptions/auth_exceptions.dart';

class AuthRepository {
  Future<void> signup(UserModel user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 400) {
      throw InvalidDataException(body['detail']);
    } else if (response.statusCode == 409) {
      throw UserAlreadyExistsException(body['detail']);
    } else if (response.statusCode != 201) {
      throw SignupFailedException('Signup failed: ${response.statusCode}');
    }
  }

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 400) {
      throw InvalidCredentialsException(body['detail']);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else if (response.statusCode == 200) {
      final token = body['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    } else {
      throw LoginFailedException(body['detail']);
    }
  }

  Future<void> changePassword(
    String email,
    String currentPassword,
    String newPassword,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/change-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 404) {
      throw UserNotFoundException(body['detail']);
    } else if (response.statusCode == 400) {
      throw IncorrectPasswordException(body['detail']);
    } else if (response.statusCode != 200) {
      throw PasswordChangeFailedException(
        body['detail'] ?? 'Failed to change password',
      );
    }

    // Clear the token since password was changed
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<void> forgotPasswordSendCode(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password/send-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(body['detail'] ?? 'Failed to send reset code');
    }
  }

  Future<void> forgotPasswordVerifyCode(
    String email,
    String code,
    String newPassword,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password/verify-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
        'new_password': newPassword,
      }),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(body['detail'] ?? 'Failed to reset password');
    }
  }
}
