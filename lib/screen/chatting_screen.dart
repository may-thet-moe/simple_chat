import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_chat/api/api.dart';
import 'package:simple_chat/helper/util.dart';
import 'package:simple_chat/main.dart';
import 'package:simple_chat/model/chat_user.dart';
import 'package:simple_chat/model/message.dart';
import 'package:simple_chat/widgets/message_card.dart';

class ChattingScreen extends StatefulWidget {
  const ChattingScreen({super.key, required this.user});

  final ChatUser user;
  @override
  State<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  List<Message> _list = [];
  TextEditingController _textEditingController = TextEditingController();
  bool _showEmoji = false;
  bool _isImgUpload = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: PopScope(
          canPop: !_showEmoji,
          onPopInvokedWithResult: (didPop, result) {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            body: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, top: 10),
                    child: StreamBuilder(
                        stream: APIs.getAllMessage(widget.user),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                              return const Center(
                                child: CircularProgressIndicator(),
                              );

                            case ConnectionState.active:
                            case ConnectionState.done:
                              final doc = snapshot.data?.docs;
                              _list = doc
                                      ?.map((e) => Message.fromJson(e.data()))
                                      .toList() ??
                                  [];
                              if (_list.isNotEmpty) {
                                return ListView.builder(
                                    reverse: true,
                                    itemCount: _list.length,
                                    itemBuilder: (context, index) {
                                      return MessageCard(msg: _list[index]);
                                    });
                              } else {
                                return const Center(
                                  child: Text(
                                    'Say Hi! 👋',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                );
                              }
                          }
                        }),
                  ),
                ),
                if (_isImgUpload)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                _sentMsgCard(),
                if (_showEmoji)
                  EmojiPicker(
                    textEditingController: _textEditingController,
                    config: const Config(
                        height: 256,
                        bottomActionBarConfig:
                            BottomActionBarConfig(enabled: false)),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
        child: StreamBuilder(
            stream: APIs.getUserUpdateStatus(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
              return Row(
                children: [
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      )),
                  SizedBox(
                    width: mq.width * 0.01,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.width * 0.06),
                    child: CachedNetworkImage(
                      imageUrl: widget.user.img ?? "",
                      width: mq.width * 0.12,
                      height: mq.width * 0.12,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) {
                        return const CircleAvatar(child: Icon(Icons.person));
                      },
                    ),
                  ),
                  SizedBox(
                    width: mq.width * 0.02,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.name ?? "",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(
                        height: 1,
                      ),
                      Text(
                        list.isEmpty
                        ?  Util.getLastActiveTime(
                                lastActive: widget.user.lastActive ?? '',
                                context: context)
                        : list[0].isOnline ?? false
                            ? 'Online'
                            : Util.getLastActiveTime(
                                lastActive: list[0].lastActive?? '',
                                context: context),
                        style:
                            const TextStyle(fontSize: 13, color: Colors.white),
                      )
                    ],
                  )
                ],
              );
            }));
  }

  Widget _sentMsgCard() {
    final ScrollController _scrollController = ScrollController();
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
      child: Row(
        children: [
          Expanded(
            child: Card(
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          FocusScope.of(context).unfocus();
                          _showEmoji = !_showEmoji;
                        });
                      },
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.blue,
                      )),
                  Expanded(
                      child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    minLines: 1, //when text is empty show single line
                    scrollController: _scrollController,
                    controller: _textEditingController,
                    onTap: () {
                      if (_showEmoji) {
                        setState(() => _showEmoji = !_showEmoji);
                      }
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type something',
                      hintStyle: TextStyle(color: Colors.blue),
                    ),
                  )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);

                        for (var element in images) {
                          setState(() => _isImgUpload = true);
                          await APIs.sentImage(widget.user, File(element.path));
                          setState(() => _isImgUpload = false);
                        }
                      },
                      icon: const Icon(
                        Icons.image_rounded,
                        color: Colors.blue,
                      )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          setState(() => _isImgUpload = true);
                          await APIs.sentImage(widget.user, File(image.path));
                          setState(() => _isImgUpload = false);
                        }
                      },
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.blue,
                      ))
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 2,
          ),
          CircleAvatar(
            backgroundColor: Colors.lightGreen,
            child: Padding(
              padding: const EdgeInsets.only(left: 2),
              child: IconButton(
                  onPressed: () {
                    if (_textEditingController.text.isNotEmpty) {
                      APIs.sentMessage(
                          widget.user, _textEditingController.text, Type.text);
                      _textEditingController.clear();
                    }
                  },
                  icon: const Icon(
                    Icons.send,
                    color: Colors.white,
                  )),
            ),
          )
        ],
      ),
    );
  }
}
