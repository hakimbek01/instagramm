
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagramclone/services/auth_service.dart';
import 'package:instagramclone/services/file_service.dart';
import 'package:instagramclone/services/http_service.dart';
import 'package:instagramclone/services/utils_service.dart';

import '../models/member_model.dart';
import '../models/post_model.dart';

class DataService {
  
  static final _firestore = FirebaseFirestore.instance;
  static String folderUser = "Users";
  static String folderPost = "posts";
  static String folderLike = "likes";
  static String folderFollowing = "following";
  static String folderFollowers = "followers";

  // save user
  static Future storeMember(Member member) async {
    member.uid = AuthService.currentUserId();

    Map<String, String> params = await Utils.deviceParams();

    member.device_id = params["device_id"]!;
    member.device_type = params["device_type"]!;
    member.device_token = params["device_token"]!;

    return _firestore.collection(folderUser).doc(member.uid).set(member.toJson());
  }

  static Future<Member> loadMember() async {
    String uid = AuthService.currentUserId();
    var value = await _firestore.collection(folderUser).doc(uid).get();
    Member member = Member.fromJson(value.data()!);

    var doc1 = await _firestore.collection(folderUser).doc(uid).collection(folderFollowers).get();
    var doc2 = await _firestore.collection(folderUser).doc(uid).collection(folderFollowing).get();

    member.followers_count = doc1.docs.length;
    member.following_count = doc2.docs.length;

    return member;
  }

  static Future<Member> loadSomeone(String uid) async {
    var value = await _firestore.collection(folderUser).doc(uid).get();
    Member member = Member.fromJson(value.data()!);

    var doc1 = await _firestore.collection(folderUser).doc(uid).collection(folderFollowers).get();
    var doc2 = await _firestore.collection(folderUser).doc(uid).collection(folderFollowing).get();

    member.followers_count = doc1.docs.length;
    member.following_count = doc2.docs.length;

    return member;
  }

  static Future updateMember(Member member) async {
    String uid = AuthService.currentUserId();
    return _firestore.collection(folderUser).doc(uid).update(member.toJson());
  }

  static Future<List<Member>> searchMembers(List keywords) async {
    print(keywords);
    List<Member> members = [];
    String uid = AuthService.currentUserId();

    List followings = [];
    var doc = await _firestore.collection(folderUser).doc(uid).collection(folderFollowing).get();
    for (var item in doc.docs) {
      followings.add(item.id);
    }

    for (var item in keywords) {
      var querySnapshot = await _firestore.collection(folderUser).where("email", isEqualTo: item).get();

      querySnapshot.docs.forEach((element) {
        Member newMember = Member.fromJson(element.data());
        if (newMember.uid != uid) {
          print(newMember.fullName);
          newMember.followed = followings.contains(newMember.uid);
          members.add(newMember);
        }
      });
    }

    return members;
  }

  static Future<List<Member>> loadAllMembers() async {

    List<Member> members = [];
    String uid = AuthService.currentUserId();


    var docs = await _firestore.collection(folderUser).get();
    for (var doc in docs.docs) {
      Member member = Member.fromJson(doc.data());
      if (member.uid != uid) {
        members.add(member);
      }
    }

    return members;

  }

  static Future<Post> storePost(Post post) async {
    String uid = AuthService.currentUserId();
    post.uid = uid;
    post.date = Utils.currentDate();

    String postId = _firestore.collection(folderUser).doc(uid).collection(folderPost).doc().id;
    post.id = postId;
    await _firestore.collection(folderUser).doc(uid).collection(folderPost).doc(postId).set(post.toJson());
    return post;
  }

  static Future<List<Post>> loadPosts() async {
    List<Post> posts = [];
    String uid = AuthService.currentUserId();
    var likedPostsData = [];
    var likedPosts = [];

    likedPostsData = await DataService.loadLikedPostsData();
    for (var item in likedPostsData) {
      likedPosts.addAll(item["posts"]);
    }

    var docs = await _firestore.collection(folderUser).doc(uid).collection(folderPost).get();
    for (var item in docs.docs) {
      Post post = Post.fromJson(item.data());
      post.mine = true;
      var doc = await _firestore.collection(folderUser).doc(uid).get();
      post.fullName = doc.data()!["fullName"];
      post.imgUser = doc.data()!["img_url"];

      if (likedPosts.contains(post.id)) {
        post.isLiked = true;
      } else {
        post.isLiked  = false;
      }

      posts.add(post);
    }
    return posts;
  }

