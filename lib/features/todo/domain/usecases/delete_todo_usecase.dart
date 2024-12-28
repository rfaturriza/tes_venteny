import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/local_notification.dart';
import '../repositories/todo_repository.dart';

@injectable
class DeleteTodoUsecase implements UseCase<Unit, int> {
  final TodoRepository repository;
  final LocalNotification localNotification;

  DeleteTodoUsecase(this.repository, this.localNotification);

  @override
  Future<Either<Failure, Unit>> call(
    int id,
  ) async {
    final result = await repository.deleteTodo(id: id);

    if (result.isRight()) {
      await localNotification.cancel(id);
    }

    return result;
  }
}
