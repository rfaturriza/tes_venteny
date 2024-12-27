import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/login_response_model.dart';

part 'login.freezed.dart';

@freezed
class Login with _$Login {
  const factory Login({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? gender,
    String? image,
    String? accessToken,
    String? refreshToken,
  }) = _Login;

  const Login._();

  factory Login.fromResponseModel(LoginResponseModel response) {
    return Login(
      id: response.id,
      username: response.username,
      email: response.email,
      firstName: response.firstName,
      lastName: response.lastName,
      gender: response.gender,
      image: response.image,
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
  }
}
