import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:science_center_manager/graphQLBloc/GraphQLStates.dart';
import '../graphQLBloc/GraphQLBloc.dart';
import '../graphQLBloc/GraphQLEvents.dart';
import 'CreateItem.dart';

class ItemMaker extends StatefulWidget {
  ItemMaker({Key key}) : super(key: key);

  @override
  _ItemMakerState createState() => _ItemMakerState();
}

class _ItemMakerState extends State<ItemMaker> {
  final TextEditingController _textController = new TextEditingController();
  final TextEditingController _textController2 = new TextEditingController();
  File _image;

  String _imageURL = "";
  int zoneIdOfthis;
  String name;
  String desc;

  List data = [];

  String allZonesQuery = r'''
  query{
    getAllZones{
      zone{
        name
      }
      id
      name
    }
  }
  ''';

  String createItemQuery = '';

  void _handleSubmitted1(String text) {
    name = text;
  }

  void _handleSubmitted2(String text) {
    desc = text;
  }

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
        appBar: AppBar(title: Text("Cloud Storage Demo")),
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
                  RaisedButton(
                    child: Text("Camera"),
                    onPressed: () {
                      _uploadImageToStorage(ImageSource.camera);
                    },
                  )
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _textController,
                  onSubmitted: _handleSubmitted1,
                  decoration: new InputDecoration.collapsed(
                      hintText: "enter item name"),
                ),
              ),
              Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  height: 100,
                  width: 400,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: _textController2,
                    onSubmitted: _handleSubmitted2,
                    decoration: new InputDecoration.collapsed(
                        hintText: "enter item description"),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    child: RaisedButton(
                      onPressed: () {
                        setState(() {
                          createItemQuery =
                              'mutation{createItem(zoneId:${zoneIdOfthis}, data:{name:"${name}", desc:"${desc}", imageURL:"${_imageURL}"}){id,name,desc,imageURL}}';
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
                            create: (BuildContext context) => GraphQLBloc()
                              ..add(FetchGQLData(createItemQuery)),
                            child: CreateItem(),
                          );
                        }));
                      },
                      child: Text("Create a item"),
                    ),
                  ),
                ],
              ),
              Container(
                height: 100,
                width: 400,
                child: Text(createItemQuery),
              ),
              //zone selector 만들어야함
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

    // 파일 업로드
    StorageUploadTask storageUploadTask = storageReference.putFile(_image);

    // 파일 업로드 완료까지 대기
    await storageUploadTask.onComplete;

    // 업로드한 사진의 URL 획득
    String downloadURL = await storageReference.getDownloadURL();

    // 업로드된 사진의 URL을 페이지에 반영
    setState(() {
      _imageURL = downloadURL;
    });
  }
}
