import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/todo.dart';

part 'todo_remote_model.freezed.dart';
part 'todo_remote_model.g.dart';

@freezed
class TodoRemoteModel with _$TodoRemoteModel {
  static const tableName = 'todos';

  const factory TodoRemoteModel({
    int? id,
    String? title,
    String? description,
    @JsonKey(name: 'due_date') String? dueDate,
    String? status,
  }) = _TodoRemoteModel;

  const TodoRemoteModel._();

  factory TodoRemoteModel.fromJson(Map<String, dynamic> json) =>
      _$TodoRemoteModelFromJson(json);

  Todo toEntity() {
    return Todo(
      id: id,
      title: title,
      description: description,
      dueDate: DateTime.tryParse(dueDate ?? ''),
      status: () {
        switch (status) {
          case 'pending':
            return TodoStatus.pending;
          case 'inProgress':
            return TodoStatus.inProgress;
          case 'completed':
            return TodoStatus.completed;
          default:
            return null;
        }
      }(),
    );
  }
}
