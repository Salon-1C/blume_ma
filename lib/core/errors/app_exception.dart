class AppException implements Exception {
  final String code;
  final String message;

  const AppException({required this.code, required this.message});

  @override
  String toString() => message;

  static AppException fromApiError(Map<String, dynamic> json) {
    return AppException(
      code: json['error'] as String? ?? 'UNKNOWN_ERROR',
      message: json['message'] as String? ?? 'Ocurrió un error inesperado',
    );
  }
}

class NetworkException extends AppException {
  const NetworkException()
      : super(code: 'NETWORK_ERROR', message: 'Sin conexión. Verifica tu red.');
}

class UnauthorizedException extends AppException {
  const UnauthorizedException()
      : super(code: 'UNAUTHORIZED', message: 'Sesión expirada. Inicia sesión de nuevo.');
}

class NotFoundException extends AppException {
  const NotFoundException()
      : super(code: 'NOT_FOUND', message: 'Recurso no encontrado.');
}
