import 'package:equatable/equatable.dart';

class PaginationResponseModel<T> extends Equatable {
  const PaginationResponseModel({
    this.code,
    this.status,
    this.message,
    this.page,
    this.count,
    this.total,
    this.data,
  });

  final int? code;
  final bool? status;
  final String? message;
  final int? page;
  final int? count;
  final int? total;
  final List<T>? data;

  /// Factory constructor with a `fromJsonT` function to handle `T` parsing.
  factory PaginationResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    return PaginationResponseModel(
      code: json['code'] as int?,
      status: json['status'] as bool?,
      message: json['message'] as String?,
      page: json['page'] as int?,
      count: json['count'] as int?,
      total: json['total'] as int?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts the object to JSON with a `toJsonT` function to handle `T` serialization.
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return {
      'code': code,
      'status': status,
      'message': message,
      'page': page,
      'count': count,
      'total': total,
      'data': data != null ? toJsonT(data as T) : null,
    };
  }

  /// A copyWith method for immutability.
  PaginationResponseModel<T> copyWith({
    int? code,
    bool? status,
    String? message,
    int? page,
    int? count,
    int? total,
    List<T>? data,
  }) {
    return PaginationResponseModel<T>(
      code: code ?? this.code,
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [
        code,
        status,
        message,
        page,
        count,
        total,
        data,
      ];
}
