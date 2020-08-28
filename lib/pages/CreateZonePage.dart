import 'package:flutter/material.dart';
import '../beaconBloc/BeaconBloc.dart';

class CreateZonePage extends StatefulWidget {
  CreateZonePage({Key key}) : super(key: key);

  @override
  _CreateZonePageState createState() => _CreateZonePageState();
}

class _CreateZonePageState extends State<CreateZonePage> {
  final beaconBloc = BeaconBloc();
  @override
  void dispose() {
    super.dispose();
    beaconBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: StreamBuilder(
          stream: beaconBloc.macStream,
          builder: (context, snapshot) {
            return Text(snapshot.data);
          },
        ),
      ),
    );
  }
}
