import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/chats/chat_screen.dart';
import 'package:flutter_chat_app/util//photo.dart';
import 'package:page_transition/page_transition.dart';

class Chats extends StatefulWidget {

  String currentUserId;

  Chats({this.currentUserId});

  @override
  ChatsState createState() => ChatsState(currentUserId: currentUserId);
}

class ChatsState extends State<Chats> {

  String currentUserId;
  ChatsState({this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("chats").document(currentUserId).collection("users").snapshots(),
        builder: (context , snapshot) {
          if(!snapshot.hasData){
            return Center(child: Text("No Data Found"),);
          }
          else{
            return _buildList(context, snapshot.data.documents);
          }
        },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final _userRec = Record.fromSnapshot(data);

    return Container(
      padding: EdgeInsets.all(10.0),
      child: ListTile(
        onTap: (){
          Navigator.of(context).push(
              PageTransition(
                child: ChatScreen(
                  currentUserId: currentUserId,
                  chatUserId: _userRec.reference.documentID,
                  chatUserName: _userRec.name,
                  chatUserPic: _userRec.img,
                ),
                duration: Duration(seconds: 1),
                type: PageTransitionType.fade
              )
          );
        },
        title: Padding(
          padding: EdgeInsets.only(left: 20.0),
          child: Text(_userRec.name),
        ),
        leading: InkWell(
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => PhotoActivity(img: _userRec.img,)));
          },
          child: CircleAvatar(
            backgroundImage: NetworkImage(_userRec.img),
          ),
        ),
      ),

    );
  }
}

class Record {
  final String name , img;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['img'] != null),
        name = map['name'],
        img = map['img'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$img>";
}
