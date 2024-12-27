import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:tes_venteny/features/auth/domain/entities/login.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/get_user_usecase.dart';
import '/core/error/failures.dart';
import '/features/auth/data/models/login_request_model.dart';
import '/features/auth/domain/usecases/login_usecase.dart';

part 'login_state.dart';
part 'login_event.dart';
part 'login_bloc.freezed.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUsecase _loginUsecase;
  final GetUserUsecase _getUserUsecase;

  LoginBloc(
    this._loginUsecase,
    this._getUserUsecase,
  ) : super(const LoginState.initial()) {
    on<_GetUser>(_onGetUser);
    on<_Submit>(_onSubmit);
  }

  void _onGetUser(
    _GetUser event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginState.gettingUser());
    final result = await _getUserUsecase(NoParams());
    emit(result.fold(
      (failure) => LoginState.error(failure),
      (data) => LoginState.success(data),
    ));
  }

  void _onSubmit(
    _Submit event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginState.loading());
    final result = await _loginUsecase(
      LoginParams(
        requestModel: event.requestModel,
      ),
    );
    emit(result.fold(
      (failure) => LoginState.error(failure),
      (data) => LoginState.success(data),
    ));
  }
}
