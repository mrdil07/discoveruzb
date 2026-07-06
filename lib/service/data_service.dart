import 'package:flutter/foundation.dart';

import '../models/comments.dart';
import '../models/external_review.dart';
import '../models/gallery_model.dart';
import '../models/places_model.dart';
import '../models/users_model.dart';
import 'api_client.dart';
import 'pref_service.dart';

/// Backend API bilan ishlaydigan repository (`backend/app/api/v1/`,
/// `dio` orqali).
///
/// Endpointlar:
/// - `GET /users/me` — profil
/// - `PATCH /users/me`
/// - `GET /posts/`
/// - `GET /posts/famous`, `/posts/recommend`, `/posts/search`
/// - `GET /posts/me/liked`, `/posts/me/saved`
/// - `POST /posts/{id}/like`, `/save`
/// - `GET /comments/post/{post_id}`
/// - `GET /galleries/me`
class DataService {
  DataService._();

  static final _api = ApiClient.instance;

  // ===== USER =====

  static Future<Users> loadUser() async {
    final response = await _api.dio.get<Map<String, dynamic>>('/users/me');
    return Users.fromJson(response.data!);
  }

  static Future<Users> updateUser(Users user) async {
    final response = await _api.dio.patch<Map<String, dynamic>>(
      '/users/me',
      data: {
        'fullname': user.fullname,
        'email': user.email.isEmpty ? null : user.email,
        'language': user.language,
      }..removeWhere((_, v) => v == null),
    );
    return Users.fromJson(response.data!);
  }

  // ===== POSTS =====

  static Future<List<Place>> loadFamousPlace({int limit = 20}) async {
    final response = await _api.dio.get<List<dynamic>>(
      '/posts/famous',
      queryParameters: {'limit': limit},
    );
    return _parseDirectList(response.data);
  }

  static Future<List<Place>> loadRecommendPlace({int limit = 20}) async {
    final response = await _api.dio.get<List<dynamic>>(
      '/posts/recommend',
      queryParameters: {'limit': limit},
    );
    return _parseDirectList(response.data);
  }

  static Future<List<Place>> loadNewAdded({int page = 1, int size = 20}) async {
    final response = await _api.dio.get<Map<String, dynamic>>(
      '/posts',
      queryParameters: {
        'page': page,
        'size': size,
        'sort': 'time',
        'order': 'desc',
      },
    );
    return _parseList(response.data!);
  }

  static Future<List<Place>> loadFeedsByType(
    String type, {
    int page = 1,
    int size = 20,
  }) async {
    final response = await _api.dio.get<Map<String, dynamic>>(
      '/posts',
      queryParameters: {
        'type': type,
        'page': page,
        'size': size,
      },
    );
    return _parseList(response.data!);
  }

  static Future<List<Place>?> searchPosts(String keyword) async {
    if (keyword.trim().isEmpty) return [];
    final response = await _api.dio.get<List<dynamic>>(
      '/posts/search',
      queryParameters: {'q': keyword},
    );
    return _parseDirectList(response.data);
  }

  static Future<Place> toggleLike(String postId) async {
    final response = await _api.dio.post<Map<String, dynamic>>(
      '/posts/$postId/like',
    );
    final userId = await Prefs.loadUserId() ?? '';
    return Place.fromJson(_postToModelJson(response.data!, userId));
  }

  static Future<Place> toggleSave(String postId) async {
    final response = await _api.dio.post<Map<String, dynamic>>(
      '/posts/$postId/save',
    );
    final userId = await Prefs.loadUserId() ?? '';
    return Place.fromJson(_postToModelJson(response.data!, userId));
  }

  static Future<List<Place>> loadLiked() async {
    final response = await _api.dio.get<List<dynamic>>(
      '/posts/me/liked',
    );
    return _parseDirectList(response.data);
  }

  static Future<List<Place>> loadSaved() async {
    final response = await _api.dio.get<List<dynamic>>(
      '/posts/me/saved',
    );
    return _parseDirectList(response.data);
  }

  static Future<List<Place>> loadMyPosts() async {
    // Admin va oddiy user uchun bir xil endpoint — backend `role` bo'yicha
    // farqlamaydi (mobile'da ishlatilmaydi). Admin bu ish admin panelida.
    return loadLiked();
  }

  static Future<void> removePost(String postId) async {
    await _api.dio.delete('/posts/$postId');
  }

  // ===== COMMENTS =====

