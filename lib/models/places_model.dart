class Place {
  String? uid;
  List<dynamic> placeImage;
  String? userImage;
  String placeInfo;
  String placeName;
  String address;
  String? id;
  String type;
  String source;
  int time;
  List<dynamic> phoneNumber;
  String price;
  List<dynamic> comments = [];
  List liked = [];
  List saved = [];
  int likeCount = 0;
  double lat;
  double lon;

  Place(
      {required this.placeImage,
      required this.price,
      required this.placeInfo,
      required this.address,
      required this.placeName,
      required this.type,
      required this.source,
      required this.lat,
      required this.lon,
      required this.time,
      required this.phoneNumber,
      required this.comments});

  Place.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        placeImage = json['placeImage'],
        userImage = json['userImage'],
        placeInfo = json['placeInfo'],
        placeName = json['placeName'],
        id = json['id'],
        address = json['address'],
        type = json['type'],
        liked = json['liked'],
        saved = json['saved'],
        likeCount = json['likeCount'],
        lat = json['lat'],
        lon = json['longlat'],
        time = json['time'],
        phoneNumber = json['phoneNumber'],
        price = json['price'],
        comments = json['comments'],
        source = json['source'];

  Map<String, dynamic> toJson() => {
        'placeImage': placeImage,
        'userImage': userImage,
        'placeInfo': placeInfo,
        'placeName': placeName,
        'address': address,
        'uid': uid,
        'id': id,
        'type': type,
        'liked': liked,
        'saved': saved,
        'likeCount': likeCount,
        'source': source,
        'lat': lat,
        'longlat': lon,
        'time': time,
        'phoneNumber': phoneNumber,
        'price': price,
        'comments': comments,
      };
}
