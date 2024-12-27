import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:dartz/dartz.dart';
import 'package:formz/formz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/todo_repository.dart';

@injectable
class SyncTodosUseCase
    implements StreamUseCase<FormzSubmissionStatus, NoParams> {
  final TodoRepository repository;
  final Connectivity connectivity;

  SyncTodosUseCase(this.repository, this.connectivity);

  @override
  Stream<Either<Failure, FormzSubmissionStatus>> call(NoParams params) {
    return connectivity.onConnectivityChanged.asyncMap((event) async {
      if (event.contains(ConnectivityResult.none)) {
        return Left(ServerFailure(message: 'No internet connection'));
      }
      final ping = await Ping('google.com', count: 5).stream.last;
      if (ping.error != null) {
        return Left(ServerFailure(message: 'No internet connection'));
      }
      final resultSync = await repository.syncTodos();
      return resultSync.fold((l) {
        return Left(l);
      }, (r) {
        return Right(FormzSubmissionStatus.success);
      });
    });
  }
}
