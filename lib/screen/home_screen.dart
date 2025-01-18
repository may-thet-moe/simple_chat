
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:simple_chat/api/api.dart';
import 'package:simple_chat/main.dart';
import 'package:simple_chat/model/chat_user.dart';
import 'package:simple_chat/screen/profile_screen.dart';
import 'package:simple_chat/widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Simple Chat"),
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.home)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(user: list[0])));
          }, icon: const Icon(Icons.more_vert))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await APIs.auth.signOut();
          await GoogleSignIn().signOut();
        },
        child: const Icon(Icons.add_comment_rounded),
      ),
      body: StreamBuilder(
          stream: APIs.firestore.collection('users').snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.none:
                return const Center(
                  child: CircularProgressIndicator(),
                );

              case ConnectionState.active:
              case ConnectionState.done:
                final data = snapshot.data?.docs;
                list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                    [];
                return ListView.builder(
                    itemCount: list.length,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(top: mq.width * 0.01),
                    itemBuilder: (context, index) {
                      return ChatUserCard(chatUser: list[index]);
                    });
            }
          }),
    );
  }
}
