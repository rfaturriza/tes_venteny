part of 'todo_bloc.dart';

@freezed
class TodoState with _$TodoState {
  const factory TodoState({
    @Default(1) int page,
    @Default(20) int limit,
    String? titleSearch,
    TodoStatus? filterStatus,
    Either<Failure, Pagination<Todo?>>? todos,
    Either<Failure, Unit?>? deleteTodo,
    @Default(false) bool isFetching,
    @Default(false) bool isDeleting,
  }) = _TodoState;
}
