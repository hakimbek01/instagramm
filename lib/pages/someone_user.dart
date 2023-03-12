import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/member_model.dart';
import '../models/post_model.dart';
import '../services/db_service.dart';

class SomeoneUser extends StatefulWidget {
  final Member? member;
  const SomeoneUser({Key? key, this.member}) : super(key: key);

  @override
  State<SomeoneUser> createState() => _SomeoneUserState();
}

class _SomeoneUserState extends State<SomeoneUser> {

  List<Post> items=[];
  int countPosts = 0, countFollowers = 0, countFollowing = 0;
  bool isLoading=false;
  void loadPosts() async {
    List<Post> posts = await DataService.loadSomeonePosts(widget.member!.uid);
    setState(() {
      items = posts;
      isLoading=false;
    });
  }

  void followMember(Member member) async {
    setState(() {
      member.followed = true;
    });
    await DataService.followMember(member);
  }

  void unFollowMember(Member member) async {
    setState(() {
      member.followed = false;
    });
    await DataService.unfollowMember(member);
  }


  void getMember() {
    setState(() {
      isLoading=true;
    });
    DataService.loadSomeone(widget.member!.uid).then((member) => {
      setState((){
        countFollowers = member.followers_count;
        countFollowing = member.following_count;
        print(countFollowers);
        loadPosts();
      }),
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
          appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(
                color: Colors.black
            ),
            title: Text("Result",style: TextStyle(fontFamily: "billabong",color: Colors.black,fontSize: 24),),
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
                        child: (widget.member!.img_url.isNotEmpty) ?
                        Image.network(widget.member!.img_url, height: 70, width: 70, fit: BoxFit.cover,) :
                        Image(
                          height: 70,
                          width: 70,
                          image: AssetImage("assets/images/ic_userImage.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Text(widget.member!.fullName.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
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
                widget.member!.followed?
                MaterialButton(
                  minWidth: double.infinity,
                  shape: RoundedRectangleBorder(side: BorderSide(color: Colors.blue,width: 1)),
                  onPressed: () {
                    unFollowMember(widget.member!);
                  },
                  child: Text("UnFollow",style: TextStyle(color: Colors.black),),
                ):
                MaterialButton(
                  color: Colors.blue,
                  minWidth: double.infinity,
                  onPressed: () {
                    followMember(widget.member!);
                  },
                  child: Text("Follow",style: TextStyle(color: Colors.white),),
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
        isLoading?
        Scaffold(
          backgroundColor: Colors.grey.withOpacity(.3),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ):
        SizedBox()
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
