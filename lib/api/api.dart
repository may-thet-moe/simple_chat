import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_chat/model/chat_user.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //get current user
  static User get currentUser => auth.currentUser!;

  //check user exist or not
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(currentUser.uid).get())
        .exists;
  }

  //create new chatUser
  static Future<void> createUser() async{
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
      img: currentUser.photoURL,
      about: "looking good",
      name: currentUser.displayName,
      email: currentUser.email,
      isOnline: false,
      crateAt: time,
      lastActive: time,
      pushToken: ""
    );
    return(await firestore.collection('users').doc(currentUser.uid).set(chatUser.toJson()));
  }
}
