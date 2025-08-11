import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../utils/app_exceptions.dart'; // Import custom exceptions

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

      final responseData = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
          if (responseData['message'] == 'Login exitoso') {
            // Save token
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('auth_token', responseData['token']);
            return responseData; // Return actual data on success
          } else {
            throw BadRequestException(responseData['message'] ?? 'Email o contraseña incorrectos');
          }
        case 400:
          throw BadRequestException(responseData['message'] ?? 'Solicitud inválida');
        case 401:
          throw UnauthorizedException(responseData['message'] ?? 'Credenciales inválidas');
        case 404:
          throw NotFoundException(responseData['message'] ?? 'Recurso no encontrado');
        case 500:
          throw InternalServerErrorException(responseData['message'] ?? 'Error interno del servidor');
        default:
          throw FetchDataException('Error durante la comunicación con el servidor: ${response.statusCode}');
      }
    } on SocketException {
      throw FetchDataException('No hay conexión a Internet. Verifica tu conexión.');
    } catch (e) {
      // Catch any other unexpected errors
      throw FetchDataException('Ocurrió un error inesperado: ${e.toString()}');
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
