import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tes_venteny/core/error/failures.dart';
import 'package:tes_venteny/core/network/dio_config.dart';
import 'package:tes_venteny/features/todo/data/data_sources/remote/todo_remote_data_source_impl.dart';
import 'package:tes_venteny/features/todo/data/models/todo_remote_model.dart';
import 'package:tes_venteny/shared/data/models/pagination_response_model.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late TodoRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUpAll(() {
    registerFallbackValue(Uri());
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    final baseOptions = BaseOptions(
      baseUrl: NetworkConfig.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    mockDio = MockDio();
    when(() => mockDio.options).thenReturn(baseOptions);
    dataSource = TodoRemoteDataSourceImpl(mockDio);
  });

  group('createTodo', () {
    final tTodoRemoteModel = TodoRemoteModel(id: 1, title: 'Test Todo');

    test('should return TodoRemoteModel when the call to Dio is successful',
        () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: [
            {'id': 1, 'title': 'Test Todo'}
          ],
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // act
      final result = await dataSource.createTodo(todo: tTodoRemoteModel);

      // assert
      expect(result.isRight(), true);
      expect(result.getOrElse(() => tTodoRemoteModel), tTodoRemoteModel);
      verify(
        () => mockDio.post(
          '/todos',
          data: tTodoRemoteModel.toJson()
            ..removeWhere((key, value) => value == null),
        ),
      ).called(1);
    });

    test('should return ServerFailure when the call to Dio is unsuccessful',
        () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          response: Response(
            data: {'message': 'Error occurred'},
            requestOptions: RequestOptions(path: ''),
          ),
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // act
      final result = await dataSource.createTodo(todo: tTodoRemoteModel);

      // assert
      expect(result, Left(ServerFailure()));
      verify(
        () => mockDio.post(
          '/todos',
          data: tTodoRemoteModel.toJson()
            ..removeWhere((key, value) => value == null),
        ),
      ).called(1);
    });
  });

  group('deleteTodo', () {
    final tId = 1;

    test('should return Unit when the call to Dio is successful', () async {
      // arrange
      when(() => mockDio.delete(any(),
          queryParameters: any(named: 'queryParameters'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // act
      final result = await dataSource.deleteTodo(id: tId);

      // assert
      expect(result.isRight(), true);
      expect(result.getOrElse(() => unit), unit);
      verify(
        () => mockDio.delete(
          '/todos',
          queryParameters: {'id': 'eq.$tId'},
        ),
      ).called(1);
    });

    test('should return ServerFailure when the call to Dio is unsuccessful',
        () async {
      // arrange
      when(() => mockDio.delete(any(),
          queryParameters: any(named: 'queryParameters'))).thenThrow(
        DioException(
          response: Response(
            data: {'message': 'Error occurred'},
            requestOptions: RequestOptions(path: ''),
          ),
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // act
      final result = await dataSource.deleteTodo(id: tId);

      // assert
      expect(result, Left(ServerFailure()));
      verify(
        () => mockDio.delete(
          '/todos',
          queryParameters: {'id': 'eq.$tId'},
        ),
      ).called(1);
    });
  });

  group('getTodoById', () {
    final tId = '1';
    final tTodoRemoteModel = TodoRemoteModel(id: 1, title: 'Test Todo');

    test('should return TodoRemoteModel when the call to Dio is successful',
        () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: {'id': 1, 'title': 'Test Todo'},
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // act
      final result = await dataSource.getTodoById(id: tId);

      // assert
      expect(result.isRight(), true);
      expect(result.getOrElse(() => tTodoRemoteModel), tTodoRemoteModel);
      verify(
        () => mockDio.get('/todos/$tId'),
      ).called(1);
    });

    test('should return ServerFailure when the call to Dio is unsuccessful',
        () async {
      // arrange
      when(() => mockDio.get(any())).thenThrow(
        DioException(
          response: Response(
            data: {'message': 'Error occurred'},
            requestOptions: RequestOptions(path: ''),
          ),
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // act
      final result = await dataSource.getTodoById(id: tId);

      // assert
      expect(result, Left(ServerFailure()));
      verify(
        () => mockDio.get('/todos/$tId'),
      ).called(1);
    });
  });

  group('getTodos', () {
    final tPaginationResponseModel = PaginationResponseModel<TodoRemoteModel>(
      code: 200,
      status: true,
      message: 'Success',
      page: 1,
      count: 1,
      total: 1,
      data: [TodoRemoteModel(id: 1, title: 'Test Todo')],
    );

    test(
        'should return PaginationResponseModel when the call to Dio is successful',
        () async {
      // arrange
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          statusMessage: 'Success',
          data: [
            {
              'id': 1,
              'title': 'Test Todo',
            }
          ],
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // act
      final result = await dataSource.getTodos(page: 1, limit: 1);

      // assert
      expect(result.isRight(), true);
      expect(
        result.getOrElse(() => tPaginationResponseModel),
        tPaginationResponseModel,
      );
      verify(
        () => mockDio.get(
          '/todos',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('should return ServerFailure when the call to Dio is unsuccessful',
        () async {
      // arrange
      when(() => mockDio.get(any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'))).thenThrow(
        DioException(
          response: Response(
            data: {'message': 'Error occurred'},
            requestOptions: RequestOptions(path: ''),
          ),
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // act
      final result = await dataSource.getTodos(page: 1, limit: 1);

      // assert
      expect(result, Left(ServerFailure()));
      verify(
        () => mockDio.get('/todos',
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options')),
      ).called(1);
    });
  });

  group('updateTodo', () {
    final tTodoRemoteModel = TodoRemoteModel(id: 1, title: 'Test Todo');

    test('should return TodoRemoteModel when the call to Dio is successful',
        () async {
      // arrange
      when(() => mockDio.patch(any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'))).thenAnswer(
        (_) async => Response(
          data: [
            {'id': 1, 'title': 'Test Todo'}
          ],
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // act
      final result = await dataSource.updateTodo(todo: tTodoRemoteModel);

      // assert
      expect(result.isRight(), true);
      expect(result.getOrElse(() => tTodoRemoteModel), tTodoRemoteModel);
      verify(
        () => mockDio.patch('/todos',
            data: tTodoRemoteModel.toJson(),
            queryParameters: {'id': 'eq.${tTodoRemoteModel.id}'}),
      ).called(1);
    });

    test('should return ServerFailure when the call to Dio is unsuccessful',
        () async {
      // arrange
      when(() => mockDio.patch(any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'))).thenThrow(
        DioException(
          response: Response(
            data: {'message': 'Error occurred'},
            requestOptions: RequestOptions(path: ''),
          ),
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // act
      final result = await dataSource.updateTodo(todo: tTodoRemoteModel);

      // assert
      expect(result, Left(ServerFailure()));
      verify(
        () => mockDio.patch(
          '/todos',
          data: tTodoRemoteModel.toJson(),
          queryParameters: {'id': 'eq.${tTodoRemoteModel.id}'},
        ),
      ).called(1);
    });
  });
}
