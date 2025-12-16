// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MyMediaModel _$MyMediaModelFromJson(Map<String, dynamic> json) {
  return _MyMediaModel.fromJson(json);
}

/// @nodoc
mixin _$MyMediaModel {
  String? get myVideos => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<String>? get myImages => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get uploadedDate => throw _privateConstructorUsedError;
  List<String> get likes => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get comments => throw _privateConstructorUsedError;
  Users? get users => throw _privateConstructorUsedError;

  /// Serializes this MyMediaModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MyMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MyMediaModelCopyWith<MyMediaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyMediaModelCopyWith<$Res> {
  factory $MyMediaModelCopyWith(
          MyMediaModel value, $Res Function(MyMediaModel) then) =
      _$MyMediaModelCopyWithImpl<$Res, MyMediaModel>;
  @useResult
  $Res call(
      {String? myVideos,
      String name,
      List<String>? myImages,
      String? description,
      String? uploadedDate,
      List<String> likes,
      List<Map<String, dynamic>> comments,
      Users? users});

  $UsersCopyWith<$Res>? get users;
}

/// @nodoc
class _$MyMediaModelCopyWithImpl<$Res, $Val extends MyMediaModel>
    implements $MyMediaModelCopyWith<$Res> {
  _$MyMediaModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MyMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? myVideos = freezed,
    Object? name = null,
    Object? myImages = freezed,
    Object? description = freezed,
    Object? uploadedDate = freezed,
    Object? likes = null,
    Object? comments = null,
    Object? users = freezed,
  }) {
    return _then(_value.copyWith(
      myVideos: freezed == myVideos
          ? _value.myVideos
          : myVideos // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      myImages: freezed == myImages
          ? _value.myImages
          : myImages // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      uploadedDate: freezed == uploadedDate
          ? _value.uploadedDate
          : uploadedDate // ignore: cast_nullable_to_non_nullable
              as String?,
      likes: null == likes
          ? _value.likes
          : likes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      comments: null == comments
          ? _value.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      users: freezed == users
          ? _value.users
          : users // ignore: cast_nullable_to_non_nullable
              as Users?,
    ) as $Val);
  }

  /// Create a copy of MyMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UsersCopyWith<$Res>? get users {
    if (_value.users == null) {
      return null;
    }

    return $UsersCopyWith<$Res>(_value.users!, (value) {
      return _then(_value.copyWith(users: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MyMediaModelImplCopyWith<$Res>
    implements $MyMediaModelCopyWith<$Res> {
  factory _$$MyMediaModelImplCopyWith(
          _$MyMediaModelImpl value, $Res Function(_$MyMediaModelImpl) then) =
      __$$MyMediaModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? myVideos,
      String name,
      List<String>? myImages,
      String? description,
      String? uploadedDate,
      List<String> likes,
      List<Map<String, dynamic>> comments,
      Users? users});

  @override
  $UsersCopyWith<$Res>? get users;
}

/// @nodoc
class __$$MyMediaModelImplCopyWithImpl<$Res>
    extends _$MyMediaModelCopyWithImpl<$Res, _$MyMediaModelImpl>
    implements _$$MyMediaModelImplCopyWith<$Res> {
  __$$MyMediaModelImplCopyWithImpl(
      _$MyMediaModelImpl _value, $Res Function(_$MyMediaModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MyMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? myVideos = freezed,
    Object? name = null,
    Object? myImages = freezed,
    Object? description = freezed,
    Object? uploadedDate = freezed,
    Object? likes = null,
    Object? comments = null,
    Object? users = freezed,
  }) {
    return _then(_$MyMediaModelImpl(
      myVideos: freezed == myVideos
          ? _value.myVideos
          : myVideos // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      myImages: freezed == myImages
          ? _value._myImages
          : myImages // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      uploadedDate: freezed == uploadedDate
          ? _value.uploadedDate
          : uploadedDate // ignore: cast_nullable_to_non_nullable
              as String?,
      likes: null == likes
          ? _value._likes
          : likes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      comments: null == comments
          ? _value._comments
          : comments // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      users: freezed == users
          ? _value.users
          : users // ignore: cast_nullable_to_non_nullable
              as Users?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MyMediaModelImpl with DiagnosticableTreeMixin implements _MyMediaModel {
  const _$MyMediaModelImpl(
      {this.myVideos,
      required this.name,
      final List<String>? myImages,
      this.description,
      this.uploadedDate,
      final List<String> likes = const [],
      final List<Map<String, dynamic>> comments = const [],
      this.users})
      : _myImages = myImages,
        _likes = likes,
        _comments = comments;

  factory _$MyMediaModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MyMediaModelImplFromJson(json);

  @override
  final String? myVideos;
  @override
  final String name;
  final List<String>? _myImages;
  @override
  List<String>? get myImages {
    final value = _myImages;
    if (value == null) return null;
    if (_myImages is EqualUnmodifiableListView) return _myImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? description;
  @override
  final String? uploadedDate;
  final List<String> _likes;
  @override
  @JsonKey()
  List<String> get likes {
    if (_likes is EqualUnmodifiableListView) return _likes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_likes);
  }

  final List<Map<String, dynamic>> _comments;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get comments {
    if (_comments is EqualUnmodifiableListView) return _comments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_comments);
  }

  @override
  final Users? users;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MyMediaModel(myVideos: $myVideos, name: $name, myImages: $myImages, description: $description, uploadedDate: $uploadedDate, likes: $likes, comments: $comments, users: $users)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MyMediaModel'))
      ..add(DiagnosticsProperty('myVideos', myVideos))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('myImages', myImages))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('uploadedDate', uploadedDate))
      ..add(DiagnosticsProperty('likes', likes))
      ..add(DiagnosticsProperty('comments', comments))
      ..add(DiagnosticsProperty('users', users));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MyMediaModelImpl &&
            (identical(other.myVideos, myVideos) ||
                other.myVideos == myVideos) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._myImages, _myImages) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.uploadedDate, uploadedDate) ||
                other.uploadedDate == uploadedDate) &&
            const DeepCollectionEquality().equals(other._likes, _likes) &&
            const DeepCollectionEquality().equals(other._comments, _comments) &&
            (identical(other.users, users) || other.users == users));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      myVideos,
      name,
      const DeepCollectionEquality().hash(_myImages),
      description,
      uploadedDate,
      const DeepCollectionEquality().hash(_likes),
      const DeepCollectionEquality().hash(_comments),
      users);

  /// Create a copy of MyMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MyMediaModelImplCopyWith<_$MyMediaModelImpl> get copyWith =>
      __$$MyMediaModelImplCopyWithImpl<_$MyMediaModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MyMediaModelImplToJson(
      this,
    );
  }
}

abstract class _MyMediaModel implements MyMediaModel {
  const factory _MyMediaModel(
      {final String? myVideos,
      required final String name,
      final List<String>? myImages,
      final String? description,
      final String? uploadedDate,
      final List<String> likes,
      final List<Map<String, dynamic>> comments,
      final Users? users}) = _$MyMediaModelImpl;

  factory _MyMediaModel.fromJson(Map<String, dynamic> json) =
      _$MyMediaModelImpl.fromJson;

  @override
  String? get myVideos;
  @override
  String get name;
  @override
  List<String>? get myImages;
  @override
  String? get description;
  @override
  String? get uploadedDate;
  @override
  List<String> get likes;
  @override
  List<Map<String, dynamic>> get comments;
  @override
  Users? get users;

  /// Create a copy of MyMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MyMediaModelImplCopyWith<_$MyMediaModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
