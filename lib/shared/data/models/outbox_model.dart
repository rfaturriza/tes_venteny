import 'package:freezed_annotation/freezed_annotation.dart';

part 'outbox_model.freezed.dart';
part 'outbox_model.g.dart';

@freezed
class OutboxModel with _$OutboxModel {
  static String get table => 'outboxes';
  const factory OutboxModel({
    int? id,
    String? action,
    @JsonKey(name: 'table_name') String? tableName,
    String? payload,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _OutboxModel;

  factory OutboxModel.fromJson(Map<String, dynamic> json) =>
      _$OutboxModelFromJson(json);
}
