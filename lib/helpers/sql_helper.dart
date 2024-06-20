import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class SqlHelper {
  Database? db;

  Future<void> registerForeignKeys() async {
    await db!.rawQuery('PRAGMA foreign_keys = on');
    var result = await db!.rawQuery('PRAGMA foreign_keys');

    print(result);
  }

  Future<bool> createTables() async {
    try {
      await registerForeignKeys();
      var batch = db!.batch();
      batch.execute("""
      Create table If not exists categories(
      id integer primary key,
      name text not null,
      description text not null
      )""");
      batch.execute("""
      Create table If not exists products(
      id integer primary key,
      name text,
      description text,
      price double,
      stock integer,
      isAvailable boolean,
      image text,
      categoryId integer,
      foreign key(categoryId) references categories(id)
      ON Delete restrict
      )""");
      batch.execute("""
      Create table If not exists clients(
      id integer primary key,
      name text,
      email text,
      phone text,
      address text
      )""");
      batch.execute("""
      Create table If not exists orders(
      id integer primary key,
      label text,
      totalPrice real,
      discount real,
      clientId integer ,
      foreign key(clientId) references clients(id)
      ON Delete restrict
      )""");
      batch.execute("""
      Create table If not exists orderProductItems(
      orderId Integer,
      productCount Integer,
      productId Integer,
      foreign key(productId) references products(id)
      ON Delete restrict
      )""");

      var result = await batch.commit();

      log('tables Created Successfully: $result');
      return true;
    } catch (e) {
      log('error in create tables $e');
      return false;
    }
  }

  Future<void> initDb() async {
    try {
      if (kIsWeb) {
        var factory = databaseFactoryFfiWeb;
        db = await factory.openDatabase('pos.db');
        log('=================== Db Created');
      } else {
        db = await openDatabase(
          'pos.db',
          version: 1,
          onCreate: (db, version) {
            log('=================== Db Created');
          },
        );
      }
    } catch (e) {
      log('error in create db : ${e}');
    }
  }
}
