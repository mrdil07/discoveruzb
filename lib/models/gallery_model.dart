import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'gallery_model.freezed.dart';
part 'gallery_model.g.dart';

@freezed
class GalleryModel with _$GalleryModel {
  const factory GalleryModel({
    required String placeName,
    required List<String> images,
    required String date,
  }) = _GalleryModel;

  factory GalleryModel.fromJson(Map<String, dynamic> json) => _$GalleryModelFromJson(json);
}
