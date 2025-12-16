import 'package:flutter/material.dart';

import '../models/comments.dart';
import '../models/places_model.dart';
import '../service/api_response.dart';
import '../service/data_service.dart';

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
    _apiResponse = ApiResponse.loading('Sharh qo\'shilmoqda...');
    notifyListeners();
    try {
      final newComment = Comments(
        users: {
          "fullname": fullname,
          "phoneNumber": phoneNumber ?? '',
          "imgUrl": imgUrl,
        },
        comment: _comment,
        dateTime: DateTime.now().millisecondsSinceEpoch,
      );
      List<String> updatedCommentsList = List.from(place.comments); // Create a mutable copy
      updatedCommentsList.add(newComment.toJson().toString()); // Add the new comment as a string representation of its JSON

      Place updatedPlace = place.copyWith(comments: updatedCommentsList);

      await DataService.putComment(updatedPlace);
      commentTextController.clear();
      _comment = '';
      _apiResponse = ApiResponse.completed('Sharh muvaffaqiyatli qo\'shildi!');
      await fetchComments(place.id.toString()); // Refresh comments
    } catch (e) {
      _apiResponse = ApiResponse.error('Sharh qo\'shishda xatolik: ${e.toString()}');
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteCommentFromPlace(Place place, Comments commentToDelete) async {
    _apiResponse = ApiResponse.loading('Sharh o\'chirilmoqda...');
    notifyListeners();
    try {
      List<String> updatedCommentsList = List.from(place.comments); // Create a mutable copy
      updatedCommentsList.removeWhere((element) => Comments.fromJson(element as Map<String, dynamic>) == commentToDelete);

      Place updatedPlace = place.copyWith(comments: updatedCommentsList);

      await DataService.putComment(updatedPlace);
      _apiResponse = ApiResponse.completed('Sharh muvaffaqiyatli o\'chirildi!');
      await fetchComments(place.id.toString()); // Refresh comments
    } catch (e) {
      _apiResponse = ApiResponse.error('Sharh o\'chirishda xatolik: ${e.toString()}');
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchComments(String placeId) async {
    _apiResponse = ApiResponse.loading('Sharhlar yuklanmoqda...');
    notifyListeners();
    try {
      final res = await DataService.loadComments(placeId);
      if (res is List) {
        List<Comments> fetchedComments = (res as List)
            .map((e) => Comments.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        if (fetchedComments.isEmpty) {
          _apiResponse = ApiResponse.empty("Sharhlar mavjud emas!");
        } else {
          _apiResponse = ApiResponse.completed(fetchedComments);
        }
      } else {
        _apiResponse = ApiResponse.error('Sharhlarni yuklashda noma\'lum xatolik.');
      }
    } catch (e) {
      _apiResponse = ApiResponse.error('Sharhlarni yuklashda xatolik: ${e.toString()}');
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
