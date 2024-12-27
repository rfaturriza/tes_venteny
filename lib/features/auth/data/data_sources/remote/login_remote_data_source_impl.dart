import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/error/failures.dart';
import '../../models/login_request_model.dart';
import '../../models/login_response_model.dart';
import 'login_remote_data_source.dart';

@LazySingleton(as: LoginRemoteDataSource)
class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  static const _endpointLogin = '/auth/login';
  static const _endpointUser = '/auth/me';

  final Dio _dio;
  final SharedPreferences _sharedPreferences;

  LoginRemoteDataSourceImpl(this._dio, this._sharedPreferences);
  @override
  Future<Either<Failure, LoginResponseModel>> login({
    required LoginRequestModel requestModel,
  }) async {
    try {
      final response = await _dio.post(
        _endpointLogin,
        data: requestModel.toJson(),
      );

      final result = LoginResponseModel.fromJson(response.data);
      if (result.accessToken != null && result.refreshToken != null) {
        await _sharedPreferences.setString(
          'access_token',
          result.accessToken!,
        );
        await _sharedPreferences.setString(
          'refresh_token',
          result.refreshToken!,
        );
      }
      return Right(result);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          message: e.response?.data['message'] ?? 'Unknown error occurred',
        ));
      }
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, LoginResponseModel>> getUser() async {
    try {
      final accessToken = _sharedPreferences.getString('access_token');
      final response = await _dio.get(
        _endpointUser,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      final result = LoginResponseModel.fromJson(response.data);
      return Right(result);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          message: e.response?.data['message'] ?? 'Unknown error occurred',
        ));
      }
      return Left(ServerFailure(message: e.message));
    }
  }
}
