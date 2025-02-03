// To parse this JSON data, do
//
//     final message = messageFromJson(jsonString);

import 'dart:convert';

Message messageFromJson(String str) => Message.fromJson(json.decode(str));

String messageToJson(Message data) => json.encode(data.toJson());

class Message {
    String? toId;
    String? msg;
    String? read;
    Type? type;
    String? fromId;
    String? sent;

    Message({
        this.toId,
        this.msg,
        this.read,
        this.type,
        this.fromId,
        this.sent,
    });

    factory Message.fromJson(Map<String, dynamic> json) => Message(
        toId: json["toId"].toString(),
        msg: json["msg"].toString(),
        read: json["read"].toString(),
        type: json["type"].toString() == Type.text.name ? Type.text : Type.image,
        fromId: json["fromId"].toString(),
        sent: json["sent"].toString(),
    );

    Map<String, dynamic> toJson() => {
        "toId": toId,
        "msg": msg,
        "read": read,
        "type": type?.name ?? Type.text,
        "fromId": fromId,
        "sent": sent,
    };
}

enum Type {text, image}
