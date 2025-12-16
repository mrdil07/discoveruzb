// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comments.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommentsImpl _$$CommentsImplFromJson(Map<String, dynamic> json) =>
    _$CommentsImpl(
      users: json['users'] as Map<String, dynamic>,
      dateTime: (json['dateTime'] as num).toInt(),
      comment: json['comment'] as String,
    );

Map<String, dynamic> _$$CommentsImplToJson(_$CommentsImpl instance) =>
    <String, dynamic>{
      'users': instance.users,
      'dateTime': instance.dateTime,
      'comment': instance.comment,
    };
