import '../database/db_helper.dart';

class AlarmaService {
  // INSERT
  Future<int> insertAlarma(Map<String, dynamic> alarma) async {
    final db = await DatabaseHelper.instance.database;

    return await db.insert(
      'alarma',
      alarma,
    );
  }

  // GET ALL
  Future<List<Map<String, dynamic>>> getAlarmas() async {
    final db = await DatabaseHelper.instance.database;

    return await db.query('alarma');
  }

  // GET ONE
  Future<Map<String, dynamic>?> getAlarma(int id) async {
    final db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'alarma',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // DELETE
  Future<int> deleteAlarma(int id) async {
    final db = await DatabaseHelper.instance.database;

    return await db.delete(
      'alarma',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // UPDATE
  Future<int> updateAlarma(
      int id,
      Map<String, dynamic> alarma,
      ) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'alarma',
      alarma,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}