import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:discoveruzb/models/users_model.dart';

part 'media_model.freezed.dart';
part 'media_model.g.dart';

@freezed
class MyMediaModel with _$MyMediaModel {
  const factory MyMediaModel({
    String? myVideos,
    required String name,
    List<String>? myImages,
    String? description,
    String? uploadedDate,
    @Default([]) List<String> likes,
    @Default([]) List<Map<String, dynamic>> comments,
    Users? users,
  }) = _MyMediaModel;

  factory MyMediaModel.fromJson(Map<String, dynamic> json) => _$MyMediaModelFromJson(json);
}
