import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tes_venteny/core/error/failures.dart';
import 'package:tes_venteny/features/auth/data/models/login_request_model.dart';
import 'package:tes_venteny/features/auth/domain/entities/login.dart';
import 'package:tes_venteny/features/auth/domain/usecases/get_user_usecase.dart';
import 'package:tes_venteny/features/auth/domain/usecases/login_usecase.dart';
import 'package:tes_venteny/features/auth/presentation/blocs/login/login_bloc.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockGetUserUsecase extends Mock implements GetUserUsecase {}

void main() {
  late LoginBloc loginBloc;
  late MockLoginUsecase mockLoginUsecase;
  late MockGetUserUsecase mockGetUserUsecase;

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockGetUserUsecase = MockGetUserUsecase();
    loginBloc = LoginBloc(mockLoginUsecase, mockGetUserUsecase);
  });

  setUpAll(() {
    registerFallbackValue(LoginParams(
        requestModel: LoginRequestModel(
      username: 'username',
      password: 'password',
    )));
  });

  test('initial state should be LoginState.initial()', () {
    expect(loginBloc.state, equals(const LoginState.initial()));
  });

  blocTest<LoginBloc, LoginState>(
    'emits [LoginState.loading(), LoginState.success(data)] when login is successful',
    build: () {
      when(() => mockLoginUsecase.call(any())).thenAnswer(
        (_) async => Right(Login(id: 2)),
      );
      return loginBloc;
    },
    act: (bloc) => bloc.add(LoginEvent.submit(
        requestModel: LoginRequestModel(
      username: 'username',
      password: 'password',
    ))),
    expect: () => [
      const LoginState.loading(),
      LoginState.success(Login(id: 2)),
    ],
    verify: (_) {
      verify(() => mockLoginUsecase.call(any())).called(1);
    },
  );

  blocTest<LoginBloc, LoginState>(
    'emits [LoginState.loading(), LoginState.error(failure)] when login fails',
    build: () {
      when(() => mockLoginUsecase.call(any())).thenAnswer(
        (_) async => Left(ServerFailure()),
      );
      return loginBloc;
    },
    act: (bloc) => bloc.add(LoginEvent.submit(
        requestModel: LoginRequestModel(
      username: 'username',
      password: 'password',
    ))),
    expect: () => [
      const LoginState.loading(),
      LoginState.error(ServerFailure()),
    ],
    verify: (_) {
      verify(() => mockLoginUsecase.call(any())).called(1);
    },
  );
}
