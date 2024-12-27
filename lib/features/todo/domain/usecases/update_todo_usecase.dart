import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

@injectable
class UpdateTodoUsecase implements UseCase<Todo?, UpdateTodoParams> {
  final TodoRepository repository;

  UpdateTodoUsecase(this.repository);

  @override
  Future<Either<Failure, Todo?>> call(UpdateTodoParams params) async {
    return await repository.updateTodo(todo: params.todo);
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
