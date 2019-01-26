import 'dart:io';
import 'dart:math' as Math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/util//compressor.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddPost extends StatefulWidget {

  final String uid , name , uImg;

  AddPost({this.uid , this.name , this.uImg});

  @override
  _AddPostState createState() => _AddPostState(uid: uid , name: name , uImg: uImg);
}

class _AddPostState extends State<AddPost> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final String uid , name , uImg;

  _AddPostState({this.uid , this.name , this.uImg});

  TextEditingController _controller = TextEditingController();
  File _imageFile;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Add Post"),
      ),
      bottomNavigationBar: Material(
        color: Colors.green,
        elevation: 10.0,
        child: Container(
          width: double.infinity,
          height: height / 12,
          child: FlatButton(
              onPressed: () => writePost(),
              child: Text("Done" , style: TextStyle(color: Colors.white),)
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height / 2,
            child: GestureDetector(
              child: _imageFile == null ? Image.asset("assets/default.jpg" , fit: BoxFit.cover,) : Image.file(_imageFile , fit: BoxFit.cover,),
              onTap: () => getImage(),
            ),
          ),
          Container(
            child: new ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 300.0,
              ),
              child: new Scrollbar(
                child: new SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  reverse: true,
                  child: new TextField(
                    maxLines: null,
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "What's on Your Mind??",
                      border: InputBorder.none
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  Future getImage() async {
    CompressImage compressImage = CompressImage();
    File file = await compressImage.takePicture(context);
    setState(() {
      _imageFile = file;
    });
  }

  Future _uploadImage(image , uid , desc) async{
    int rand = new Math.Random().nextInt(10000);
    final StorageReference reference = FirebaseStorage.instance.ref().child(
        'posts/$uid/$rand.jpg');
    final StorageUploadTask uploadTask = reference.putFile(image);
    var downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL();

    Firestore.instance.collection("newsfeed").add({
      "name" : name,
      "img" : downloadUrl,
      "desc" : desc,
      "time" : DateTime.now().toIso8601String(),
      "uimg" : uImg,
      "uid" : uid
    }).then((error){
      Fluttertoast.showToast(
          msg: "Your Post is added",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1
      );
    });
  }

  void writePost(){
    String desc = _controller.text;
    _imageFile != null ?
    _uploadImage(_imageFile, uid, desc).then((value){
      Navigator.of(context).pop();
    }) :
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Make sure that image is not empty"),
    ));
  }
}