  static Future<List<Post>> loadSomeonePosts(String uid) async {
    List<Post> posts = [];
    var likedPostsData = [];
    var likedPosts = [];

    likedPostsData = await DataService.loadLikedPostsData();
    for (var item in likedPostsData) {
      likedPosts.addAll(item["posts"]);
    }

    var docs = await _firestore.collection(folderUser).doc(uid).collection(folderPost).get();
    for (var item in docs.docs) {
      Post post = Post.fromJson(item.data());
      post.mine = true;
      var doc = await _firestore.collection(folderUser).doc(uid).get();
      post.fullName = doc.data()!["fullName"];
      post.imgUser = doc.data()!["img_url"];

      if (likedPosts.contains(post.id)) {
        post.isLiked = true;
      } else {
        post.isLiked  = false;
      }

      posts.add(post);
    }
    return posts;
  }

  static Future likePost(Post post, bool isLiked) async {
    String myUid = AuthService.currentUserId();
    String uid = post.uid!;
    String postId = post.id!;
    List<Map<String, dynamic>> likedPostsData = await loadLikedPostsData();
    List posts = [];

    if (likedPostsData.isNotEmpty) {
      Map<String, dynamic> userAndPosts = likedPostsData.firstWhere((e) => e['uid'] == uid, orElse: () => {});
      if (userAndPosts.isNotEmpty) posts = userAndPosts["posts"];
    }

    if (isLiked) {
      posts.add(postId);
    } else {
      posts.remove(postId);
    }
    await _firestore.collection(folderUser).doc(myUid).collection(folderLike).doc(uid).set({
      "uid" : uid,
      "posts" : posts,
    });

  }

  static Future<List<Map<String, dynamic>>> loadLikedPostsData() async {
    String uid = AuthService.currentUserId();
    List<Map<String, dynamic>> postsData = [];
    var docs = await _firestore.collection(folderUser).doc(uid).collection(folderLike).get();
    for (var item in docs.docs) {
      postsData.add({
        "uid" : item["uid"],
        "posts" : item["posts"],
      });
    }
    return postsData;
  }

  static Future<List<Post>> loadLikes() async {
    List<Map<String, dynamic>> postsData = await loadLikedPostsData();
    String uid = AuthService.currentUserId();
    List<Post> posts = [];
    for (var item in postsData) {
      for (var postsId in item["posts"]) {
        var doc = await _firestore.collection(folderUser).doc(item["uid"]).collection(folderPost).doc(postsId).get();
        if (doc.exists) {
          Post post = Post.fromJson(doc.data()!);
          var userDoc = await _firestore.collection(folderUser).doc(post.uid).get();
          post.fullName = userDoc.data()!["fullName"];
          post.imgUser = userDoc.data()!["img_url"];
          posts.add(post);
        }
      }
    }
    return posts;
  }

  static Future<void> followMember(Member someone) async {
    String uid = AuthService.currentUserId();
    Member me = await loadMember();

    await _firestore.collection(folderUser).doc(uid).collection(folderFollowing).doc(someone.uid).set({}).then((value) => {
      Network.sendNotification(me.fullName!, someone),
    });

    await _firestore.collection(folderUser).doc(someone.uid).collection(folderFollowers).doc(uid).set({});
  }

  static Future<void> unfollowMember(Member member) async {
    String uid = AuthService.currentUserId();
    await _firestore.collection(folderUser).doc(uid).collection(folderFollowing).doc(member.uid).delete();
    await _firestore.collection(folderUser).doc(member.uid).collection(folderFollowers).doc(uid).delete();
  }

  static Future<List<Post>> loadFeeds() async {
    List<Post> posts = [];
    String uid = AuthService.currentUserId();

    var doc = await _firestore.collection(folderUser).doc(uid).collection(folderFollowing).get();
    List<Map<String, dynamic>> likedPosts = await loadLikedPostsData();
    Map<String, dynamic> userAndPost = {};
    List postsId = [];

    for (var someone in doc.docs) {
      var postsDoc = await _firestore.collection(folderUser).doc(someone.id).collection(folderPost).get();

      userAndPost = likedPosts.firstWhere((element) => element["uid"] == someone.id, orElse: () => {});
      if (userAndPost.isNotEmpty) postsId = userAndPost["posts"];

      for (var item in postsDoc.docs) {
        Post post = Post.fromJson(item.data());
        if (someone.id == uid) post.mine = true;
        var doc = await _firestore.collection(folderUser).doc(someone.id).get();
        post.fullName = doc.data()!["fullName"];
        post.imgUser = doc.data()!["img_url"];
        post.isLiked = postsId.contains(post.id);
        posts.add(post);
      }
    }
    return posts;
  }

  static Future<void> removePost(Post post) async {
    String uid = AuthService.currentUserId();
    await FileService.removePostImage(post.imgPost);
    await _firestore.collection(folderUser).doc(uid).collection(folderPost).doc(post.id).delete();
  }

}
