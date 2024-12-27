import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/pagination_entity.dart';
import '../entities/todo.dart';

abstract class TodoRepository {
  Future<Either<Failure, Pagination<Todo>>> getTodos({
    int? page,
    int? limit,
    String? search,
    TodoStatus? status,
  });

  Future<Either<Failure, Todo>> getTodoById({
    required String id,
  });

  Future<Either<Failure, Todo>> createTodo({
    required Todo todo,
  });

  Future<Either<Failure, Todo>> updateTodo({
    required Todo todo,
  });

  Future<Either<Failure, Unit>> deleteTodo({
    required int id,
  });

  Future<Either<Failure, Unit>> syncTodos();
}
