import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:science_center_manager/graphQLBloc/GraphQLEvents.dart';
import 'package:science_center_manager/pages/OneZonesItems.dart';
import '../graphQLBloc/GraphQLBloc.dart';
import '../graphQLBloc/GraphQLStates.dart';

class AllZones extends StatefulWidget {
  AllZones({Key key}) : super(key: key);

  @override
  _AllZonesState createState() => _AllZonesState();
}

class _AllZonesState extends State<AllZones> {
  List data = [];

  String query = "";
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
          data = (state as LoadDataSuccess).data['getAllZones'];
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
      height: 400,
      width: 700,
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index) {
          var item = data[index];
          return ListTile(
            onTap: () {
              query =
                  'query{getOneZone(macAddr:"${item['mac']}"){items{name,desc,imageURL}}}';
              print(query);
              return Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                return BlocProvider<GraphQLBloc>(
                  create: (BuildContext context) =>
                      GraphQLBloc()..add(FetchGQLData(query)),
                  child: OneZonesItems(),
                );
              }));
            },
            leading: Text(item['mac']),
            title: Text(item['name']),
            trailing: Image(
              image: NetworkImage(item['map']['mapURL']),
            ),
          );
        },
      ),
    );
  }
}
