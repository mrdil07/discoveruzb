// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MyMediaModelImpl _$$MyMediaModelImplFromJson(Map<String, dynamic> json) =>
    _$MyMediaModelImpl(
      myVideos: json['myVideos'] as String?,
      name: json['name'] as String,
      myImages: (json['myImages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      description: json['description'] as String?,
      uploadedDate: json['uploadedDate'] as String?,
      likes:
          (json['likes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      users: json['users'] == null
          ? null
          : Users.fromJson(json['users'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$MyMediaModelImplToJson(_$MyMediaModelImpl instance) =>
    <String, dynamic>{
      'myVideos': instance.myVideos,
      'name': instance.name,
      'myImages': instance.myImages,
      'description': instance.description,
      'uploadedDate': instance.uploadedDate,
      'likes': instance.likes,
      'comments': instance.comments,
      'users': instance.users,
    };
