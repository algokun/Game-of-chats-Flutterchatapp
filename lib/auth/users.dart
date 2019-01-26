import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Users extends StatefulWidget {
  String currentUserId , currentName , currentUserPic;

  Users({this.currentUserId , this.currentName , this.currentUserPic});

  @override
  _UsersState createState() => _UsersState(currentUserId: currentUserId , currentName: currentName , currentUserPic: currentUserPic);
}

class _UsersState extends State<Users> {
  String currentUserId , currentName , currentUserPic;

  _UsersState({this.currentUserId , this.currentName , this.currentUserPic});

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text("Add Friends"),),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("users").where("privacy" , isEqualTo: false).snapshots(),
        builder: (context , snapshot) {
          if(!snapshot.hasData){
            return Center(child: Text("No Data Found"),);
          }
          else{
            return _buildList(context, snapshot.data.documents);
          }
        },
      ),
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
    final _isVisible = _userRec.uid == currentUserId;
    return Visibility(
      visible: !_isVisible,
      child: Container(
        padding: EdgeInsets.all(10.0),

        child: ListTile(
          title: Text(_userRec.name),
          leading: CircleAvatar(backgroundImage: NetworkImage(_userRec.img), radius: 30.0,),
          trailing: IconButton(icon: Icon(Icons.person_add , color: Colors.green,), onPressed: () => requestUser(_userRec.uid , _userRec.name , _userRec.img)),
          key: ValueKey(_userRec.uid),
          contentPadding: EdgeInsets.all(10.0),
        ),

      ),
    );
  }
  void requestUser(String friendUserId , String name , String img){
    Firestore.instance.collection("chatrequests").document(friendUserId).collection("requests").document(currentUserId)
        .get()
        .then((value){
          if(value.exists){
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text("Request has been sent already"),
            ));
          }
          else{
            value.reference.setData({
              "from" : currentUserId,
              "to" : friendUserId,
              "name" : currentName,
              "img" : currentUserPic,
              "accept" : false
            }).then((value){
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text("Your request has been sent"),
              ));
            }).catchError((error){

            });
          }
    });
  }
}

class Record {
  final String name , img , uid;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['img'] != null),
        assert(map['uid'] != null),
        name = map['name'],
        uid = map['uid'],
        img = map['img'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$img:$uid>";
}