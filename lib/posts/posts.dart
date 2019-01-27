import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/util//photo.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Posts extends StatefulWidget {
  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("newsfeed").orderBy("time" , descending: true).snapshots(),
        builder: (context , snapshot){
          if(!snapshot.hasData) return Center(child: Text("No Posts Yet"),);

          return ListView(
            padding: const EdgeInsets.only(top: 20.0),
            children: snapshot.data.documents.map((data) => _buildListItem(context, data)).toList(),
          );
        },
      ),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final _postRec = PostRecord.fromSnapshot(data);
    return CardTile(
      userImage: _postRec.uImg,
      username: _postRec.name,
      desc: _postRec.desc,
      timestamp: _postRec.time,
      postImage: _postRec.img,
    );
  }
}

class CardTile extends StatelessWidget {
  final String username , timestamp , userImage , desc , postImage;
  CardTile({this.username, this.timestamp, this.userImage, this.desc , this.postImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Card(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.fade,
                            child: PhotoActivity(img: postImage,) ,
                            duration: Duration(seconds: 1))
                    );
                  },
                  child: Container(
                    child: Stack(
                      children: <Widget>[
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 3,
                          width: double.infinity,
                          child: Image.network(
                            postImage,
                            fit: BoxFit.cover,
                            color: Colors.black45,
                            colorBlendMode: BlendMode.darken,
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 30,
                          right: 30,
                          child: Text(
                            desc,
                            style: Theme.of(context).textTheme.subhead.apply(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 60.0,
                  width: double.infinity,
                  color: Colors.white,
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        username,
                        style: Theme.of(context).textTheme.subhead,
                      ),
                      Text(
                        dateConvert(DateTime.parse(timestamp)),
                        style: Theme.of(context).textTheme.caption.apply(color: Colors.black45),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Positioned(
              child: CircleAvatar(
                radius: 45.0,
                backgroundColor: Colors.white,
              ),
              bottom: 18,
              right: 10,
            ),
            Positioned(
              child: GestureDetector(
                onTap: () {
                  Alert(
                      context: context,
                      type: AlertType.none,
                      title: username,
                      style: AlertStyle(
                          animationDuration: Duration(seconds: 1),
                          animationType: AnimationType.grow
                      ),
                      content: Image.network(userImage)
                  ).show();
                },
                child: CircleAvatar(
                  radius: 35.0,
                  backgroundImage: NetworkImage(userImage),
                  backgroundColor: Colors.white,
                ),
              ),
              bottom: 30,
              right: 20,
            ),
          ],
        )
      ),
    );
  }

  String dateConvert(a){
    var date = DateTime.now();
    var hr = date.difference(a).inHours;
    var ret;
    if(hr > 23){
      hr = date.difference(a).inDays;
      ret = '$hr'+'d';
    }
    else if(hr < 1){
      hr = date.difference(a).inMinutes;
      if(hr <= 1){
        ret = 'Just now';
      }
      else{
        ret = '$hr'+'m';
      }
    }
    else{
      ret = '$hr'+'h';
    }
    return ret != 'Just now' ? ret + " ago" : ret;
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
