import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tes_venteny/features/auth/domain/entities/login.dart';
import '/core/error/failures.dart';
import '/core/usecases/usecase.dart';
import '/features/auth/domain/repositories/login_repository.dart';

@injectable
class GetUserUsecase implements UseCase<Login?, NoParams> {
  final LoginRepository repository;

  GetUserUsecase(this.repository);

  @override
  Future<Either<Failure, Login?>> call(NoParams params) async {
    return await repository.getUser();
  }
}
