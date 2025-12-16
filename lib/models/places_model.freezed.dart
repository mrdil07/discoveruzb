// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'places_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Place _$PlaceFromJson(Map<String, dynamic> json) {
  return _Place.fromJson(json);
}

/// @nodoc
mixin _$Place {
  String? get uid => throw _privateConstructorUsedError;
  List<String> get placeImage => throw _privateConstructorUsedError;
  String? get userImage => throw _privateConstructorUsedError;
  String get placeInfo => throw _privateConstructorUsedError;
  String get placeName => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String? get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  int get time => throw _privateConstructorUsedError;
  List<String> get phoneNumber => throw _privateConstructorUsedError;
  String get price => throw _privateConstructorUsedError;
  List<String> get comments => throw _privateConstructorUsedError;
  List<String> get liked => throw _privateConstructorUsedError;
  List<String> get saved => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lon => throw _privateConstructorUsedError;

  /// Serializes this Place to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaceCopyWith<Place> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaceCopyWith<$Res> {
  factory $PlaceCopyWith(Place value, $Res Function(Place) then) =
      _$PlaceCopyWithImpl<$Res, Place>;
  @useResult
  $Res call(
      {String? uid,
      List<String> placeImage,
      String? userImage,
      String placeInfo,
      String placeName,
      String address,
      String? id,
      String type,
      String source,
      int time,
      List<String> phoneNumber,
      String price,
      List<String> comments,
      List<String> liked,
      List<String> saved,
      int likeCount,
      double lat,
      double lon});
}

/// @nodoc
class _$PlaceCopyWithImpl<$Res, $Val extends Place>
    implements $PlaceCopyWith<$Res> {
  _$PlaceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = freezed,
    Object? placeImage = null,
    Object? userImage = freezed,
    Object? placeInfo = null,
    Object? placeName = null,
    Object? address = null,
    Object? id = freezed,
    Object? type = null,
    Object? source = null,
    Object? time = null,
    Object? phoneNumber = null,
    Object? price = null,
    Object? comments = null,
    Object? liked = null,
    Object? saved = null,
    Object? likeCount = null,
    Object? lat = null,
    Object? lon = null,
  }) {
    return _then(_value.copyWith(
      uid: freezed == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String?,
      placeImage: null == placeImage
          ? _value.placeImage
          : placeImage // ignore: cast_nullable_to_non_nullable
              as List<String>,
      userImage: freezed == userImage
          ? _value.userImage
          : userImage // ignore: cast_nullable_to_non_nullable
              as String?,
      placeInfo: null == placeInfo
          ? _value.placeInfo
          : placeInfo // ignore: cast_nullable_to_non_nullable
              as String,
      placeName: null == placeName
          ? _value.placeName
          : placeName // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as List<String>,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as String,
      comments: null == comments
          ? _value.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as List<String>,
      liked: null == liked
          ? _value.liked
          : liked // ignore: cast_nullable_to_non_nullable
              as List<String>,
      saved: null == saved
          ? _value.saved
          : saved // ignore: cast_nullable_to_non_nullable
              as List<String>,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lon: null == lon
          ? _value.lon
          : lon // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlaceImplCopyWith<$Res> implements $PlaceCopyWith<$Res> {
  factory _$$PlaceImplCopyWith(
          _$PlaceImpl value, $Res Function(_$PlaceImpl) then) =
      __$$PlaceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? uid,
      List<String> placeImage,
      String? userImage,
      String placeInfo,
      String placeName,
      String address,
      String? id,
      String type,
      String source,
      int time,
      List<String> phoneNumber,
      String price,
      List<String> comments,
      List<String> liked,
      List<String> saved,
      int likeCount,
      double lat,
      double lon});
}

