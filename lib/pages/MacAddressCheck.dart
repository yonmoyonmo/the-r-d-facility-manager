import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../graphQLBloc/GraphQLBloc.dart';
import '../graphQLBloc/GraphQLStates.dart';
import '../graphQLBloc/GraphQLEvents.dart';
import 'CreateZone.dart';

class MacAddressCheck extends StatefulWidget {
  String query;
  MacAddressCheck(String _query) {
    query = _query;
  }
  @override
  _MacAddressCheckState createState() => _MacAddressCheckState(query);
}

class _MacAddressCheckState extends State<MacAddressCheck> {
  String query;
  _MacAddressCheckState(String _query) {
    query = _query;
  }
  Map<String, dynamic> data;

  @override
  void initState() {
    super.initState();
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('mac duplication check'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GraphQLBloc, GraphQLStates>(
      builder: (BuildContext context, GraphQLStates state) {
        if (state is Loading) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: LinearProgressIndicator(),
          );
        } else if (state is LoadDataFail) {
          return Scaffold(
              appBar: _buildAppBar(),
              body: Column(
                children: [
                  Text(state.error.toString() + "\n아직 등록되지 않은 비콘이라는 뜻."),
                  RaisedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return BlocProvider<GraphQLBloc>(
                          create: (BuildContext context) =>
                              GraphQLBloc()..add(FetchGQLData(query)),
                          child: CreateZone(),
                        );
                      }));
                    },
                    child: Text("Create Zone with current data"),
                  ),
                ],
              ));
        } else {
          data = (state as LoadDataSuccess).data['getOneZone'];
          print(data);
          return Scaffold(
            appBar: _buildAppBar(),
            body: _buildBody(),
          );
        }
      },
    );
  }

  Widget _buildBody() {
    return Container(
      height: 300,
      width: 300,
      child: Column(
        children: [
          Text(data['name'].toString()),
          Text(data['mac'].toString()),
          Text(data['major'].toString()),
          Text("이미 등록된 비콘입니다."),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
