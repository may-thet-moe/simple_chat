import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:simple_chat/api/api.dart';
import 'package:simple_chat/helper/dialogs.dart';
import 'package:simple_chat/main.dart';
import 'package:simple_chat/screen/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isAnimate = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        isAnimate = true;
      });
    });
  }

  _handleGoogleSignBtnClick() {
    Dialogs.showProgressBar(context);

    _signInWithGoogle().then((user) async{
      if (mounted) {
        Navigator.pop(context);
      }

      if (user != null) {
        // log('\nuser info : ${user.user}');
        // log('\nadditional user info : ${user.additionalUserInfo}');

        if(await APIs.userExists()){
          Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        }else{
          await APIs.createUser().then((valeu){
            Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup("google.com");
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log("\n_signInWithGoogle : $e");
      Dialogs.showSnackBar(context, "Something wrong (Check Internet!)");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Welcome to We Chat"),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              top: mq.height * 0.15,
              right: isAnimate ? mq.width * 0.25 : -mq.width * 0.5,
              width: mq.width * 0.5,
              duration: const Duration(seconds: 1),
              child: Image.asset("images/chat.png")),
          Positioned(
              bottom: mq.height * 0.15,
              left: mq.width * 0.05,
              width: mq.width * 0.9,
              height: mq.height * 0.06,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(121, 156, 231, 124),
                      shape: const StadiumBorder(),
                      elevation: 1),
                  onPressed: () {
                    _handleGoogleSignBtnClick();
                  },
                  icon: Image.asset(
                    "images/google.png",
                    height: mq.height * 0.03,
                  ),
                  label: RichText(
                      text: const TextSpan(
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          children: [
                        TextSpan(text: "Login in With "),
                        TextSpan(
                            text: "Google",
                            style: TextStyle(fontWeight: FontWeight.bold))
                      ]))))
        ],
      ),
    );
  }
}
