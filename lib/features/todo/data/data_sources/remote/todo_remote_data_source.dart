import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../shared/data/models/pagination_response_model.dart';
import '../../models/todo_remote_model.dart';

abstract class TodoRemoteDataSource {
  Future<Either<Failure, PaginationResponseModel<TodoRemoteModel>>> getTodos({
    int? page,
    int? limit,
    String? search,
    String? status,
  });

  Future<Either<Failure, TodoRemoteModel>> getTodoById({
    required String id,
  });

  Future<Either<Failure, TodoRemoteModel>> createTodo({
    required TodoRemoteModel todo,
  });

  Future<Either<Failure, TodoRemoteModel>> updateTodo({
    required TodoRemoteModel todo,
  });

  Future<Either<Failure, Unit>> deleteTodo({
    required int id,
  });
}
