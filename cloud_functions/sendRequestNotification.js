'use strict';
const functions = require('firebase-functions');

const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

exports.sendRequestNotification = functions.firestore
    .document('chatrequests/{userId}/requests/{chatId}')
    .onWrite((change, context) => {
        const fromuserName = change.after.data().name;
        const toUid = context.params.userId;
        
        console.log(fromuserName);
        
        console.log(toUid);
        
        var userToken = "";

        var userRef = admin.firestore()
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
                    return "Hello";
                }).catch((err) => {
                    console.log(err);
                    console.log("Failed");
                });
            }
        );
        
        console.log("User token is : ",userToken);
        
    });
