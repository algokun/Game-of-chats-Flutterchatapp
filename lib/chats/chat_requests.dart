import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Requests extends StatefulWidget {
  String uid , currentUserName , currentUserPic;
  Requests({this.uid , this.currentUserPic , this.currentUserName});
  @override
  _RequestsState createState() => _RequestsState(uid: uid , currentUserPic: currentUserPic , currentUserName: currentUserName);
}

class _RequestsState extends State<Requests> {

  String uid , currentUserName , currentUserPic;

  _RequestsState({this.uid , this.currentUserPic , this.currentUserName});

  String friendName , friendPic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection("chatrequests").document(uid).collection("requests").snapshots(),
          builder: (context , snapshot) {
            if(!snapshot.hasData){
              return Center(child: Text("No Requests "
                  "Found"),);
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
    final accept = _userRec.accept;
    return Container(
      padding: EdgeInsets.all(10.0),

      child: ListTile(
        title: Padding(
          padding: EdgeInsets.only(left: 20.0),
          child: Text(_userRec.name),
        ),
        leading: CircleAvatar(backgroundImage: NetworkImage(_userRec.img), radius: 30.0,),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Visibility(
              visible: !accept,
              child: FlatButton.icon(
                icon: Icon(Icons.delete , color: Colors.red,),
                onPressed: () => deleteRequest(_userRec.reference) ,
                label: Text("Delete"),
                shape: StadiumBorder(side: BorderSide(color: Colors.redAccent)),
              ),
            ),
            SizedBox(width: 10,),
            FlatButton.icon(
              icon: !accept ? Icon(Icons.done_all , color: Colors.green,) : Icon(Icons.people , color: Colors.green,),
              onPressed: !accept ? () => acceptRequest(_userRec.reference ,_userRec.from , _userRec.to) : (){},
              label: !accept ? Text("Accept") : Text("Friends" ),
              shape: StadiumBorder(side: BorderSide(color: Colors.green)),
            ),
          ],
        ),
        contentPadding: EdgeInsets.all(10.0),
      ),

    );
  }

  void deleteRequest(DocumentReference ref){
    ref.delete().then((value){
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Request Deleted")));
    });
  }

  void acceptRequest(DocumentReference ref , String requestUser , String currentUser) async {
    ref.updateData({
      "accept" : true
    });
    Firestore.instance
        .collection("chats")
        .document(requestUser)
        .collection("users")
        .document(currentUser)
        .setData({
      "name" : currentUserName,
      "img" : currentUserPic
    }).then((value){
      getUserData(requestUser).then((value){
        Firestore.instance
            .collection("chats")
            .document(currentUser)
            .collection("users")
            .document(requestUser)
            .setData({
          "name" : friendName,
          "img" : friendPic
        }).then((value){
          Scaffold.of(context).showSnackBar(SnackBar(content: Text("Request Accepted")));
        }
        );
      });
    });
  }

  Future getUserData(String userID) async{
    await Firestore.instance.collection("users").document(userID).get().then((doc){
      setState(() {
        friendName = doc.data['name'];
        friendPic = doc.data['img'];
      });
    });
  }
}

class Record {
  final String name , img , from , to;
  final bool accept;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['img'] != null),
        assert(map['from'] != null),
        assert(map['to'] != null),
        assert(map['accept'] != null),
        name = map['name'],
        from = map['from'],
        to = map['to'],
        img = map['img'],
        accept = map['accept'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$img>";
}
