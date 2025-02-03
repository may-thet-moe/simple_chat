import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat/api/api.dart';
import 'package:simple_chat/helper/util.dart';
import 'package:simple_chat/main.dart';
import 'package:simple_chat/model/chat_user.dart';
import 'package:simple_chat/model/message.dart';
import 'package:simple_chat/screen/chatting_screen.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key, required this.chatUser});

  final ChatUser chatUser;

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _lastMsg;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0.5,
      child: InkWell(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ChattingScreen(
                        user: widget.chatUser,
                      ))),
          child: StreamBuilder(
              stream: APIs.getLastMessage(widget.chatUser),
              builder: (context, snapshot) {
                final doc = snapshot.data?.docs;
                final list =
                    doc?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                if (list.isNotEmpty) _lastMsg = list[0];
                return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * 0.03),
                      child: CachedNetworkImage(
                          imageUrl: widget.chatUser.img.toString(),
                          width: mq.height * 0.055,
                          height: mq.height * 0.055,
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                                child: Icon(Icons.person),
                              )),
                    ),
                    title: Text(widget.chatUser.name.toString()),
                    subtitle: Text(
                      _lastMsg != null
                          ? _lastMsg!.type == Type.image
                              ? 'image'
                              : _lastMsg!.msg ?? ''
                          : widget.chatUser.about.toString(),
                      maxLines: 1,
                    ),
                    trailing: _lastMsg == null
                        ? null
                        : _lastMsg!.read!.isEmpty &&
                                _lastMsg!.fromId != APIs.currentUser.uid
                            ? Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                    color: Colors.greenAccent.shade400,
                                    borderRadius: BorderRadius.circular(10)),
                              )
                            : Text(
                                Util.getMessageTime(
                                    time: _lastMsg!.sent ?? '',
                                    context: context),
                                style: const TextStyle(color: Colors.black54),
                              ));
              })),
    );
  }
}
