import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Notifications extends StatefulWidget {
  String uid;
  Notifications({this.uid});
  @override
  _NotificationsState createState() => _NotificationsState(uid : uid);
}

class _NotificationsState extends State<Notifications> {
  String uid;
  _NotificationsState({this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("notifications").snapshots(),
        builder: (context , snapshot){
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
    final _notifyRec = Record.fromSnapshot(data);
    return Visibility(
      visible: _notifyRec.uid == uid,
      child: Slidable(
        delegate: new SlidableDrawerDelegate(),
        actionExtentRatio: 0.25,
        child: ListTile(
          leading: Icon(Icons.notifications),
          title: Text(_notifyRec.title),
          subtitle: Text(_notifyRec.subtitle),
        ),
        secondaryActions: <Widget>[
          new IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: (){
              _notifyRec.reference.delete();
            },
          ),
        ],
      ),
    );
  }
}

class Record {
  final String title , subtitle , uid;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['title'] != null),
        assert(map['subtitle'] != null),
        assert(map['uid'] != null),
        title = map['title'],
        uid = map['uid'],
        subtitle = map['subtitle'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$title:$subtitle>";
}