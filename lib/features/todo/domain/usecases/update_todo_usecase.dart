import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:tes_venteny/core/utils/extension/dartz_ext.dart';
import 'package:tes_venteny/core/utils/local_notification.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

@injectable
class UpdateTodoUsecase implements UseCase<Todo?, UpdateTodoParams> {
  final TodoRepository repository;
  final LocalNotification localNotification;

  UpdateTodoUsecase(this.repository, this.localNotification);

  @override
  Future<Either<Failure, Todo?>> call(UpdateTodoParams params) async {
    final result = await repository.updateTodo(todo: params.todo);

    if (result.isRight()) {
      final todo = result.asRight();
      if (todo.id == null || todo.dueDate == null) return result;
      await localNotification.cancel(todo.id!);
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

class UpdateTodoParams extends Equatable {
  final Todo todo;

  const UpdateTodoParams({
    required this.todo,
  });

  @override
  List<Object?> get props => [todo];
}
