
class Post {

  String? uid;
  String? id;
  String? fullName;
  String? imgUser;
  String? imgPost;
  String? caption;
  String? date;
  bool isLiked = false;

  bool mine = false;

  Post({
    this.imgPost,
    this.caption,
  });

  Post.fromJson(Map<String, dynamic> json) {
        uid = json["uid"];
        id = json["id"];
        imgPost = json["imgPost"];
        caption = json["caption"];
        date = json["date"];
        // isLiked = json["likes"];
      }

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "id": id,
    "imgPost": imgPost,
    "caption": caption,
    "date": date,
    // "likes": isLiked,
  };
}
