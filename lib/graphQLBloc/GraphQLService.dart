import 'package:graphql/client.dart';

class GraphQLService {
  GraphQLClient _client;

  GraphQLService() {
    HttpLink link = HttpLink(uri: "http://164.125.154.49:8000/");
    _client = GraphQLClient(link: link, cache: InMemoryCache());
  }

  Future<QueryResult> performQuery(String query,
      {Map<String, dynamic> variables}) async {
    QueryOptions options =
        QueryOptions(documentNode: gql(query), variables: variables);
    final result = await _client.query(options);
    print("Query result : ");
    print(result);
    return result;
  }

  Future<QueryResult> performMutation(String query,
      {Map<String, dynamic> variables}) async {
    MutationOptions options =
        MutationOptions(documentNode: gql(query), variables: variables);

    final result = await _client.mutate(options);

    print("Mutation result : ");
    print(result);
    return result;
  }
}
