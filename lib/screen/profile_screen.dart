import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:simple_chat/api/api.dart';
import 'package:simple_chat/helper/dialogs.dart';
import 'package:simple_chat/main.dart';
import 'package:simple_chat/model/chat_user.dart';
import 'package:simple_chat/screen/authentication/login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});

  final ChatUser user;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Screen"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: ()async{
          Dialogs.showProgressBar(context);
          await APIs.auth.signOut().then((value) async{
            await GoogleSignIn().signOut().then((value){
              //popup for dialog
              Navigator.pop(context);
              //navigate to home
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            });
          });
          
        }, 
        label: const Text('Logout', style: TextStyle(color: Colors.white),),
        icon: const Icon(Icons.logout, color: Colors.white,),
        backgroundColor: Colors.redAccent,),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: mq.width * 0.1),
        child: Column(
          children: [
            SizedBox(height: mq.height * 0.05,),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.width * 0.3),
                  child: CachedNetworkImage(
                    imageUrl: widget.user.img.toString(),
                    width: mq.width * 0.5,
                    height: mq.width * 0.5,
                    fit: BoxFit.fill,
                    errorWidget: (context, url, error) => const CircleAvatar(child: Icon(Icons.person),),),
                  
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: MaterialButton(
                    onPressed: (){},
                    color: Colors.white,
                    elevation: 1,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.edit, color: Colors.blue,),),
                )
              ],
            ),
            SizedBox(height: mq.height * 0.03,),
            Text(
              widget.user.email.toString(), 
              textAlign: TextAlign.center,
              maxLines: 1,
              style: const TextStyle(fontSize: 20),),
            SizedBox(height: mq.height * 0.05,),
            TextFormField(
              initialValue: widget.user.name,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person, color: Colors.blue,),
                label: const Text("Name"),
                hintText: 'eg. Mg Mg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)
                )
              ),
            ),

            SizedBox(height: mq.height * 0.03,),

            TextFormField(
              initialValue: widget.user.about,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.info_outline, color: Colors.blue,),
                label: const Text("About"),
                hintText: 'eg. Feel free',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)
                )
              ),
            ),
            SizedBox(height: mq.height * 0.03,),

            ElevatedButton.icon(
              onPressed: (){}, 
              label: const Text('UPDATE', style: TextStyle(fontSize: 16),),
              icon: const Icon(Icons.edit, size: 38, color: Colors.white,),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                minimumSize: Size(mq.width * 0.5, mq.height * 0.06)
              ),)
          ],
        ),
      ),
    );
  }
}