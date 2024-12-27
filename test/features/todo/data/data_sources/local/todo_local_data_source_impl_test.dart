import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tes_venteny/core/database/db.dart';
import 'package:tes_venteny/core/error/failures.dart';
import 'package:tes_venteny/core/utils/extension/dartz_ext.dart';
import 'package:tes_venteny/features/todo/data/data_sources/local/todo_local_data_source_impl.dart';
import 'package:tes_venteny/shared/data/models/outbox_model.dart';
import 'package:tes_venteny/shared/data/models/pagination_response_model.dart';
import 'package:tes_venteny/features/todo/data/models/todo_local_model.dart';

class MockDatabaseProvider extends Mock implements DatabaseProvider {}

class MockDatabase extends Mock implements Database {}

class MockBatch extends Mock implements Batch {}

void main() {
  late TodoLocalDataSourceImpl dataSource;
  late MockDatabaseProvider mockDatabaseProvider;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDatabaseProvider = MockDatabaseProvider();
    mockDatabase = MockDatabase();
    dataSource = TodoLocalDataSourceImpl(mockDatabaseProvider);
  });

  group('createTodo', () {
    final todo = TodoLocalModel(id: 1, title: 'Test Todo', status: 'pending');

    test('should return TodoLocalModel when insertion is successful', () async {
      when(() => mockDatabaseProvider.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.insert(any(), any())).thenAnswer((_) async => 1);

      final result = await dataSource.createTodo(todo: todo);

      expect(result, Right(todo.copyWith(id: 1)));
    });

    test('should return CacheFailure when insertion fails', () async {
      when(() => mockDatabaseProvider.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.insert(any(), any())).thenThrow(Exception());

      final result = await dataSource.createTodo(todo: todo);

      expect(result, Left(CacheFailure()));
    });
  });

  group('deleteTodo', () {
    test('should return unit when deletion is successful', () async {
      when(() => mockDatabaseProvider.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.delete(any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);

      final result = await dataSource.deleteTodo(id: 1);

      expect(result, Right(unit));
    });

    test('should return CacheFailure when deletion fails', () async {
      when(() => mockDatabaseProvider.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.delete(any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenThrow(Exception());

      final result = await dataSource.deleteTodo(id: 1);

      expect(result, Left(CacheFailure()));
    });
  });

  group('getTodoById', () {
    final todo = TodoLocalModel(id: 1, title: 'Test Todo', status: 'pending');

    test('should return TodoLocalModel when query is successful', () async {
      when(() => mockDatabaseProvider.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.query(any(),
              where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => [todo.toJson()]);

      final result = await dataSource.getTodoById(id: '1');

      expect(result, Right(todo));
    });

    test('should return CacheFailure when query fails', () async {
      when(() => mockDatabaseProvider.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.query(any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenThrow(Exception());

      final result = await dataSource.getTodoById(id: '1');

      expect(result, Left(CacheFailure()));
    });
  });

  group('updateTodo', () {
    final todo = TodoLocalModel(id: 1, title: 'Test Todo', status: 'pending');

    test('should return TodoLocalModel when update is successful', () async {
      when(() => mockDatabaseProvider.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.update(any(), any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);

      final result = await dataSource.updateTodo(todo: todo);

      expect(result, Right(todo));
    });

    test('should return CacheFailure when update fails', () async {
      when(() => mockDatabaseProvider.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.update(any(), any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenThrow(Exception());

      final result = await dataSource.updateTodo(todo: todo);

      expect(result, Left(CacheFailure()));
    });
  });

  group('getTodos', () {
    final todo = TodoLocalModel(id: 1, title: 'Test Todo', status: 'pending');
    final todos = [todo];
    final paginationResponse = PaginationResponseModel<TodoLocalModel>(
      data: todos,
      page: 1,
      total: 1,
    );

    test('should return PaginationResponseModel when query is successful',
        () async {
      when(() => mockDatabaseProvider.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.rawQuery(any(), any())).thenAnswer((_) async => [
            {'COUNT(*)': 1}
          ]);
      when(() => mockDatabase.query(any(),
              where: any(named: 'where'),
              whereArgs: any(named: 'whereArgs'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset')))
          .thenAnswer((_) async => [todo.toJson()]);

      final result = await dataSource.getTodos(page: 1, limit: 10);

      expect(result, Right(paginationResponse));
    });

    test('should return CacheFailure when query fails', () async {
      when(() => mockDatabaseProvider.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.rawQuery(any(), any())).thenThrow(Exception());

      final result = await dataSource.getTodos(page: 1, limit: 10);

      expect(result, Left(CacheFailure()));
    });
  });

  group('getUnsyncedTodos', () {
    final outbox = OutboxModel(id: 1, tableName: 'todos', payload: '{}');
    final outboxes = [outbox];

    test('should return List<OutboxModel> when query is successful', () async {
      when(() => mockDatabaseProvider.database)
          .thenAnswer((_) async => mockDatabase);
      when(
        () => mockDatabase.query(
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).thenAnswer((_) async => [outbox.toJson()]);

      final result = await dataSource.getUnsyncedTodos();

      expect(result.isRight(), true);
      expect(result.asRight(), outboxes);
    });

    test('should return CacheFailure when query fails', () async {
      when(() => mockDatabaseProvider.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.query(any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenThrow(Exception());

      final result = await dataSource.getUnsyncedTodos();

      expect(result, Left(CacheFailure()));
    });
  });

  group('deleteAllTodo', () {
    test('should return unit when deletion is successful', () async {
      when(() => mockDatabaseProvider.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.delete(any())).thenAnswer((_) async => 1);

      final result = await dataSource.deleteAllTodo();

      expect(result, Right(unit));
    });

    test('should return CacheFailure when deletion fails', () async {
      when(() => mockDatabaseProvider.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.delete(any())).thenThrow(Exception());

      final result = await dataSource.deleteAllTodo();

      expect(result, Left(CacheFailure()));
    });
  });

  group('saveTodos', () {
    final todo = TodoLocalModel(id: 1, title: 'Test Todo', status: 'pending');
    final todos = [todo];
    test('should return unit when insertion is successful', () async {
      final mockBatch = MockBatch();
      when(() => mockBatch.insert(any(), any())).thenReturn(null);
      when(() => mockBatch.commit(noResult: any(named: 'noResult')))
          .thenAnswer((_) async => []);
      when(() => mockDatabaseProvider.database).thenAnswer(
        (_) async => mockDatabase,
      );
      when(() => mockDatabase.batch()).thenReturn(mockBatch);

      final result = await dataSource.saveTodos(todos);

      expect(result, Right(unit));
    });

    test('should return CacheFailure when insertion fails', () async {
      when(() => mockDatabaseProvider.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.batch()).thenThrow(Exception());

      final result = await dataSource.saveTodos(todos);

      expect(result, Left(CacheFailure()));
    });
  });

  group('saveOutbox', () {
    final outbox = OutboxModel(id: 1, tableName: 'todos', payload: '{}');

    test('should return unit when insertion is successful', () async {
      when(() => mockDatabaseProvider.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.insert(any(), any())).thenAnswer((_) async => 1);

      final result = await dataSource.saveOutbox(outbox);

      expect(result, Right(unit));
    });

    test('should return CacheFailure when insertion fails', () async {
      when(() => mockDatabaseProvider.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.insert(any(), any())).thenThrow(Exception());

      final result = await dataSource.saveOutbox(outbox);

      expect(result, Left(CacheFailure()));
    });
  });

  group('deleteOutbox', () {
    test('should return unit when deletion is successful', () async {
      when(() => mockDatabaseProvider.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.delete(any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);

      final result = await dataSource.deleteOutbox(1);

      expect(result, Right(unit));
    });

    test('should return CacheFailure when deletion fails', () async {
      when(() => mockDatabaseProvider.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.delete(any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'))).thenThrow(Exception());

      final result = await dataSource.deleteOutbox(1);

      expect(result, Left(CacheFailure()));
    });
  });
}
