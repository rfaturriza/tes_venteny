part of 'login_bloc.dart';

@freezed
class LoginEvent with _$LoginEvent {
  const factory LoginEvent.submit({
    required LoginRequestModel requestModel,
  }) = _Submit;

  const factory LoginEvent.getUser() = _GetUser;
}