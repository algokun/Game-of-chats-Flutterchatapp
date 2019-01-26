import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  String name , image , uid;

  Settings({this.name, this.image, this.uid});

  @override
  _SettingsState createState() => _SettingsState(image: image , uid: uid , name: name);
}

class _SettingsState extends State<Settings> {
  String name , image , uid;

  _SettingsState({this.name, this.image, this.uid});

  @override
  Widget build(BuildContext context) {

    final height = MediaQuery.of(context).size.height;
//    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: height / 3 + 30,
            child: Stack(
              children: <Widget>[
                BlurredImage(image: image,height: height / 4,),
                Positioned(
                  top: 100,
                  left: 20,
                  child: CircleAvatar(
                    radius: 60.0,
                    backgroundImage: NetworkImage(image),
                  ),
                ),
                Positioned(
                  bottom: 100,
                  right: 20,
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.headline.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows:[
                          Shadow(color: Colors.black , blurRadius: 20.0 , offset: Offset(2, 1))
                        ]
                    ),
                  )
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
                "Timeline",
                style: Theme.of(context).textTheme.subhead.copyWith(fontWeight: FontWeight.bold)
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Divider(color: Colors.black,),
          ),
          Container(
            height: height / 4,
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection("newsfeed").where("name" , isEqualTo: name).orderBy("time",descending: true).snapshots(),
              builder: (context , snapshot){
                if(!snapshot.hasData) return Center(child: Text("No Posts Yet"),);

                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(10.0),
                  children: snapshot.data.documents.map((data) => _buildListItem(context, data)).toList(),
                );
              },
            ),
          )
        ],
      )
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final _postRec = PostRecord.fromSnapshot(data);
    return Card(
      elevation: 6,
      child: Container(
          width: MediaQuery.of(context).size.width / 2,
          child: Image.network(_postRec.img , fit: BoxFit.cover)
      ),
    );
  }
}

class BlurredImage extends StatelessWidget {
  final String image;
  final double height;
  BlurredImage({this.image , this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new NetworkImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: new BackdropFilter(
        filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: new Container(
          decoration: new BoxDecoration(color: Colors.black.withOpacity(0.2)),
        ),
      ),
    );
  }
}

class PostRecord {
  final String name , time , uImg , desc , img;
  final DocumentReference reference;

  PostRecord.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['time'] != null),
        assert(map['img'] != null),
        assert(map['uimg'] != null),
        name = map['name'],
        time = map['time'],
        img = map['img'],
        uImg = map['uimg'],
        desc = map['desc'];

  PostRecord.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$time:$desc:$img:$uImg>";
}
