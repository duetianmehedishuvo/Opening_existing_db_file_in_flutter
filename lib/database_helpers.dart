
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelpers{
  static final databaseName='TORA.db';
  static final databaseVersion=2;
  static final table_name='Tora';
  static final ColumnEmail='EMAIL';
  static final ColumnName='NAME';

  DBHelpers._privateConstrator();
  static final DBHelpers instance=DBHelpers._privateConstrator();

  static Database _database;
  Future<Database> get database async{
    if(_database!=null)return _database;
    _database=await _initDatabase();
    return _database;
  }

  _initDatabase() async{
    var databasePath=await getDatabasesPath();
    String path=join(databasePath,databaseName);

    var exists=await databaseExists(path);
    if(!exists){
      print('Copy Database Start');

      try{
        await Directory(dirname(path)).create(recursive: true);
      }catch(_){}

      ByteData data=await rootBundle.load(join("assets",databaseName));
      List<int> bytes=data.buffer.asUint8List(data.offsetInBytes,data.lengthInBytes);

      //write
      await File(path).writeAsBytes(bytes,flush: true);

    }else{
      print('Opening existing database');
    }

    return await openDatabase(path,version: databaseVersion);
  }

  ///CRUD
///==========================================================

  // Insert
  Future<int> insert(Map<String,dynamic> row)async{
  Database db=await instance.database;
  return await db.insert(table_name, row,nullColumnHack: null);
  }

  //Select All
  Future<List> getAllStudent()async{
    Database db=await instance.database;
    var result=await db.query(table_name);
    return result.toList();
  }


}