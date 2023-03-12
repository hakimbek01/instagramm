import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagramclone/services/prefs_service.dart';
import 'package:platform_device_id/platform_device_id.dart';

class Utils {
  static void fireToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static bool emailValidate(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  static bool passwordValidate(String password) {
    return RegExp(r'(?=.*?[0-9]).{8,}$').hasMatch(password);
  }

  static Future<bool> commonDialog(context, title, content, yes, no) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return Platform.isAndroid ?
        AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.pop(context, false);
              },
              child: Text(no, style: TextStyle(color: Colors.green, fontSize: 16),),
            ),
            TextButton(
              onPressed: (){
                Navigator.pop(context, true);
              },
              child: Text(yes, style: TextStyle(color: Colors.red, fontSize: 16),),
            )
          ],
        ) :
        CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.pop(context, false);
              },
              child: Text(no, style: TextStyle(color: Colors.green, fontSize: 16),),
            ),
            TextButton(
              onPressed: (){
                Navigator.pop(context, true);
              },
              child: Text(yes, style: TextStyle(color: Colors.red, fontSize: 16),),
            )
          ],
        );
      },
    );
  }

  static Future<Map<String, String>> deviceParams() async {
    Map<String, String> params = {};

    var getDeviceId = await PlatformDeviceId.getDeviceId;
    String fcmToken = await Prefs.loadFCM();

    if (Platform.isAndroid) {
      params.addAll({
        "device_id" : getDeviceId!,
        "device_type" : "A",
        "device_token" : fcmToken,
      });
    } else {
      params.addAll({
        "device_id" : getDeviceId!,
        "device_type" : "I",
        "device_token" : fcmToken,
      });
    }

    return params;

  }

  static String currentDate() {
    DateTime now = DateTime.now();

    String convertedDateTime = "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString()}:${now.minute.toString()}";
    return convertedDateTime;
  }

  static Future<void> showLocalNotification(Map<String, dynamic> message) async {
    String title = message["title"];
    String body = message["body"];

    var android = const AndroidNotificationDetails("channelId", "channelName", channelDescription: "channelDescription");
    var platform = NotificationDetails(android: android);

    int id = Random().nextInt(pow(2, 31).toInt() - 1);
    await FlutterLocalNotificationsPlugin().show(id, title, body, platform);
  }

}





