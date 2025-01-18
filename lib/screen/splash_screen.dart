import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_chat/api/api.dart';
import 'package:simple_chat/main.dart';
import 'package:simple_chat/screen/authentication/login.dart';
import 'package:simple_chat/screen/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isAnimate = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
      if (APIs.auth.currentUser != null) {
        log("currentUser : ${APIs.auth.currentUser}");
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Welcome to We Chat"),
      ),
      body: Stack(
        children: [
          Positioned(
              top: mq.height * 0.15,
              right: mq.width * 0.25,
              width: mq.width * 0.5,
              child: Image.asset("images/chat.png")),
          Positioned(
              bottom: mq.height * 0.15,
              width: mq.width,
              child: const Text(
                "Develop With Love 🥰",
                textAlign: TextAlign.center,
                style: TextStyle(letterSpacing: 5, fontSize: 16),
              ))
        ],
      ),
    );
  }
}
