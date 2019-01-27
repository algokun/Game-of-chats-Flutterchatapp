import 'dart:io';
import 'dart:math' as Math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/util/compressor.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditUserInfo extends StatefulWidget {
  final String userImg , name , uid;
  EditUserInfo({this.userImg , this.name , this.uid});

  @override
  _EditUserInfoState createState() => _EditUserInfoState(name: name , userImg: userImg , uid: uid);
}

class _EditUserInfoState extends State<EditUserInfo> {

  final String userImg , name , uid;
  _EditUserInfoState({this.userImg , this.name , this.uid});

  File _image;

  bool isProgressVisible , isButtonEnabled;

  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    isProgressVisible = false;
    isButtonEnabled = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: ListView(
        children: <Widget>[
          Visibility(
            visible: isProgressVisible,
            child: LinearProgressIndicator(
              backgroundColor: Colors.redAccent,
            ),
          ),
          Container(
            padding: EdgeInsets.all(15.0),
            child: GestureDetector(
              child: _image == null  ? Image.network(userImg , fit: BoxFit.cover,) : Image.file(_image),
              onTap: () {
                getImage().then((value){
                  setState(() {
                    this.isProgressVisible = false;
                  });
                });
              },
            ),
            height: height / 3,
          ),
          Container(
            padding: EdgeInsets.all(15.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: name,
                labelText: "Choose New Name"
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Material(
        elevation: 10.0,
        color: Colors.green,
        child: Container(
          width: double.infinity,
          height: height / 12,
          child: FlatButton(
              onPressed: (){
                setUserData();
              },
              child: Text("Save Changes" , style: TextStyle(color: Colors.white),)
          ),
        ),
      ),
    );
  }

  Future getImage() async {
    setState(() {
      isProgressVisible = true;
    });

    CompressImage compressImage = CompressImage();
    File file = await compressImage.takePicture(context);
    setState(() {
      _image = file;
    });
  }

  Future _uploadImage(image , uid , newName) async{
    int rand = new Math.Random().nextInt(10000);
    final StorageReference reference = FirebaseStorage.instance.ref().child(
        'profile/images/$rand.jpg');
    final StorageUploadTask uploadTask = reference.putFile(image);
    var downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL();

    Firestore.instance.collection("users").document(uid).updateData({
      "name" : newName,
      "img" :  downloadUrl
    }).then((value){
      UserUpdateInfo user_info = UserUpdateInfo();
      user_info.displayName = newName;
      user_info.photoUrl = downloadUrl;

      FirebaseAuth.instance.currentUser().then((value){
        value.updateProfile(user_info);
      });

    });
  }

  void setUserData(){
    setState(() {
      isButtonEnabled = false;
      isProgressVisible = true;
    });
    UserUpdateInfo info = UserUpdateInfo();

    if(_image == null){
      info.displayName = _controller.text;
      FirebaseAuth.instance.currentUser().then((value){
        value.updateProfile(info);
      });
    }
    else{
      if(_controller.text.isEmpty){
        _uploadImage(_image, uid, name).then((value){
          Fluttertoast.showToast(
              msg: "Changes Made",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 1
          );
        });
      }
      else{
        _uploadImage(_image, uid, _controller.text).then((value){
          Fluttertoast.showToast(
              msg: "Changes Made",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 1
          );
        });
      }
    }

    Navigator.pop(context);
  }
}
