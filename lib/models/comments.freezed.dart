// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comments.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Comments _$CommentsFromJson(Map<String, dynamic> json) {
  return _Comments.fromJson(json);
}

/// @nodoc
mixin _$Comments {
  Map<String, dynamic> get users => throw _privateConstructorUsedError;
  int get dateTime => throw _privateConstructorUsedError;
  String get comment => throw _privateConstructorUsedError;

  /// Serializes this Comments to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Comments
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentsCopyWith<Comments> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentsCopyWith<$Res> {
  factory $CommentsCopyWith(Comments value, $Res Function(Comments) then) =
      _$CommentsCopyWithImpl<$Res, Comments>;
  @useResult
  $Res call({Map<String, dynamic> users, int dateTime, String comment});
}

/// @nodoc
class _$CommentsCopyWithImpl<$Res, $Val extends Comments>
    implements $CommentsCopyWith<$Res> {
  _$CommentsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Comments
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? users = null,
    Object? dateTime = null,
    Object? comment = null,
  }) {
    return _then(_value.copyWith(
      users: null == users
          ? _value.users
          : users // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      dateTime: null == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as int,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommentsImplCopyWith<$Res>
    implements $CommentsCopyWith<$Res> {
  factory _$$CommentsImplCopyWith(
          _$CommentsImpl value, $Res Function(_$CommentsImpl) then) =
      __$$CommentsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, dynamic> users, int dateTime, String comment});
}

/// @nodoc
class __$$CommentsImplCopyWithImpl<$Res>
    extends _$CommentsCopyWithImpl<$Res, _$CommentsImpl>
    implements _$$CommentsImplCopyWith<$Res> {
  __$$CommentsImplCopyWithImpl(
      _$CommentsImpl _value, $Res Function(_$CommentsImpl) _then)
      : super(_value, _then);

  /// Create a copy of Comments
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? users = null,
    Object? dateTime = null,
    Object? comment = null,
  }) {
    return _then(_$CommentsImpl(
      users: null == users
          ? _value._users
          : users // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      dateTime: null == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as int,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommentsImpl with DiagnosticableTreeMixin implements _Comments {
  const _$CommentsImpl(
      {required final Map<String, dynamic> users,
      required this.dateTime,
      required this.comment})
      : _users = users;

  factory _$CommentsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommentsImplFromJson(json);

  final Map<String, dynamic> _users;
  @override
  Map<String, dynamic> get users {
    if (_users is EqualUnmodifiableMapView) return _users;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_users);
  }

  @override
  final int dateTime;
  @override
  final String comment;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Comments(users: $users, dateTime: $dateTime, comment: $comment)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Comments'))
      ..add(DiagnosticsProperty('users', users))
      ..add(DiagnosticsProperty('dateTime', dateTime))
      ..add(DiagnosticsProperty('comment', comment));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentsImpl &&
            const DeepCollectionEquality().equals(other._users, _users) &&
            (identical(other.dateTime, dateTime) ||
                other.dateTime == dateTime) &&
            (identical(other.comment, comment) || other.comment == comment));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_users), dateTime, comment);

  /// Create a copy of Comments
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentsImplCopyWith<_$CommentsImpl> get copyWith =>
      __$$CommentsImplCopyWithImpl<_$CommentsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommentsImplToJson(
      this,
    );
  }
}

abstract class _Comments implements Comments {
  const factory _Comments(
      {required final Map<String, dynamic> users,
      required final int dateTime,
      required final String comment}) = _$CommentsImpl;

  factory _Comments.fromJson(Map<String, dynamic> json) =
      _$CommentsImpl.fromJson;

  @override
  Map<String, dynamic> get users;
  @override
  int get dateTime;
  @override
  String get comment;

  /// Create a copy of Comments
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentsImplCopyWith<_$CommentsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