/// @nodoc
class __$$PlaceImplCopyWithImpl<$Res>
    extends _$PlaceCopyWithImpl<$Res, _$PlaceImpl>
    implements _$$PlaceImplCopyWith<$Res> {
  __$$PlaceImplCopyWithImpl(
      _$PlaceImpl _value, $Res Function(_$PlaceImpl) _then)
      : super(_value, _then);

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = freezed,
    Object? placeImage = null,
    Object? userImage = freezed,
    Object? placeInfo = null,
    Object? placeName = null,
    Object? address = null,
    Object? id = freezed,
    Object? type = null,
    Object? source = null,
    Object? time = null,
    Object? phoneNumber = null,
    Object? price = null,
    Object? comments = null,
    Object? liked = null,
    Object? saved = null,
    Object? likeCount = null,
    Object? lat = null,
    Object? lon = null,
  }) {
    return _then(_$PlaceImpl(
      uid: freezed == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String?,
      placeImage: null == placeImage
          ? _value._placeImage
          : placeImage // ignore: cast_nullable_to_non_nullable
              as List<String>,
      userImage: freezed == userImage
          ? _value.userImage
          : userImage // ignore: cast_nullable_to_non_nullable
              as String?,
      placeInfo: null == placeInfo
          ? _value.placeInfo
          : placeInfo // ignore: cast_nullable_to_non_nullable
              as String,
      placeName: null == placeName
          ? _value.placeName
          : placeName // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
      phoneNumber: null == phoneNumber
          ? _value._phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as List<String>,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as String,
      comments: null == comments
          ? _value._comments
          : comments // ignore: cast_nullable_to_non_nullable
              as List<String>,
      liked: null == liked
          ? _value._liked
          : liked // ignore: cast_nullable_to_non_nullable
              as List<String>,
      saved: null == saved
          ? _value._saved
          : saved // ignore: cast_nullable_to_non_nullable
              as List<String>,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lon: null == lon
          ? _value.lon
          : lon // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaceImpl with DiagnosticableTreeMixin implements _Place {
  const _$PlaceImpl(
      {this.uid,
      required final List<String> placeImage,
      this.userImage,
      required this.placeInfo,
      required this.placeName,
      required this.address,
      this.id,
      required this.type,
      required this.source,
      required this.time,
      required final List<String> phoneNumber,
      required this.price,
      final List<String> comments = const [],
      final List<String> liked = const [],
      final List<String> saved = const [],
      this.likeCount = 0,
      required this.lat,
      required this.lon})
      : _placeImage = placeImage,
        _phoneNumber = phoneNumber,
        _comments = comments,
        _liked = liked,
        _saved = saved;

  factory _$PlaceImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaceImplFromJson(json);

  @override
  final String? uid;
  final List<String> _placeImage;
  @override
  List<String> get placeImage {
    if (_placeImage is EqualUnmodifiableListView) return _placeImage;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_placeImage);
  }

  @override
  final String? userImage;
  @override
  final String placeInfo;
  @override
  final String placeName;
  @override
  final String address;
  @override
  final String? id;
  @override
  final String type;
  @override
  final String source;
  @override
  final int time;
  final List<String> _phoneNumber;
  @override
  List<String> get phoneNumber {
    if (_phoneNumber is EqualUnmodifiableListView) return _phoneNumber;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_phoneNumber);
  }

  @override
  final String price;
  final List<String> _comments;
  @override
  @JsonKey()
  List<String> get comments {
    if (_comments is EqualUnmodifiableListView) return _comments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_comments);
  }

  final List<String> _liked;
  @override
  @JsonKey()
  List<String> get liked {
    if (_liked is EqualUnmodifiableListView) return _liked;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_liked);
  }

  final List<String> _saved;
  @override
  @JsonKey()
  List<String> get saved {
    if (_saved is EqualUnmodifiableListView) return _saved;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_saved);
  }

  @override
  @JsonKey()
  final int likeCount;
  @override
  final double lat;
  @override
  final double lon;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Place(uid: $uid, placeImage: $placeImage, userImage: $userImage, placeInfo: $placeInfo, placeName: $placeName, address: $address, id: $id, type: $type, source: $source, time: $time, phoneNumber: $phoneNumber, price: $price, comments: $comments, liked: $liked, saved: $saved, likeCount: $likeCount, lat: $lat, lon: $lon)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Place'))
      ..add(DiagnosticsProperty('uid', uid))
      ..add(DiagnosticsProperty('placeImage', placeImage))
      ..add(DiagnosticsProperty('userImage', userImage))
      ..add(DiagnosticsProperty('placeInfo', placeInfo))
      ..add(DiagnosticsProperty('placeName', placeName))
      ..add(DiagnosticsProperty('address', address))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('source', source))
      ..add(DiagnosticsProperty('time', time))
      ..add(DiagnosticsProperty('phoneNumber', phoneNumber))
      ..add(DiagnosticsProperty('price', price))
      ..add(DiagnosticsProperty('comments', comments))
      ..add(DiagnosticsProperty('liked', liked))
      ..add(DiagnosticsProperty('saved', saved))
      ..add(DiagnosticsProperty('likeCount', likeCount))
      ..add(DiagnosticsProperty('lat', lat))
      ..add(DiagnosticsProperty('lon', lon));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaceImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            const DeepCollectionEquality()
                .equals(other._placeImage, _placeImage) &&
            (identical(other.userImage, userImage) ||
                other.userImage == userImage) &&
            (identical(other.placeInfo, placeInfo) ||
                other.placeInfo == placeInfo) &&
            (identical(other.placeName, placeName) ||
                other.placeName == placeName) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.time, time) || other.time == time) &&
            const DeepCollectionEquality()
                .equals(other._phoneNumber, _phoneNumber) &&
            (identical(other.price, price) || other.price == price) &&
            const DeepCollectionEquality().equals(other._comments, _comments) &&
            const DeepCollectionEquality().equals(other._liked, _liked) &&
            const DeepCollectionEquality().equals(other._saved, _saved) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lon, lon) || other.lon == lon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uid,
      const DeepCollectionEquality().hash(_placeImage),
      userImage,
      placeInfo,
      placeName,
      address,
      id,
      type,
      source,
      time,
      const DeepCollectionEquality().hash(_phoneNumber),
      price,
      const DeepCollectionEquality().hash(_comments),
      const DeepCollectionEquality().hash(_liked),
      const DeepCollectionEquality().hash(_saved),
      likeCount,
      lat,
      lon);

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaceImplCopyWith<_$PlaceImpl> get copyWith =>
      __$$PlaceImplCopyWithImpl<_$PlaceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaceImplToJson(
      this,
    );
  }
}

abstract class _Place implements Place {
  const factory _Place(
      {final String? uid,
      required final List<String> placeImage,
      final String? userImage,
      required final String placeInfo,
      required final String placeName,
      required final String address,
      final String? id,
      required final String type,
      required final String source,
      required final int time,
      required final List<String> phoneNumber,
      required final String price,
      final List<String> comments,
      final List<String> liked,
      final List<String> saved,
      final int likeCount,
      required final double lat,
      required final double lon}) = _$PlaceImpl;

  factory _Place.fromJson(Map<String, dynamic> json) = _$PlaceImpl.fromJson;

  @override
  String? get uid;
  @override
  List<String> get placeImage;
  @override
  String? get userImage;
  @override
  String get placeInfo;
  @override
  String get placeName;
  @override
  String get address;
  @override
  String? get id;
  @override
  String get type;
  @override
  String get source;
  @override
  int get time;
  @override
  List<String> get phoneNumber;
  @override
  String get price;
  @override
  List<String> get comments;
  @override
  List<String> get liked;
  @override
  List<String> get saved;
  @override
  int get likeCount;
  @override
  double get lat;
  @override
  double get lon;

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaceImplCopyWith<_$PlaceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
