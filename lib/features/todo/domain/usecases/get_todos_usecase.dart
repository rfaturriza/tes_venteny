import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:tes_venteny/shared/domain/entities/pagination_entity.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

@injectable
class GetTodosUsecase implements UseCase<Pagination<Todo?>, GetTodosParams> {
  final TodoRepository repository;

  GetTodosUsecase(this.repository);

  @override
  Future<Either<Failure, Pagination<Todo?>>> call(
    GetTodosParams params,
  ) async {
    return await repository.getTodos(
      page: params.page,
      limit: params.limit,
      search: params.search,
      status: params.status,
    );
  }
}

class GetTodosParams extends Equatable {
  final int page;
  final int limit;
  final String? search;
  final TodoStatus? status;
  const GetTodosParams({
    required this.page,
    required this.limit,
    this.search,
    this.status,
  });

  @override
  List<Object?> get props => [
        page,
        limit,
        search,
        status,
      ];
}
