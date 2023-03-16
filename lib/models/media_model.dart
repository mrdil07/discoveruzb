import 'package:discoveruzb/models/users_model.dart';

class MyMediaModel {
  String? myVideos;
  String name;
  List<String>? myImages;
  String? description;
  String? uploadedDate;
  List? likes;
  List? comments;
  Users? users;
  MyMediaModel(
      {required this.myVideos,
      required this.name,
      this.myImages,
      this.description,
      this.uploadedDate,
      this.comments,
      this.likes,
      this.users});
}
