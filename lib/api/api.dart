import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:simple_chat/model/chat_user.dart';
import 'package:simple_chat/model/message.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;

  //get current user from login
  static User get currentUser => auth.currentUser!;

  //get self info from firebase store
  static late ChatUser me;

  //check user exist or not
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(currentUser.uid).get())
        .exists;
  }

  //create new chatUser
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        id: currentUser.uid,
        img: currentUser.photoURL,
        about: "looking good",
        name: currentUser.displayName,
        email: currentUser.email,
        isOnline: false,
        crateAt: time,
        lastActive: time,
        pushToken: "");
    return (await firestore
        .collection('users')
        .doc(currentUser.uid)
        .set(chatUser.toJson()));
  }

  //get all user from firebase
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: currentUser.uid)
        .snapshots();
  }

  static Future<void> getSelfInfo() async {
    await firestore
        .collection('users')
        .doc(currentUser.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMsgToken();
        updateStatus(true);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserUpdateStatus(
      ChatUser user) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: user.id)
        .snapshots();
  }

  static Future<void> updateUser() async {
    await firestore
        .collection('users')
        .doc(currentUser.uid)
        .update({"name": me.name, "about": me.about});
  }

  static Future<void> updateProfilePicture(File file) async {
    //get file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child('profile_pictures/${currentUser.uid}.$ext');

    //upload img
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred : ${p0.bytesTransferred / 1000} kb');
    });

    //update image in firebase database
    me.img = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(currentUser.uid)
        .update({'image': me.img});
  }

  //used for getting conversation Id
  static String getConversationId(String toUserId) =>
      currentUser.uid.hashCode <= toUserId.hashCode
          ? '${currentUser.uid}_$toUserId'
          : '${toUserId}_${currentUser.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id ?? "")}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sentMessage(
      ChatUser chatUser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Message message = Message(
        toId: chatUser.id,
        fromId: currentUser.uid,
        read: '',
        sent: time,
        msg: msg,
        type: type);

    final ref = firestore
        .collection('chats/${getConversationId(chatUser.id ?? '')}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) {
      // pushNotification(chatUser, type == Type.text ? msg : 'image');
    });
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    await firestore
        .collection(
            'chats/${getConversationId(message.fromId ?? '')}/messages/')
        .doc(message.sent)
        .update({'read': time});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id ?? '')}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sentImage(ChatUser chatUser, File file) async {
    //get file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationId(chatUser.id ?? '')}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //upload img
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred : ${p0.bytesTransferred / 1000} kb');
    });

    //update image in firebase database
    final imageUrl = await ref.getDownloadURL();

    await sentMessage(chatUser, imageUrl, Type.image);
  }

  static Future<void> updateStatus(bool isOnline) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    await firestore.collection('users').doc(currentUser.uid).update({
      'is_online': isOnline,
      'last_active': time,
      'push_token': me.pushToken
    });
  }

  static FirebaseMessaging firebaseMsg = FirebaseMessaging.instance;

  static Future<void> getFirebaseMsgToken() async {
    await firebaseMsg.requestPermission();
    await firebaseMsg.getToken().then((token) {
      if (token != null) {
        me.pushToken = token;
        log('\n firebaseMessaginToken : $token');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  static Future<void> pushNotification(ChatUser chatUser, String msg) async {
    try {
      final body = {
        "registration_ids": [chatUser.pushToken],
        "data": {
          "title": chatUser.name,
          "body": msg,
          "android_channel_id": "chats",
          "data": {"userID": "${me.id}"}
        }
      };

      var res =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader: 'key=serverKeyRequired'
              },
              body: jsonEncode(body));
      log('response status: ${res.statusCode} \n ${res.body}');
    } catch (e) {
      log('\n notification error: $e');
    }
  }

  static Future<void> deleteMessage(Message msg) async {
    await firestore
        .collection('chats/${getConversationId(msg.toId ?? "")}/messages')
        .doc(msg.sent)
        .delete();
    if (msg.type == Type.image) {
      await storage.refFromURL(msg.msg ?? "").delete();
    }
  }
}
