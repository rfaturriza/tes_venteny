import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/login_request_model.dart';
import '../entities/login.dart';

abstract class LoginRepository {
  Future<Either<Failure, Login?>> login({
    required LoginRequestModel requestModel,
  });

  Future<Either<Failure, Login?>> getUser();
}
