import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/places_model.dart';
import '../models/users_model.dart';
import '../service/data_service.dart';
import '../service/file_service.dart';
import '../service/pref_service.dart';

class AccountViewModel extends ChangeNotifier {
  List<Place> places = [];
  var isLoading = false;
  String fullName = '', imgUrl = '', email = '';
  File? _image;
  var subController = ScrollController();
  var isSelected = [true, false];
  ImagePicker imagePicker = ImagePicker();
  String? phone = '';

  imgFromGallery() async {
    XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    _image = File(image!.path);
    notifyListeners();

    apiChangePhoto();
  } //galeriyadan rasm olish uchun

  imgFromCamera() async {
    XFile? image = await imagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    _image = File(image!.path);
    notifyListeners();

    apiChangePhoto();
  } //kameradan rasm olish uchun

  void showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Gallery'),
                    onTap: () {
                      imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  void apiloadUser() async {
    isLoading = true;
    notifyListeners();
    DataService.loadUser().then((value) => {showUserInfo(value)});
  } // user malumotlarini yangilab beradi shuning uchun bu initState.ga yozib qoyilgan.

  showUserInfo(Users users) {
    isLoading = false;
    fullName = users.fullname;
    email = users.email;
    imgUrl = users.imgUrl;
    notifyListeners();
  } // uida rasmni korish uchun mos ozgarruvchilar userni yangi data.lari bilan tenglanyapti

  apiChangePhoto() {
    if (_image == null) return;

    isLoading = true;
    notifyListeners();

    FileService.uploadFile(_image!, FileService.folderGallery)
        .then((downloadUrl) => {
              apiUpdateUser(downloadUrl),
            });
  }

  apiUpdateUser(String downloadUrl) async {
    Users users = await DataService.loadUser();
    isLoading = false;
    users.imgUrl = downloadUrl;
    notifyListeners();

    await DataService.updateUser(users);
    apiloadUser();
  }

  void apiLoadMyPosts() async {
    phone = await Prefs.loadPhone();
    isLoading = true;

    notifyListeners();
    if (phone == '+998911490349') {
      await DataService.loadPosts().then((value) => {resLoadPosts(value)});
    } else {
      await DataService.loadLiked().then((value) => {resLoadPosts(value)});
    }
  }

  resLoadPosts(List<Place> newPlaces) {
    places = newPlaces;
    isLoading = false;
    notifyListeners();
  }

  void apiLoadMySaved() async {
    isLoading = true;
    notifyListeners();
    await DataService.loadSaved().then((value) => {resLoadPosts(value)});
  }

  resLoadSaved(List<Place> newPlaces) {
    places = newPlaces;
    isLoading = false;
    notifyListeners();
  }

  void resDelPosts(Place place, BuildContext context) async {
    isLoading = true;
    notifyListeners();
    Navigator.pop(context);
    DataService.removePost(place, place.id)
        .then((value) => {isLoading = false, apiLoadMyPosts()});
  }
}
