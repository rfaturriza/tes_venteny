import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tes_venteny/core/error/failures.dart';
import 'package:tes_venteny/features/todo/data/data_sources/remote/todo_remote_data_source.dart';
import 'package:tes_venteny/features/todo/data/models/todo_remote_model.dart';
import 'package:tes_venteny/shared/data/models/pagination_response_model.dart';

@LazySingleton(as: TodoRemoteDataSource)
class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final Dio _dio;
  static const _endpoint = '/todos';
  static const _baseUrl = 'https://nuhrtywkjxpjppjgrrdv.supabase.co/rest/v1';
  static const _anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im51aHJ0eXdranhwanBwamdycmR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUyMjE5MTYsImV4cCI6MjA1MDc5NzkxNn0.E-hFX0Cwy-yYuPMx9Dc8_z4-gKEUUQMDExHrSXrDsMw';

  TodoRemoteDataSourceImpl(this._dio) {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers['apikey'] = _anonKey;
    _dio.options.headers['Authorization'] = 'Bearer $_anonKey';
    _dio.options.headers['Prefer'] = 'return=representation';
  }
  @override
  Future<Either<Failure, TodoRemoteModel>> createTodo({
    required TodoRemoteModel todo,
  }) async {
    try {
      final response = await _dio.post(
        _endpoint,
        data: todo.toJson()..removeWhere((key, value) => value == null),
      );
      return Right(TodoRemoteModel.fromJson((response.data as List).first));
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Something went wrong, please try again'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTodo({required int id}) async {
    try {
      await _dio.delete(_endpoint, queryParameters: {
        'id': 'eq.$id',
      });
      return Right(unit);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Something went wrong, please try again'),
      );
    }
  }

  @override
  Future<Either<Failure, TodoRemoteModel>> getTodoById(
      {required String id}) async {
    try {
      final response = await _dio.get('$_endpoint/$id');
      return Right(TodoRemoteModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Something went wrong, please try again'),
      );
    }
  }

  @override
  Future<Either<Failure, PaginationResponseModel<TodoRemoteModel>>> getTodos({
    int? page,
    int? limit,
    String? search,
    String? status,
  }) async {
    final query = {
      'select': '*',
      'order': 'due_date.asc',
    };
    if (search != null && search.isNotEmpty) {
      query['title'] = 'ilike.*$search*';
    }
    if (status != null && status.isNotEmpty) {
      query['status'] = 'eq.$status';
    }
    try {
      final from = {(page ?? 0) * (limit ?? 20)}.toString();
      final to = {((page ?? 0) + 1) * (limit ?? 20) - 1}.toString();
      final response = await _dio.get(
        _endpoint,
        queryParameters: query,
        options: Options(
          headers: {
            'Range': '$from-$to',
          },
        ),
      );
      final result = {
        'code': response.statusCode,
        'status': response.statusCode == 200,
        'message': response.statusMessage,
        'page': page,
        'count': response.data.length,
        'total': response.data.length,
        'data': response.data,
      };
      return Right(PaginationResponseModel.fromJson(
        result,
        (data) => TodoRemoteModel.fromJson(data),
      ));
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Something went wrong, please try again'),
      );
    }
  }

  @override
  Future<Either<Failure, TodoRemoteModel>> updateTodo({
    required TodoRemoteModel todo,
  }) async {
    try {
      final query = {
        'id': 'eq.${todo.id}',
      };
      final response = await _dio.patch(
        _endpoint,
        data: todo.toJson(),
        queryParameters: query,
      );
      return Right(TodoRemoteModel.fromJson((response.data as List).first));
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Something went wrong, please try again'));
    }
  }
}
