import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../models/comments.dart';
import '../models/places_model.dart';
import '../service/api_response.dart';
import '../service/data_service.dart';
import 'home_vm.dart';

class CommentVM extends ChangeNotifier {
  ApiResponse _apiResponse = ApiResponse.initial("loading");
  ApiResponse get response {
    return _apiResponse;
  }

  final TextEditingController commentTextController = TextEditingController();

  String comment = '';

  Future apiComment(Place place, Comments comments) async {
    place.comments.add(comments.toJson());
    print(place.comments.length);
    notifyListeners();
    var res = await DataService.putComment(place);
    notifyListeners();
  }

  Future apiDeleteComment(Place place, Comments comments) async {
    place.comments.remove(comments);
    notifyListeners();
    await DataService.putComment(place);
    notifyListeners();
  }

  Future sendComment(Place place, BuildContext context) async {
    final providerUser = Provider.of<HomeViewModel>(context, listen: false);
    await apiComment(
      place,
      Comments(
        users: {
          "fullname": providerUser.fullName,
          "phoneNumber": providerUser.phone,
          "imgUrl": providerUser.imgUrl,
        },
        comment: comment,
        dateTime: DateTime.now().toString(),
      ),
    );
    commentTextController.text = '';
    comment = "";
    getComments(place.id.toString());
    notifyListeners();
  }

  Future getComments(String id) async {
    _apiResponse = ApiResponse.initial('loading');
    notifyListeners();
    var res = await DataService.loadComments(id);
    if (res == "Error") {
      _apiResponse = ApiResponse.error(res);
      notifyListeners();
    } else {
      if ((res as List<Comments>).isEmpty) {
        _apiResponse = ApiResponse.haveNotShops("Kommentlar mavjud emas!");
        notifyListeners();
      } else {
        _apiResponse = ApiResponse.haveShops(res);
        notifyListeners();
      }
    }
  }
}
