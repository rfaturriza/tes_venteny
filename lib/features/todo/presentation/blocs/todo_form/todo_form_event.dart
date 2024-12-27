part of 'todo_form_bloc.dart';

@freezed
class TodoFormEvent with _$TodoFormEvent {
  const factory TodoFormEvent.createTodo({
    required Todo todo,
  }) = _CreateTodo;
  const factory TodoFormEvent.updateTodo({
    required Todo todo,
  }) = _UpdateTodo;
}
