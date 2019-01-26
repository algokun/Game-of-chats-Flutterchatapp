'use strict';

const functions = require('firebase-functions');

const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

exports.sendPostNotification = functions.firestore
.document('newsfeed/{postId}')
.onCreate(
    (snapshot , context) => {
        const name = snapshot.data().name;
        const desc = snapshot.data().desc;
        const uid = snapshot.data().uid;
        var userID = new String(uid);
        console.log(name + desc);    

        var tokenRef = admin.firestore().collection('tokens').get().then(
            (snapshots) => {
                var tokens = [];
                
                if(snapshots.empty){
                    console.log("NO Devices");
                }
                
                else{
                    for(var token of snapshots.docs){                        
                            tokens.push(token.data().token);
                    }

                    var paylod = {
                        "notification" : {
                            "title" : name+" added a new Photo",
                            "body" : desc,
                            "sound" : "default"
                        },
                        "data" : {
                            "sendername" : name,
                            "message" : "Message"
                        }
                    }
                    
                    return admin.messaging().sendToDevice(tokens , paylod).then(
                        (value) => {
                        console.log("pushed");
                        return "Pushed";
                    }).catch((err) => {
                        console.log(err);
                        console.log("Failed");
                    });
                }

                return "Push Notify";
            }
        );
    }
)