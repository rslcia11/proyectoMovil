import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart'; // Import AppConfig

class FieldService {
  final String _baseUrl = AppConfig.baseUrl; // Use AppConfig.baseUrl
  
  // Obtener token guardado
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Crear nueva cancha
  Future<Map<String, dynamic>> createField({
    required int companyId,
    required String fieldName,
    required String fieldType,
    required String fieldSize,
    required int fieldMaxCapacity,
    required double fieldHourPrice,
    required String fieldDescription,
    File? fieldImage,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw UnauthorizedException('Token no encontrado');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/fields'),
      );

      // Agregar headers con token
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Agregar campos
      request.fields['company_id'] = companyId.toString();
      request.fields['field_name'] = fieldName;
      request.fields['field_type'] = fieldType;
      request.fields['field_size'] = fieldSize;
      request.fields['field_max_capacity'] = fieldMaxCapacity.toString();
      request.fields['field_hour_price'] = fieldHourPrice.toString();
      request.fields['field_description'] = fieldDescription;

      // Agregar imagen si existe
      if (fieldImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'field_image',
          fieldImage.path,
        ));
      }

      // Enviar solicitud
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      switch (response.statusCode) {
        case 201:
          return json.decode(responseData); // Return actual data
        case 400:
          throw BadRequestException(json.decode(responseData)['message'] ?? 'Solicitud inválida');
        case 401:
          throw UnauthorizedException(json.decode(responseData)['message'] ?? 'No autorizado');
        case 404:
          throw NotFoundException(json.decode(responseData)['message'] ?? 'Recurso no encontrado');
        case 500:
          throw InternalServerErrorException(json.decode(responseData)['message'] ?? 'Error interno del servidor');
        default:
          throw FetchDataException('Error al crear la cancha: ${response.statusCode}');
      }
    } on SocketException {
      throw FetchDataException('No hay conexión a Internet. Verifica tu conexión.');
    } catch (e) {
      throw FetchDataException('Ocurrió un error inesperado: ${e.toString()}');
    }
  }

  // Obtener todas las canchas disponibles (para jugadores/clientes) - READ
  Future<List<dynamic>> getAllFields() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/fields'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final dynamic responseData = jsonDecode(response.body);

      switch (response.statusCode) {
        case 200:
          // Manejar tanto si viene como array directo o dentro de un objeto
          return responseData is List 
              ? responseData 
              : responseData['data'] ?? responseData['fields'] ?? [];
        case 400:
          throw BadRequestException(responseData['message'] ?? 'Solicitud inválida');
        case 401:
          throw UnauthorizedException(responseData['message'] ?? 'No autorizado');
        case 404:
          throw NotFoundException(responseData['message'] ?? 'Recurso no encontrado');
        case 500:
          throw InternalServerErrorException(responseData['message'] ?? 'Error interno del servidor');
        default:
          throw FetchDataException('Error al cargar las canchas: ${response.statusCode}');
      }
    } on SocketException {
      throw FetchDataException('No hay conexión a Internet. Verifica tu conexión.');
    } catch (e) {
      throw FetchDataException('Ocurrió un error inesperado: ${e.toString()}');
    }
  }

  // Obtener una cancha específica por ID
  Future<Map<String, dynamic>> getFieldById(int fieldId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/fields/$fieldId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      switch (response.statusCode) {
        case 200:
          return responseData; // Return actual data
        case 400:
          throw BadRequestException(responseData['message'] ?? 'Solicitud inválida');
        case 401:
          throw UnauthorizedException(responseData['message'] ?? 'No autorizado');
        case 404:
          throw NotFoundException(responseData['message'] ?? 'Recurso no encontrado');
        case 500:
          throw InternalServerErrorException(responseData['message'] ?? 'Error interno del servidor');
        default:
          throw FetchDataException('Error al cargar la cancha: ${response.statusCode}');
      }
    } on SocketException {
      throw FetchDataException('No hay conexión a Internet. Verifica tu conexión.');
    } catch (e) {
      throw FetchDataException('Ocurrió un error inesperado: ${e.toString()}');
    }
  }

  // Actualizar cancha - UPDATE
  Future<Map<String, dynamic>> updateField({
    required int fieldId,
    required int companyId,
    required String fieldName,
    required String fieldType,
    required String fieldSize,
    required int fieldMaxCapacity,
    required double fieldHourPrice,
    required String fieldDescription,
    File? fieldImage,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw UnauthorizedException('Token no encontrado');
      }

      String? imageBase64;
      if (fieldImage != null) {
        final bytes = await fieldImage.readAsBytes();
        imageBase64 = base64Encode(bytes);
      }

      final body = {
        'company_id': companyId.toString(),
        'field_name': fieldName,
        'field_type': fieldType,
        'field_size': fieldSize,
        'field_max_capacity': fieldMaxCapacity.toString(),
        'field_hour_price': fieldHourPrice.toString(),
        'field_description': fieldDescription,
        if (imageBase64 != null) 'field_img': imageBase64,
      };

      final response = await http.put(
        Uri.parse('$_baseUrl/fields/$fieldId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      switch (response.statusCode) {
        case 200:
          return responseData; // Return actual data
        case 400:
          throw BadRequestException(responseData['message'] ?? 'Solicitud inválida');
        case 401:
          throw UnauthorizedException(responseData['message'] ?? 'No autorizado');
        case 404:
          throw NotFoundException(responseData['message'] ?? 'Recurso no encontrado');
        case 500:
          throw InternalServerErrorException(responseData['message'] ?? 'Error interno del servidor');
        default:
          throw FetchDataException('Error al actualizar la cancha: ${response.statusCode}');
      }
    } on SocketException {
      throw FetchDataException('No hay conexión a Internet. Verifica tu conexión.');
    } catch (e) {
      throw FetchDataException('Ocurrió un error inesperado: ${e.toString()}');
    }
  }

  // Eliminar cancha - DELETE
  Future<Map<String, dynamic>> deleteField(int fieldId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token no encontrado'};
      }

      import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/app_config.dart';
