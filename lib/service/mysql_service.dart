import 'package:mysql1/mysql1.dart';

class MySqlService {
  static final settings = ConnectionSettings(
    host: 'mirxojiddin.uz',
    port: 3306,
    user: 'mirxojid_mko',
    password: '3121123um',
    db: 'mirxojid_mko-ttp-db',
  );

  static Future getData() async {
    var conn = await MySqlConnection.connect(settings);
    var results = await conn.query('select * from discover_botuser');
    print("resulats:$results");
  }
}
