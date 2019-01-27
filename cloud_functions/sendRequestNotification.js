'use strict';
const functions = require('firebase-functions');

const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

exports.sendRequest = functions.firestore
    .document('chatrequests/{userId}/requests/{chatId}')
    .onWrite((change, context) => {
        
        const fromuserName = change.after.data().name;
        const fromUid = change.after.data().from;
        const toUid = context.params.userId;
        const accepted = change.after.data().accept;

        console.log(fromuserName);
        console.log(toUid);
        console.log(fromUid);
        console.log(accepted);

        var tokenRef = admin.firestore().collection("tokens");    
        var toUserName = "";

        if(accepted){
            var userRef1 = admin.firestore()
            .collection("users").doc(toUid)
            .get()
            .then(
                (document) => {
                    const notifyName = document.data().name;
                    
                    return admin.firestore()
                    .collection("tokens")
                    .doc(fromUid)
                    .get()
                    .then(
                        (doc1) => {
                            const token = doc1.data().token;
                
                            userToken.concat(token);
                            
                            console.log("User token is : ",token);        
                            
                            var paylod = {
                                "notification" : {
                                    "title" : "Congratulations..!!!",
                                    "body" : notifyName + " accepted your friend request",
                                    "sound" : "default"
                                },
                                "data" : {
                                    "sendername" : toUid,
                                    "message" : "Message"
                                }
                            }
                            return admin.messaging().sendToDevice(token , paylod).then(
                                (value) => {
                                console.log("pushed");
                                return admin
                                .firestore()
                                .collection("notifications")
                                .add({
                                    title : "You have got a new Friend",
                                    subtitle : notifyName + " accepted your friend request",
                                    uid : fromUid
                                });
                            }).catch((err) => {
                                console.log(err);
                                console.log("Failed");
                            });
                        }
                    );
                }
            );  
        }

        else{
            var userRef2 = admin.firestore()
        .collection("tokens").doc(toUid)
        .get()
        .then(
            (document) => {
                const token = document.data().token;
                
                userToken.concat(token);
                
                console.log("User token is : ",token);        
                
                var paylod = {
                    "notification" : {
                        "title" : "A new Friend Request",
                        "body" : fromuserName + " sent you a request",
                        "sound" : "default"
                    },
                    "data" : {
                        "sendername" : fromuserName,
                        "message" : "Message"
                    }
                }
                
                return admin.messaging().sendToDevice(token , paylod).then(
                    (value) => {
                    console.log("pushed");
                    return admin
                    .firestore()
                    .collection("notifications")
                    .add({
                        title : "New Friend Request!",
                        subtitle : fromuserName + " sent you a request",
                        uid : toUid
                    });
                }).catch((err) => {
                    console.log(err);
                    console.log("Failed");
                });
            }
        );
        }
        
        var userToken = "";
        
    });
