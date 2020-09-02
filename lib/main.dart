import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'graphQLBloc/Simple_delegate.dart';
import './graphQLBloc/GraphQLBloc.dart';
import './graphQLBloc/GraphQLEvents.dart';

import 'pages/ZoneMaker.dart';
import 'pages/ItemMaker.dart';
import 'pages/AllZones.dart';
import 'pages/AddMap.dart';

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
    id
    name
    mac
    major
    map{
      id
      mapURL
    }
  }
}
  ''';

  @override
  void initState() {
    super.initState();
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('Facility Manager Tool (Demo)'),
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
    Size mediaSize = MediaQuery.of(context).size;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(10),
            height: mediaSize.height / 10,
            width: mediaSize.width / 1.2,
            child: RaisedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ZoneMaker()));
              },
              child: Text("Zone Maker"),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            height: mediaSize.height / 10,
            width: mediaSize.width / 1.2,
            child: RaisedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ItemMaker()));
              },
              child: Text("Item Maker"),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            height: mediaSize.height / 10,
            width: mediaSize.width / 1.2,
            child: RaisedButton(
              color: Colors.deepOrange[100],
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
          ),
          Container(
            margin: EdgeInsets.all(10),
            height: mediaSize.height / 10,
            width: mediaSize.width / 1.2,
            child: RaisedButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => AddMap()));
              },
              child: Text("Add a map to a zone"),
            ),
          ),
        ],
      ),
    );
  }
}
