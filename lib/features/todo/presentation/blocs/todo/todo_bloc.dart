import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:tes_venteny/core/usecases/usecase.dart';
import 'package:tes_venteny/features/todo/domain/usecases/sync_todo_usecase.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../shared/domain/entities/pagination_entity.dart';
import '../../../domain/entities/todo.dart';
import '../../../domain/usecases/delete_todo_usecase.dart';
import '../../../domain/usecases/get_todos_usecase.dart';

part 'todo_state.dart';
part 'todo_event.dart';
part 'todo_bloc.freezed.dart';

@injectable
class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final GetTodosUsecase _getTodos;
  final DeleteTodoUsecase _deleteTodo;
  final SyncTodosUseCase _syncTodos;

  late StreamSubscription _syncSubscription;
  TodoBloc(
    this._getTodos,
    this._deleteTodo,
    this._syncTodos,
  ) : super(const TodoState()) {
    _syncSubscription = _syncTodos(NoParams()).listen((event) {
      event.fold(
        (failure) {
          print('Error');
        },
        (status) {
          print('Success');
        },
      );
    });

    on<_ChangeFilterStatus>(_onChangeFilterStatus);

    on<_ChangeSearchTitle>(_onChangeSearchTitle);

    on<_ChangePage>(_onChangePage);

    on<_ChangeLimit>(_onChangeLimit);

    on<_GetTodos>(_onGetTodos);

    on<_DeleteTodo>(_onDeleteTodo);
  }

  void _onChangeFilterStatus(
    _ChangeFilterStatus event,
    Emitter<TodoState> emit,
  ) {
    emit(state.copyWith(filterStatus: event.status));
    add(const _GetTodos());
  }

  void _onChangeSearchTitle(
    _ChangeSearchTitle event,
    Emitter<TodoState> emit,
  ) {
    emit(state.copyWith(titleSearch: event.title));
    add(const _GetTodos());
  }

  void _onChangePage(
    _ChangePage event,
    Emitter<TodoState> emit,
  ) {
    emit(state.copyWith(page: event.page));
    add(const _GetTodos());
  }

  void _onChangeLimit(_ChangeLimit event, Emitter<TodoState> emit) {
    emit(state.copyWith(limit: event.limit));
    add(const _GetTodos());
  }

  void _onGetTodos(_GetTodos event, Emitter<TodoState> emit) async {
    emit(state.copyWith(isFetching: true));
    final result = await _getTodos(
      GetTodosParams(
        page: state.page,
        limit: state.limit,
        search: state.titleSearch,
        status: state.filterStatus,
      ),
    );
    emit(state.copyWith(
      isFetching: false,
      todos: result,
    ));
  }

  void _onDeleteTodo(_DeleteTodo event, Emitter<TodoState> emit) async {
    emit(state.copyWith(isDeleting: true));
    final result = await _deleteTodo(event.id);
    emit(state.copyWith(
      isDeleting: false,
      deleteTodo: result,
    ));
  }

  @override
  Future<void> close() {
    _syncSubscription.cancel();
    return super.close();
  }
}
