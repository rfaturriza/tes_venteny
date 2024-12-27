import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/entities/todo.dart';
import '../../../domain/usecases/create_todo_usecase.dart';
import '../../../domain/usecases/update_todo_usecase.dart';

part 'todo_form_state.dart';
part 'todo_form_event.dart';
part 'todo_form_bloc.freezed.dart';

@injectable
class TodoFormBloc extends Bloc<TodoFormEvent, TodoFormState> {
  final CreateTodoUsecase _createTodo;
  final UpdateTodoUsecase _updateTodo;
  TodoFormBloc(this._createTodo, this._updateTodo)
      : super(const TodoFormState()) {
    on<_CreateTodo>((event, emit) async {
      emit(state.copyWith(isSubmitting: true));
      final result = await _createTodo(CreateTodoParams(todo: event.todo));
      emit(state.copyWith(
        isSubmitting: false,
        result: result,
      ));
    });

    on<_UpdateTodo>((event, emit) async {
      emit(state.copyWith(isSubmitting: true));
      final result = await _updateTodo(UpdateTodoParams(todo: event.todo));
      emit(state.copyWith(
        isSubmitting: false,
        result: result,
      ));
    });
  }
}
