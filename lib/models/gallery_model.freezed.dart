// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gallery_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GalleryModel _$GalleryModelFromJson(Map<String, dynamic> json) {
  return _GalleryModel.fromJson(json);
}

/// @nodoc
mixin _$GalleryModel {
  String get placeName => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;

  /// Serializes this GalleryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GalleryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GalleryModelCopyWith<GalleryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GalleryModelCopyWith<$Res> {
  factory $GalleryModelCopyWith(
          GalleryModel value, $Res Function(GalleryModel) then) =
      _$GalleryModelCopyWithImpl<$Res, GalleryModel>;
  @useResult
  $Res call({String placeName, List<String> images, String date});
}

/// @nodoc
class _$GalleryModelCopyWithImpl<$Res, $Val extends GalleryModel>
    implements $GalleryModelCopyWith<$Res> {
  _$GalleryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GalleryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? placeName = null,
    Object? images = null,
    Object? date = null,
  }) {
    return _then(_value.copyWith(
      placeName: null == placeName
          ? _value.placeName
          : placeName // ignore: cast_nullable_to_non_nullable
              as String,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GalleryModelImplCopyWith<$Res>
    implements $GalleryModelCopyWith<$Res> {
  factory _$$GalleryModelImplCopyWith(
          _$GalleryModelImpl value, $Res Function(_$GalleryModelImpl) then) =
      __$$GalleryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String placeName, List<String> images, String date});
}

/// @nodoc
class __$$GalleryModelImplCopyWithImpl<$Res>
    extends _$GalleryModelCopyWithImpl<$Res, _$GalleryModelImpl>
    implements _$$GalleryModelImplCopyWith<$Res> {
  __$$GalleryModelImplCopyWithImpl(
      _$GalleryModelImpl _value, $Res Function(_$GalleryModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of GalleryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? placeName = null,
    Object? images = null,
    Object? date = null,
  }) {
    return _then(_$GalleryModelImpl(
      placeName: null == placeName
          ? _value.placeName
          : placeName // ignore: cast_nullable_to_non_nullable
              as String,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GalleryModelImpl with DiagnosticableTreeMixin implements _GalleryModel {
  const _$GalleryModelImpl(
      {required this.placeName,
      required final List<String> images,
      required this.date})
      : _images = images;

  factory _$GalleryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GalleryModelImplFromJson(json);

  @override
  final String placeName;
  final List<String> _images;
  @override
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  final String date;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GalleryModel(placeName: $placeName, images: $images, date: $date)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'GalleryModel'))
      ..add(DiagnosticsProperty('placeName', placeName))
      ..add(DiagnosticsProperty('images', images))
      ..add(DiagnosticsProperty('date', date));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GalleryModelImpl &&
            (identical(other.placeName, placeName) ||
                other.placeName == placeName) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.date, date) || other.date == date));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, placeName,
      const DeepCollectionEquality().hash(_images), date);

  /// Create a copy of GalleryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GalleryModelImplCopyWith<_$GalleryModelImpl> get copyWith =>
      __$$GalleryModelImplCopyWithImpl<_$GalleryModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GalleryModelImplToJson(
      this,
    );
  }
}

abstract class _GalleryModel implements GalleryModel {
  const factory _GalleryModel(
      {required final String placeName,
      required final List<String> images,
      required final String date}) = _$GalleryModelImpl;

  factory _GalleryModel.fromJson(Map<String, dynamic> json) =
      _$GalleryModelImpl.fromJson;

  @override
  String get placeName;
  @override
  List<String> get images;
  @override
  String get date;

  /// Create a copy of GalleryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GalleryModelImplCopyWith<_$GalleryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
