import 'package:equatable/equatable.dart';

abstract class GraphQLStates extends Equatable {
  GraphQLStates();

  @override
  List<Object> get props => null;
}

class Loading extends GraphQLStates {
  Loading() : super();
}

class LoadDataSuccess extends GraphQLStates {
  final dynamic data;
  LoadDataSuccess(this.data) : super();
  @override
  List<Object> get props => data;
}

class LoadDataFail extends GraphQLStates {
  final dynamic error;
  LoadDataFail(this.error) : super();

  @override
  List<Object> get props => error;
}
