import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'places_model.freezed.dart';
part 'places_model.g.dart';

@freezed
class Place with _$Place {
  const factory Place({
    String? uid,
    required List<String> placeImage,
    String? userImage,
    required String placeInfo,
    required String placeName,
    required String address,
    String? id,
    required String type,
    required String source,
    required int time,
    required List<String> phoneNumber,
    required String price,
    @Default([]) List<String> comments,
    @Default([]) List<String> liked,
    @Default([]) List<String> saved,
    @Default(0) int likeCount,
    required double lat,
    required double lon,
  }) = _Place;

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);
}