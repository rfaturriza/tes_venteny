import 'package:equatable/equatable.dart';

import '../utils/extension/string_ext.dart';

abstract class Failure extends Equatable {
  final String? message;
  const Failure({this.message});
  @override
  List<Object> get props => [message ?? emptyString];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message});
}

class GeneralFailure extends Failure {
  const GeneralFailure({super.message});
}

String mapFailureToMessage(Failure failure) {
  switch (failure.runtimeType) {
    case ServerFailure _:
      return failure.message ??
          'Sorry, something went wrong with the server. Please try again later';
    case CacheFailure _:
      return failure.message ??
          'Sorry, something went wrong with the cache. Please try again later';
    default:
      return 'Unexpected Error, please try again';
  }
}
