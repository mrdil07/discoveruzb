import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  static void fireToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: Colors.tealAccent,
      fontSize: 18,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      textColor: Colors.red.shade900,
    );
  }
}
