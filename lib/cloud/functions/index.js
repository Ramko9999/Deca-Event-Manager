//cloud function that will triggered when some one creates a new notification. Still under progress

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

var tokens
var message;



exports.triggerPush = functions.firestore.document("Notifications/{NotificationId}"
).onCreate((snapshot, context)=>{
    
    message = snapshot.data();
    
    admin.firestore().collection('Users').get().then((snapshots)=>{
        tokens = [];
        if(message.hasOwnProperty("filter")){
            console.log("Filter is not null");
            for(var user of snapshots.docs){
                console.log(user.data().groups);
                if(user.data()['groups'].includes(message.filter) && user.data().hasOwnProperty('device-token')){

                    tokens.push(user.data()['device-token']);
                }
            }
        }
        else{
            for(user of snapshots.docs){
                if( user.data().hasOwnProperty("device-token")){
                    var token = user.data()['device-token'];
                    tokens.push(token);
                }
                
            }
        }
        console.log(message);
        var data = {
            'header' : message['header'],
            'body' : message['body'],
        }

        if(message.hasOwnProperty('date')){
            data.date = message.date;
        }

        var paylod = {
            'notification':{
                'title': message['header'],
                'body': message['body'],
                'sound': 'default',
            },
            'data': data
        }

        admin.messaging().sendToDevice(tokens, paylod);
        return "Sent";

    }).catch((error) => {
        console.log(error);   
})});
