import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tes_venteny/core/error/failures.dart';
import 'package:tes_venteny/features/todo/domain/entities/todo.dart';
import 'package:tes_venteny/features/todo/domain/usecases/create_todo_usecase.dart';
import 'package:tes_venteny/features/todo/domain/usecases/update_todo_usecase.dart';
import 'package:tes_venteny/features/todo/presentation/blocs/todo_form/todo_form_bloc.dart';

class MockCreateTodoUsecase extends Mock implements CreateTodoUsecase {}

class MockUpdateTodoUsecase extends Mock implements UpdateTodoUsecase {}

void main() {
  late TodoFormBloc todoFormBloc;
  late MockCreateTodoUsecase mockCreateTodoUsecase;
  late MockUpdateTodoUsecase mockUpdateTodoUsecase;

  setUp(() {
    mockCreateTodoUsecase = MockCreateTodoUsecase();
    mockUpdateTodoUsecase = MockUpdateTodoUsecase();
    todoFormBloc = TodoFormBloc(mockCreateTodoUsecase, mockUpdateTodoUsecase);
  });

  setUpAll(() {
    registerFallbackValue(CreateTodoParams(
        todo: Todo(
      id: 1,
      title: 'Test Todo',
    )));
    registerFallbackValue(UpdateTodoParams(
        todo: Todo(
      id: 1,
      title: 'Updated Todo',
    )));
  });

  test('initial state should be TodoFormState()', () {
    expect(todoFormBloc.state, equals(const TodoFormState()));
  });

  blocTest<TodoFormBloc, TodoFormState>(
    'emits [TodoFormState(isSubmitting: true), TodoFormState(isSubmitting: false, result: Right(unit))] when _CreateTodo is added and successful',
    build: () {
      when(() => mockCreateTodoUsecase.call(any())).thenAnswer(
        (_) async => Right(null),
      );
      return todoFormBloc;
    },
    act: (bloc) => bloc.add(const TodoFormEvent.createTodo(
      todo: Todo(
        id: 1,
        title: 'Test Todo',
      ),
    )),
    expect: () => [
      const TodoFormState(isSubmitting: true),
      const TodoFormState(isSubmitting: false, result: Right(null)),
    ],
    verify: (_) {
      verify(() => mockCreateTodoUsecase.call(any())).called(1);
    },
  );

  blocTest<TodoFormBloc, TodoFormState>(
    'emits [TodoFormState(isSubmitting: true), TodoFormState(isSubmitting: false, result: Right(unit))] when _UpdateTodo is added and successful',
    build: () {
      when(() => mockUpdateTodoUsecase.call(any())).thenAnswer(
        (_) async => Right(null),
      );
      return todoFormBloc;
    },
    act: (bloc) => bloc.add(const TodoFormEvent.updateTodo(
      todo: Todo(
        id: 1,
        title: 'Updated Todo',
      ),
    )),
    expect: () => [
      const TodoFormState(isSubmitting: true),
      const TodoFormState(isSubmitting: false, result: Right(null)),
    ],
    verify: (_) {
      verify(() => mockUpdateTodoUsecase.call(any())).called(1);
    },
  );

  blocTest<TodoFormBloc, TodoFormState>(
    'emits [TodoFormState(isSubmitting: true), TodoFormState(isSubmitting: false, result: Left(ServerFailure()))] when _CreateTodo is added and fails',
    build: () {
      when(() => mockCreateTodoUsecase.call(any())).thenAnswer(
        (_) async => Left(ServerFailure()),
      );
      return todoFormBloc;
    },
    act: (bloc) => bloc.add(const TodoFormEvent.createTodo(
      todo: Todo(
        id: 1,
        title: 'Test Todo',
      ),
    )),
    expect: () => [
      const TodoFormState(isSubmitting: true),
      const TodoFormState(isSubmitting: false, result: Left(ServerFailure())),
    ],
    verify: (_) {
      verify(() => mockCreateTodoUsecase.call(any())).called(1);
    },
  );

  blocTest<TodoFormBloc, TodoFormState>(
    'emits [TodoFormState(isSubmitting: true), TodoFormState(isSubmitting: false, result: Left(ServerFailure()))] when _UpdateTodo is added and fails',
    build: () {
      when(() => mockUpdateTodoUsecase.call(any())).thenAnswer(
        (_) async => Left(ServerFailure()),
      );
      return todoFormBloc;
    },
    act: (bloc) => bloc.add(const TodoFormEvent.updateTodo(
      todo: Todo(
        id: 1,
        title: 'Updated Todo',
      ),
    )),
    expect: () => [
      const TodoFormState(isSubmitting: true),
      const TodoFormState(isSubmitting: false, result: Left(ServerFailure())),
    ],
    verify: (_) {
      verify(() => mockUpdateTodoUsecase.call(any())).called(1);
    },
  );
}
