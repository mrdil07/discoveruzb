class GalleryModel {
  String placeName;
  List<dynamic> images;
  String date;

  GalleryModel(
      {required this.images, required this.date, required this.placeName});

  GalleryModel.fromJson(Map<String, dynamic> json)
      : images = json['images'],
        date = json['date'],
        placeName = json['placeName'];
  Map<String, dynamic> toJson() => {
        "placeName": placeName,
        "images": images,
        "date": date,
      };
}
