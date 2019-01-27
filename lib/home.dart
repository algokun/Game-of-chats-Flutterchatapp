import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_app/posts/addpost.dart';
import 'package:flutter_chat_app/splash/after_splash.dart';
import 'package:flutter_chat_app/chats/chat_intro_screen.dart';
import 'package:flutter_chat_app/notifications.dart';
import 'package:flutter_chat_app/posts/posts.dart';
import 'package:flutter_chat_app/chats/chat_requests.dart';
import 'package:flutter_chat_app/auth/user_profile.dart';
import 'package:flutter_chat_app/auth/users.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class HomePage extends StatefulWidget {
  String displayName , photoUrl;
  HomePage({this.displayName , this.photoUrl});
  @override
  _HomePageState createState() => _HomePageState(displayName: displayName , photoUrl: photoUrl);
}

class _HomePageState extends State<HomePage> {
  _HomePageState({this.displayName , this.photoUrl});

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String displayName , photoUrl , uid;
  int currentIndex = 0;
  bool isPrivateUser = false;

  @override
  void initState(){
    uid = "";
    getDataFromFireStore();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> itemsList = [
      Posts(),
      Chats(currentUserId: uid,),
      Requests(uid : uid , currentUserPic: photoUrl, currentUserName: displayName,),
    ];

    List<Widget> floatingButtons = [
      FloatingActionButton(
        child: Icon(FontAwesomeIcons.feather),
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddPost(
            name: displayName,
            uid: uid,
            uImg: photoUrl,
          )));
        },
      ),
      FloatingActionButton(
        child: Icon(Icons.people),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => Users(
          currentUserId: uid,
          currentName: displayName,
          currentUserPic: photoUrl,
        ))),
      ),
      SizedBox(),
    ];

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(

        key: _scaffoldKey,

        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
              icon: Icon(Icons.menu , color: Colors.green,),
              onPressed: () => _scaffoldKey.currentState.openDrawer()
              ),
          title: Hero(
              tag: "tag_1",
              child: Text(
                "Game of Chats",
                style: TextStyle(fontFamily: "Appfont2" , color: Colors.green , fontWeight: FontWeight.bold),
              )
          ),
        ),

        drawer: Drawer(
          child: Material(
            color: Colors.green,
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: Text("My Profile Card" , style: TextStyle(color: Colors.white),),
                  leading: Icon(Icons.person , color: Colors.white,),
                  trailing: Icon(Icons.arrow_right , color: Colors.white),
                  onTap: () => showFlipCard(displayName , photoUrl),
                ),
                ListTile(
                  title: Text("Users" , style: TextStyle(color: Colors.white),),
                  leading: Icon(Icons.people , color: Colors.white,),
                  trailing: Icon(Icons.arrow_right , color: Colors.white),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => Users(
                    currentUserId: uid,
                    currentName: displayName,
                    currentUserPic: photoUrl,
                  ))),
                ),
                ListTile(
                  title: Text("Notifications" , style: TextStyle(color: Colors.white),),
                  leading: Icon(Icons.notifications , color: Colors.white,),
                  trailing: Icon(Icons.arrow_right , color: Colors.white),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Notifications(uid: uid,))),
                ),
                ListTile(
                  title: Text("Profile" , style: TextStyle(color: Colors.white),),
                  leading: Icon(Icons.settings , color: Colors.white,),
                  trailing: Icon(Icons.arrow_right , color: Colors.white),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => Settings(
                    uid: uid,
                    name: displayName,
                    image: photoUrl,
                  ))),
                ),
                Divider(color: Colors.white,),
                ListTile(
                  contentPadding: EdgeInsets.all(20.0),
                  title: Text("LOGOUT" , style: Theme.of(context).textTheme.title.apply(color: Colors.white),),
                  subtitle: Text("$displayName" , style: Theme.of(context).textTheme.subhead.apply(color: Colors.white),),
                  trailing: CircleAvatar(backgroundImage: NetworkImage("$photoUrl"),radius: 40.0, backgroundColor: Colors.white,),
                  isThreeLine: true,
                  onTap: () => logOut(context),
                ),
              ],
            ),
          ),
        ),


        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.featured_play_list) ,
              title: Text("News Feed"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message) ,
              title: Text("Chats"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.record_voice_over) ,
              title: Text("Requests"),
            ),
          ],
          onTap: (index) {
            setState(() {
              this.currentIndex  = index;
            });
          },
          currentIndex: currentIndex,
        ),

        floatingActionButton: floatingButtons[currentIndex],

        body: itemsList[currentIndex],
      ),
    );
  }

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text('Do you really want to exit the app?'),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: Text('No')),
                FlatButton(
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                    child: Text('Yes')),
              ],
            ));
  }

  void getDataFromFireStore() async{
    await FirebaseAuth.instance.currentUser().then((user){
      setState(() {
        this.uid = user.uid;
      });
      dataFromFireBase(user.uid);
      getTokens(uid);
    });
  }

  void dataFromFireBase(uid){
    Firestore.instance.collection("users").document(uid).get().then((doc){
      setState(() {
        this.displayName = doc.data['name'];
        this.photoUrl = doc.data['img'];
      });
    });
  }

  void logOut(BuildContext context){
    showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text('Do you really wanna log out?'),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: Text('No')),
                FlatButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut().then((user){
                        Navigator.of(context).push(PageTransition(type: PageTransitionType.rotate ,child: AfterSplash() , duration: Duration(seconds: 2)));
                      });
                    },
                    child: Text('Yes')),
              ],
            ));
  }

  void getTokens(uid){
    FirebaseMessaging _msg = FirebaseMessaging();

    print("Get Tokens");

    _msg.getToken().then((token){
      Firestore.instance.collection("tokens").document(uid).setData({
        "token" : token,
        "uid" : uid,
      });
    });

  }

  void showFlipCard(name , img){
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

