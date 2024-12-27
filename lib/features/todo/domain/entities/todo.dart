import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tes_venteny/features/todo/data/models/todo_remote_model.dart';

import '../../data/models/todo_local_model.dart';

part 'todo.freezed.dart';

enum TodoStatus { pending, inProgress, completed }

@freezed
class Todo with _$Todo {
  const factory Todo({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TodoStatus? status,
  }) = _Todo;

  const Todo._();

  TodoLocalModel toLocalModel() {
    return TodoLocalModel(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate?.toIso8601String(),
      status: status.toString().split('.').last,
    );
  }

  TodoRemoteModel toRemoteModel() {
    return TodoRemoteModel(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate?.toIso8601String(),
      status: status.toString().split('.').last,
    );
  }
}
