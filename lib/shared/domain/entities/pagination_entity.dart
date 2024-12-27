import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_entity.freezed.dart';

@freezed
class Pagination<T> with _$Pagination<T> {
  const factory Pagination({
    int? code,
    bool? status,
    String? message,
    int? page,
    int? count,
    int? total,
    List<T>? data,
  }) = _Pagination<T>;
}
