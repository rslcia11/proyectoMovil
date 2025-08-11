import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class AuthService {
  final String _baseUrl = AppConfig.baseUrl;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_email': email,
          'user_hashed_password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['message'] == 'Login exitoso') {
          // Save token
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', responseData['token']);
          return {'success': true, 'data': responseData};
        } else {
          return {'success': false, 'message': responseData['message'] ?? 'Email o contraseña incorrectos'};
        }
      } else {
        String errorMessage = 'Error del servidor. Intenta nuevamente.';
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          errorMessage = 'Error ${response.statusCode}: ${response.body}';
        }
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión. Verifica tu internet.'};
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
