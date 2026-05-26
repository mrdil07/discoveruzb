// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'external_review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExternalReviewsResponseImpl _$$ExternalReviewsResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ExternalReviewsResponseImpl(
      postId: json['post_id'] as String,
      summaries: (json['summaries'] as List<dynamic>?)
              ?.map((e) => SourceSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((e) => ExternalReview.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ExternalReviewsResponseImplToJson(
        _$ExternalReviewsResponseImpl instance) =>
    <String, dynamic>{
      'post_id': instance.postId,
      'summaries': instance.summaries,
      'reviews': instance.reviews,
    };

_$SourceSummaryImpl _$$SourceSummaryImplFromJson(Map<String, dynamic> json) =>
    _$SourceSummaryImpl(
      source: json['source'] as String,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      lastFetchedAt: json['last_fetched_at'] as String?,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$SourceSummaryImplToJson(_$SourceSummaryImpl instance) =>
    <String, dynamic>{
      'source': instance.source,
      'review_count': instance.reviewCount,
      'average_rating': instance.averageRating,
      'last_fetched_at': instance.lastFetchedAt,
      'error': instance.error,
    };

_$ExternalReviewImpl _$$ExternalReviewImplFromJson(Map<String, dynamic> json) =>
    _$ExternalReviewImpl(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      source: json['source'] as String,
      externalId: json['external_id'] as String,
      authorName: json['author_name'] as String,
      authorAvatarUrl: json['author_avatar_url'] as String?,
      authorProfileUrl: json['author_profile_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      text: json['text'] as String?,
      language: json['language'] as String?,
      postedAt: json['posted_at'] as String?,
      helpfulCount: (json['helpful_count'] as num?)?.toInt() ?? 0,
      fetchedAt: json['fetched_at'] as String,
    );

Map<String, dynamic> _$$ExternalReviewImplToJson(
        _$ExternalReviewImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'post_id': instance.postId,
      'source': instance.source,
      'external_id': instance.externalId,
      'author_name': instance.authorName,
      'author_avatar_url': instance.authorAvatarUrl,
      'author_profile_url': instance.authorProfileUrl,
      'rating': instance.rating,
      'text': instance.text,
      'language': instance.language,
      'posted_at': instance.postedAt,
      'helpful_count': instance.helpfulCount,
      'fetched_at': instance.fetchedAt,
    };
