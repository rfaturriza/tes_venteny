import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tes_venteny/core/error/failures.dart';
import 'package:tes_venteny/core/usecases/usecase.dart';
import 'package:tes_venteny/features/todo/domain/entities/todo.dart';
import 'package:tes_venteny/features/todo/domain/usecases/delete_todo_usecase.dart';
import 'package:tes_venteny/features/todo/domain/usecases/get_todos_usecase.dart';
import 'package:tes_venteny/features/todo/domain/usecases/sync_todo_usecase.dart';
import 'package:tes_venteny/features/todo/presentation/blocs/todo/todo_bloc.dart';
import 'package:tes_venteny/shared/domain/entities/pagination_entity.dart';

class MockGetTodosUsecase extends Mock implements GetTodosUsecase {}

class MockDeleteTodoUsecase extends Mock implements DeleteTodoUsecase {}

class MockSyncTodosUseCase extends Mock implements SyncTodosUseCase {}

void main() {
  late TodoBloc todoBloc;
  late MockGetTodosUsecase mockGetTodosUsecase;
  late MockDeleteTodoUsecase mockDeleteTodoUsecase;
  late MockSyncTodosUseCase mockSyncTodosUseCase;

  setUp(() {
    mockGetTodosUsecase = MockGetTodosUsecase();
    mockDeleteTodoUsecase = MockDeleteTodoUsecase();
    mockSyncTodosUseCase = MockSyncTodosUseCase();

    when(() => mockSyncTodosUseCase.call(any())).thenAnswer(
      (_) => Stream.value(Right(FormzSubmissionStatus.success)),
    );
    todoBloc = TodoBloc(
      mockGetTodosUsecase,
      mockDeleteTodoUsecase,
      mockSyncTodosUseCase,
    );
  });

  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFallbackValue(GetTodosParams(
      page: 1,
      limit: 1,
    ));
  });

  test('initial state should be TodoState()', () {
    expect(todoBloc.state, equals(const TodoState()));
  });

  blocTest<TodoBloc, TodoState>(
    'emits [TodoState(isFetching: true), TodoState(isFetching: false, todos: data)] when _GetTodos is added and successful',
    build: () {
      when(() => mockGetTodosUsecase.call(any())).thenAnswer(
        (_) async => Right(
          const Pagination<Todo>(
            data: [Todo(id: 1, title: 'Test Todo')],
          ),
        ),
      );
      return todoBloc;
    },
    act: (bloc) => bloc.add(const TodoEvent.getTodos()),
    expect: () => [
      const TodoState(isFetching: true),
      TodoState(
        isFetching: false,
        todos: right(Pagination<Todo>(data: [Todo(id: 1, title: 'Test Todo')])),
      ),
    ],
    verify: (_) {
      verify(() => mockGetTodosUsecase.call(any())).called(1);
    },
  );

  blocTest<TodoBloc, TodoState>(
    'emits [TodoState(isDeleting: true), TodoState(isDeleting: false, deleteTodo: data)] when _DeleteTodo is added and successful',
    build: () {
      when(() => mockDeleteTodoUsecase.call(any())).thenAnswer(
        (_) async => Right(unit),
      );
      return todoBloc;
    },
    act: (bloc) => bloc.add(const TodoEvent.deleteTodo(id: 1)),
    expect: () => [
      const TodoState(isDeleting: true),
      const TodoState(isDeleting: false, deleteTodo: Right(unit)),
    ],
    verify: (_) {
      verify(() => mockDeleteTodoUsecase.call(any())).called(1);
    },
  );

  blocTest<TodoBloc, TodoState>(
    'emits [TodoState(isFetching: true), TodoState(isFetching: false)] when _GetTodos is added and fails',
    build: () {
      when(() => mockGetTodosUsecase.call(any())).thenAnswer(
        (_) async => Left(ServerFailure()),
      );
      return todoBloc;
    },
    act: (bloc) => bloc.add(const TodoEvent.getTodos()),
    expect: () => [
      const TodoState(isFetching: true),
      const TodoState(isFetching: false, todos: Left(ServerFailure())),
    ],
    verify: (_) {
      verify(() => mockGetTodosUsecase.call(any())).called(1);
    },
  );

  blocTest<TodoBloc, TodoState>(
    'emits [TodoState(isDeleting: true), TodoState(isDeleting: false)] when _DeleteTodo is added and fails',
    build: () {
      when(() => mockDeleteTodoUsecase.call(any())).thenAnswer(
        (_) async => Left(ServerFailure()),
      );
      return todoBloc;
    },
    act: (bloc) => bloc.add(const TodoEvent.deleteTodo(id: 1)),
    expect: () => [
      const TodoState(isDeleting: true),
      const TodoState(isDeleting: false, deleteTodo: Left(ServerFailure())),
    ],
    verify: (_) {
      verify(() => mockDeleteTodoUsecase.call(any())).called(1);
    },
  );
}
