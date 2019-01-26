'use strict';
const functions = require('firebase-functions');

const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

exports.sendMessageNotification = functions.firestore
.document('messages/{docId}')
.onCreate(
    (snapshot , context) => {
        const from = snapshot.data().from;
        const to = snapshot.data().to;
        const msg = snapshot.data().msg;

        console.log(from + to + msg);

        var userRef = admin.firestore()
        .collection("users")
        .doc(from)
        .get()
        .then(
            (userDoc) =>{
                const userName = userDoc.data().name;
                
                return admin.firestore()
                .collection("tokens")
                .doc(to)
                .get()
                .then(
                    (tokenDoc) => {
                        const token = tokenDoc.data().token;

                        var paylod = {
                            "notification" : {
                                "title" : "You have got a new Message from "+userName,
                                "body" : msg,
                                "sound" : "default"
                            },
                            "data" : {
                                "sendername" : from,
                                "message" : "Message"
                            }
                        }

                        return admin.messaging().sendToDevice(token , paylod).then(
                            (value) => {
                            console.log("pushed");
                            return "Pushed";
                        }).catch((err) => {
                            console.log(err);
                            console.log("Failed");
                        });

                    }
                );
            }
        );
    }
)