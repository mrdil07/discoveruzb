import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/external_review.dart';
import '../service/data_service.dart';

/// Bitta post uchun tashqi xarita reviewlarini boshqaradi.
///
/// Holatlar:
///   - `isLoading` — backend chaqirilmoqda.
///   - `error` — tarmoq xatosi (per-source error'lar `summaries.error`'da).
///   - `response` — backend javobi (summaries + reviews).
///   - `selectedSource` — tablar uchun joriy tanlangan source
///     (`google` | `yandex` | `2gis`).
class ExternalReviewsVM extends ChangeNotifier {
  ExternalReviewsVM();

  ExternalReviewsResponse? _response;
  ExternalReviewsResponse? get response => _response;

  String _selectedSource = ReviewSourceIds.google;
  String get selectedSource => _selectedSource;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// `_lastPostId` — bir xil postni qayta yuklamaslik uchun.
  String? _lastPostId;

  /// Postga tegishli sources'larni ro'yxati qaytaradi
  /// (`Place.googlePlaceId` va h.k. bo'sh emasligi tekshiriladi).
  List<SourceSummary> get summariesNonEmpty {
    final all = _response?.summaries ?? const <SourceSummary>[];
    // `error == "place_id sozlanmagan"` bo'lganlarni yashirmiz
    return all.where((s) {
      final err = s.error ?? '';
      return !err.contains('place_id');
    }).toList();
  }

  /// Joriy source uchun reviewlar.
  List<ExternalReview> get reviewsForSelected {
    final reviews = _response?.reviews ?? const <ExternalReview>[];
    return reviews.where((r) => r.source == _selectedSource).toList();
  }

  /// Joriy source uchun summary.
  SourceSummary? get summaryForSelected {
    final summaries = _response?.summaries ?? const [];
    for (final s in summaries) {
      if (s.source == _selectedSource) return s;
    }
    return null;
  }

  void selectSource(String source) {
    if (_selectedSource == source) return;
    _selectedSource = source;
    notifyListeners();
  }

  /// Post o'zgargandagi initial load yoki pull-to-refresh.
  Future<void> load(String postId, {bool force = false}) async {
    if (_lastPostId == postId && _response != null && !force) {
      // Cache hit (mahalliy) — qayta yuklamaymiz
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _response = await DataService.loadExternalReviews(postId);
      _lastPostId = postId;
      // Birinchi mavjud (xatosiz) source'ni default qilib tanlash
      _autoSelectFirstAvailable();
    } on DioException catch (e) {
      _error = _extractError(e);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Admin/moderator force refresh.
  Future<void> refresh(String postId, {List<String>? sources}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _response = await DataService.refreshExternalReviews(
        postId,
        sources: sources,
      );
      _lastPostId = postId;
      _autoSelectFirstAvailable();
    } on DioException catch (e) {
      _error = _extractError(e);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _autoSelectFirstAvailable() {
    final available = summariesNonEmpty;
    if (available.isEmpty) return;
    // Agar joriy source mavjud bo'lmasa, birinchisiga o'tamiz.
    if (!available.any((s) => s.source == _selectedSource)) {
      _selectedSource = available.first.source;
    }
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String) return detail;
    }
    return 'Tarmoq xatosi: ${e.message ?? 'noma\'lum'}';
  }

  /// Yangi postga o'tilganda holatni tozalash.
  void reset() {
    _response = null;
    _lastPostId = null;
    _selectedSource = ReviewSourceIds.google;
    _error = null;
    _isLoading = false;
  }
}
