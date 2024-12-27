import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/todo.dart';

part 'todo_local_model.freezed.dart';
part 'todo_local_model.g.dart';

@freezed
class TodoLocalModel with _$TodoLocalModel {
  static const tableName = 'todos';

  const factory TodoLocalModel({
    int? id,
    String? title,
    String? description,
    @JsonKey(name: 'due_date') String? dueDate,
    String? status,
  }) = _TodoLocalModel;

  const TodoLocalModel._();

  factory TodoLocalModel.fromJson(Map<String, dynamic> json) =>
      _$TodoLocalModelFromJson(json);

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
