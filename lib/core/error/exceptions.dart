import 'dart:io';

import 'package:dio/dio.dart';

class ServerException implements Exception {
  final Exception _exception;

  ServerException(Exception exception) : _exception = exception;

  String get message {
    if (_exception is DioException) {
      return _dioMessage;
    } else if (_exception is SocketException) {
      return 'No Internet Connection';
    } else {
      return 'Unknown Error';
    }
  }

  String get _dioMessage {
    switch ((_exception as DioException).type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection Timeout';
      case DioExceptionType.sendTimeout:
        return 'Send Timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive Timeout';
      case DioExceptionType.badResponse:
        return 'Bad Response';
      case DioExceptionType.cancel:
        return 'Request Cancelled';
      case DioExceptionType.badCertificate:
        return 'Bad Certificate';
      default:
        return 'Unknown Error';
    }
  }
}

class CacheException implements Exception {}
