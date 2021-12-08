import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DB {
  // ignore: avoid_init_to_null
  static var _db = null;

  static Future<void> close() async {
    if (_db.isOpen) {
      await _db.close();
    }
  }

  static Future<void> createTableContacts() async {
    String _sql = '''
    CREATE TABLE Contacts(
      id VARCHAR(255), 
      name VARCHAR(255), 
      thumbnail1 BLOB,
      thumbnail2 BLOB,
      first_address VARCHAR(255), 
      second_address VARCHAR(255), 
      third_address VARCHAR(255), 
      first_email VARCHAR(255), 
      second_email VARCHAR(255), 
      third_email VARCHAR(255), 
      first_number VARCHAR(255), 
      second_number VARCHAR(255), 
      third_number VARCHAR(255), 
      first_coordinates VARCHAR(255), 
      second_coordinates VARCHAR(255), 
      third_coordinates VARCHAR(255),
      control BOOLEAN
    );
    ''';
    await _db.execute(_sql);
  }

  static Future<void> createTableSettings() async {
    String _sql = '''
    CREATE TABLE Settings(
      map_type VARCHAR(255), 
      location_marker_color VARCHAR(255) 
    );
    ''';
    await _db.execute(_sql);
  }

  static Future<void> deleteAllFromContactsTable() async {
    String _sql = 'DELETE FROM Contacts;';
    await _db.execute(_sql);
  }

  static Future<void> deleteAllFromSettingsTable() async {
    String _sql = 'DELETE FROM Settings;';
    await _db.execute(_sql);
  }

  static Future<void> deleteAllFromContactsTableByControl() async {
    String _sql = 'DELETE FROM Contacts WHERE control = 1;';
    await _db.execute(_sql);
  }

  static Future<void> dropDatabase() async {
    String _path = join(await getDatabasesPath(), 'contacts_on_map');
    await deleteDatabase(_path);
  }

  static Future<void> dropTableContacts() async {
    String _sql = 'DROP TABLE IF EXISTS Contacts;';
    await _db.execute(_sql);
  }

  static Future<void> dropTableSettings() async {
    String _sql = 'DROP TABLE IF EXISTS Settings;';
    await _db.execute(_sql);
  }

  static Future<List<Map>> getAllFromContactsTable() async {
    String _sql = 'SELECT * FROM Contacts ORDER BY id;';
    List<Map> _list = await _db.rawQuery(_sql);
    return _list;
  }

  static Future<List<Map>> getContactsByID({required String id}) async {
    String _sql = 'SELECT * FROM Contacts WHERE id = ?;';
    List<Map> _list = await _db.rawQuery(_sql, [id]);
    return _list;
  }

  static Future<String> getCurrentMapType() async {
    String _result = 'Normal';
    String _sql = 'SELECT map_type FROM Settings;';
    List<Map> _records = await _db.rawQuery(_sql);
    if (_records.isNotEmpty) {
      _result = _records.first['map_type'].toString();
    }
    return _result;
  }

  static Future<String> getLocationMarkerColor() async {
    String _result = 'Red';
    String _sql = 'SELECT location_marker_color FROM Settings;';
    List<Map> _records = await _db.rawQuery(_sql);
    if (_records.isNotEmpty) {
      _result = _records.first['location_marker_color'].toString();
    }
    return _result;
  }

  static Future<void> insertInContactsTable({
    required String id,
    required String name,
    required Uint8List thumbnail1,
    required Uint8List thumbnail2,
    required String firstAddress,
    required String secondAddress,
    required String thirdAddress,
    required String firstEmail,
    required String secondEmail,
    required String thirdEmail,
    required String firstNumber,
    required String secondNumber,
    required String thirdNumber,
    required String firstCoordinates,
    required String secondCoordinates,
    required String thirdCoordinates,
    required bool control,
  }) async {
    String _sql = '''
    INSERT INTO Contacts(
      id,
      name,
      thumbnail1,
      thumbnail2,
      first_address,
      second_address,
      third_address,
      first_email,
      second_email,
      third_email,
      first_number,
      second_number,
      third_number,
      first_coordinates,
      second_coordinates,
      third_coordinates,
      control
    ) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
    ''';
    await _db.execute(_sql, [
      id,
      name,
      thumbnail1,
      thumbnail2,
      firstAddress,
      secondAddress,
      thirdAddress,
      firstEmail,
      secondEmail,
      thirdEmail,
      firstNumber,
      secondNumber,
      thirdNumber,
      firstCoordinates,
      secondCoordinates,
      thirdCoordinates,
      control,
    ]);
  }

  static Future<void> open() async {
    String _path = join(await getDatabasesPath(), 'contacts_on_map');

    if (_db != null) return;
    _db = await openDatabase(
      _path,
      version: 1,
      onCreate: (Database db, int version) async {
        String _sql = '''
        CREATE TABLE Contacts(
          id VARCHAR(255), 
          name VARCHAR(255), 
          thumbnail1 BLOB,
          thumbnail2 BLOB,          
          first_address VARCHAR(255), 
          second_address VARCHAR(255), 
          third_address VARCHAR(255), 
          first_email VARCHAR(255), 
          second_email VARCHAR(255), 
          third_email VARCHAR(255), 
          first_number VARCHAR(255), 
          second_number VARCHAR(255), 
          third_number VARCHAR(255), 
          first_coordinates VARCHAR(255), 
          second_coordinates VARCHAR(255), 
          third_coordinates VARCHAR(255),
          control BOOLEAN
        );
        ''';
        await db.execute(_sql);
        _sql = '''
        CREATE TABLE Settings(
          map_type VARCHAR(255), 
          location_marker_color VARCHAR(255) 
        );
        ''';
        await db.execute(_sql);
      },
    );
  }

  static Future<void> resetContactsTableControl() async {
    String _sql = 'UPDATE Contacts SET control = 1;';
    await _db.execute(_sql);
  }

  static Future<void> setCurrentMapType(String value) async {
    String _sql = 'SELECT COUNT(*) FROM Settings;';
    int? _count = Sqflite.firstIntValue(await _db.rawQuery(_sql));
    if (_count == 0) {
      _sql = 'INSERT INTO Settings (map_type) VALUES (?);';
    } else {
      _sql = 'UPDATE Settings SET map_type = ?;';
    }
    await _db.execute(_sql, [value]);
  }

  static Future<void> setLocationMarkerColor(String value) async {
    String _sql = 'SELECT COUNT(*) FROM Settings;';
    int? _count = Sqflite.firstIntValue(await _db.rawQuery(_sql));
    if (_count == 0) {
      _sql = 'INSERT INTO Settings (location_marker_color) VALUES (?);';
    } else {
      _sql = 'UPDATE Settings SET location_marker_color = ?;';
    }
    await _db.execute(_sql, [value]);
  }

  static Future<void> updateContactTable({
    required String id,
    required String name,
    required Uint8List thumbnail1,
    required Uint8List thumbnail2,
    required String firstAddress,
    required String secondAddress,
    required String thirdAddress,
    required String firstEmail,
    required String secondEmail,
    required String thirdEmail,
    required String firstNumber,
    required String secondNumber,
    required String thirdNumber,
    required String firstCoordinates,
    required String secondCoordinates,
    required String thirdCoordinates,
    required bool control,
  }) async {
    String _sql = '''
    UPDATE Contacts SET
      name = ?,
      thumbnail1 = ?,
      thumbnail2 = ?,
      first_address = ?,
      second_address = ?,
      third_address = ?,
      first_email = ?,
      second_email = ?,
      third_email = ?,
      first_number = ?,
      second_number = ?,
      third_number = ?,
      first_coordinates = ?,
      second_coordinates = ?,
      third_coordinates = ?,
      control = ?
    WHERE id = ?;        
    ''';
    await _db.execute(_sql, [
      name,
      thumbnail1,
      thumbnail2,
      firstAddress,
      secondAddress,
      thirdAddress,
      firstEmail,
      secondEmail,
      thirdEmail,
      firstNumber,
      secondNumber,
      thirdNumber,
      firstCoordinates,
      secondCoordinates,
      thirdCoordinates,
      control,
      id,
    ]);
  }
}
