import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'external_review.freezed.dart';
part 'external_review.g.dart';

/// Backend `GET /posts/{id}/external-reviews` javobi.
///
/// Per-source summaries + barcha cache'langan reviewlar.
@freezed
class ExternalReviewsResponse with _$ExternalReviewsResponse {
  const factory ExternalReviewsResponse({
    @JsonKey(name: 'post_id') required String postId,
    @Default([]) List<SourceSummary> summaries,
    @Default([]) List<ExternalReview> reviews,
  }) = _ExternalReviewsResponse;

  factory ExternalReviewsResponse.fromJson(Map<String, dynamic> json) =>
      _$ExternalReviewsResponseFromJson(json);
}

@freezed
class SourceSummary with _$SourceSummary {
  const factory SourceSummary({
    /// `google` | `yandex` | `2gis`
    required String source,
    @JsonKey(name: 'review_count') @Default(0) int reviewCount,
    @JsonKey(name: 'average_rating') double? averageRating,
    @JsonKey(name: 'last_fetched_at') String? lastFetchedAt,
    String? error,
  }) = _SourceSummary;

  factory SourceSummary.fromJson(Map<String, dynamic> json) =>
      _$SourceSummaryFromJson(json);
}

@freezed
class ExternalReview with _$ExternalReview {
  const factory ExternalReview({
    required String id,
    @JsonKey(name: 'post_id') required String postId,
    required String source,
    @JsonKey(name: 'external_id') required String externalId,
    @JsonKey(name: 'author_name') required String authorName,
    @JsonKey(name: 'author_avatar_url') String? authorAvatarUrl,
    @JsonKey(name: 'author_profile_url') String? authorProfileUrl,
    double? rating,
    String? text,
    String? language,
    @JsonKey(name: 'posted_at') String? postedAt,
    @JsonKey(name: 'helpful_count') @Default(0) int helpfulCount,
    @JsonKey(name: 'fetched_at') required String fetchedAt,
  }) = _ExternalReview;

  factory ExternalReview.fromJson(Map<String, dynamic> json) =>
      _$ExternalReviewFromJson(json);
}

extension ExternalReviewX on ExternalReview {
  /// `posted_at`'ni `DateTime` qilib parse qiladi.
  DateTime? get postedAtDate {
    final at = postedAt;
    if (at == null || at.isEmpty) return null;
    return DateTime.tryParse(at);
  }
}

/// Source identifikatorlar (`Place.googlePlaceId` va h.k. bilan ishlatish).
class ReviewSourceIds {
  ReviewSourceIds._();

  static const String google = 'google';
  static const String yandex = 'yandex';
  static const String gis = '2gis';

  static const List<String> all = [google, yandex, gis];
}
