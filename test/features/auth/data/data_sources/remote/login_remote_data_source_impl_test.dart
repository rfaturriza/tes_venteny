import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tes_venteny/core/error/failures.dart';
import 'package:tes_venteny/features/auth/data/data_sources/remote/login_remote_data_source_impl.dart';
import 'package:tes_venteny/features/auth/data/models/login_request_model.dart';
import 'package:tes_venteny/features/auth/data/models/login_response_model.dart';

class MockDio extends Mock implements Dio {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late LoginRemoteDataSourceImpl dataSource;
  late MockDio mockDio;
  late MockSharedPreferences mockSharedPreferences;

  setUpAll(() {
    registerFallbackValue(Uri());
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = MockDio();
    mockSharedPreferences = MockSharedPreferences();
    dataSource = LoginRemoteDataSourceImpl(mockDio, mockSharedPreferences);
  });

  group('login', () {
    final tLoginRequestModel = LoginRequestModel(
      username: 'username',
      password: 'password',
    );
    final tLoginModel = LoginResponseModel(
      id: 1,
      username: 'name',
    );

    test('should return LoginResponseModel when the call to Dio is successful',
        () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: {
            'id': 1,
            'username': 'name',
          },
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // act
      final result = await dataSource.login(requestModel: tLoginRequestModel);

      // assert
      expect(result.isRight(), true);
      expect(result.getOrElse(() => LoginResponseModel()), tLoginModel);
      verify(
        () => mockDio.post('/auth/login', data: tLoginRequestModel.toJson()),
      ).called(1);
    });

    test('should return ServerFailure when the call to Dio is unsuccessful',
        () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          response: Response(
            data: {'message': 'Error occurred'},
            requestOptions: RequestOptions(path: ''),
          ),
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // act
      final result = await dataSource.login(requestModel: tLoginRequestModel);

      // assert
      expect(result, Left(ServerFailure(message: 'Error occurred')));
      verify(
        () => mockDio.post('/auth/login', data: tLoginRequestModel.toJson()),
      ).called(1);
    });

    test(
        'should return ServerFailure with message when DioException has no response',
        () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'No response',
        ),
      );

      // act
      final result = await dataSource.login(requestModel: tLoginRequestModel);

      // assert
      expect(result, Left(ServerFailure(message: 'No response')));
      verify(
        () => mockDio.post('/auth/login', data: tLoginRequestModel.toJson()),
      ).called(1);
    });
  });
}
