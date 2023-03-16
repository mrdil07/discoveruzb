import 'dart:io';

import 'package:discoveruzb/models/gallery_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import '../service/data_service.dart';
import '../service/file_service.dart';

class CreateGalleryVM extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  List<GalleryModel> images = [];
  TextEditingController placeNameController = TextEditingController();
  List<File> imagesFile = [];
  List<String> phones = [];
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

  Future uploadNewPost(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    print("images:$imagesFile");
    await FileService.uploadFiles(imagesFile, FileService.folderGallery)
        .then((downloadUrl) => {
              _resPostImage(downloadUrl, context),
            });
    print("object");
  }

  void _resPostImage(List<String> downloadUrl, BuildContext context) {
    print("image link:$downloadUrl");
    GalleryModel gallery = GalleryModel(
        placeName: placeNameController.text.toString().trim(),
        date: "${DateTime.now()}",
        images: downloadUrl);
    _apiStorePost(gallery, context);
  }

  _apiStorePost(GalleryModel gallery, BuildContext context) {
    isLoading = true;
    notifyListeners();
    DataService.storeGallery(gallery).then((value) => {
          debugPrint(value.toString()),
          print("boldi"),
        });
  }

  Future getData() async {
    await DataService.loadGallery().then((value) => {
          images = value,
          notifyListeners(),
        });
  }
}
