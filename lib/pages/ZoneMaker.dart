import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../beaconBloc/BeaconBloc.dart';
import '../graphQLBloc/GraphQLBloc.dart';
import '../graphQLBloc/GraphQLEvents.dart';
import 'CreateZone.dart';
import 'MacAddressCheck.dart';

class ZoneMaker extends StatefulWidget {
  ZoneMaker({Key key}) : super(key: key);

  @override
  _ZoneMakerState createState() => _ZoneMakerState();
}

class _ZoneMakerState extends State<ZoneMaker> {
  final beaconBloc = BeaconBloc();
  String mac = "없음";
  int major = 0;
  String name = 'default';
  String query = '';
  String query2 = '';

  final TextEditingController _textController = new TextEditingController();

  @override
  void dispose() {
    super.dispose();
    beaconBloc.dispose();
  }

  void _handleSubmitted(String text) {
    name = text;
  }

  @override
  Widget build(BuildContext context) {
    print(name);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder(
            stream: beaconBloc.beaconStream,
            builder: (context, snapshot) {
              return Container(
                  height: 100,
                  width: 300,
                  child: Text(snapshot.data.toString()));
            },
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration:
                  new InputDecoration.collapsed(hintText: "enter zone name"),
            ),
          ),
          StreamBuilder(
              stream: beaconBloc.majStream,
              builder: (context, snapshot1) {
                return StreamBuilder(
                  stream: beaconBloc.macStream,
                  builder: (context, snapshot2) {
                    return Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(20),
                          color: Colors.lightBlue,
                          child: Text("current query : " + query),
                        ),
                        Container(
                          margin: EdgeInsets.all(20),
                          color: Colors.pink,
                          child: Text("current name : " + name),
                        ),
                        Container(
                          margin: EdgeInsets.all(20),
                          color: Colors.green,
                          child: Text("current mac : " + mac),
                        ),
                        Container(
                          margin: EdgeInsets.all(20),
                          color: Colors.orange,
                          child: Text("current major : " + major.toString()),
                        ),
                        RaisedButton(
                          child: Text("set name"),
                          onPressed: () =>
                              _handleSubmitted(_textController.text),
                        ),
                        RaisedButton(
                          onPressed: () {
                            setState(() {
                              mac = snapshot2.data;
                              major = snapshot1.data;
                            });
                          },
                          child: Text("Get this Beacon's mac and major"),
                        ),
                        RaisedButton(
                          onPressed: () {
                            setState(() {
                              print(major);
                              query =
                                  'mutation{createZone(data:{mac:"${mac}", major:${major}, name:"${name}"}){id, name, mac, major}}';
                            });
                          },
                          child: Text("set query"),
                        ),
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
                        RaisedButton(
                          onPressed: () {
                            setState(() {
                              print(major);
                              query2 =
                                  'query{getOneZone(macAddr:"${mac}"){id, name, mac, major}}';
                            });
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return BlocProvider<GraphQLBloc>(
                                create: (BuildContext context) =>
                                    GraphQLBloc()..add(FetchGQLData(query2)),
                                child: MacAddressCheck(),
                              );
                            }));
                          },
                          child: Text("Mac Address duplication check"),
                        ),
                      ],
                    );
                  },
                );
              }),
        ],
      ),
    );
  }
}
