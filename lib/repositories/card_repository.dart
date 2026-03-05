import '../data/database_helper.dart';
import '../models/playing_card_model.dart';

class CardRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<List<PlayingCardModel>> getCardsByFolder(int folderId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'cards',
      where: 'folder_id = ?',
      whereArgs: [folderId],
      orderBy: '''
        CASE card_name
          WHEN 'Ace' THEN 1
          WHEN '2' THEN 2
          WHEN '3' THEN 3
          WHEN '4' THEN 4
          WHEN '5' THEN 5
          WHEN '6' THEN 6
          WHEN '7' THEN 7
          WHEN '8' THEN 8
          WHEN '9' THEN 9
          WHEN '10' THEN 10
          WHEN 'Jack' THEN 11
          WHEN 'Queen' THEN 12
          WHEN 'King' THEN 13
          ELSE 99
        END
      ''',
    );

    return maps.map((m) => PlayingCardModel.fromMap(m)).toList();
  }

  Future<int> insertCard(PlayingCardModel card) async {
    final db = await _dbHelper.database;
    return db.insert('cards', card.toMap());
  }

  Future<int> updateCard(PlayingCardModel card) async {
    final db = await _dbHelper.database;
    return db.update(
      'cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<int> deleteCard(int id) async {
    final db = await _dbHelper.database;
    return db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }
}