// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'external_review.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ExternalReviewsResponse _$ExternalReviewsResponseFromJson(
    Map<String, dynamic> json) {
  return _ExternalReviewsResponse.fromJson(json);
}

/// @nodoc
mixin _$ExternalReviewsResponse {
  @JsonKey(name: 'post_id')
  String get postId => throw _privateConstructorUsedError;
  List<SourceSummary> get summaries => throw _privateConstructorUsedError;
  List<ExternalReview> get reviews => throw _privateConstructorUsedError;

  /// Serializes this ExternalReviewsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExternalReviewsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExternalReviewsResponseCopyWith<ExternalReviewsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExternalReviewsResponseCopyWith<$Res> {
  factory $ExternalReviewsResponseCopyWith(ExternalReviewsResponse value,
          $Res Function(ExternalReviewsResponse) then) =
      _$ExternalReviewsResponseCopyWithImpl<$Res, ExternalReviewsResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'post_id') String postId,
      List<SourceSummary> summaries,
      List<ExternalReview> reviews});
}

/// @nodoc
class _$ExternalReviewsResponseCopyWithImpl<$Res,
        $Val extends ExternalReviewsResponse>
    implements $ExternalReviewsResponseCopyWith<$Res> {
  _$ExternalReviewsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExternalReviewsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postId = null,
    Object? summaries = null,
    Object? reviews = null,
  }) {
    return _then(_value.copyWith(
      postId: null == postId
          ? _value.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String,
      summaries: null == summaries
          ? _value.summaries
          : summaries // ignore: cast_nullable_to_non_nullable
              as List<SourceSummary>,
      reviews: null == reviews
          ? _value.reviews
          : reviews // ignore: cast_nullable_to_non_nullable
              as List<ExternalReview>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExternalReviewsResponseImplCopyWith<$Res>
    implements $ExternalReviewsResponseCopyWith<$Res> {
  factory _$$ExternalReviewsResponseImplCopyWith(
          _$ExternalReviewsResponseImpl value,
          $Res Function(_$ExternalReviewsResponseImpl) then) =
      __$$ExternalReviewsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'post_id') String postId,
      List<SourceSummary> summaries,
      List<ExternalReview> reviews});
}

/// @nodoc
class __$$ExternalReviewsResponseImplCopyWithImpl<$Res>
    extends _$ExternalReviewsResponseCopyWithImpl<$Res,
        _$ExternalReviewsResponseImpl>
    implements _$$ExternalReviewsResponseImplCopyWith<$Res> {
  __$$ExternalReviewsResponseImplCopyWithImpl(
      _$ExternalReviewsResponseImpl _value,
      $Res Function(_$ExternalReviewsResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of ExternalReviewsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postId = null,
    Object? summaries = null,
    Object? reviews = null,
  }) {
    return _then(_$ExternalReviewsResponseImpl(
      postId: null == postId
          ? _value.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String,
      summaries: null == summaries
          ? _value._summaries
          : summaries // ignore: cast_nullable_to_non_nullable
              as List<SourceSummary>,
      reviews: null == reviews
          ? _value._reviews
          : reviews // ignore: cast_nullable_to_non_nullable
              as List<ExternalReview>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExternalReviewsResponseImpl
    with DiagnosticableTreeMixin
    implements _ExternalReviewsResponse {
  const _$ExternalReviewsResponseImpl(
      {@JsonKey(name: 'post_id') required this.postId,
      final List<SourceSummary> summaries = const [],
      final List<ExternalReview> reviews = const []})
      : _summaries = summaries,
        _reviews = reviews;

  factory _$ExternalReviewsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExternalReviewsResponseImplFromJson(json);

  @override
  @JsonKey(name: 'post_id')
  final String postId;
  final List<SourceSummary> _summaries;
  @override
  @JsonKey()
  List<SourceSummary> get summaries {
    if (_summaries is EqualUnmodifiableListView) return _summaries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_summaries);
  }

  final List<ExternalReview> _reviews;
  @override
  @JsonKey()
  List<ExternalReview> get reviews {
    if (_reviews is EqualUnmodifiableListView) return _reviews;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reviews);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ExternalReviewsResponse(postId: $postId, summaries: $summaries, reviews: $reviews)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ExternalReviewsResponse'))
      ..add(DiagnosticsProperty('postId', postId))
      ..add(DiagnosticsProperty('summaries', summaries))
      ..add(DiagnosticsProperty('reviews', reviews));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExternalReviewsResponseImpl &&
            (identical(other.postId, postId) || other.postId == postId) &&
            const DeepCollectionEquality()
                .equals(other._summaries, _summaries) &&
            const DeepCollectionEquality().equals(other._reviews, _reviews));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      postId,
      const DeepCollectionEquality().hash(_summaries),
      const DeepCollectionEquality().hash(_reviews));

  /// Create a copy of ExternalReviewsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExternalReviewsResponseImplCopyWith<_$ExternalReviewsResponseImpl>
      get copyWith => __$$ExternalReviewsResponseImplCopyWithImpl<
          _$ExternalReviewsResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExternalReviewsResponseImplToJson(
      this,
    );
  }
}

