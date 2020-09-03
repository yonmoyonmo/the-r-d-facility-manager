import 'dart:async';
import 'BeaconEvent.dart';
import 'dart:io';
import 'package:flutter_beacon/flutter_beacon.dart';

class BeaconBloc {
  StreamSubscription<BluetoothState> _streamBluetooth;
  StreamSubscription<RangingResult> _streamRanging;
  final _regionBeacons = <Region, List<Beacon>>{};
  final _beacons = <Beacon>[];
  bool authorizationStatusOk = false;
  bool locationServiceEnabled = false;

  bool bluetoothEnabled = false;

  final _beaconStateStreamController = StreamController<BluetoothState>();
  StreamSink<BluetoothState> get stateSink => _beaconStateStreamController.sink;
  Stream<BluetoothState> get stateStream => _beaconStateStreamController.stream;

  final _beaconStreamController = StreamController<Beacon>();
  Stream<Beacon> get beaconStream => _beaconStreamController.stream;
  StreamSink<Beacon> get beaconSink => _beaconStreamController.sink;

  final _macStream = StreamController<String>();
  Stream<String> get macStream => _macStream.stream;
  StreamSink<String> get macSink => _macStream.sink;

  final _majStream = StreamController<int>();
  Stream<int> get majStream => _majStream.stream;
  StreamSink<int> get majSink => _majStream.sink;

  // final _accStream = StreamController<double>();
  // Stream<double> get accStream => _accStream.stream;
  // StreamSink<double> get accSink => _accStream.sink;

  final _beaconEventController = StreamController<BeaconEvent>();
  Sink<BeaconEvent> get beaconEventSink => _beaconEventController.sink;

  BeaconBloc() {
    _streamBluetooth = flutterBeacon
        .bluetoothStateChanged()
        .listen((BluetoothState state) async {
      if (!authorizationStatusOk) await flutterBeacon.requestAuthorization;
      if (!bluetoothEnabled) await flutterBeacon.bluetoothState;
      print('BluetoothState = $state');
      stateSink.add(state);
      switch (state) {
        case BluetoothState.stateOn:
          initScanBeacon();
          break;
        case BluetoothState.stateOff:
          await pauseScanBeacon();
          await checkAllRequirements();
          break;
      }
    });
  }
  checkAllRequirements() async {
    final bluetoothState = await flutterBeacon.bluetoothState;
    final bluetoothEnabled = bluetoothState == BluetoothState.stateOn;
    final authorizationStatus = await flutterBeacon.authorizationStatus;
    final authorizationStatusOk =
        authorizationStatus == AuthorizationStatus.allowed ||
            authorizationStatus == AuthorizationStatus.always;
    final locationServiceEnabled =
        await flutterBeacon.checkLocationServicesIfEnabled;
    this.authorizationStatusOk = authorizationStatusOk;
    this.locationServiceEnabled = locationServiceEnabled;
    this.bluetoothEnabled = bluetoothEnabled;
  }

  initScanBeacon() async {
    await flutterBeacon.initializeScanning;
    await checkAllRequirements();
    if (!authorizationStatusOk ||
        !locationServiceEnabled ||
        !bluetoothEnabled) {
      print('RETURNED, authorizationStatusOk=$authorizationStatusOk, '
          'locationServiceEnabled=$locationServiceEnabled, '
          'bluetoothEnabled=$bluetoothEnabled');
      return;
    }
    final regions = <Region>[];
    if (Platform.isIOS) {
      // iOS platform, at least set identifier and proximityUUID for region scanning
      regions.add(Region(
          identifier: 'BlunoBeetle',
          proximityUUID: '0000dfb0-0000-1000-8000-00805f9b34fb'));
    } else {
      // android platform, it can ranging out of beacon that filter all of Proximity UUID
      regions.add(Region(identifier: 'com.beacon'));
    }

    if (_streamRanging != null) {
      if (_streamRanging.isPaused) {
        _streamRanging.resume();
        return;
      }
    }

    _streamRanging =
        flutterBeacon.ranging(regions).listen((RangingResult result) {
      //print(result);
      if (result != null) {
        _regionBeacons[result.region] = result.beacons;
        _beacons.clear();
        _regionBeacons.values.forEach((list) {
          _beacons.addAll(list);
        });
        _beacons.sort(_compareParameters);
        //print(_beacons);
        _beacons.forEach((element) {
          if (element.accuracy < 4) {
            //얼마나 가까이 와야 하는지를 조절
            beaconSink.add(element);
            macSink.add(element.macAddress);
            majSink.add(element.major);
            //accSink.add(element.accuracy);
          }
        });
      }
    });
  }

  pauseScanBeacon() async {
    _streamRanging?.pause();
    if (_beacons.isNotEmpty) {
      _beacons.clear();
    }
  }

  int _compareParameters(Beacon a, Beacon b) {
    int compare = a.proximityUUID.compareTo(b.proximityUUID);

    if (compare == 0) {
      compare = a.major.compareTo(b.major);
    }

    if (compare == 0) {
      compare = a.minor.compareTo(b.minor);
    }

    return compare;
  }

  dispose() {
    _beaconStreamController?.close();
    _beaconEventController?.close();
    _beaconStateStreamController?.close();
    _macStream?.close();
    _majStream.close();
    //_accStream.close();
    _streamRanging?.cancel();
    _streamBluetooth?.cancel();
    flutterBeacon.close;
  }
}
