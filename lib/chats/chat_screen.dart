import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter_chat_app/chats/chat_bubble.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_villains/villains/villains.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChatScreen extends StatefulWidget {
  String chatUserId , currentUserId , chatUserPic , chatUserName;

  ChatScreen({this.currentUserId , this.chatUserId , this.chatUserPic , this.chatUserName});

  @override
  _ChatScreenState createState() => _ChatScreenState(
      currentUserId: currentUserId ,
      chatUserId: chatUserId,
      chatUserName: chatUserName,
      chatUserPic: chatUserPic
  );
}

class _ChatScreenState extends State<ChatScreen> {

  String chatUserId , currentUserId , chatUserPic , chatUserName;

  _ChatScreenState({this.currentUserId , this.chatUserId , this.chatUserPic , this.chatUserName});

  TextEditingController messageController = TextEditingController();

  ScrollController _scrollController;

  static AudioCache player = new AudioCache();
  var alarmAudioPath = "sent.mp3";

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width  = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Material(
            color: Colors.green,
            elevation: 10.0,
            child: Container(
              margin: EdgeInsets.only(top: 10.0),
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: ListTile(
                title: Text(chatUserName , style: Theme.of(context).textTheme.subhead.apply(color: Colors.white),),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back , color: Colors.white,),
                  onPressed: (){
                    Navigator.maybePop(context);
                  }
                ),
                trailing: Villain(
                  villainAnimation: VillainAnimation.fromBottom(
                    relativeOffset: 0.4,
                    from: Duration(milliseconds: 100),
                    to: Duration(seconds: 1),
                  ),
                  animateExit: false,
                  secondaryVillainAnimation: VillainAnimation.fade(),
                  child: InkWell(
                    onTap: () => flipCard(chatUserName , chatUserPic),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(chatUserPic),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildChatScreen(context),
          ),
          Material(
            color: Colors.white,
            elevation: 5.0,
            child: Container(
              height: height / 10,
              child: Row(
                children: <Widget>[
                  SizedBox(width: 10.0,),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      width: width / 2,
                      child: TextField(
                        controller: messageController,
                        style: new TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Start Typing..",
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.lightGreen,
                        borderRadius: BorderRadius.circular(20.0)
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: (){
                      sendMessage(chatUserId , currentUserId);
                    },
                    color: Colors.green,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatScreen(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("messages").orderBy("timestamp" , descending: false).snapshots(),
      builder: (context , snapshot) {
        if(!snapshot.hasData){
          return Center(child: Text("No Data Found"));
        }
        else{
          return _buildList(context, snapshot.data.documents);
        }
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final _userRec = Record.fromSnapshot(data);
    bool isMe = _userRec.from == currentUserId;
    bool isVisible = (_userRec.from == currentUserId && _userRec.to == chatUserId) || (_userRec.from == chatUserId && _userRec.to == currentUserId);
    return Visibility(
      visible: isVisible,
      child: Slidable(
        delegate: new SlidableDrawerDelegate(),
        actionExtentRatio: 0.25,
        secondaryActions: isMe ? <Widget>[
          new IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: (){
              _userRec.reference.delete();
            },
          ),
        ] : null,
        child: GestureDetector(
          onLongPress: (){
            ClipboardManager.copyToClipBoard(_userRec.msg).then((value){
              Fluttertoast.showToast(
                  msg: "Message Copied",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIos: 1
              );
            });
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            child: Bubble(
              message: _userRec.msg,
              delivered: true,
              isMe: !isMe,
              time: displayTime(_userRec.timestamp),
            ),
          ),
        ),
      )
    );
  }


  void sendMessage(String userId1 , String userId2){
    Firestore.instance.collection("messages").add({
      "from" : userId2,
      "to" : userId1,
      "msg" : messageController.text,
      "timestamp" : DateTime.now().microsecondsSinceEpoch.toString()
    }).then((value){
      messageController.clear();
      player.play(alarmAudioPath);
    });
  }

  String displayTime(String microsecondsSinceEpoch){
    String ampm = "am";
    int micro = int.parse(microsecondsSinceEpoch);
    var dateObj = DateTime.fromMicrosecondsSinceEpoch(micro);
    int hr = dateObj.hour;
    int min = dateObj.minute;
    if(hr > 12){
      hr = hr - 12;
      ampm = "pm";
    }
    else if(hr == 12){
      ampm = "pm";
    }
    else if(hr == 0){
      hr = 12;
      ampm = "am";
    }
    return "$hr:$min $ampm";
  }

  void flipCard(name , img){
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    showDialog(
        context: context,
        builder: (_) => FlipCard(
          direction: FlipDirection.HORIZONTAL,
          front: Container(
            width: width - 50,
            height: height / 2,
            padding: EdgeInsets.all(30.0),
            margin: EdgeInsets.all(10.0),
            child: Card(
              child: Image.network(img , fit: BoxFit.contain,),
            ),
          ),
          back: Container(
              padding: EdgeInsets.all(30.0),
              child: Card(
                margin: EdgeInsets.all(10.0),
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.display1.apply(color: Colors.green , fontWeightDelta: 100),
                  )
                ),
              )
          ),
        )
        );
  }
}

class Record {
  final String to , msg , from , timestamp;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['to'] != null),
        assert(map['msg'] != null),
        assert(map['from'] != null),
        assert(map['timestamp'] != null),
        to = map['to'],
        timestamp = map['timestamp'],
        from = map['from'],
        msg = map['msg'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$to:$msg:$from>";
}