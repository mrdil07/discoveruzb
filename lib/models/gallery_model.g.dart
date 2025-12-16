// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GalleryModelImpl _$$GalleryModelImplFromJson(Map<String, dynamic> json) =>
    _$GalleryModelImpl(
      placeName: json['placeName'] as String,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      date: json['date'] as String,
    );

Map<String, dynamic> _$$GalleryModelImplToJson(_$GalleryModelImpl instance) =>
    <String, dynamic>{
      'placeName': instance.placeName,
      'images': instance.images,
      'date': instance.date,
    };
