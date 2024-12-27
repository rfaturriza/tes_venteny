import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:injectable/injectable.dart';

@injectable
class NetworkConfig {
  static const baseUrl = 'https://dummyjson.com/';
  static const refreshToken =
      'refresh_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJsZXZlbCI6IiIsInBlcm1pc3Npb25zIjpudWxsLCJ1c2VyX25hbWUiOiIiLCJzaXRlX25hbWUiOiIiLCJleHAiOjE3MzU4NzEzODYsImlzcyI6IjEyMzQ1In0.tRor5YBjhAeiBSfYaDGEh9PR1pP_wKbRRt4r96ReoDo;';

  static var accessToken = '';

  static var unitId = '';

  static final _baseOptions = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  static Dio getDio() {
    final dio = Dio(_baseOptions);
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        responseBody: true,
        requestBody: true,
        requestHeader: true,
        responseHeader: true,
      ),
    );
    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      logPrint: print,
      retries: 3,
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 3),
      ],
    ));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        options.headers['Cookie'] = '$refreshToken $accessToken';
        return handler.next(options);
      },
    ));
    return dio;
  }
}
