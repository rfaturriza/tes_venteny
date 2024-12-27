import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/todo_repository.dart';

@injectable
class DeleteTodoUsecase implements UseCase<Unit, int> {
  final TodoRepository repository;

  DeleteTodoUsecase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(
    int id,
  ) async {
    return await repository.deleteTodo(id: id);
  }
}
