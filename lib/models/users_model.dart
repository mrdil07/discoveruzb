import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'users_model.freezed.dart';
part 'users_model.g.dart';

@freezed
class Users with _$Users {
  const factory Users({
    @Default('') String uid,
    required String fullname,
    required String phoneNumber,
    @Default('') String email,
    @Default('') String password, 
    @Default('') String imgUrl,
    @Default('') String device_id,
    @Default('') String device_type,
    @Default('') String device_token,
  }) = _Users;

  factory Users.fromJson(Map<String, dynamic> json) => _$UsersFromJson(json);
}
