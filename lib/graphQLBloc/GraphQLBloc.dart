import 'package:flutter_bloc/flutter_bloc.dart';
import 'GraphQLService.dart';
import 'GraphQLEvents.dart';
import 'GraphQLStates.dart';

class GraphQLBloc extends Bloc<GraphQLEvents, GraphQLStates> {
  GraphQLService service;

  GraphQLBloc() {
    service = GraphQLService();
  }
  @override
  GraphQLStates get initialState => Loading();

  @override
  Stream<GraphQLStates> mapEventToState(GraphQLEvents event) async* {
    if (event is FetchGQLData) {
      yield* _mapFetchDataToState(event);
    }
  }

  Stream<GraphQLStates> _mapFetchDataToState(FetchGQLData event) async* {
    final query = event.query;
    final variables = event.variables ?? null;

    try {
      final result = await service.performMutation(query, variables: variables);

      if (result.hasException) {
        print("graphQL Errors: ${result.exception.graphqlErrors.toString()}");
        print("client Errors: ${result.exception.clientException.toString()}");
        yield LoadDataFail(result.exception.graphqlErrors[0]);
      } else {
        yield LoadDataSuccess(result.data);
      }
    } catch (e) {
      print(e);
      yield LoadDataFail(e.toString());
    }
  }
}
