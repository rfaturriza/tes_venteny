import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

@injectable
class CreateTodoUsecase implements UseCase<Todo?, CreateTodoParams> {
  final TodoRepository repository;

  CreateTodoUsecase(this.repository);

  @override
  Future<Either<Failure, Todo?>> call(CreateTodoParams params) async {
    return await repository.createTodo(todo: params.todo);
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