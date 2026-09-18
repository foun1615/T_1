import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:restaurant_queue_manager/models/queue.dart';

class QueueRepository {
  static const _dbName = 'queue_database.db';
  static const _tableName = 'queues';

  static Future<Database> _database() async {
    final database = openDatabase(
      join(await getDatabasesPath(), _dbName),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $_tableName(id INTEGER PRIMARY KEY , customerName TEXT, pax INTEGER, zone TEXT, createdAt TEXT)',
        );
      },
      version: 1,
    );
    return database;
  }

  static insert({required Queue queue}) async {
    final db = await _database();
    await db.insert(
      _tableName,
      queue.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Queue>> getQueue() async {
    final db = await _database();
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (i) {
      return Queue(
        id: maps[i]['id'] as int,
        customerName: maps[i]['customerName'] as String,
        pax: maps[i]['pax'] as int,
        zone: maps[i]['zone'] as String,
        createdAt: DateTime.parse(maps[i]['createdAt']),
      );
    });
  }

  // ใหม่: อัปเดตข้อมูลคิวที่มีอยู่แล้ว โดยอ้างอิงจาก id
  static update({required Queue queue}) async {
    final db = await _database();
    await db.update(
      _tableName,
      queue.toMap(),
      where: 'id = ?',
      whereArgs: [queue.id],
    );
  }

  static delete({required Queue queue}) async {
    final db = await _database();
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [queue.id],
    );
  }
}