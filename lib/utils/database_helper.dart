import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {

  static final _databaseName = "MyCart.db";
  static final _databaseVersion = 2;

  static final table = 'my_cart';

  static final columnId = '_id';
  static final columnProId = 'pro_id';
  static final columnProName = 'pro_name';
  static final columnProImageUrl = 'pro_image';
  static final columnProQty = 'pro_qty';
  static final columnProType = 'pro_type';
  static final columnProCustomization = 'pro_customization';
  static final columnIsRepeatCustomization = 'isRepeatCustomization';
  static final columnProPrice= 'pro_price';
  static final columnQTYReset = 'cQTYReset';
  static final columnAvailableItem = 'cAvailableItem';
  static final columnItemResetValue = 'cItemResetValue';
  static final columnIsCustomization = 'isCustomization';

  static final columnItemQty = 'itemQty';
  static final columnItemTempPrice = 'itemTempPrice';
  static final columnCurrentPriceWithoutCustomization = 'cPriceWithoutCust';

  static final columnRestId = 'restId';
  static final columnRestName = 'restName';
  static final columnRestImage = 'restImage';


  // static final columnisProCustomization = 'is_pro_customization';
  // static final columnCustomizationProPrice= 'customization_pro_price';
  // static final columnCustomizationProQty = 'customization_pro_qty';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }


  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnProId INTEGER NOT NULL,
            $columnProPrice TEXT NOT NULL,
            $columnProName TEXT NOT NULL,
            $columnProImageUrl TEXT NOT NULL,
            $columnProQty INTEGER NOT NULL,
            $columnRestId INTEGER NOT NULL,
            $columnItemQty INTEGER NOT NULL,
            $columnRestName TEXT NOT NULL,
            $columnQTYReset TEXT NOT NULL,
            $columnAvailableItem INTEGER,
            $columnItemResetValue INTEGER,
            $columnRestImage TEXT NOT NULL,
            $columnIsRepeatCustomization INTEGER,
            $columnIsCustomization INTEGER,
            $columnItemTempPrice INTEGER,
            $columnProCustomization TEXT,
            $columnCurrentPriceWithoutCustomization TEXT,
            $columnProType TEXT
            )
          ''');
  }

  // int proId,String proPrice,String proName, String proImage,int proQty,int restId,String restName

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await (instance.database);
    return await db.insert(table, row);
  }

  Future<int> deleteTable() async {
    Database db = await (instance.database);
    return await db.delete(table);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await (instance.database);
    return await db.query(table);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int?> queryRowCount() async {
    Database db = await (instance.database);
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  // ignore: missing_return
  Future<int?> update(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    if(row[columnProQty] == 0){
      delete(row[columnProId]);
    }else{
      int? id = row[columnProId];
      return await db.update(table, row, where: '$columnProId = ?', whereArgs: [id]);
    }

  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int? id) async {
    Database db = await (instance.database);
    return await db.delete(table, where: '$columnProId = ?', whereArgs: [id]);
  }
}