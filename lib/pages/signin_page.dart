
import 'package:flutter/material.dart';
import 'package:instagramclone/pages/signup_page.dart';
import 'package:instagramclone/services/auth_service.dart';

import '../services/utils_service.dart';
import 'home_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  void doSignIn() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    if (!Utils.emailValidate(email)) {
      Utils.fireToast("Invalid email address");
      return;
    }

    if (!Utils.passwordValidate(password)) {
      Utils.fireToast("Invalid password\nMinimum 1 uppercase or lowercase\nMinimum 1 numeric number\nMinimum 1 Special Character");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await AuthService.signInUser(email, password).then((value) => {
        if (value != null) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage())),
        }
      });
    } catch (e) {
      print("RASVO");
    } finally {
      setState(() {
        isLoading = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(183, 53, 132, 1),
                    Color.fromRGBO(131, 58, 180, 1),
                  ]
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Instagram", style: TextStyle(color: Colors.white, fontSize: 45, fontFamily: "billabong"),),
                      SizedBox(height: 20,),
                      //#email
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        height: 50,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: TextField(
                          controller: emailController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Email",
                            border: InputBorder.none,
                            hintStyle:
                            TextStyle(fontSize: 17, color: Colors.white54),
                          ),
                        ),
                      ),
                      //#password
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        height: 50,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: TextField(
                          controller: passwordController,
                          obscureText: true,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Password",
                            border: InputBorder.none,
                            hintStyle:
                            TextStyle(fontSize: 17, color: Colors.white54),
                          ),
                        ),
                      ),
                      // Sign in
                      Container(
                          margin: EdgeInsets.only(top: 10),
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7)),
                          child: MaterialButton(
                            onPressed: doSignIn,
                            minWidth: double.infinity,
                            child: Text("Sign In", style: TextStyle(color: Colors.white),),
                          )
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don`t have an account?",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          (isLoading) ?
          Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.grey.withOpacity(.3),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ) : SizedBox(),
        ],
      ),
    );
  }
}
