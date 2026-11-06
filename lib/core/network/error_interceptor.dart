import 'package:dio/dio.dart';
import '../errors/app_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = const TimeoutException();
        break;

      case DioExceptionType.connectionError:
        exception = const NetworkException();
        break;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final responseData = err.response?.data;
        String errorMessage = 'সার্ভারে সমস্যা হয়েছে।';

        if (responseData is Map<String, dynamic>) {
          final rawDetail = responseData['detail'] ??
              responseData['message'] ??
              responseData['error'];

          if (rawDetail is String) {
            errorMessage = rawDetail;
          } else if (rawDetail is List) {
            errorMessage = rawDetail.map((e) {
              if (e is Map) {
                final locList = e['loc'];
                final field = (locList is List && locList.isNotEmpty)
                    ? locList.last.toString()
                    : '';
                final msg = e['msg'] ?? 'invalid';
                return field.isNotEmpty ? '$field: $msg' : msg.toString();
              }
              return e.toString();
            }).join(', ');
          } else if (rawDetail != null) {
            errorMessage = rawDetail.toString();
          }
        }

        switch (statusCode) {
          case 400:
            exception = ValidationException(message: errorMessage, statusCode: 400);
            break;
          case 401:
            exception = UnauthorizedException(
              message: errorMessage.isNotEmpty && errorMessage != 'সার্ভারে সমস্যা হয়েছে।'
                  ? errorMessage
                  : 'লগইন তথ্য সঠিক নয়। অনুগ্রহ করে ইমেইল/মোবাইল এবং পাসওয়ার্ড যাচাই করুন।',
            );
            break;
          case 403:
            exception = const ForbiddenException();
            break;
          case 404:
            exception = const NotFoundException();
            break;
          case 422:
            exception = ValidationException(
              message: errorMessage,
              statusCode: 422,
              details: responseData,
            );
            break;
          case 500:
          case 502:
          case 503:
          default:
            exception = ServerException(message: errorMessage, statusCode: statusCode);
            break;
        }
        break;

      case DioExceptionType.cancel:
        exception = const AppException(message: 'অনুরোধটি বাতিল করা হয়েছে।');
        break;

      default:
        exception = const AppException(
          message: 'একটি অপ্রত্যাশিত ত্রুটি ঘটেছে। আবার চেষ্টা করুন।',
        );
        break;
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
      ),
    );
  }
}
