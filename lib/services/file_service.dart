
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagramclone/services/auth_service.dart';

class FileService {
  static final _storage = FirebaseStorage.instance.ref();
  static final folderMember = "memberImage";
  static final postImage = "postImage";

  static Future<String> uploadMemberImage(File image) async {
    String uid = AuthService.currentUserId();
    String imgName = uid;
    var firebaseStorageRef = _storage.child(folderMember).child(imgName);
    var uploadTask = firebaseStorageRef.putFile(image);
    String downloadUrl = await firebaseStorageRef.getDownloadURL();
    print(downloadUrl);
    return downloadUrl;
  }

  static Future<String> uploadPostImage(File image) async {
    String uid = AuthService.currentUserId();
    String imgName = uid + "_" + DateTime.now().toString();
    var firebaseStorageRef = _storage.child(postImage).child(imgName);
    var uploadTask = firebaseStorageRef.putFile(image);
    final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  static Future<void> removePostImage(imageUrl) async {
    await _storage.storage.refFromURL(imageUrl).delete();
  }


}