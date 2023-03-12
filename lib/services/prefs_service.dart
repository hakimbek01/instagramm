
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {

  static Future<bool> saveFCM(String fcmToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString("fcmToken", fcmToken);
  }

  static Future<String> loadFCM() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("fcmToken");
    return token!;
  }

}