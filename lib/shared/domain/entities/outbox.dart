import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/outbox_model.dart';

part 'outbox.freezed.dart';

enum OutboxAction {
  @JsonValue('post')
  post,
  @JsonValue('put')
  put,
  @JsonValue('delete')
  delete,
  @JsonValue('patch')
  patch,
}

@freezed
class Outbox with _$Outbox {
  const factory Outbox({
    int? id,
    OutboxAction? action,
    @JsonKey(name: 'table_name') String? tableName,
    Map<String, dynamic>? payload,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _Outbox;

  const Outbox._();

  factory Outbox.fromModel(OutboxModel model) {
    return Outbox(
      id: model.id,
      action: () {
        switch (model.action) {
          case 'post':
            return OutboxAction.post;
          case 'put':
            return OutboxAction.put;
          case 'delete':
            return OutboxAction.delete;
          case 'patch':
            return OutboxAction.patch;
          default:
            return null;
        }
      }(),
      tableName: model.tableName,
      payload: () {
        if (model.payload != null) {
          return json.decode(model.payload!);
        } else {
          return null;
        }
      }(),
      createdAt: model.createdAt,
    );
  }

  OutboxModel toModel() {
    return OutboxModel(
      id: id,
      action: () {
        switch (action) {
          case OutboxAction.post:
            return 'post';
          case OutboxAction.put:
            return 'put';
          case OutboxAction.delete:
            return 'delete';
          case OutboxAction.patch:
            return 'patch';
          default:
            return null;
        }
      }(),
      tableName: tableName,
      payload: () {
        if (payload != null) {
          return json.encode(payload);
        } else {
          return null;
        }
      }(),
      createdAt: createdAt,
    );
  }
}
