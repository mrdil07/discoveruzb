import 'package:flutter/material.dart';

import '../service/pref_service.dart';

class MainViewModel extends ChangeNotifier {
  int currentPage = 0;
  var pageController = PageController();
  String? uid;

  Future loadUser() async {
    String? userId = await Prefs.loadUserId();
    uid = userId;
    notifyListeners();
  }

  onPageChanged(int index) {
    currentPage = index;
    notifyListeners();
  }

  onTap(int index) {
    currentPage = index;
    notifyListeners();
    pageController.animateToPage(currentPage,
        duration: const Duration(microseconds: 200), curve: Curves.easeIn);
  }
}
