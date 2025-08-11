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
    required String token,
    required String fieldName,
    required String fieldType,
    required String fieldSize,
    required int fieldMaxCapacity,
    required double fieldHourPrice,
    required String fieldDescription,
    File? fieldImage,
  }) async {
    try {
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

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Cancha creada exitosamente'};
      } else {
        return {
          'success': false,
          'message': jsonDecode(responseData)['message'] ?? 'Error desconocido'
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  
  }

  // Obtener todas las canchas disponibles (para jugadores/clientes) - READ
  Future<Map<String, dynamic>> getAllFields() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/fields'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        // Manejar tanto si viene como array directo o dentro de un objeto
        final List<dynamic> fieldsData = responseData is List 
            ? responseData 
            : responseData['data'] ?? responseData['fields'] ?? [];
        
        return {
          'success': true,
          'data': fieldsData,
        };
      } else {
        return {
          'success': false,
          'message': 'Error al cargar las canchas: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
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

      if (response.statusCode == 200) {
        final Map<String, dynamic> fieldData = jsonDecode(response.body);
        return {
          'success': true,
          'data': fieldData,
        };
      } else {
        return {
          'success': false,
          'message': 'Error al cargar la cancha: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
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
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token no encontrado'};
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

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Cancha actualizada exitosamente',
          'data': jsonDecode(response.body)
        };
      } else {
        return {
          'success': false,
          'message': 'Error al actualizar la cancha: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
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
        return {'success': false, 'message': 'Token no encontrado'};
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

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Cancha creada exitosamente'};
      } else {
        return {
          'success': false,
          'message': jsonDecode(responseData)['message'] ?? 'Error desconocido'
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  
  }

  // Obtener todas las canchas disponibles (para jugadores/clientes) - READ
  Future<Map<String, dynamic>> getAllFields() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/fields'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        // Manejar tanto si viene como array directo o dentro de un objeto
        final List<dynamic> fieldsData = responseData is List 
            ? responseData 
            : responseData['data'] ?? responseData['fields'] ?? [];
        
        return {
          'success': true,
          'data': fieldsData,
        };
      } else {
        return {
          'success': false,
          'message': 'Error al cargar las canchas: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
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

      if (response.statusCode == 200) {
        final Map<String, dynamic> fieldData = jsonDecode(response.body);
        return {
          'success': true,
          'data': fieldData,
        };
      } else {
        return {
          'success': false,
          'message': 'Error al cargar la cancha: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
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
        return {'success': false, 'message': 'Token no encontrado'};
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

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Cancha actualizada exitosamente',
          'data': jsonDecode(response.body)
        };
      } else {
        return {
          'success': false,
          'message': 'Error al actualizar la cancha: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
    }
  }

  // Eliminar cancha - DELETE
  Future<Map<String, dynamic>> deleteField(int fieldId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token no encontrado'};
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/fields/$fieldId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Cancha eliminada exitosamente'
        };
      } else {
        return {
          'success': false,
          'message': 'Error al eliminar la cancha: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
    }
  }

  // Obtener canchas de una empresa específica (para el dueño)
  Future<Map<String, dynamic>> getFieldsByCompany(int companyId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token no encontrado'};
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/fields?company_id=$companyId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        final List<dynamic> fieldsData = responseData is List 
            ? responseData 
            : responseData['data'] ?? responseData['fields'] ?? [];
        
        return {
          'success': true,
          'data': fieldsData,
        };
      } else {
        return {
          'success': false,
          'message': 'Error al cargar las canchas: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
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

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Cancha eliminada exitosamente'
        };
      } else {
        return {
          'success': false,
          'message': 'Error al eliminar la cancha: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
    }
  }

  // Obtener canchas de una empresa específica (para el dueño)
  Future<Map<String, dynamic>> getFieldsByCompany(int companyId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token no encontrado'};
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/fields?company_id=$companyId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        final List<dynamic> fieldsData = responseData is List 
            ? responseData 
            : responseData['data'] ?? responseData['fields'] ?? [];
        
        return {
          'success': true,
          'data': fieldsData,
        };
      } else {
        return {
          'success': false,
          'message': 'Error al cargar las canchas: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
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