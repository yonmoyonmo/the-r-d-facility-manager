import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../graphQLBloc/GraphQLBloc.dart';
import '../graphQLBloc/GraphQLStates.dart';

class CreateZone extends StatefulWidget {
  CreateZone() {}
  @override
  _CreateZoneState createState() => _CreateZoneState();
}

class _CreateZoneState extends State<CreateZone> {
  Map<String, dynamic> data;

  @override
  void initState() {
    super.initState();
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('make a zone'),
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
          data = (state as LoadDataSuccess).data['createZone'];
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
