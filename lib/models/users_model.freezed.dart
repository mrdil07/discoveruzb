// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'users_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Users _$UsersFromJson(Map<String, dynamic> json) {
  return _Users.fromJson(json);
}

/// @nodoc
mixin _$Users {
  @JsonKey(name: 'id')
  String get uid => throw _privateConstructorUsedError;
  String get fullname => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'img_url')
  String get imgUrl =>
      throw _privateConstructorUsedError; // 'user' | 'moderator' | 'admin'
  String get role => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_banned')
  bool get isBanned => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  @JsonKey(name: 'google_sub')
  String? get googleSub => throw _privateConstructorUsedError;
  @JsonKey(name: 'telegram_id')
  int? get telegramId => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_login_at')
  String? get lastLoginAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Users to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Users
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UsersCopyWith<Users> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UsersCopyWith<$Res> {
  factory $UsersCopyWith(Users value, $Res Function(Users) then) =
      _$UsersCopyWithImpl<$Res, Users>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String uid,
      String fullname,
      String phone,
      String email,
      @JsonKey(name: 'img_url') String imgUrl,
      String role,
      @JsonKey(name: 'is_banned') bool isBanned,
      String language,
      @JsonKey(name: 'google_sub') String? googleSub,
      @JsonKey(name: 'telegram_id') int? telegramId,
      @JsonKey(name: 'last_login_at') String? lastLoginAt,
      @JsonKey(name: 'created_at') String? createdAt});
}

/// @nodoc
class _$UsersCopyWithImpl<$Res, $Val extends Users>
    implements $UsersCopyWith<$Res> {
  _$UsersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Users
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? fullname = null,
    Object? phone = null,
    Object? email = null,
    Object? imgUrl = null,
    Object? role = null,
    Object? isBanned = null,
    Object? language = null,
    Object? googleSub = freezed,
    Object? telegramId = freezed,
    Object? lastLoginAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      fullname: null == fullname
          ? _value.fullname
          : fullname // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      imgUrl: null == imgUrl
          ? _value.imgUrl
          : imgUrl // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      isBanned: null == isBanned
          ? _value.isBanned
          : isBanned // ignore: cast_nullable_to_non_nullable
              as bool,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      googleSub: freezed == googleSub
          ? _value.googleSub
          : googleSub // ignore: cast_nullable_to_non_nullable
              as String?,
      telegramId: freezed == telegramId
          ? _value.telegramId
          : telegramId // ignore: cast_nullable_to_non_nullable
              as int?,
      lastLoginAt: freezed == lastLoginAt
          ? _value.lastLoginAt
          : lastLoginAt // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UsersImplCopyWith<$Res> implements $UsersCopyWith<$Res> {
  factory _$$UsersImplCopyWith(
          _$UsersImpl value, $Res Function(_$UsersImpl) then) =
      __$$UsersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String uid,
      String fullname,
      String phone,
      String email,
      @JsonKey(name: 'img_url') String imgUrl,
      String role,
      @JsonKey(name: 'is_banned') bool isBanned,
      String language,
      @JsonKey(name: 'google_sub') String? googleSub,
      @JsonKey(name: 'telegram_id') int? telegramId,
      @JsonKey(name: 'last_login_at') String? lastLoginAt,
      @JsonKey(name: 'created_at') String? createdAt});
}

