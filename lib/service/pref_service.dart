import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static Future<bool> saveUserId(String? userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('userId', userId!);
  }

  static Future<String?> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
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
    return prefs.remove('phone');
  }

  /// fullname
  static Future<bool> saveFullname(String fullname) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('fullname', fullname);
  }

  static Future<String?> loadFullname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('fullname');
  }

  /// UI tili ('uz' | 'ru' | 'en'). Default — o'zbek.
  static Future<bool> saveLocale(String code) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('locale', code);
  }

  static Future<String> loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('locale') ?? 'uz';
  }

  /// Guest (preview) rejim — login'siz ko'rish
  static Future<bool> saveGuestMode(bool enabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool('guestMode', enabled);
  }

  static Future<bool> loadGuestMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('guestMode') ?? false;
  }

  static Future<bool> removeGuestMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove('guestMode');
  }
}
