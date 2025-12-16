import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discoveruzb/models/comments.dart';
import 'package:discoveruzb/models/gallery_model.dart';
import 'package:discoveruzb/service/pref_service.dart';

import '../models/places_model.dart';
import '../models/users_model.dart';

class DataService {
  static final _firestore = FirebaseFirestore.instance;

  static String folderUsers = 'users';
  static String folderPosts = 'posts';
  static String folderGallery = 'gallery';
  static String folderNews = "news";

  //static String address='hududlar';

  //user related
  static Future storeUser(Users users) async {
    String? uid = (await Prefs.loadUserId());
    if (uid != null) {
      users = users.copyWith(uid: uid); // Update uid using copyWith
    }
    return _firestore
        .collection(folderUsers)
        .doc(users.uid)
        .set(users.toJson());
  }

  static Future storeGallery(GalleryModel gallery) async {
    String galleryId = _firestore.collection(folderGallery).doc().id;
    await _firestore
        .collection(folderGallery)
        .doc(galleryId)
        .set(gallery.toJson());
    return "success";
  }

  static Future updateGallery(List images, index) async {
    var value = await _firestore.collection(folderGallery).get();
    String docId = value.docs[index].id;
    print("docId:$docId");
    await _firestore
        .collection(folderGallery)
        .doc(docId)
        .update({"images": FieldValue.arrayUnion(images)});
    print("qoshimcha qoshildi");
  }

  static Future loadGallery() async {
    List<GalleryModel> gallery = [];
    var value = await _firestore.collection(folderGallery).get();
    for (var result in value.docs) {
      GalleryModel _gallery = GalleryModel.fromJson(result.data());
      gallery.add(_gallery);
    }
    return gallery;
  }

  static Future loadUser() async {
    String? uid = await Prefs.loadUserId();
    var value = await _firestore.collection('users').doc(uid).get();
    Users users = Users.fromJson(value.data()!);
    return users;
  }

  static Future updateUser(Users users) async {
    String? uid = await Prefs.loadUserId();
    return _firestore.collection(folderUsers).doc(uid).update(users.toJson());
  }

  //posts

  static loadFeedsNew(
    String subCategoryName,
  ) async {
    List<Place> posts = [];

    var querySnapshot = await _firestore
        .collection(folderPosts)
        .where('type', isEqualTo: subCategoryName)
        .get();

    for (var result in querySnapshot.docs) {
      Place post = Place.fromJson(result.data());
      posts.add(post);
    }
    return posts;
  }

  static Future<List<Place>> loadFeedLocation(
      String collectionPath, String address) async {
    List<Place> posts = [];

    var querySnapshot = await _firestore
        .collection(folderPosts)
        .where('type', isEqualTo: collectionPath)
        .where('address', isEqualTo: address)
        .get();

    for (var result in querySnapshot.docs) {
      Place post = Place.fromJson(result.data());
      posts.add(post);
    }
    return posts;
  }

  static Future<List<Place>> loadFamousPlace() async {
    List<Place> posts = [];

    var querySnapshot = await _firestore
        .collection(folderPosts)
        .orderBy("likeCount", descending: true)
        .get();

    for (var result in querySnapshot.docs) {
      Place post = Place.fromJson(result.data());

      posts.add(post);
    }
    return posts;
  }

  static Future<List<Place>> loadRecommendPlace() async {
    List<Place> posts = [];
    var querySnapshot = await _firestore
        .collection(folderPosts)
        .where(
          'liked',
          arrayContains: 'ZkjvOrSr6jTKPpuBAkMETo3DjMe2',
        )
        .get();

    for (var result in querySnapshot.docs) {
      Place post = Place.fromJson(result.data());
      posts.insert(0, post);
    }
    return posts;
  }

