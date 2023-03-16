import 'package:flutter/cupertino.dart';

import '../models/places_model.dart';
import '../service/data_service.dart';

class SubCategoryVM extends ChangeNotifier {
  bool isLoading = false;
  List<Place> subCategory = [];

  String? address1 = 'Manzil hududi';

  apiLoadPosts(String subCatName) {
    isLoading = true;
    notifyListeners();
    DataService.loadFeedsNew(subCatName).then((value) => {_resLoadPost(value)});
  }

  _resLoadPost(List<Place> places) {
    subCategory = places;
    isLoading = false;
    notifyListeners();
  }

  apiLoadPostsNew(String subCatName) async {
    isLoading = true;
    notifyListeners();
    await DataService.loadFeedLocation(subCatName, address1!)
        .then((value) => {_resLoadPost(value)});
  }

  var mainController = ScrollController();
  var subController = ScrollController();
  String noData = '';
}
