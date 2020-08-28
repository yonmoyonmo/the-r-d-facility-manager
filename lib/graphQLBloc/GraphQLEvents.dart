import 'package:equatable/equatable.dart';

abstract class GraphQLEvents extends Equatable {
  GraphQLEvents();
  @override
  List<Object> get props => null;
}

class FetchGQLData extends GraphQLEvents {
  final String query;
  final Map<String, dynamic> variables;

  FetchGQLData(this.query, {this.variables}) : super();

  @override
  List<Object> get props => [query, variables];
}
