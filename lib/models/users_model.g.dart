// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UsersImpl _$$UsersImplFromJson(Map<String, dynamic> json) => _$UsersImpl(
      uid: json['id'] as String? ?? '',
      fullname: json['fullname'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      imgUrl: json['img_url'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      isBanned: json['is_banned'] as bool? ?? false,
      language: json['language'] as String? ?? 'uz',
      googleSub: json['google_sub'] as String?,
      telegramId: (json['telegram_id'] as num?)?.toInt(),
      lastLoginAt: json['last_login_at'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$$UsersImplToJson(_$UsersImpl instance) =>
    <String, dynamic>{
      'id': instance.uid,
      'fullname': instance.fullname,
      'phone': instance.phone,
      'email': instance.email,
      'img_url': instance.imgUrl,
      'role': instance.role,
      'is_banned': instance.isBanned,
      'language': instance.language,
      'google_sub': instance.googleSub,
      'telegram_id': instance.telegramId,
      'last_login_at': instance.lastLoginAt,
      'created_at': instance.createdAt,
    };
