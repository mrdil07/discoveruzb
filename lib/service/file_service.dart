import 'dart:io';

import 'package:discoveruzb/service/pref_service.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FileService {
  static final Reference _storage = FirebaseStorage.instance.ref();
  static const String folderUserImg = "user_image";
  static const String folderPostImg = "post_image";
  static const String folderGallery = "gallery";

  static Future<List<String>> uploadFiles(
      List<File> _images, String folder) async {
    var imageUrls =
        await Future.wait(_images.map((_image) => uploadFile(_image, folder)));
    return imageUrls;
  }

  // static Future<String> uploadFile(File _image) async {
  //   String? id = await Prefs.loadUserId();
  //   Reference storageReference = FirebaseStorage.instance
  //       .ref()
  //       .child('posts/' + id.toString() + DateTime.now().toString());
  //   UploadTask uploadTask = storageReference.putFile(_image);
  //   await uploadTask;
  //
  //   return await storageReference.getDownloadURL();
  // }

  static Future<String> uploadFile(File image, String folder) async {
    /// image name
    String? uid = await Prefs.loadUserId();
    String imgProfileName = uid!;

    /// rasm uchun nom 1-holat
    String imgName = "image_${DateTime.now()}";

    /// rasm uchun nom berilyapti 2-holat
    Reference storageRef = _storage.child(folder).child(
        imgName); //firebase storage bolimida papka ochib(nomi folder ning qiymatiga teng), rasm(nomi imgName qiymatiga teng)ni joylashtiradi.
    UploadTask uploadTask = storageRef.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask;
    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
