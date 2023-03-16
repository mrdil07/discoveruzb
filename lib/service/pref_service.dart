import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static Future<bool> saveUserId(String? userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("saveUserId $userId");
    return prefs.setString('userId', userId!);
  }

  static Future<String?> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringId = prefs.getString('userId');
    print("loadUserId $stringId");
    return stringId;
  }

  static Future<bool> removeUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove('userId');
  }

  /// name
  static Future<bool> savePhone(String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('phone', phone);
  }

  static Future<String?> loadPhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phone = prefs.getString('phone');
    return phone;
  }

  static Future<bool> removePhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('removed');
    return prefs.remove('phone');
  }

  /// familya
  // static Future<bool> saveFam(String? fam) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   print("fam $fam");
  //   return prefs.setString('fam', fam!);
  // }
  //
  // static Future<String?> loadFam() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? fam = prefs.getString('fam');
  //   print("fam $fam");
  //   return fam;
  // }
  //
  // static Future<bool> removeFam() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.remove('fam');
  // }
}
