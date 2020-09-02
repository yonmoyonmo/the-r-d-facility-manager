import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../graphQLBloc/GraphQLBloc.dart';
import '../graphQLBloc/GraphQLStates.dart';

class CreateMap extends StatefulWidget {
  CreateMap({Key key}) : super(key: key);

  @override
  _CreateMapState createState() => _CreateMapState();
}

class _CreateMapState extends State<CreateMap> {
  Map<String, dynamic> data;

  @override
  void initState() {
    super.initState();
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('make a Map'),
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
              body: Center(
                child: Text(state.error),
              ));
        } else {
          data = (state as LoadDataSuccess).data['addMap'];
          print(data);
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: Scaffold(
              appBar: _buildAppBar(),
              body: _buildBody(),
            ),
          );
        }
      },
    );
  }

  Widget _buildBody() {
    return Container(
      height: double.infinity,
      width: 700,
      child: Column(
        children: [
          Text(data['id'].toString()),
          Container(
            child: Image(
              image: NetworkImage(data['mapURL']),
            ),
          ),
          RaisedButton(
            onPressed: () => _backToHome(),
            child: Text("return to home page"),
          ),
        ],
      ),
    );
  }

  void _backToHome() {
    Navigator.popUntil(
        context, ModalRoute.withName(Navigator.defaultRouteName));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
