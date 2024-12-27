import 'package:dartz/dartz.dart';
import 'package:tes_venteny/features/auth/data/models/login_request_model.dart';
import 'package:tes_venteny/features/auth/data/models/login_response_model.dart';

import '../../../../../core/error/failures.dart';

abstract class LoginRemoteDataSource {
  Future<Either<Failure, LoginResponseModel>> login({
   required LoginRequestModel requestModel,
  });

  Future<Either<Failure, LoginResponseModel>> getUser();
}