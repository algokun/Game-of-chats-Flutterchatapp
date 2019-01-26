import 'dart:io';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:flutter_villains/villains/villains.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:photo_view/photo_view.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';


class PhotoActivity extends StatelessWidget {
  PhotoActivity({this.img});
  String img;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Image"),
        actions: <Widget>[
          FlatButton(
            onPressed: getPermissions,
            child: Text("Save Image")
          )
        ],
      ),
      body: Villain(
        villainAnimation: VillainAnimation.fromBottom(
          relativeOffset: 0.4,
          from: Duration(milliseconds: 100),
          to: Duration(milliseconds: 700),
        ),
        animateExit: false,
        secondaryVillainAnimation: VillainAnimation.scale(),
        child: PhotoView(
          backgroundDecoration: BoxDecoration(
              color: Colors.white
          ),
          imageProvider: NetworkImage(img),
        ),
      ),
    );
  }

  Future saveFile() async {
    var response = await get(img);

    final documentDirectory = await getExternalStorageDirectory();

    final storageDirectory = Directory(documentDirectory.path + '/GameOfChats/Pictures');

    storageDirectory.exists().then((bool value){
      if(!value){
        storageDirectory.create();
      }
    });

    final date = DateTime.now();

    int rand = new Math.Random().nextInt(10000);

    String timestamp = "" + date.year.toString() + "" + date.month.toString() + "" + date.day.toString() + "_" + rand.toString();

    File file = new File(
        join(storageDirectory.path, 'IMG'+timestamp+'.png')
    );

    file.writeAsBytesSync(response.bodyBytes);
  }

  void getPermissions() async{
    await SimplePermissions.requestPermission(Permission.WriteExternalStorage).then((permission){
      saveFile().then((saved){
        Fluttertoast.showToast(
            msg: "Image Saved",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1
        );
      });
    });
  }
}