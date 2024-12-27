import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:tes_venteny/features/auth/domain/entities/login.dart';
import '/core/error/failures.dart';
import '/core/usecases/usecase.dart';
import '/features/auth/data/models/login_request_model.dart';
import '/features/auth/domain/repositories/login_repository.dart';

@injectable
class LoginUsecase implements UseCase<Login?, LoginParams> {
  final LoginRepository repository;

  LoginUsecase(this.repository);

  @override
  Future<Either<Failure, Login?>> call(LoginParams params) async {
    return await repository.login(
      requestModel: params.requestModel,
    );
  }
}

class LoginParams extends Equatable {
  final LoginRequestModel requestModel;

  const LoginParams({
    required this.requestModel,
  });

  @override
  List<Object?> get props => [requestModel];
}