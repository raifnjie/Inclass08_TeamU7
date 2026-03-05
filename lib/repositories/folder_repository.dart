import '../data/database_helper.dart';
import '../models/folder_model.dart';

class FolderRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getFoldersWithCounts() async {
    final db = await _dbHelper.database;

    return db.rawQuery('''
      SELECT f.id, f.folder_name, f.timestamp, COUNT(c.id) AS card_count
      FROM folders f
      LEFT JOIN cards c ON c.folder_id = f.id
      GROUP BY f.id
      ORDER BY f.folder_name
    ''');
  }

  Future<int> insertFolder(FolderModel folder) async {
    final db = await _dbHelper.database;
    return db.insert('folders', folder.toMap());
  }

  Future<int> updateFolder(FolderModel folder) async {
    final db = await _dbHelper.database;
    return db.update(
      'folders',
      folder.toMap(),
      where: 'id = ?',
      whereArgs: [folder.id],
    );
  }

  Future<int> deleteFolder(int id) async {
    final db = await _dbHelper.database;
    return db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }
}