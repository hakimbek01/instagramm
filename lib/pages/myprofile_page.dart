
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagramclone/models/member_model.dart';
import 'package:instagramclone/models/post_model.dart';
import 'package:instagramclone/pages/signin_page.dart';
import 'package:instagramclone/services/auth_service.dart';
import 'package:instagramclone/services/db_service.dart';
import 'package:instagramclone/services/file_service.dart';
import 'package:instagramclone/services/utils_service.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {

  List<Post> items = [];

  File? _image;
  final ImagePicker _picker = ImagePicker();
  String fullName = "";
  String email = "";
  String imgUrl = "";
  int countPosts = 0, countFollowers = 0, countFollowing = 0;
  bool isLoading = false;


  _imgFromGallery() async {
    XFile? image =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    print(image!.path.toString());
    setState(() {
      _image = File(image.path);
    });
    uploadMemberImage();
  }
  void doSignOut() {
    AuthService.signOutUser().then((value) => {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInPage())),
    });
  }

  void getMember() {
    setState(() {
      isLoading = true;
    });
    DataService.loadMember().then((member) => {
      setState((){
        fullName = member.fullName!;
        email = member.email!;
        imgUrl = member.img_url;
        countFollowers = member.followers_count;
        countFollowing = member.following_count;
        loadPosts();
      }),
    });
  }

  void uploadMemberImage() {
    if (_image == null) return;
    FileService.uploadMemberImage(_image!).then((value) => {
      print(value),
      updateMember(value),
    });
  }

  void updateMember(String downloadUrl) async {
    Member member = await DataService.loadMember();
    member.img_url = downloadUrl;
    await DataService.updateMember(member);
    getMember();
  }

  void loadPosts() async {
    List<Post> posts = await DataService.loadPosts();
    setState(() {
      items = posts;
      countPosts = items.length;
      isLoading = false;
    });
  }

  @override
  void initState() {
    getMember();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            title: Text("Profile", style: TextStyle(color: Colors.black, fontFamily: "billabong", fontSize: 28)),
            actions: [
              IconButton(
                onPressed: () async {
                  bool yes = await Utils.commonDialog(context, "Profildan chiqish", "Profilingizdan chiqmoqchimisiz?", "Ha", "Yo'q");
                  if (yes) {
                    doSignOut();
                  }
                },
                icon: Icon(Icons.output),
              )
            ],
          ),
          body: Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(70),
                        border: Border.all(
                          width: 1.5,
                          color: Color.fromRGBO(193, 53, 132, 1),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: (imgUrl.isNotEmpty) ?
                        Image.network(imgUrl, height: 70, width: 70, fit: BoxFit.cover,) :
                        Image(
                          height: 70,
                          width: 70,
                          image: AssetImage("assets/images/ic_userImage.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _imgFromGallery,
                      child: Container(
                        height: 80,
                        width: 80,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(Icons.add_circle, color: Colors.purple),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Text(fullName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                Text(email, style: TextStyle(color: Colors.black54),),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  height: 80,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(countPosts.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                            Text("POSTS", style: TextStyle(color: Colors.grey),),
                          ],
                        ),
                      ),
                      VerticalDivider(indent: 20, endIndent: 20, color: Colors.grey),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(countFollowers.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                            Text("FOLLOWERS", style: TextStyle(color: Colors.grey),),
                          ],
                        ),
                      ),
                      VerticalDivider(indent: 20, endIndent: 20, color: Colors.grey),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(countFollowing.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                            Text("FOLLOWING", style: TextStyle(color: Colors.grey),),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _itemOfPost(items[index]);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
        (isLoading) ?
        Scaffold(
          backgroundColor: Colors.grey.withOpacity(.3),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ) : SizedBox(),
      ],
    );
  }

  Widget _itemOfPost(Post post) {
    return Container(
      margin: EdgeInsets.all(5),
      child: Column(
        children: [
          Expanded(
            child: CachedNetworkImage(
              width: double.infinity,
              imageUrl: post.imgPost!,
              placeholder: (context, url) {
                return Center(child: CircularProgressIndicator(),);
              },
              errorWidget: (context, url, error) {
                return Icon(Icons.error);
              },
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 3,),
          Text(post.caption!)
        ],
      ),
    );
  }

}
