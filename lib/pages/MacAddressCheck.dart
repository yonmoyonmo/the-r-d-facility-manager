import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../graphQLBloc/GraphQLBloc.dart';
import '../graphQLBloc/GraphQLStates.dart';

class MacAddressCheck extends StatefulWidget {
  MacAddressCheck() {}
  @override
  _MacAddressCheckState createState() => _MacAddressCheckState();
}

class _MacAddressCheckState extends State<MacAddressCheck> {
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
              body: Center(
                child: Text(state.error.toString() + "\n아직 등록되지 않은 비콘이라는 뜻."),
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
          Text("또 등록 해도 상관 없지만 안하는게 나을듯?"),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
