import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
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
  final _formKey = GlobalKey<FormState>();
  String? _profile;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile Screen"),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: ()async{
            Dialogs.showProgressBar(context);
            await APIs.updateStatus(false);
            await APIs.auth.signOut().then((value) async{
              await GoogleSignIn().signOut().then((value){
                //popup for dialog
                Navigator.pop(context);
                //navigate to home
                Navigator.pop(context);
                APIs.auth = FirebaseAuth.instance;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              });
            });
            
          }, 
          label: const Text('Logout', style: TextStyle(color: Colors.white),),
          icon: const Icon(Icons.logout, color: Colors.white,),
          backgroundColor: Colors.redAccent,),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.1),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: mq.height * 0.05,),
                  Stack(
                    children: [
                      _profile != null 
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(mq.width * 0.25),
                        child: Image.file(
                          File(_profile!),
                          width: mq.width * 0.5,
                          height: mq.width * 0.5,
                          fit: BoxFit.cover,)
                      )
                      : ClipRRect(
                        borderRadius: BorderRadius.circular(mq.width * 0.25),
                        child: CachedNetworkImage(
                          imageUrl: widget.user.img.toString(),
                          width: mq.width * 0.5,
                          height: mq.width * 0.5,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const CircleAvatar(child: Icon(Icons.person),),), 
                      ),
                            
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          onPressed: (){  
                            _showBottomSheet();
                          },
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
                    onSaved: (newValue) => APIs.me.name = newValue,
                    validator: (value) => value != null && value.isNotEmpty ? null : "Required Field",
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
                    onSaved: (newValue) => APIs.me.about = newValue,
                    validator: (value) => value != null && value.isNotEmpty ? null : "Required Field",
                  ),
                  SizedBox(height: mq.height * 0.03,),
                        
                  ElevatedButton.icon(
                    onPressed: (){
                      if(_formKey.currentState!.validate()){
                        _formKey.currentState!.save();
                        APIs.updateUser().then((value){
                          FocusScope.of(context).unfocus();
                          Dialogs.showSnackBar(context, "Profile update Success");
                        });
                      }
                    }, 
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
          ),
        ),
      ),
    );
  }
  _showBottomSheet(){
    showModalBottomSheet(
      context: context, 
      builder: (context) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          const Text("Take Profile Picture", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
          SizedBox(height: mq.height * 0.03,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  fixedSize: Size(mq.width * 0.25, mq.width * 0.25)
                ),
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  // Pick an image.
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 30);

                  if(image != null){
                    log('Image path : ${image.path}');
                    setState(() {
                      _profile = image.path;
                    });

                    APIs.updateProfilePicture(File(_profile!));
                  }
                  Navigator.pop(context);
                }, 
                child: Image.asset("images/gallery.png")),

                ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  fixedSize: Size(mq.width * 0.25, mq.width * 0.25)
                ),
                onPressed: () async{
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 30);

                  if(image != null){
                    log('Image path : ${image.path}');
                    setState(() {
                      _profile = image.path;
                    });

                    APIs.updateProfilePicture(File(_profile!));
                  }

                  Navigator.pop(context);
                }, 
                child: Image.asset("images/camera.png"))
            ],
          ),

          SizedBox(height: mq.height * 0.05,)
        ],
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))));
      
  }
}