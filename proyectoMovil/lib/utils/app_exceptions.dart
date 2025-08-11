class AppException implements Exception {
  final String message;
  final String? prefix;

  AppException(this.message, [this.prefix]);

  @override
  String toString() {
    return "${prefix ?? ""}$message";
  }
}

class FetchDataException extends AppException {
  FetchDataException([String? message])
      : super(message ?? "Error durante la comunicación", "Error de Conexión: ");
}

class BadRequestException extends AppException {
  BadRequestException([String? message])
      : super(message ?? "Solicitud inválida", "Solicitud Inválida: ");
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String? message])
      : super(message ?? "No autorizado", "No Autorizado: ");
}

class NotFoundException extends AppException {
  NotFoundException([String? message])
      : super(message ?? "Recurso no encontrado", "No Encontrado: ");
}

class InternalServerErrorException extends AppException {
  InternalServerErrorException([String? message])
      : super(message ?? "Error interno del servidor", "Error del Servidor: ");
}

class InvalidInputException extends AppException {
  InvalidInputException([String? message])
      : super(message ?? "Entrada inválida", "Entrada Inválida: ");
}
