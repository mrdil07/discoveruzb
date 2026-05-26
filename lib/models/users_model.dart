import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'users_model.freezed.dart';
part 'users_model.g.dart';

@freezed
class Users with _$Users {
  const factory Users({
    @Default('') @JsonKey(name: 'id') String uid,
    @Default('') String fullname,
    @Default('') String phone,
    @Default('') String email,
    @JsonKey(name: 'img_url') @Default('') String imgUrl,
    // 'user' | 'moderator' | 'admin'
    @Default('user') String role,
    @JsonKey(name: 'is_banned') @Default(false) bool isBanned,
    @Default('uz') String language,
    @JsonKey(name: 'google_sub') String? googleSub,
    @JsonKey(name: 'telegram_id') int? telegramId,
    @JsonKey(name: 'last_login_at') String? lastLoginAt,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _Users;

  factory Users.fromJson(Map<String, dynamic> json) => _$UsersFromJson(json);
}

extension UsersX on Users {
  /// Admin huquqi tekshiruvi.
  bool get isAdmin => role == 'admin';

  /// Moderator yoki admin.
  bool get isModerator => role == 'moderator' || role == 'admin';

  /// Foydalanuvchi'da telefon raqami qo'shilganmi.
  bool get hasPhone => phone.isNotEmpty;

  /// Eski "phoneNumber" property — legacy code uchun.
  @Deprecated('Use `phone` instead')
  String get phoneNumber => phone;
}
