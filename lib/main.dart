import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'graphQLBloc/Simple_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './graphQLBloc/GraphQLBloc.dart';
import './graphQLBloc/GraphQLEvents.dart';

import 'pages/ZoneMaker.dart';
import 'pages/ItemMaker.dart';
import 'pages/AllZones.dart';

void main() {
  BlocSupervisor.delegate = MySimpleBlocDelegate();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(title: "LOCS Science Center Manager"));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String query = r'''
    query{
    getAllZones{
      name
      mac
      major
    }
  ''';

  @override
  void initState() {
    super.initState();
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('GraphQL Demo'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buttons(),
    );
  }

  Widget _buttons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RaisedButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ZoneMaker()));
          },
          child: Text("Zone Maker"),
        ),
        RaisedButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ItemMaker()));
          },
          child: Text("Item Maker"),
        ),
        RaisedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return BlocProvider<GraphQLBloc>(
                create: (BuildContext context) =>
                    GraphQLBloc()..add(FetchGQLData(query)),
                child: AllZones(),
              );
            }));
          },
          child: Text("show all Zones"),
        ),
      ],
    );
  }
}
