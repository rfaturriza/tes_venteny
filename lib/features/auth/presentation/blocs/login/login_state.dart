part of 'login_bloc.dart';

@freezed
class LoginState with _$LoginState {
  const factory LoginState.initial() = InitialLogin;
  const factory LoginState.gettingUser() = GettingUser;
  const factory LoginState.loading() = LoadingLogin;
  const factory LoginState.success(Login? login) = SuccessLogin;
  const factory LoginState.error(Failure failure) = ErrorLogin;
}