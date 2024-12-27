import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tes_venteny/features/auth/domain/entities/login.dart';
import '/core/error/failures.dart';
import '/features/auth/data/data_sources/remote/login_remote_data_source.dart';
import '/features/auth/data/models/login_request_model.dart';
import '/features/auth/domain/repositories/login_repository.dart';

@LazySingleton(as: LoginRepository)
class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDataSource remoteDataSource;

  LoginRepositoryImpl(this.remoteDataSource);
  @override
  Future<Either<Failure, Login?>> login({
    required LoginRequestModel requestModel,
  }) async {
    final result = await remoteDataSource.login(
      requestModel: requestModel,
    );
    return result.fold(
      (l) => Left(l),
      (r) => Right(r.toEntity()),
    );
  }

  @override
  Future<Either<Failure, Login?>> getUser() async {
    final result = await remoteDataSource.getUser();
    return result.fold(
      (l) => Left(l),
      (r) => Right(r.toEntity()),
    );
  }
}
