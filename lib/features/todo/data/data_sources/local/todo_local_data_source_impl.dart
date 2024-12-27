import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tes_venteny/core/database/db.dart';
import 'package:tes_venteny/shared/data/models/outbox_model.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../shared/data/models/pagination_response_model.dart';
import '../../models/todo_local_model.dart';
import 'todo_local_data_source.dart';

@LazySingleton(as: TodoLocalDataSource)
class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  final DatabaseProvider _db;

  TodoLocalDataSourceImpl(this._db);
  @override
  Future<Either<Failure, TodoLocalModel>> createTodo({
    required TodoLocalModel todo,
  }) async {
    try {
      final db = await _db.database;
      final id = await db.insert(TodoLocalModel.tableName, todo.toJson());
      return Right(todo.copyWith(id: id));
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTodo({
    required int? id,
  }) async {
    if (id == null) {
      return Right(unit);
    }
    try {
      final db = await _db.database;
      await db.delete(
        TodoLocalModel.tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      return Right(unit);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, TodoLocalModel>> getTodoById({
    required String id,
  }) async {
    try {
      final db = await _db.database;
      final result = await db.query(
        TodoLocalModel.tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isEmpty) {
        return Left(CacheFailure());
      }
      return Right(TodoLocalModel.fromJson(result.first));
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, TodoLocalModel>> updateTodo({
    required TodoLocalModel todo,
  }) async {
    try {
      final db = await _db.database;
      await db.update(
        TodoLocalModel.tableName,
        todo.toJson(),
        where: 'id = ?',
        whereArgs: [todo.id],
      );
      return Right(todo);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, PaginationResponseModel<TodoLocalModel>>> getTodos({
    int? page,
    int? limit,
    String? search,
    String? status,
  }) async {
    try {
      final db = await _db.database;
      final whereClause = StringBuffer();
      final whereArgs = <String>[];

      if (search != null && search.isNotEmpty) {
        whereClause.write('title LIKE ?');
        whereArgs.add('%$search%');
      }

      if (status != null && status.isNotEmpty) {
        if (whereClause.isNotEmpty) {
          whereClause.write(' AND ');
        }
        whereClause.write('status = ?');
        whereArgs.add(status);
      }

      final count = Sqflite.firstIntValue(
        await db.rawQuery(
          '''
            SELECT 
              COUNT(*) 
            FROM 
              ${TodoLocalModel.tableName}
              ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''}
          ''',
          whereArgs,
        ),
      );

      final result = await db.query(
        TodoLocalModel.tableName,
        where: whereClause.isNotEmpty ? whereClause.toString() : null,
        whereArgs: whereArgs,
        limit: limit,
        offset: ((page ?? 0) - 1) * (limit ?? 10),
      );
      final todos = result.map((e) => TodoLocalModel.fromJson(e)).toList();
      return Right(PaginationResponseModel(
        data: todos,
        page: page,
        total: count,
      ));
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<OutboxModel>>> getUnsyncedTodos() async {
    try {
      final db = await _db.database;
      final result = await db.query(
        OutboxModel.table,
        where: 'table_name = ?',
        whereArgs: [TodoLocalModel.tableName],
      );
      final todos = result.map((e) => OutboxModel.fromJson(e)).toList();
      return Right(todos);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAllTodo() async {
    try {
      final db = await _db.database;
      await db.delete(TodoLocalModel.tableName);
      return Right(unit);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> saveTodos(List<TodoLocalModel> todos) async {
    try {
      final db = await _db.database;
      final batch = db.batch();
      for (final todo in todos) {
        batch.insert(TodoLocalModel.tableName, todo.toJson());
      }
      await batch.commit(noResult: true);
      return Right(unit);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> saveOutbox(OutboxModel outbox) async {
    try {
      final db = await _db.database;
      await db.insert(OutboxModel.table, outbox.toJson());
      return Right(unit);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteOutbox(int? id) async {
    try {
      final db = await _db.database;
      await db.delete(
        OutboxModel.table,
        where: 'id = ?',
        whereArgs: [id],
      );
      return Right(unit);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
