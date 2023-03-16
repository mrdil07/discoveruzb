import 'package:discoveruzb/screens/introPages/login_with_phone.dart';
import 'package:discoveruzb/service/pref_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  //signIn
  static Future<Map<String, User?>> signInUser(
      String email, String password) async {
    Map<String, User?> map = {};
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final User? user = _auth.currentUser;
      map.addAll({"SUCCESS": user});
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      map.addAll({"ERROR": null});
    }
    return map;
  }

  static Future<Map<String, User?>> signUpUser(BuildContext context,
      String fullname, String email, String password) async {
    Map<String, User?> map = {};
    try {
      var authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = authResult.user;
      map.addAll({"SUCCESS": user!});
      return map;
    } catch (error) {
      switch (error) {
        case "ERROR_EMAIL_ALREADY_IN_USE":
          map.addAll({"ERROR_EMAIL_ALREADY_IN_USE": null});
          break;
        default:
          map.addAll({"ERROR": null});
          if (kDebugMode) {
            print(error);
          }
      }
    }
    return map;
  }

  static signOutUser(BuildContext context) {
    _auth.signOut();
    Prefs.removeUserId().then((value) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (ctx) => const LoginWithPhone()),
          (route) => false);
    });
  }
}
