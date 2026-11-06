class AppException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final dynamic details;

  const AppException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.details,
  });

  @override
  String toString() => 'AppException: $message (code: $statusCode, errCode: $errorCode)';
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'ইন্টারনেট সংযোগ নেই। অনুগ্রহ করে আপনার নেটওয়ার্ক পরীক্ষা করুন।',
    super.statusCode,
    super.errorCode = 'NETWORK_ERROR',
  });
}

class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'অনুরোধের সময়সীমা পার হয়ে গেছে। পুনরায় চেষ্টা করুন।',
    super.statusCode,
    super.errorCode = 'TIMEOUT_ERROR',
  });
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'আপনার সেশনটি শেষ হয়ে গেছে। পুনরায় লগইন করুন।',
    super.statusCode = 401,
    super.errorCode = 'UNAUTHORIZED',
  });
}

class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'এই তথ্যটি অ্যাক্সেস করার অনুমতি আপনার নেই।',
    super.statusCode = 403,
    super.errorCode = 'FORBIDDEN',
  });
}

class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'অনুরোধকৃত উপাদানটি পাওয়া যায়নি।',
    super.statusCode = 404,
    super.errorCode = 'NOT_FOUND',
  });
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.statusCode = 422,
    super.errorCode = 'VALIDATION_ERROR',
    super.details,
  });
}

class ServerException extends AppException {
  const ServerException({
    super.message = 'সার্ভারে সমস্যা হয়েছে। পরে আবার চেষ্টা করুন।',
    super.statusCode = 500,
    super.errorCode = 'SERVER_ERROR',
  });
}

class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.errorCode = 'STORAGE_ERROR',
  });
}