/// @nodoc
class __$$UsersImplCopyWithImpl<$Res>
    extends _$UsersCopyWithImpl<$Res, _$UsersImpl>
    implements _$$UsersImplCopyWith<$Res> {
  __$$UsersImplCopyWithImpl(
      _$UsersImpl _value, $Res Function(_$UsersImpl) _then)
      : super(_value, _then);

  /// Create a copy of Users
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? fullname = null,
    Object? phone = null,
    Object? email = null,
    Object? imgUrl = null,
    Object? role = null,
    Object? isBanned = null,
    Object? language = null,
    Object? googleSub = freezed,
    Object? telegramId = freezed,
    Object? lastLoginAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$UsersImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      fullname: null == fullname
          ? _value.fullname
          : fullname // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      imgUrl: null == imgUrl
          ? _value.imgUrl
          : imgUrl // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      isBanned: null == isBanned
          ? _value.isBanned
          : isBanned // ignore: cast_nullable_to_non_nullable
              as bool,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      googleSub: freezed == googleSub
          ? _value.googleSub
          : googleSub // ignore: cast_nullable_to_non_nullable
              as String?,
      telegramId: freezed == telegramId
          ? _value.telegramId
          : telegramId // ignore: cast_nullable_to_non_nullable
              as int?,
      lastLoginAt: freezed == lastLoginAt
          ? _value.lastLoginAt
          : lastLoginAt // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UsersImpl with DiagnosticableTreeMixin implements _Users {
  const _$UsersImpl(
      {@JsonKey(name: 'id') this.uid = '',
      this.fullname = '',
      this.phone = '',
      this.email = '',
      @JsonKey(name: 'img_url') this.imgUrl = '',
      this.role = 'user',
      @JsonKey(name: 'is_banned') this.isBanned = false,
      this.language = 'uz',
      @JsonKey(name: 'google_sub') this.googleSub,
      @JsonKey(name: 'telegram_id') this.telegramId,
      @JsonKey(name: 'last_login_at') this.lastLoginAt,
      @JsonKey(name: 'created_at') this.createdAt});

  factory _$UsersImpl.fromJson(Map<String, dynamic> json) =>
      _$$UsersImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String uid;
  @override
  @JsonKey()
  final String fullname;
  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey()
  final String email;
  @override
  @JsonKey(name: 'img_url')
  final String imgUrl;
// 'user' | 'moderator' | 'admin'
  @override
  @JsonKey()
  final String role;
  @override
  @JsonKey(name: 'is_banned')
  final bool isBanned;
  @override
  @JsonKey()
  final String language;
  @override
  @JsonKey(name: 'google_sub')
  final String? googleSub;
  @override
  @JsonKey(name: 'telegram_id')
  final int? telegramId;
  @override
  @JsonKey(name: 'last_login_at')
  final String? lastLoginAt;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Users(uid: $uid, fullname: $fullname, phone: $phone, email: $email, imgUrl: $imgUrl, role: $role, isBanned: $isBanned, language: $language, googleSub: $googleSub, telegramId: $telegramId, lastLoginAt: $lastLoginAt, createdAt: $createdAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Users'))
      ..add(DiagnosticsProperty('uid', uid))
      ..add(DiagnosticsProperty('fullname', fullname))
      ..add(DiagnosticsProperty('phone', phone))
      ..add(DiagnosticsProperty('email', email))
      ..add(DiagnosticsProperty('imgUrl', imgUrl))
      ..add(DiagnosticsProperty('role', role))
      ..add(DiagnosticsProperty('isBanned', isBanned))
      ..add(DiagnosticsProperty('language', language))
      ..add(DiagnosticsProperty('googleSub', googleSub))
      ..add(DiagnosticsProperty('telegramId', telegramId))
      ..add(DiagnosticsProperty('lastLoginAt', lastLoginAt))
      ..add(DiagnosticsProperty('createdAt', createdAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UsersImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.fullname, fullname) ||
                other.fullname == fullname) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.imgUrl, imgUrl) || other.imgUrl == imgUrl) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.isBanned, isBanned) ||
                other.isBanned == isBanned) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.googleSub, googleSub) ||
                other.googleSub == googleSub) &&
            (identical(other.telegramId, telegramId) ||
                other.telegramId == telegramId) &&
            (identical(other.lastLoginAt, lastLoginAt) ||
                other.lastLoginAt == lastLoginAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uid,
      fullname,
      phone,
      email,
      imgUrl,
      role,
      isBanned,
      language,
      googleSub,
      telegramId,
      lastLoginAt,
      createdAt);

  /// Create a copy of Users
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UsersImplCopyWith<_$UsersImpl> get copyWith =>
      __$$UsersImplCopyWithImpl<_$UsersImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UsersImplToJson(
      this,
    );
  }
}

abstract class _Users implements Users {
  const factory _Users(
      {@JsonKey(name: 'id') final String uid,
      final String fullname,
      final String phone,
      final String email,
      @JsonKey(name: 'img_url') final String imgUrl,
      final String role,
      @JsonKey(name: 'is_banned') final bool isBanned,
      final String language,
      @JsonKey(name: 'google_sub') final String? googleSub,
      @JsonKey(name: 'telegram_id') final int? telegramId,
      @JsonKey(name: 'last_login_at') final String? lastLoginAt,
      @JsonKey(name: 'created_at') final String? createdAt}) = _$UsersImpl;

  factory _Users.fromJson(Map<String, dynamic> json) = _$UsersImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String get uid;
  @override
  String get fullname;
  @override
  String get phone;
  @override
  String get email;
  @override
  @JsonKey(name: 'img_url')
  String get imgUrl; // 'user' | 'moderator' | 'admin'
  @override
  String get role;
  @override
  @JsonKey(name: 'is_banned')
  bool get isBanned;
  @override
  String get language;
  @override
  @JsonKey(name: 'google_sub')
  String? get googleSub;
  @override
  @JsonKey(name: 'telegram_id')
  int? get telegramId;
  @override
  @JsonKey(name: 'last_login_at')
  String? get lastLoginAt;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;

  /// Create a copy of Users
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UsersImplCopyWith<_$UsersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