abstract class _ExternalReviewsResponse implements ExternalReviewsResponse {
  const factory _ExternalReviewsResponse(
      {@JsonKey(name: 'post_id') required final String postId,
      final List<SourceSummary> summaries,
      final List<ExternalReview> reviews}) = _$ExternalReviewsResponseImpl;

  factory _ExternalReviewsResponse.fromJson(Map<String, dynamic> json) =
      _$ExternalReviewsResponseImpl.fromJson;

  @override
  @JsonKey(name: 'post_id')
  String get postId;
  @override
  List<SourceSummary> get summaries;
  @override
  List<ExternalReview> get reviews;

  /// Create a copy of ExternalReviewsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExternalReviewsResponseImplCopyWith<_$ExternalReviewsResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SourceSummary _$SourceSummaryFromJson(Map<String, dynamic> json) {
  return _SourceSummary.fromJson(json);
}

/// @nodoc
mixin _$SourceSummary {
  /// `google` | `yandex` | `2gis`
  String get source => throw _privateConstructorUsedError;
  @JsonKey(name: 'review_count')
  int get reviewCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_rating')
  double? get averageRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_fetched_at')
  String? get lastFetchedAt => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Serializes this SourceSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SourceSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SourceSummaryCopyWith<SourceSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SourceSummaryCopyWith<$Res> {
  factory $SourceSummaryCopyWith(
          SourceSummary value, $Res Function(SourceSummary) then) =
      _$SourceSummaryCopyWithImpl<$Res, SourceSummary>;
  @useResult
  $Res call(
      {String source,
      @JsonKey(name: 'review_count') int reviewCount,
      @JsonKey(name: 'average_rating') double? averageRating,
      @JsonKey(name: 'last_fetched_at') String? lastFetchedAt,
      String? error});
}

/// @nodoc
class _$SourceSummaryCopyWithImpl<$Res, $Val extends SourceSummary>
    implements $SourceSummaryCopyWith<$Res> {
  _$SourceSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SourceSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? reviewCount = null,
    Object? averageRating = freezed,
    Object? lastFetchedAt = freezed,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      reviewCount: null == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      averageRating: freezed == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double?,
      lastFetchedAt: freezed == lastFetchedAt
          ? _value.lastFetchedAt
          : lastFetchedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SourceSummaryImplCopyWith<$Res>
    implements $SourceSummaryCopyWith<$Res> {
  factory _$$SourceSummaryImplCopyWith(
          _$SourceSummaryImpl value, $Res Function(_$SourceSummaryImpl) then) =
      __$$SourceSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String source,
      @JsonKey(name: 'review_count') int reviewCount,
      @JsonKey(name: 'average_rating') double? averageRating,
      @JsonKey(name: 'last_fetched_at') String? lastFetchedAt,
      String? error});
}

