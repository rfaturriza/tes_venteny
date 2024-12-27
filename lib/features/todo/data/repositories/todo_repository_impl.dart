import 'dart:convert';

import 'package:dart_ping/dart_ping.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:tes_venteny/core/utils/extension/dartz_ext.dart';
import 'package:tes_venteny/features/todo/data/models/todo_remote_model.dart';
import 'package:tes_venteny/shared/data/models/outbox_model.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/pagination_entity.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../data_sources/local/todo_local_data_source.dart';
import '../data_sources/remote/todo_remote_data_source.dart';
import '../models/todo_local_model.dart';

@LazySingleton(as: TodoRepository)
class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource _localDataSource;
  final TodoRemoteDataSource _remoteDataSource;

  TodoRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
  );
  @override
  Future<Either<Failure, Todo>> createTodo({required Todo todo}) async {
    final localResult = await _localDataSource.createTodo(
      todo: todo.toLocalModel(),
    );

    if (localResult.isLeft()) {
      return left(localResult.asLeft());
    }

    final ping = await Ping('google.com', count: 1).stream.first;
    if (ping.error != null) {
      final outboxModel = OutboxModel(
        action: 'post',
        tableName: TodoLocalModel.tableName,
        payload: jsonEncode(
            localResult.asRight().toEntity().toRemoteModel().toJson()),
      );
      await _localDataSource.saveOutbox(outboxModel);
      return right(todo);
    }

    final remoteResult = await _remoteDataSource.createTodo(
      todo: localResult.asRight().toEntity().toRemoteModel(),
    );

    if (remoteResult.isLeft()) {
      return left(remoteResult.asLeft());
    }

    return right(todo);
  }

  @override
  Future<Either<Failure, Unit>> deleteTodo({required int id}) async {
    final localResult = await _localDataSource.deleteTodo(
      id: id,
    );

    if (localResult.isLeft()) {
      return left(localResult.asLeft());
    }

    final ping = await Ping('google.com', count: 1).stream.first;
    if (ping.error != null) {
      final outboxModel = OutboxModel(
        action: 'delete',
        tableName: TodoLocalModel.tableName,
        payload: jsonEncode({'id': id}),
      );
      await _localDataSource.saveOutbox(outboxModel);
      return right(unit);
    }

    final remoteResult = await _remoteDataSource.deleteTodo(
      id: id,
    );

    if (remoteResult.isLeft()) {
      return left(remoteResult.asLeft());
    }

    return right(unit);
  }

  @override
  Future<Either<Failure, Todo>> getTodoById({required String id}) async {
    final localResult = await _localDataSource.getTodoById(
      id: id,
    );

    return localResult.fold(
      (l) => left(l),
      (r) => right(r.toEntity()),
    );
  }

  @override
  Future<Either<Failure, Pagination<Todo>>> getTodos({
    int? page,
    int? limit,
    String? search,
    TodoStatus? status,
  }) async {
    final ping = await Ping('google.com', count: 1).stream.first;
    if (ping.error != null) {
      final localResult = await _localDataSource.getTodos(
        page: page,
        limit: limit,
        search: search,
        status: status?.name ?? '',
      );

      return localResult.fold(
        (l) => left(l),
        (r) {
          return right(
            Pagination<Todo>(
              code: r.code,
              status: r.status,
              message: r.message,
              page: r.page,
              count: r.count,
              total: r.total,
              data: r.data?.map((e) => e.toEntity()).toList(),
            ),
          );
        },
      );
    }

    await _localDataSource.deleteAllTodo();
    final remoteResult = await _remoteDataSource.getTodos(
      page: page,
      limit: limit,
      search: search,
      status: status?.name,
    );

    if (remoteResult.isLeft()) {
      return left(remoteResult.asLeft());
    }

    final remoteData = remoteResult.asRight();

    await _localDataSource.saveTodos(
      remoteData.data?.map((e) => e.toEntity().toLocalModel()).toList() ?? [],
    );

    return right(
      Pagination<Todo>(
        code: remoteData.code,
        status: remoteData.status,
        message: remoteData.message,
        page: remoteData.page,
        count: remoteData.count,
        total: remoteData.total,
        data: remoteData.data?.map((e) => e.toEntity()).toList(),
      ),
    );
  }

  @override
  Future<Either<Failure, Todo>> updateTodo({required Todo todo}) async {
    final localResult = await _localDataSource.updateTodo(
      todo: todo.toLocalModel(),
    );

    if (localResult.isLeft()) {
      return left(localResult.asLeft());
    }

    final ping = await Ping('google.com', count: 1).stream.first;
    if (ping.error != null) {
      final outboxModel = OutboxModel(
        action: 'patch',
        tableName: TodoLocalModel.tableName,
        payload: jsonEncode(todo.toRemoteModel().toJson()),
      );
      await _localDataSource.saveOutbox(outboxModel);
      return right(todo);
    }

    final remoteResult = await _remoteDataSource.updateTodo(
      todo: todo.toRemoteModel(),
    );

    if (remoteResult.isLeft()) {
      return left(remoteResult.asLeft());
    }

    return right(todo);
  }

  @override
  Future<Either<Failure, Unit>> syncTodos() async {
    final ping = await Ping('google.com', count: 1).stream.first;
    if (ping.error != null) {
      return left(ServerFailure(message: 'No internet connection'));
    }

    final unsyncedTodos = await _localDataSource.getUnsyncedTodos();
    for (final todo in unsyncedTodos. asRight()) {
      try {
        final todoModel = TodoRemoteModel.fromJson(jsonDecode(todo.payload!));
        if (todoModel.id == null) {
          throw Exception('Todo id must not be null');
        }
        switch (todo.action) {
          case 'post':
            final result = await _remoteDataSource.createTodo(
              todo: todoModel,
            );
            if (result.isRight()) {
              await _localDataSource.deleteTodo(
                id: todoModel.id,
              );
              await _localDataSource.deleteOutbox(
                todo.id,
              );
              return right(unit);
            }
            throw Exception('Error creating todo');
          case 'put':
          case 'patch':
            final result = await _remoteDataSource.updateTodo(
              todo: todoModel,
            );
            if (result.isRight()) {
              await _localDataSource.deleteTodo(
                id: todoModel.id,
              );
              await _localDataSource.deleteOutbox(
                todo.id,
              );
              return right(unit);
            }
            throw Exception('Error updating todo');
          case 'delete':
            final result = await _remoteDataSource.deleteTodo(
              id: todoModel.id!,
            );
            if (result.isRight()) {
              await _localDataSource.deleteTodo(
                id: todoModel.id,
              );
              await _localDataSource.deleteOutbox(
                todo.id,
              );
              return right(unit);
            }
            throw Exception('Error deleting todo');
        }
      } catch (e) {
        debugPrint('Error syncing todo: $e');

        return left(ServerFailure(message: e.toString()));
      }
    }

    return right(unit);
  }
}
