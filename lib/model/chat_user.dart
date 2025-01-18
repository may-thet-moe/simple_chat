// To parse this JSON data, do
//
//     final chatUser = chatUserFromJson(jsonString);

import 'dart:convert';

ChatUser chatUserFromJson(String str) => ChatUser.fromJson(json.decode(str));

String chatUserToJson(ChatUser data) => json.encode(data.toJson());

class ChatUser {
  String? img;
  String? about;
  String? name;
  bool? isOnline;
  String? id;
  String? lastActive;
  String? crateAt;
  String? pushToken;
  String? email;

  ChatUser({
    this.img,
    this.about,
    this.name,
    this.isOnline,
    this.id,
    this.lastActive,
    this.crateAt,
    this.pushToken,
    this.email,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
        img: json["img"],
        about: json["about"],
        name: json["name"],
        isOnline: json["is_online"],
        id: json["id"],
        lastActive: json["last_active"],
        crateAt: json["crate_at"],
        pushToken: json["push_token"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "img": img,
        "about": about,
        "name": name,
        "is_online": isOnline,
        "id": id,
        "last_active": lastActive,
        "crate_at": crateAt,
        "push_token": pushToken,
        "email": email,
      };
}