/// @nodoc
class __$$SourceSummaryImplCopyWithImpl<$Res>
    extends _$SourceSummaryCopyWithImpl<$Res, _$SourceSummaryImpl>
    implements _$$SourceSummaryImplCopyWith<$Res> {
  __$$SourceSummaryImplCopyWithImpl(
      _$SourceSummaryImpl _value, $Res Function(_$SourceSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of SourceSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? reviewCount = null,
    Object? averageRating = freezed,
    Object? lastFetchedAt = freezed,
    Object? error = freezed,
  }) {
    return _then(_$SourceSummaryImpl(
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      reviewCount: null == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      averageRating: freezed == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double?,
      lastFetchedAt: freezed == lastFetchedAt
          ? _value.lastFetchedAt
          : lastFetchedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SourceSummaryImpl
    with DiagnosticableTreeMixin
    implements _SourceSummary {
  const _$SourceSummaryImpl(
      {required this.source,
      @JsonKey(name: 'review_count') this.reviewCount = 0,
      @JsonKey(name: 'average_rating') this.averageRating,
      @JsonKey(name: 'last_fetched_at') this.lastFetchedAt,
      this.error});

  factory _$SourceSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$SourceSummaryImplFromJson(json);

  /// `google` | `yandex` | `2gis`
  @override
  final String source;
  @override
  @JsonKey(name: 'review_count')
  final int reviewCount;
  @override
  @JsonKey(name: 'average_rating')
  final double? averageRating;
  @override
  @JsonKey(name: 'last_fetched_at')
  final String? lastFetchedAt;
  @override
  final String? error;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SourceSummary(source: $source, reviewCount: $reviewCount, averageRating: $averageRating, lastFetchedAt: $lastFetchedAt, error: $error)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SourceSummary'))
      ..add(DiagnosticsProperty('source', source))
      ..add(DiagnosticsProperty('reviewCount', reviewCount))
      ..add(DiagnosticsProperty('averageRating', averageRating))
      ..add(DiagnosticsProperty('lastFetchedAt', lastFetchedAt))
      ..add(DiagnosticsProperty('error', error));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SourceSummaryImpl &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.lastFetchedAt, lastFetchedAt) ||
                other.lastFetchedAt == lastFetchedAt) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, source, reviewCount, averageRating, lastFetchedAt, error);

  /// Create a copy of SourceSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SourceSummaryImplCopyWith<_$SourceSummaryImpl> get copyWith =>
      __$$SourceSummaryImplCopyWithImpl<_$SourceSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SourceSummaryImplToJson(
      this,
    );
  }
}

abstract class _SourceSummary implements SourceSummary {
  const factory _SourceSummary(
      {required final String source,
      @JsonKey(name: 'review_count') final int reviewCount,
      @JsonKey(name: 'average_rating') final double? averageRating,
      @JsonKey(name: 'last_fetched_at') final String? lastFetchedAt,
      final String? error}) = _$SourceSummaryImpl;

  factory _SourceSummary.fromJson(Map<String, dynamic> json) =
      _$SourceSummaryImpl.fromJson;

  /// `google` | `yandex` | `2gis`
  @override
  String get source;
  @override
  @JsonKey(name: 'review_count')
  int get reviewCount;
  @override
  @JsonKey(name: 'average_rating')
  double? get averageRating;
  @override
  @JsonKey(name: 'last_fetched_at')
  String? get lastFetchedAt;
  @override
  String? get error;

  /// Create a copy of SourceSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SourceSummaryImplCopyWith<_$SourceSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExternalReview _$ExternalReviewFromJson(Map<String, dynamic> json) {
  return _ExternalReview.fromJson(json);
}

/// @nodoc
mixin _$ExternalReview {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'post_id')
  String get postId => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  @JsonKey(name: 'external_id')
  String get externalId => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_name')
  String get authorName => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_avatar_url')
  String? get authorAvatarUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_profile_url')
  String? get authorProfileUrl => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;
  String? get text => throw _privateConstructorUsedError;
  String? get language => throw _privateConstructorUsedError;
  @JsonKey(name: 'posted_at')
  String? get postedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'helpful_count')
  int get helpfulCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'fetched_at')
  String get fetchedAt => throw _privateConstructorUsedError;

  /// Serializes this ExternalReview to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExternalReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExternalReviewCopyWith<ExternalReview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExternalReviewCopyWith<$Res> {
  factory $ExternalReviewCopyWith(
          ExternalReview value, $Res Function(ExternalReview) then) =
      _$ExternalReviewCopyWithImpl<$Res, ExternalReview>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'post_id') String postId,
      String source,
      @JsonKey(name: 'external_id') String externalId,
      @JsonKey(name: 'author_name') String authorName,
      @JsonKey(name: 'author_avatar_url') String? authorAvatarUrl,
      @JsonKey(name: 'author_profile_url') String? authorProfileUrl,
      double? rating,
      String? text,
      String? language,
      @JsonKey(name: 'posted_at') String? postedAt,
      @JsonKey(name: 'helpful_count') int helpfulCount,
      @JsonKey(name: 'fetched_at') String fetchedAt});
}

