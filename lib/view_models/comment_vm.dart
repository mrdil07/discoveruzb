import 'package:flutter/material.dart';

import '../models/comments.dart';
import '../models/places_model.dart';
import '../service/api_response.dart';
import '../service/data_service.dart';
import '../service/utils.dart';

class CommentVM extends ChangeNotifier {
  ApiResponse _apiResponse = ApiResponse.initial("loading");
  ApiResponse get response => _apiResponse;

  final TextEditingController commentTextController = TextEditingController();
  String _comment = '';
  String get comment => _comment;
  set comment(String value) {
    _comment = value;
    notifyListeners();
  }

  void updateCommentText(String text) {
    _comment = text;
    notifyListeners();
  }

  Future<void> addCommentToPlace(
    Place place,
    String fullname,
    String? phoneNumber,
    String imgUrl,
  ) async {
    final id = place.id;
    if (id == null) {
      _apiResponse = ApiResponse.error('Post topilmadi');
      notifyListeners();
      return;
    }
    _apiResponse = ApiResponse.loading('Sharh qo\'shilmoqda...');
    notifyListeners();
    try {
      await DataService.addComment(id, _comment);
      commentTextController.clear();
      _comment = '';
      _apiResponse = ApiResponse.completed('Sharh muvaffaqiyatli qo\'shildi!');
      await fetchComments(id);
    } catch (e) {
      _apiResponse = ApiResponse.error(Utils.friendlyError('Sharh qo\'shishda xatolik', e));
    } finally {
      notifyListeners();
    }
  }

  /// Backend RPC: `DELETE /comments/{comment_id}`.
  ///
  /// TODO Sprint 4: backendda comment'ning egasi/admini bo'lish tekshiruvi.
  Future<void> deleteCommentFromPlace(Place place, Comments commentToDelete) async {
    // Hozircha mobile-da comment delete UI yo'q — admin panelda bo'ladi.
    // ViewModel signaturasini saqlab qo'yamiz.
    _apiResponse = ApiResponse.error('Sharh o\'chirish admin panelda mavjud');
    notifyListeners();
  }

  Future<void> fetchComments(String placeId) async {
    _apiResponse = ApiResponse.loading('Sharhlar yuklanmoqda...');
    notifyListeners();
    try {
      final fetchedComments = await DataService.loadComments(placeId);
      if (fetchedComments.isEmpty) {
        _apiResponse = ApiResponse.empty("Sharhlar mavjud emas!");
      } else {
        _apiResponse = ApiResponse.completed(fetchedComments);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(Utils.friendlyError('Sharhlarni yuklashda xatolik', e));
    } finally {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }
}
