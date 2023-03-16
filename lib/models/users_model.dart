class Users {
  String uid = "";
  String fullname = "";
  String phoneNumber = '';
  String email = "";
  String password = "";
  String imgUrl = '';

  String device_id = "";
  String device_type = "";
  String device_token = "";

  Users({required this.fullname, required this.phoneNumber, this.imgUrl = ''});

  Users.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        fullname = json['fullname'],
        email = json['email'],
        password = json['password'],
        imgUrl = json['imgUrl'],
        device_id = json['device_id'],
        device_type = json['device_type'],
        device_token = json['device_token'],
        phoneNumber = json['phoneNumber'];

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'fullname': fullname,
        'email': email,
        'password': password,
        'imgUrl': imgUrl,
        'device_id': device_id,
        'device_type': device_type,
        'device_token': device_token,
        'phoneNumber': phoneNumber,
      };

  @override
  bool operator ==(other) {
    return (other is Users) && other.uid == uid;
  }
}
