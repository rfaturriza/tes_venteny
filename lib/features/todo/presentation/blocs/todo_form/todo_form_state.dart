part of 'todo_form_bloc.dart';

@freezed
class TodoFormState with _$TodoFormState {
  const factory TodoFormState({
    Either<Failure, Todo?>? result,
    @Default(false) bool isSubmitting,
  }) = _TodoFormState;
}
