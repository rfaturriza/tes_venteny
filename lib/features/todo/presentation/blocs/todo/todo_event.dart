part of 'todo_bloc.dart';

@freezed
class TodoEvent with _$TodoEvent {
  const factory TodoEvent.changeFilterStatus([
    TodoStatus? status,
  ]) = _ChangeFilterStatus;

  const factory TodoEvent.changeSearchTitle(
    String title,
  ) = _ChangeSearchTitle;

  const factory TodoEvent.changePage(
    int page,
  ) = _ChangePage;

  const factory TodoEvent.changeLimit(
    int limit,
  ) = _ChangeLimit;

  const factory TodoEvent.getTodos() = _GetTodos;

  const factory TodoEvent.deleteTodo({
    required int id,
  }) = _DeleteTodo;
}
