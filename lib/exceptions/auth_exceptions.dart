class AuthException implements Exception {
  final String message;
  final String? code;
  
  AuthException(this.message, {this.code});
  
  @override
  String toString() => 'AuthException: $message';
}

class NetworkException extends AuthException {
  NetworkException(String message) : super(message, code: 'network_error');
  
  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException extends AuthException {
  ValidationException(String message) : super(message, code: 'validation_error');
  
  @override
  String toString() => 'ValidationException: $message';
}

class ServerException extends AuthException {
  ServerException(String message) : super(message, code: 'server_error');
  
  @override
  String toString() => 'ServerException: $message';
}

class AuthenticationException extends AuthException {
  AuthenticationException(String message) : super(message, code: 'auth_error');
  
  @override
  String toString() => 'AuthenticationException: $message';
}

class TokenExpiredException extends AuthException {
  TokenExpiredException(String message) : super(message, code: 'token_expired');
  
  @override
  String toString() => 'TokenExpiredException: $message';
}