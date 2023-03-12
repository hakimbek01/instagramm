
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:instagramclone/pages/signin_page.dart';
import 'package:instagramclone/services/auth_service.dart';
import 'package:instagramclone/services/prefs_service.dart';

import 'home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  void _initNotification() async {
    _firebaseMessaging.getToken().then((value) async {
      String fcmToken = value.toString();
      await Prefs.saveFCM(fcmToken);
      String token = await Prefs.loadFCM();
      print(token);
    });
  }

  @override
  void initState() {
    _initNotification();
    initPage();
    super.initState();
  }

  bool isLogged = false;
  void initPage() async {
    await Future.delayed(Duration(seconds: 2));
    isLogged = AuthService.isLoggedIn();
    if (isLogged) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(193, 53, 132, 1),
              Color.fromRGBO(131, 58, 180, 1),
            ]
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text("Instagram", style: TextStyle(color: Colors.white, fontSize: 45, fontFamily: "billabong"),),
              ),
            ),
            Text("All rights reserved", style: TextStyle(color: Colors.white, fontSize: 16),),
            SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }
}
