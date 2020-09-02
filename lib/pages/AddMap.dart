import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:science_center_manager/graphQLBloc/GraphQLStates.dart';
import '../graphQLBloc/GraphQLBloc.dart';
import '../graphQLBloc/GraphQLEvents.dart';
import 'CreateMap.dart';

class AddMap extends StatefulWidget {
  AddMap({Key key}) : super(key: key);

  @override
  _AddMapState createState() => _AddMapState();
}

class _AddMapState extends State<AddMap> {
  File _image;
  String _imageURL = "";
  int zoneIdOfthis;
  String name;
  String desc;
  List data = [];
  String allZonesQuery = r'''
  query{
    getAllZones{
      id
      name
    }
  }
  ''';
  String addMapQuery = '';

  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
      });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GraphQLBloc>(
      create: (BuildContext context) =>
          GraphQLBloc()..add(FetchGQLData(allZonesQuery)),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: Text("Add Map")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 100,
                width: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: (_imageURL != null)
                        ? NetworkImage(_imageURL)
                        : AssetImage("images/LOCS logo.PNG"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    child: Text("Gallery"),
                    onPressed: () {
                      _uploadImageToStorage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    child: RaisedButton(
                      onPressed: () {
                        setState(() {
                          addMapQuery =
                              'mutation{addMap(zoneId:${zoneIdOfthis}, url:"${_imageURL}"){id,mapURL}}';
                        });
                      },
                      child: Text("set query"),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return BlocProvider<GraphQLBloc>(
                            create: (BuildContext context) =>
                                GraphQLBloc()..add(FetchGQLData(addMapQuery)),
                            child: CreateMap(),
                          );
                        }));
                      },
                      child: Text("Create a Map"),
                    ),
                  ),
                ],
              ),
              Container(
                height: 100,
                width: 400,
                child: Text(addMapQuery),
              ),
              BlocBuilder<GraphQLBloc, GraphQLStates>(
                builder: (BuildContext context, GraphQLStates state) {
                  if (state is Loading) {
                    return Container(
                      child: LinearProgressIndicator(),
                    );
                  } else if (state is LoadDataFail) {
                    return Container(
                      child: Text("gql data load fail"),
                    );
                  } else {
                    data = (state as LoadDataSuccess).data['getAllZones'];
                    print(data);
                    return _buildListOfZones();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildListOfZones() {
    return Container(
        height: 200,
        width: 300,
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            var item = data[index];
            return ListTile(
              onTap: () {
                zoneIdOfthis = int.parse(item['id']);
              },
              leading: Text(item['id']),
              title: Text(item['name']),
            );
          },
        ));
  }

  void _uploadImageToStorage(ImageSource source) async {
    File image = await ImagePicker.pickImage(source: source);
    if (image == null) return;
    setState(() {
      _image = image;
    });
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('images/${Path.basename(_image.path)}}');
    StorageUploadTask storageUploadTask = storageReference.putFile(_image);
    await storageUploadTask.onComplete;
    String downloadURL = await storageReference.getDownloadURL();
    setState(() {
      _imageURL = downloadURL;
    });
  }
}