  static Future<List<Place>> loadPosts() async {
    List<Place> posts = [];

    var querySnapshot = await _firestore
        .collection(folderPosts)
        .where('time',
            isLessThanOrEqualTo: DateTime.now().microsecondsSinceEpoch)
        .get();
    for (var result in querySnapshot.docs) {
      Place post = Place.fromJson(result.data());
      posts.insert(0, post);
    }
    return posts;
  }

  static Future loadComments(String docId) async {
    try {
      var res = await _firestore.collection(folderPosts).doc(docId).get();
      return (res['comments'] as List)
          .map((e) => Comments.fromJson(e))
          .toList();
    } catch (e) {
      return 'Error';
    }
  }

  static Future<List<Place>?> searchPosts(String keyword) async {
    List<Place> places = [];

    var querySnapshot1 = await _firestore
        .collection(folderPosts)
        .orderBy("placeName")
        .startAt([keyword]).endAt([keyword]).get();

    for (var result in querySnapshot1.docs) {
      Place newPlace = Place.fromJson(result.data());
      places.add(newPlace);
    }
    return places;
  }

  ///like post
  static Future<Place> likePost(Place place) async {
    String? uid = await Prefs.loadUserId();

    await _firestore.collection(folderPosts).doc(place.id).set(place.toJson());

    if (uid == place.uid) {
      await _firestore
          .collection(folderUsers)
          .doc(uid)
          .collection(folderPosts)
          .doc(place.id)
          .set(place.toJson());
    }
    return place;
  }

  ///save post
  static Future<Place> savePost(Place place) async {
    String? uid = await Prefs.loadUserId();

    await _firestore.collection(folderPosts).doc(place.id).set(place.toJson());

    if (uid == place.uid) {
      await _firestore
          .collection(folderUsers)
          .doc(uid)
          .collection(folderPosts)
          .doc(place.id)
          .set(place.toJson());
    }
    return place;
  }

  /// put comment
  static Future<Place> putComment(Place place) async {
    try {
      String? uid = await Prefs.loadUserId();
      await _firestore
          .collection(folderPosts)
          .doc(place.id)
          .set(place.toJson());
      var res = await _firestore.collection(folderPosts).doc(place.id).get();
      print("place res: $res");

      if (uid == place.uid) {
        await _firestore
            .collection(folderUsers)
            .doc(uid)
            .collection(folderPosts)
            .doc(place.id)
            .set(place.toJson());
      }
    } catch (e) {
      print("error:$e");
    }
    return place;
  }

  static Future<List<Place>> loadSaved() async {
    List<Place> posts = [];
    String? uid = await Prefs.loadUserId();

    var querySnapshot = await _firestore
        .collection(folderPosts)
        .where('saved', arrayContains: uid)
        .get();
    for (var result in querySnapshot.docs) {
      Place post = Place.fromJson(result.data());
      posts.insert(0, post);
    }
    return posts;
  }

  static Future<List<Place>> loadLiked() async {
    List<Place> posts = [];
    String? uid = await Prefs.loadUserId();

    var querySnapshot = await _firestore
        .collection(folderPosts)
        .where('liked', arrayContains: uid)
        .get();
    for (var result in querySnapshot.docs) {
      Place post = Place.fromJson(result.data());
      posts.insert(0, post);
    }
    return posts;
  }

  static Future<List<Place>> loadNewAdded() async {
    List<Place> posts = [];

    var querySnapshot = await _firestore
        .collection('posts')
        .where('time',
            isLessThanOrEqualTo: DateTime.now().microsecondsSinceEpoch)
        .get();
    for (var result in querySnapshot.docs) {
      Place post = Place.fromJson(result.data());
      posts.insert(0, post);
    }
    return posts;
  }

  static Future<void> removePost(Place place, postId) async {
    Users me = await loadUser();
    await _firestore
        .collection(folderUsers)
        .doc(me.uid)
        .collection(folderPosts)
        .doc(postId)
        .delete();

    await _firestore.collection(folderPosts).doc(postId).delete();
  }
}