/// @nodoc
class _$ExternalReviewCopyWithImpl<$Res, $Val extends ExternalReview>
    implements $ExternalReviewCopyWith<$Res> {
  _$ExternalReviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExternalReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? postId = null,
    Object? source = null,
    Object? externalId = null,
    Object? authorName = null,
    Object? authorAvatarUrl = freezed,
    Object? authorProfileUrl = freezed,
    Object? rating = freezed,
    Object? text = freezed,
    Object? language = freezed,
    Object? postedAt = freezed,
    Object? helpfulCount = null,
    Object? fetchedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      postId: null == postId
          ? _value.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      externalId: null == externalId
          ? _value.externalId
          : externalId // ignore: cast_nullable_to_non_nullable
              as String,
      authorName: null == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String,
      authorAvatarUrl: freezed == authorAvatarUrl
          ? _value.authorAvatarUrl
          : authorAvatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      authorProfileUrl: freezed == authorProfileUrl
          ? _value.authorProfileUrl
          : authorProfileUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      postedAt: freezed == postedAt
          ? _value.postedAt
          : postedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      helpfulCount: null == helpfulCount
          ? _value.helpfulCount
          : helpfulCount // ignore: cast_nullable_to_non_nullable
              as int,
      fetchedAt: null == fetchedAt
          ? _value.fetchedAt
          : fetchedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExternalReviewImplCopyWith<$Res>
    implements $ExternalReviewCopyWith<$Res> {
  factory _$$ExternalReviewImplCopyWith(_$ExternalReviewImpl value,
          $Res Function(_$ExternalReviewImpl) then) =
      __$$ExternalReviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'post_id') String postId,
      String source,
      @JsonKey(name: 'external_id') String externalId,
      @JsonKey(name: 'author_name') String authorName,
      @JsonKey(name: 'author_avatar_url') String? authorAvatarUrl,
      @JsonKey(name: 'author_profile_url') String? authorProfileUrl,
      double? rating,
      String? text,
      String? language,
      @JsonKey(name: 'posted_at') String? postedAt,
      @JsonKey(name: 'helpful_count') int helpfulCount,
      @JsonKey(name: 'fetched_at') String fetchedAt});
}

