import 'package:equatable/equatable.dart';

class BaseResponseModel<T> extends Equatable {
  const BaseResponseModel({
    this.code,
    this.status,
    this.message,
    this.data,
  });

  final int? code;
  final bool? status;
  final String? message;
  final T? data;

  /// Factory constructor with a `fromJsonT` function to handle `T` parsing.
  factory BaseResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    return BaseResponseModel(
      code: json['code'] as int?,
      status: json['status'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  /// Converts the object to JSON with a `toJsonT` function to handle `T` serialization.
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return {
      'code': code,
      'status': status,
      'message': message,
      'data': data != null ? toJsonT(data as T) : null,
    };
  }

  /// A copyWith method for immutability.
  BaseResponseModel<T> copyWith({
    int? code,
    bool? status,
    String? message,
    T? data,
  }) {
    return BaseResponseModel<T>(
      code: code ?? this.code,
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [code, status, message, data];
}
