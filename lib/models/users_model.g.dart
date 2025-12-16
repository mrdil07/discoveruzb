// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UsersImpl _$$UsersImplFromJson(Map<String, dynamic> json) => _$UsersImpl(
      uid: json['uid'] as String? ?? '',
      fullname: json['fullname'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      imgUrl: json['imgUrl'] as String? ?? '',
      device_id: json['device_id'] as String? ?? '',
      device_type: json['device_type'] as String? ?? '',
      device_token: json['device_token'] as String? ?? '',
    );

Map<String, dynamic> _$$UsersImplToJson(_$UsersImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'fullname': instance.fullname,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'password': instance.password,
      'imgUrl': instance.imgUrl,
      'device_id': instance.device_id,
      'device_type': instance.device_type,
      'device_token': instance.device_token,
    };
