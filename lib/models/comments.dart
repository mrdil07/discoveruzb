class Comments {
  dynamic users;
  dynamic dateTime;
  dynamic comment;
  Comments(
      {required this.users, required this.comment, required this.dateTime});

  Comments.fromJson(Map<String, dynamic> json)
      : users = json['users'],
        dateTime = json['dateTime'],
        comment = json['comment'];
  Map<String, dynamic> toJson() => {
        'users': users,
        'dateTime': dateTime,
        'comment': comment,
      };
}