  static Future<List<Comments>> loadComments(String postId) async {
    final response = await _api.dio.get<List<dynamic>>(
      '/comments/post/$postId',
    );
    return (response.data ?? const [])
        .map((e) => Comments.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Comments> addComment(String postId, String body) async {
    final response = await _api.dio.post<Map<String, dynamic>>(
      '/comments/post/$postId',
      data: {'body': body},
    );
    return Comments.fromJson(response.data!);
  }

  // ===== EXTERNAL REVIEWS (Sprint 9) =====

  /// Backend `GET /posts/{id}/external-reviews` — cache-first.
  ///
  /// Google Maps, Yandex Maps va 2GIS reviewlarini bitta javobda
  /// qaytaradi. Backend o'zi cache TTL'ni hisoblaydi.
  static Future<ExternalReviewsResponse> loadExternalReviews(
    String postId,
  ) async {
    final response = await _api.dio.get<Map<String, dynamic>>(
      '/posts/$postId/external-reviews',
    );
    return ExternalReviewsResponse.fromJson(response.data!);
  }

  /// (Admin/moderator) Cache'ni ignore qilib qayta yig'ish.
  ///
  /// `sources` `null` bo'lsa — 3 ta source ham.
  static Future<ExternalReviewsResponse> refreshExternalReviews(
    String postId, {
    List<String>? sources,
  }) async {
    await _api.dio.post<Map<String, dynamic>>(
      '/posts/$postId/external-reviews/refresh',
      data: {
        if (sources != null) 'sources': sources,
      },
    );
    // Refresh javobida faqat `summaries` keladi; to'liq data uchun GET
    // qayta chaqiramiz (server cache'ga yangi yozgan).
    return loadExternalReviews(postId);
  }

  // ===== GALLERY =====

  static Future<List<GalleryModel>> loadGallery() async {
    final response = await _api.dio.get<List<dynamic>>('/galleries/me');
    return (response.data ?? const [])
        .map((e) => GalleryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<GalleryModel> storeGallery(GalleryModel gallery) async {
    final response = await _api.dio.post<Map<String, dynamic>>(
      '/galleries',
      data: gallery.toJson()..remove('id'),
    );
    return GalleryModel.fromJson(response.data!);
  }

  static Future<void> updateGallery(
    String galleryId,
    List<String> images,
  ) async {
    await _api.dio.post(
      '/galleries/$galleryId/images',
      data: {'images': images},
    );
  }

  // ===== Helpers =====

  /// Paginated response (`{items, total, page, ...}`) uchun.
  static Future<List<Place>> _parseList(Map<String, dynamic> page) {
    final items = page['items'] as List<dynamic>? ?? const [];
    return _mapPosts(items);
  }

  /// To'g'ridan-to'g'ri list qaytadigan endpointlar uchun
  /// (`/posts/famous`, `/posts/recommend`, `/posts/search`,
  /// `/posts/me/liked`, `/posts/me/saved`).
  static Future<List<Place>> _parseDirectList(List<dynamic>? data) {
    if (data == null) return Future.value(const []);
    return _mapPosts(data);
  }

  static Future<List<Place>> _mapPosts(List<dynamic> items) async {
    final userId = await Prefs.loadUserId() ?? '';
    return items
        .map((e) =>
            Place.fromJson(_postToModelJson(e as Map<String, dynamic>, userId)))
        .toList();
  }

  /// Backend post JSON (snake_case) → `Place` model JSON.
  ///
  /// `Place` Freezed modeli eski camelCase maydon nomlarini ishlatadi;
  /// model qayta generatsiya qilinmasdan shu adapter orqali moslanadi.
  /// Backend `is_liked`/`is_saved` bool qaytaradi — UI esa
  /// `place.liked.contains(userId)` tekshiradi, shuning uchun bool
  /// joriy user ID'li ro'yxatga aylantiriladi.
  static Map<String, dynamic> _postToModelJson(
    Map<String, dynamic> p,
    String userId,
  ) {
    final author = p['author'] as Map<String, dynamic>?;
    final created = DateTime.tryParse(p['created_at'] as String? ?? '');
    return {
      'uid': p['author_id'],
      'placeImage': p['images'] ?? const <String>[],
      'userImage': author?['img_url'],
      'placeInfo': p['place_info'] ?? '',
      'placeName': p['place_name'] ?? '',
      'address': p['address'] ?? '',
      'id': p['id'],
      'type': p['type'] ?? '',
      'source': p['source'] ?? '',
      'time': created?.microsecondsSinceEpoch ?? 0,
      'phoneNumber': p['phone_numbers'] ?? const <String>[],
      'price': p['price'] ?? '',
      'likeCount': p['like_count'] ?? 0,
      'liked': p['is_liked'] == true && userId.isNotEmpty
          ? [userId]
          : const <String>[],
      'saved': p['is_saved'] == true && userId.isNotEmpty
          ? [userId]
          : const <String>[],
      'lat': p['lat'] ?? 0.0,
      'lon': p['lon'] ?? 0.0,
      'google_place_id': p['google_place_id'],
      'yandex_place_id': p['yandex_place_id'],
      'gis_place_id': p['gis_place_id'],
    };
  }
}

/// Hozirda backend tayyor bo'lguncha bo'sh fallback'lar — UI yiqilmasligi
/// uchun. Sprint 5 tugagandan keyin olib tashlanadi.
@visibleForTesting
class StubDataService {
  static Future<List<Place>> empty() async => const [];
}
