import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat/main.dart';
import 'package:simple_chat/model/chat_user.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key, required this.chatUser});

  final ChatUser chatUser;

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0.5,
      child: InkWell(
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * 0.03),
            child: CachedNetworkImage(
              imageUrl: widget.chatUser.img.toString(), 
              width: mq.height * 0.055, 
              height: mq.height * 0.055, 
              errorWidget: (context, url, error) => 
              const CircleAvatar(child: Icon(Icons.person),)),
          ),
          title: Text(widget.chatUser.name.toString()),
          subtitle: Text(
            widget.chatUser.about.toString(),
            maxLines: 1,
          ),
          trailing: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: Colors.greenAccent.shade400,
              borderRadius: BorderRadius.circular(10)
            ),
          )
        ),
      ),
    );
  }
}
