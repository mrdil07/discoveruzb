import 'package:flutter/material.dart';

import '../models/places_model.dart';
import '../models/users_model.dart';
import '../service/data_service.dart';
import '../service/hive_service.dart';

class HomeViewModel extends ChangeNotifier {
  List<Place> famousPlaces = [];
  List<Place> recPosts = [];
  List<Place> newAdded = [];
  String searchedPlace = '';
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  var scrollController = ScrollController();
  String imgUrl = '', fullName = '...', userId = "", phone = "";

  void apiLoadUser() {
    DataService.loadUser().then((value) => {
          showUserInfo(value),
        });
  }

  showUserInfo(Users users) {
    HiveDB.storePerson(users);
    fullName = users.fullname;
    imgUrl = users.imgUrl;
    userId = users.uid;
    phone = users.phoneNumber;
    notifyListeners();
  }

  void apiLoadFamousPost() async {
    isLoading = true;
    notifyListeners();
    DataService.loadFamousPlace().then((value) => {
          debugPrint(value.toString()),
          _showFeeds(value),
        });
  }

  _showFeeds(List<Place> place) {
    famousPlaces = place;
    isLoading = false;
    notifyListeners();
  }

  void apiLoadPosts() async {
    isLoading = true;
    notifyListeners();

    await DataService.loadRecommendPlace().then((value) => {
          resLoadPost(value),
        });
  }

  resLoadPost(List<Place> places) {
    recPosts = places;
    isLoading = false;
    notifyListeners();
  }

  void apiLoadNewPost() async {
    isLoading = true;
    notifyListeners();
    DataService.loadNewAdded().then((value) => {
          _showNewAdded(value),
        });
  }

  _showNewAdded(List<Place> place) {
    newAdded = place;
    isLoading = false;
    notifyListeners();
  }

  Future refresh() async {
    apiLoadUser();
    apiLoadFamousPost();
    apiLoadPosts();
    apiLoadNewPost();
  }
}
