import 'package:dartz/dartz.dart';
import 'package:tes_venteny/shared/data/models/outbox_model.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../shared/data/models/pagination_response_model.dart';
import '../../models/todo_local_model.dart';

abstract class TodoLocalDataSource {
  Future<Either<Failure, PaginationResponseModel<TodoLocalModel>>> getTodos({
    int? page,
    int? limit,
    String? search,
    String? status,
  });

  Future<Either<Failure, TodoLocalModel>> getTodoById({
    required String id,
  });

  Future<Either<Failure, TodoLocalModel>> createTodo({
    required TodoLocalModel todo,
  });

  Future<Either<Failure, TodoLocalModel>> updateTodo({
    required TodoLocalModel todo,
  });

  Future<Either<Failure, Unit>> deleteAllTodo();
  
  Future<Either<Failure, Unit>> deleteTodo({
    required int? id,
  });

  Future<Either<Failure, List<OutboxModel>>> getUnsyncedTodos();

  Future<Either<Failure, Unit>> saveTodos(
    List<TodoLocalModel> todos,
  );

  Future<Either<Failure, Unit>> saveOutbox(
    OutboxModel outbox,
  );
  

  Future<Either<Failure, Unit>> deleteOutbox(
    int? id,
  );
}
