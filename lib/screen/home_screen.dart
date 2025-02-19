import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:simple_chat/api/api.dart';
import 'package:simple_chat/main.dart';
import 'package:simple_chat/model/chat_user.dart';
import 'package:simple_chat/screen/authentication/login.dart';
import 'package:simple_chat/screen/profile_screen.dart';
import 'package:simple_chat/widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  List<ChatUser> _searchList = [];
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    //update status according to lifecycle events
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message : $message');
      //when user logout auth.currentUser is null
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) APIs.updateStatus(true);
        if (message.toString().contains('pause')) APIs.updateStatus(false);
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        canPop: !_searching,
        onPopInvokedWithResult: (didPop, result) {
          if (_searching) {
            _searching = !_searching;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: _searching
                ? TextFormField(
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: 'Search...'),
                    autofocus: true,
                    onChanged: (value) {
                      _searchList.clear();
                      for (var i in _list) {
                        if (i.name!
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            i.email!
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                          _searchList.add(i);
                        }
                      }

                      setState(() {});
                    },
                  )
                : const Text("Simple Chat"),
            leading: IconButton(onPressed: () {}, icon: const Icon(Icons.home)),
            actions: [
              _searching
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _searching = !_searching;
                          _searchList.clear();
                        });
                      },
                      icon: const Icon(Icons.clear))
                  : IconButton(
                      onPressed: () {
                        setState(() {
                          _searching = !_searching;
                        });
                      },
                      icon: const Icon(Icons.search)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(user: APIs.me)));
                  },
                  icon: const Icon(Icons.more_vert))
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await APIs.auth.signOut();
              await GoogleSignIn().signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            child: const Icon(Icons.logout),
          ),
          body: StreamBuilder(
              stream: APIs.getAllUsers(),
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
                    _list = data
                            ?.map((e) => ChatUser.fromJson(e.data()))
                            .toList() ??
                        [];
                    return ListView.builder(
                        itemCount:
                            _searching ? _searchList.length : _list.length,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(top: mq.width * 0.01),
                        itemBuilder: (context, index) {
                          return ChatUserCard(
                              chatUser: _searching
                                  ? _searchList[index]
                                  : _list[index]);
                        });
                }
              }),
        ),
      ),
    );
  }
}
