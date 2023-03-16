import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/users_model.dart';

class HiveDB {
  static var box = Hive.box('person');
  static var boxBonus = Hive.box('restore');

  /// store user info

  static void storePerson(Users users) async {
    await box.put('person', users.toJson());
  }

  static Users loadPerson() {
    Users person = Users.fromJson(Map<String, dynamic>.from(box.get('person')));
    return person;
  }

  static void removePerson() {
    box.delete('person');
  }
}