/// @nodoc
class __$$ExternalReviewImplCopyWithImpl<$Res>
    extends _$ExternalReviewCopyWithImpl<$Res, _$ExternalReviewImpl>
    implements _$$ExternalReviewImplCopyWith<$Res> {
  __$$ExternalReviewImplCopyWithImpl(
      _$ExternalReviewImpl _value, $Res Function(_$ExternalReviewImpl) _then)
      : super(_value, _then);

  /// Create a copy of ExternalReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? postId = null,
    Object? source = null,
    Object? externalId = null,
    Object? authorName = null,
    Object? authorAvatarUrl = freezed,
    Object? authorProfileUrl = freezed,
    Object? rating = freezed,
    Object? text = freezed,
    Object? language = freezed,
    Object? postedAt = freezed,
    Object? helpfulCount = null,
    Object? fetchedAt = null,
  }) {
    return _then(_$ExternalReviewImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      postId: null == postId
          ? _value.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      externalId: null == externalId
          ? _value.externalId
          : externalId // ignore: cast_nullable_to_non_nullable
              as String,
      authorName: null == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String,
      authorAvatarUrl: freezed == authorAvatarUrl
          ? _value.authorAvatarUrl
          : authorAvatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      authorProfileUrl: freezed == authorProfileUrl
          ? _value.authorProfileUrl
          : authorProfileUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      postedAt: freezed == postedAt
          ? _value.postedAt
          : postedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      helpfulCount: null == helpfulCount
          ? _value.helpfulCount
          : helpfulCount // ignore: cast_nullable_to_non_nullable
              as int,
      fetchedAt: null == fetchedAt
          ? _value.fetchedAt
          : fetchedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExternalReviewImpl
    with DiagnosticableTreeMixin
    implements _ExternalReview {
  const _$ExternalReviewImpl(
      {required this.id,
      @JsonKey(name: 'post_id') required this.postId,
      required this.source,
      @JsonKey(name: 'external_id') required this.externalId,
      @JsonKey(name: 'author_name') required this.authorName,
      @JsonKey(name: 'author_avatar_url') this.authorAvatarUrl,
      @JsonKey(name: 'author_profile_url') this.authorProfileUrl,
      this.rating,
      this.text,
      this.language,
      @JsonKey(name: 'posted_at') this.postedAt,
      @JsonKey(name: 'helpful_count') this.helpfulCount = 0,
      @JsonKey(name: 'fetched_at') required this.fetchedAt});

  factory _$ExternalReviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExternalReviewImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'post_id')
  final String postId;
  @override
  final String source;
  @override
  @JsonKey(name: 'external_id')
  final String externalId;
  @override
  @JsonKey(name: 'author_name')
  final String authorName;
  @override
  @JsonKey(name: 'author_avatar_url')
  final String? authorAvatarUrl;
  @override
  @JsonKey(name: 'author_profile_url')
  final String? authorProfileUrl;
  @override
  final double? rating;
  @override
  final String? text;
  @override
  final String? language;
  @override
  @JsonKey(name: 'posted_at')
  final String? postedAt;
  @override
  @JsonKey(name: 'helpful_count')
  final int helpfulCount;
  @override
  @JsonKey(name: 'fetched_at')
  final String fetchedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ExternalReview(id: $id, postId: $postId, source: $source, externalId: $externalId, authorName: $authorName, authorAvatarUrl: $authorAvatarUrl, authorProfileUrl: $authorProfileUrl, rating: $rating, text: $text, language: $language, postedAt: $postedAt, helpfulCount: $helpfulCount, fetchedAt: $fetchedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ExternalReview'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('postId', postId))
      ..add(DiagnosticsProperty('source', source))
      ..add(DiagnosticsProperty('externalId', externalId))
      ..add(DiagnosticsProperty('authorName', authorName))
      ..add(DiagnosticsProperty('authorAvatarUrl', authorAvatarUrl))
      ..add(DiagnosticsProperty('authorProfileUrl', authorProfileUrl))
      ..add(DiagnosticsProperty('rating', rating))
      ..add(DiagnosticsProperty('text', text))
      ..add(DiagnosticsProperty('language', language))
      ..add(DiagnosticsProperty('postedAt', postedAt))
      ..add(DiagnosticsProperty('helpfulCount', helpfulCount))
      ..add(DiagnosticsProperty('fetchedAt', fetchedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExternalReviewImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.externalId, externalId) ||
                other.externalId == externalId) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.authorAvatarUrl, authorAvatarUrl) ||
                other.authorAvatarUrl == authorAvatarUrl) &&
            (identical(other.authorProfileUrl, authorProfileUrl) ||
                other.authorProfileUrl == authorProfileUrl) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.postedAt, postedAt) ||
                other.postedAt == postedAt) &&
            (identical(other.helpfulCount, helpfulCount) ||
                other.helpfulCount == helpfulCount) &&
            (identical(other.fetchedAt, fetchedAt) ||
                other.fetchedAt == fetchedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      postId,
      source,
      externalId,
      authorName,
      authorAvatarUrl,
      authorProfileUrl,
      rating,
      text,
      language,
      postedAt,
      helpfulCount,
      fetchedAt);

  /// Create a copy of ExternalReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExternalReviewImplCopyWith<_$ExternalReviewImpl> get copyWith =>
      __$$ExternalReviewImplCopyWithImpl<_$ExternalReviewImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExternalReviewImplToJson(
      this,
    );
  }
}

abstract class _ExternalReview implements ExternalReview {
  const factory _ExternalReview(
          {required final String id,
          @JsonKey(name: 'post_id') required final String postId,
          required final String source,
          @JsonKey(name: 'external_id') required final String externalId,
          @JsonKey(name: 'author_name') required final String authorName,
          @JsonKey(name: 'author_avatar_url') final String? authorAvatarUrl,
          @JsonKey(name: 'author_profile_url') final String? authorProfileUrl,
          final double? rating,
          final String? text,
          final String? language,
          @JsonKey(name: 'posted_at') final String? postedAt,
          @JsonKey(name: 'helpful_count') final int helpfulCount,
          @JsonKey(name: 'fetched_at') required final String fetchedAt}) =
      _$ExternalReviewImpl;

  factory _ExternalReview.fromJson(Map<String, dynamic> json) =
      _$ExternalReviewImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'post_id')
  String get postId;
  @override
  String get source;
  @override
  @JsonKey(name: 'external_id')
  String get externalId;
  @override
  @JsonKey(name: 'author_name')
  String get authorName;
  @override
  @JsonKey(name: 'author_avatar_url')
  String? get authorAvatarUrl;
  @override
  @JsonKey(name: 'author_profile_url')
  String? get authorProfileUrl;
  @override
  double? get rating;
  @override
  String? get text;
  @override
  String? get language;
  @override
  @JsonKey(name: 'posted_at')
  String? get postedAt;
  @override
  @JsonKey(name: 'helpful_count')
  int get helpfulCount;
  @override
  @JsonKey(name: 'fetched_at')
  String get fetchedAt;

  /// Create a copy of ExternalReview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExternalReviewImplCopyWith<_$ExternalReviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
