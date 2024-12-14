import 'dart:io';
import 'dart:core';
// import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart';
// import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper{

  /// Singleton
  DBHelper._();

  static final DBHelper getInstance = DBHelper._();
  /// table note
  static final String TABLE_NOTE = "note";
  static final String COLUMN_NOTE_SNO = "s_no";
  static final String COLUMN_NOTE_TITLE = "title";
  static final String COLUMN_NOTE_DESC = "description";
  Database? myDB;

  /// db Open (path -> if exists then open else create db)
  Future<Database> getDB() async{

    myDB ??= await openDB();
    return myDB!;

    /*if(myDB != null){
      return myDB!;
    } else {
      myDB = await openDB();
      return myDB!;
    }*/
  }

  Future<Database> openDB() async{

    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, "noteDB.db");
    
    return await openDatabase(dbPath, onCreate: (db, version){
      /// Create all your tables here (using below method we can create multiple tables)
      db.execute("create table $TABLE_NOTE ( $COLUMN_NOTE_SNO integer primary key autoincrement, $COLUMN_NOTE_TITLE text, $COLUMN_NOTE_DESC text)");
    }, version: 1);
  }

  /// all queries
  /// insertion
  Future<bool> addNote({required String myTitle, required String myDesc}) async{
    var db = await getDB();

    int rowsEffected = await db.insert(TABLE_NOTE, {
      COLUMN_NOTE_TITLE: myTitle,
      COLUMN_NOTE_DESC: myDesc
    });
    return rowsEffected > 0;
  }

  /// reading all data
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDB();
    List<Map<String, dynamic>> myData = await db.query(TABLE_NOTE); // select * from note

    return myData;
  }

  /// update data
  Future<bool> updateNote({required String myTitle, required String myDesc, required int sno}) async{
    var db = await getDB();

    int rowsEffected = await db.update(TABLE_NOTE, {
      COLUMN_NOTE_TITLE: myTitle,
      COLUMN_NOTE_DESC: myDesc
    }, where: "$COLUMN_NOTE_SNO = $sno");

    return rowsEffected > 0;
  }

  /// delete data
  Future<bool> deleteNote({required int sno}) async{
    var db = await getDB();

    int rowsEffected = await db.delete(TABLE_NOTE, where: "$COLUMN_NOTE_SNO = ?", whereArgs: ['$sno']);
    return rowsEffected > 0;
  }
}