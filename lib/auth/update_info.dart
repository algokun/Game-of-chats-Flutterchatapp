import 'dart:async';
import 'dart:io';
import 'dart:math' as Math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/util/compressor.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/home.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isButtonEnabled = false;
  String displayName;
  File _image;
  var radius1 = 60.0;
  var radius2 = 50.0;
  var radius3 = 50.0;
  var radius4 = 50.0;
  var assetImage;
  var chosenValue = 0;
  var _photoUrl;
  bool chooseFromGallery = false;
  final List<String> _assetImages = [
    "assets/male1.png",
    "assets/female2.png",
    "assets/female1.png",
    "assets/male2.png",
  ];
  final List<String> _downloadUrls = [
    "https://firebasestorage.googleapis.com/v0/b/fluttersimplechatapp.appspot.com/o/default_user_imgs%2Fmale1.png?alt=media&token=05a49601-a385-42ce-8756-a9f26acde9f3",
    "https://firebasestorage.googleapis.com/v0/b/fluttersimplechatapp.appspot.com/o/default_user_imgs%2Ffemale2.png?alt=media&token=ddfbc47a-6ac7-4a20-b2a7-3d98af968252",
    "https://firebasestorage.googleapis.com/v0/b/fluttersimplechatapp.appspot.com/o/default_user_imgs%2Ffemale1.png?alt=media&token=af89407c-6dbb-40f2-986e-b8aeb44bbc71",
    "https://firebasestorage.googleapis.com/v0/b/fluttersimplechatapp.appspot.com/o/default_user_imgs%2Fmale2.png?alt=media&token=7dcc125b-e50b-403b-aa82-c574f8b9b841",
  ];

  bool isProgressVisible = false;

  @override
  void initState() {
    assetImage = _assetImages[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Update your Profile"),
        leading: Text(""),
        centerTitle: true,
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Visibility(
            visible: isProgressVisible,
            child: LinearProgressIndicator(backgroundColor: Colors.redAccent,)
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: EdgeInsets.only(top: 20.0),
              width: 150.0,
              height: 150.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: chooseFromGallery ? FileImage(_image) : AssetImage(
                      assetImage),
                  fit: BoxFit.cover,
                ),
                borderRadius: new BorderRadius.all(new Radius.circular(80.0)),
                border: new Border.all(
                  color: Colors.green,
                  width: 4.0,
                ),
              ),
            ),
          ),
          Container(
            width: _width,
            padding: EdgeInsets.all(10.0),
            child: Wrap(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => clickProfile(1),
                      child: CircleAvatar(
                        backgroundImage: AssetImage(_assetImages[0]),
                        backgroundColor: Colors.transparent,
                        radius: radius1,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => clickProfile(2),
                      child: CircleAvatar(
                        backgroundImage: AssetImage(_assetImages[1]),
                        backgroundColor: Colors.transparent,
                        radius: radius2,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => clickProfile(3),
                      child: CircleAvatar(
                        backgroundImage: AssetImage(_assetImages[2]),
                        backgroundColor: Colors.transparent,
                        radius: radius3,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => clickProfile(4),
                      child: CircleAvatar(
                        backgroundImage: AssetImage(_assetImages[3]),
                        backgroundColor: Colors.transparent,
                        radius: radius4,
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Container(
                      width: _width / 2,
                      child: RaisedButton(onPressed: () => getImage(),
                        child: Text("Choose from Gallery"),)
                  ),
                )
              ],
            ),
          ),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
              child: TextField(
                onChanged: (value) => feedName(value),
                maxLength: 15,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    labelText: "Name",
                    prefixIcon: Icon(Icons.person)
                ),
              )
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
            width: _width,
            child: RaisedButton(
              onPressed: isButtonEnabled ? () async {
                await FirebaseAuth.instance.currentUser().then((user){
                  _uploadImage(_image, displayName, user.uid);
                });
              } : null,
              color: Colors.green,
              child: Text("Done", style: TextStyle(color: Colors.white),),
            ),
          )
        ],
      ),
    );
  }

  void feedName(String value) {
    if (value != null) {
      setState(() {
        this.displayName = value;
        this.isButtonEnabled = true;
      });
    }
  }

  void clickProfile(value) {
    setState(() {
      chooseFromGallery = false;
    });
    switch (value) {
      case 1:
        setState(() {
          radius1 = 60.0;
          radius2 = 50.0;
          radius3 = 50.0;
          radius4 = 50.0;
          assetImage = _assetImages[0];
          chosenValue = 0;
        });
        break;
      case 2:
        setState(() {
          radius1 = 50.0;
          radius2 = 60.0;
          radius3 = 50.0;
          radius4 = 50.0;
          chosenValue = 1;
          assetImage = _assetImages[1];
        });
        break;
      case 3:
        setState(() {
          radius1 = 50.0;
          radius2 = 50.0;
          radius3 = 60.0;
          radius4 = 50.0;
          chosenValue = 2;
          assetImage = _assetImages[2];
        });
        break;
      case 4:
        setState(() {
          radius1 = 50.0;
          radius2 = 50.0;
          radius3 = 50.0;
          radius4 = 60.0;
          chosenValue = 3;
          assetImage = _assetImages[3];
        });
        break;
    }
  }

  Future getImage() async {
    setState(() {
      this.isProgressVisible = true;
    });
    CompressImage compressImage = CompressImage();
    File file = await compressImage.takePicture(context);
    setState(() {
      _image = file;
      radius1 = radius2 = radius3 = radius4 = 50.0;
      chooseFromGallery = true;
      this.isProgressVisible = false;
    });
  }

  Future _uploadImage(image, name, uid) async {
    if (image == null) {
      FirebaseAuth.instance.currentUser().then((user){
        UserUpdateInfo userInfo = UserUpdateInfo();
        userInfo.displayName = displayName;
        userInfo.photoUrl = _downloadUrls[chosenValue];
        user.updateProfile(userInfo).then((value){
          Firestore.instance.collection("users").document(uid).setData({
            "name" : name,
            "uid" : uid,
            "img" : _downloadUrls[chosenValue],
            "privacy" : false
          });
        }).then((value){
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage(displayName: displayName , photoUrl: _downloadUrls[chosenValue],)));
        });
      });
    }
    else {
      int rand = new Math.Random().nextInt(10000);
      final StorageReference reference = FirebaseStorage.instance.ref().child(
          'profile/images/$rand.jpg');
      final StorageUploadTask uploadTask = reference.putFile(image);
      var downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
      FirebaseAuth.instance.currentUser().then((user){
        UserUpdateInfo userInfo = UserUpdateInfo();
        userInfo.displayName = displayName;
        userInfo.photoUrl = downloadUrl;
        user.updateProfile(userInfo).then((value){
          Firestore.instance.collection("users").document(uid).setData({
            "name" : name,
            "uid" : uid,
            "img" : downloadUrl,
            "privacy" : false
          });
        }).then((value){
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage(displayName: displayName , photoUrl: downloadUrl,)));
        });
      });
    }
  }
  @override
  void dispose() {
    super.dispose();
  }
}