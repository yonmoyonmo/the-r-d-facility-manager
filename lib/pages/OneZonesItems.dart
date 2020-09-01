import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../graphQLBloc/GraphQLBloc.dart';
import '../graphQLBloc/GraphQLStates.dart';

class OneZonesItems extends StatefulWidget {
  OneZonesItems({Key key}) : super(key: key);

  @override
  _OneZonesItemsState createState() => _OneZonesItemsState();
}

class _OneZonesItemsState extends State<OneZonesItems> {
  List data = [];
  @override
  void initState() {
    super.initState();
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('all zones'),
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
                  Text(state.error.toString()),
                ],
              ));
        } else {
          data = (state as LoadDataSuccess).data['getOneZone']['items'];
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
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index) {
          var item = data[index];
          return Card(
            elevation: 4.0,
            child: Column(children: [
              Container(
                child: Image(
                  image: NetworkImage(item['imageURL']),
                ),
              ),
              ListTile(
                leading: Text(item['name']),
                title: Text(item['desc']),
              ),
            ]),
          );
        },
      ),
    );
  }
}
