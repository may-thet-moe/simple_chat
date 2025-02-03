import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat/api/api.dart';
import 'package:simple_chat/helper/util.dart';
import 'package:simple_chat/main.dart';
import 'package:simple_chat/model/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.msg});

  final Message msg;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return widget.msg.fromId != APIs.currentUser.uid
    ? _blueMessage()
    : _greenMsg();
  }

  Widget _blueMessage(){

    if(widget.msg.read!.isEmpty){
      APIs.updateMessageReadStatus(widget.msg);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //use flexible widget for multiline text
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.msg.type == Type.image ? mq.width * 0.03 : mq.width * 0.04),
            margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 144, 210, 241),
              border: Border.all(color: Colors.lightBlue),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: 
            widget.msg.type == Type.image
            ?ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: widget.msg.msg ?? '',
                placeholder: (context, url) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2,),
                ),
                errorWidget: (context, url, error) => const CircleAvatar(child: Icon(Icons.image),),
                ),
            )
            :Text(widget.msg.msg ?? "msg", style: const TextStyle(fontSize: 15),),
        
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(Util.getMessageTime(time: widget.msg.sent ?? '', context: context), style: const TextStyle(fontSize: 13),),
        )
      ],
    );
  }

  Widget _greenMsg(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
         Row(
           children: [
              const SizedBox(width: 10,),
              if(widget.msg.read!.isNotEmpty)
                const Icon(Icons.done_all, color: Colors.blue,),
              const SizedBox(width: 2,),
              Text(Util.getMessageTime(time: widget.msg.sent ?? '', context: context), style: const TextStyle(fontSize: 13),),
           ],
         ),
        //use Flexible for multiline message
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.msg.type == Type.image ? mq.width * 0.03 : mq.width * 0.04),
            margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 188, 241, 144),
              border: Border.all(color: Colors.lightGreen),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30), bottomLeft: Radius.circular(30)),
            ),
            child: 
            widget.msg.type == Type.image
            ?ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: widget.msg.msg ?? '',
                placeholder: (context, url) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2,),
                ),
                errorWidget: (context, url, error) => const CircleAvatar(child: Icon(Icons.image),),
                ),
            )
            :Text(widget.msg.msg ?? "msg", style: const TextStyle(fontSize: 15),),
          ),
        ),
       
      ],
    );
  }
}