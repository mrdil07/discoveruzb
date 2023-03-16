import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pinput/pinput.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/places_model.dart';
import '../service/file_service.dart';
import '../service/pref_service.dart';

class MediaPageVM extends ChangeNotifier {
  PageController? controller;
  bool isLoading = false;
  String? address1;
  String? placeType1;
  final captionController = TextEditingController();
  TextEditingController placeNameController = TextEditingController();
  TextEditingController placeSourceController = TextEditingController();
  TextEditingController latitude = TextEditingController();
  TextEditingController longitude = TextEditingController();
  int countPost = 0;
  String? userId;
  String? phone;
  List<File> images = [];
  ImagePicker imagePicker = ImagePicker();

  List<String> menuItems1 = [
    "Toshkent",
    "Andijon",
    "Namangan",
    "Farg'ona",
    "Sirdaryo",
    "Jizzax",
    "Xorazm",
    "Samarqand",
    "Qashqadaryo",
    "Surxondaryo",
    "Navoiy",
    "Buxoro",
    "Qoraqolpog'iston",
    "Boshqalar",
  ];

  List<String> menuItems2 = [
    "Sanatoriya",
    "Mehmonxona",
    "Dacha",
    "Dam olish maskanlari",
    "Cho'milish havzalari",
    "Boshqalar"
  ];

  void apiPostImage() {
    print('2');
    isLoading = true;
    notifyListeners();
    FileService.uploadFiles(images, FileService.folderGallery)
        .then((downloadUrl) => {
              resPostImage(downloadUrl),
            });
  }

  void resPostImage(List<String> downloadUrl) {
    // double lat = double.parse(latitude.text.toString().trim());
    // double longLat = double.parse(longitude.text.toString().trim());
    Place place = Place(
        phoneNumber: [phone!],
        price: '0',
        placeImage: downloadUrl,
        placeInfo: captionController.text.toString().trim(),
        address: address1!,
        placeName: placeNameController.text.toString().trim(),
        type: placeType1!,
        source: placeSourceController.text.toString().trim(),
        lat: double.parse(latitude.text.toString().trim()),
        lon: double.parse(longitude.text.toString().trim()),
        comments: [],
        time: DateTime.now().microsecondsSinceEpoch);
    apiStorePost(place);
  }

  apiStorePost(Place place) async {
    //post qilish uchun postlar saqlab olamiz
    //  await DataService.storePost(place);
    //postimizni feedga ham saqlaymiz
    //  await DataService.storeFeedNew(place, address1!);
    moveToProfile();
  }

  uploadNewPost() {
    String caption = captionController.text.toString().trim();
    String placeName = placeNameController.text.toString().trim();
    String placeSource = placeSourceController.text.toString().trim();
    String lat = latitude.text.toString().trim();
    String longLat = longitude.text.toString().trim();

    if (caption.isEmpty) return;
    if (placeName.isEmpty) return;
    if (images.isEmpty) return;
    if (lat.isEmpty) return;
    if (longLat.isEmpty) return;
    if (placeSource.isEmpty) return;
    apiPostImage();
  }

  void moveToProfile() {
    isLoading = false;
    notifyListeners();
    captionController.clear();
    placeNameController.clear();
    placeType1 = '';
    placeSourceController.clear();
    latitude.clear();
    longitude.delete;
    images.clear();
    notifyListeners();
    controller?.animateToPage(3,
        duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  Future loadUser() async {
    userId = await Prefs.loadUserId();
    phone = await Prefs.loadPhone();
    notifyListeners();
    print('$userId + $phone');
  }

  void launchUrlMethod(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}
