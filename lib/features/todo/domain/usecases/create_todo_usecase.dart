import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:tes_venteny/core/utils/extension/dartz_ext.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/local_notification.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

@injectable
class CreateTodoUsecase implements UseCase<Todo?, CreateTodoParams> {
  final TodoRepository repository;
  final LocalNotification localNotification;

  CreateTodoUsecase(this.repository, this.localNotification);

  @override
  Future<Either<Failure, Todo?>> call(CreateTodoParams params) async {
    if (params.todo.title?.isEmpty ?? true) {
      return Left(GeneralFailure(message: 'Title cannot be empty'));
    }
    if (params.todo.dueDate == null) {
      return Left(GeneralFailure(message: 'Due date cannot be empty'));
    }
    if (params.todo.status == null) {
      return Left(GeneralFailure(message: 'Status cannot be empty'));
    }
    final result = await repository.createTodo(todo: params.todo);

    if (result.isRight()) {
      final todo = result.asRight();
      if (todo.id == null || todo.dueDate == null) return result;
      await localNotification.schedule(
        id: todo.id!,
        scheduledDate: todo.dueDate!,
        title: 'Reminder Todo',
        body: 'Don\'t forget to do ${todo.title}',
      );
    }

    return result;
  }
}

class CreateTodoParams extends Equatable {
  final Todo todo;

  const CreateTodoParams({
    required this.todo,
  });

  @override
  List<Object?> get props => [todo];
}