import '../di/locator.dart'; // Import locator
import '../services/auth_service.dart'; // Import AuthService
import '../utils/app_exceptions.dart'; // Import custom exceptions

class FieldService {
  final String _baseUrl = AppConfig.baseUrl;
  final AuthService _authService = locator<AuthService>(); // Get AuthService instance

  // Crear nueva cancha
  Future<Map<String, dynamic>> createField({
    required int companyId,
    required String fieldName,
    required String fieldType,
    required String fieldSize,
    required int fieldMaxCapacity,
    required double fieldHourPrice,
    required String fieldDescription,
    File? fieldImage,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw UnauthorizedException('Token no encontrado');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/fields'),
      );

      // Agregar headers con token
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Agregar campos
      request.fields['company_id'] = companyId.toString();
      request.fields['field_name'] = fieldName;
      request.fields['field_type'] = fieldType;
      request.fields['field_size'] = fieldSize;
      request.fields['field_max_capacity'] = fieldMaxCapacity.toString();
      request.fields['field_hour_price'] = fieldHourPrice.toString();
      request.fields['field_description'] = fieldDescription;

      // Agregar imagen si existe
      if (fieldImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'field_image',
          fieldImage.path,
        ));
      }

      // Enviar solicitud
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      switch (response.statusCode) {
        case 201:
          return json.decode(responseData); // Return actual data
        case 400:
          throw BadRequestException(json.decode(responseData)['message'] ?? 'Solicitud inválida');
        case 401:
          throw UnauthorizedException(json.decode(responseData)['message'] ?? 'No autorizado');
        case 404:
          throw NotFoundException(json.decode(responseData)['message'] ?? 'Recurso no encontrado');
        case 500:
          throw InternalServerErrorException(json.decode(responseData)['message'] ?? 'Error interno del servidor');
        default:
          throw FetchDataException('Error al crear la cancha: ${response.statusCode}');
      }
    } on SocketException {
      throw FetchDataException('No hay conexión a Internet. Verifica tu conexión.');
    } catch (e) {
      throw FetchDataException('Ocurrió un error inesperado: ${e.toString()}');
    }
  }

  // Obtener todas las canchas disponibles (para jugadores/clientes) - READ
  Future<List<dynamic>> getAllFields() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/fields'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final dynamic responseData = jsonDecode(response.body);

      switch (response.statusCode) {
        case 200:
          // Manejar tanto si viene como array directo o dentro de un objeto
          return responseData is List 
              ? responseData 
              : responseData['data'] ?? responseData['fields'] ?? [];
        case 400:
          throw BadRequestException(responseData['message'] ?? 'Solicitud inválida');
        case 401:
          throw UnauthorizedException(responseData['message'] ?? 'No autorizado');
        case 404:
          throw NotFoundException(responseData['message'] ?? 'Recurso no encontrado');
        case 500:
          throw InternalServerErrorException(responseData['message'] ?? 'Error interno del servidor');
        default:
          throw FetchDataException('Error al cargar las canchas: ${response.statusCode}');
      }
    } on SocketException {
      throw FetchDataException('No hay conexión a Internet. Verifica tu conexión.');
    } catch (e) {
      throw FetchDataException('Ocurrió un error inesperado: ${e.toString()}');
    }
  }

  // Obtener una cancha específica por ID
  Future<Map<String, dynamic>> getFieldById(int fieldId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/fields/$fieldId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      switch (response.statusCode) {
        case 200:
          return responseData; // Return actual data
        case 400:
          throw BadRequestException(responseData['message'] ?? 'Solicitud inválida');
        case 401:
          throw UnauthorizedException(responseData['message'] ?? 'No autorizado');
        case 404:
          throw NotFoundException(responseData['message'] ?? 'Recurso no encontrado');
        case 500:
          throw InternalServerErrorException(responseData['message'] ?? 'Error interno del servidor');
        default:
          throw FetchDataException('Error al cargar la cancha: ${response.statusCode}');
      }
    } on SocketException {
      throw FetchDataException('No hay conexión a Internet. Verifica tu conexión.');
    } catch (e) {
      throw FetchDataException('Ocurrió un error inesperado: ${e.toString()}');
    }
  }

  // Actualizar cancha - UPDATE
  Future<Map<String, dynamic>> updateField({
    required int fieldId,
    required int companyId,
    required String fieldName,
    required String fieldType,
    required String fieldSize,
    required int fieldMaxCapacity,
    required double fieldHourPrice,
    required String fieldDescription,
    File? fieldImage,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw UnauthorizedException('Token no encontrado');
      }

      String? imageBase64;
      if (fieldImage != null) {
        final bytes = await fieldImage.readAsBytes();
        imageBase64 = base64Encode(bytes);
      }

      final body = {
        'company_id': companyId.toString(),
        'field_name': fieldName,
        'field_type': fieldType,
        'field_size': fieldSize,
        'field_max_capacity': fieldMaxCapacity.toString(),
        'field_hour_price': fieldHourPrice.toString(),
        'field_description': fieldDescription,
        if (imageBase64 != null) 'field_img': imageBase64,
      };

      final response = await http.put(
        Uri.parse('$_baseUrl/fields/$fieldId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      switch (response.statusCode) {
        case 200:
          return responseData; // Return actual data
        case 400:
          throw BadRequestException(responseData['message'] ?? 'Solicitud inválida');
        case 401:
          throw UnauthorizedException(responseData['message'] ?? 'No autorizado');
        case 404:
          throw NotFoundException(responseData['message'] ?? 'Recurso no encontrado');
        case 500:
          throw InternalServerErrorException(responseData['message'] ?? 'Error interno del servidor');
        default:
          throw FetchDataException('Error al actualizar la cancha: ${response.statusCode}');
      }
    } on SocketException {
      throw FetchDataException('No hay conexión a Internet. Verifica tu conexión.');
    } catch (e) {
      throw FetchDataException('Ocurrió un error inesperado: ${e.toString()}');
    }
  }

  // Eliminar cancha - DELETE
  Future<Map<String, dynamic>> deleteField(int fieldId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw UnauthorizedException('Token no encontrado');
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/fields/$fieldId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      switch (response.statusCode) {
        case 200:
          return responseData; // Return actual data
        case 400:
          throw BadRequestException(responseData['message'] ?? 'Solicitud inválida');
        case 401:
          throw UnauthorizedException(responseData['message'] ?? 'No autorizado');
        case 404:
          throw NotFoundException(responseData['message'] ?? 'Recurso no encontrado');
        case 500:
          throw InternalServerErrorException(responseData['message'] ?? 'Error interno del servidor');
        default:
          throw FetchDataException('Error al eliminar la cancha: ${response.statusCode}');
      }
    } on SocketException {
      throw FetchDataException('No hay conexión a Internet. Verifica tu conexión.');
    } catch (e) {
      throw FetchDataException('Ocurrió un error inesperado: ${e.toString()}');
    }
  }

  // Obtener canchas de una empresa específica (para el dueño)
  Future<List<dynamic>> getFieldsByCompany(int companyId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw UnauthorizedException('Token no encontrado');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/fields?company_id=$companyId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final dynamic responseData = jsonDecode(response.body);

      switch (response.statusCode) {
        case 200:
          return responseData is List 
              ? responseData 
              : responseData['data'] ?? responseData['fields'] ?? [];
        case 400:
          throw BadRequestException(responseData['message'] ?? 'Solicitud inválida');
        case 401:
          throw UnauthorizedException(responseData['message'] ?? 'No autorizado');
        case 404:
          throw NotFoundException(responseData['message'] ?? 'Recurso no encontrado');
        case 500:
          throw InternalServerErrorException(responseData['message'] ?? 'Error interno del servidor');
        default:
          throw FetchDataException('Error al cargar las canchas: ${response.statusCode}');
      }
    } on SocketException {
      throw FetchDataException('No hay conexión a Internet. Verifica tu conexión.');
    } catch (e) {
      throw FetchDataException('Ocurrió un error inesperado: ${e.toString()}');
    }
  }

  // Obtener tipos de campo disponibles
  List<String> getFieldTypes() {
    return [
      'Fútbol 5',
      'Fútbol 7',
      'Fútbol 11',
      'Basquet 3x3',
      'Basquet 5x5',
      'Tenis',
      'EcuaVoley'
    ];
  }
}

      