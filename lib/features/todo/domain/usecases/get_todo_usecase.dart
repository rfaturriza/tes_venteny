import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

@injectable
class GetTodoUsecase implements UseCase<Todo?, String> {
  final TodoRepository repository;

  GetTodoUsecase(this.repository);

  @override
  Future<Either<Failure, Todo?>> call(
    String id,
  ) async {
    return await repository.getTodoById(
      id: id,
    );
  }
}
