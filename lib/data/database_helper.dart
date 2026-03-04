import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('card_organizer.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_name TEXT NOT NULL UNIQUE,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_name TEXT NOT NULL,
        suit TEXT NOT NULL,
        image_url TEXT,
        folder_id INTEGER NOT NULL,
        FOREIGN KEY (folder_id) REFERENCES folders(id) ON DELETE CASCADE
      )
    ''');

    await _prepopulate(db);
  }

  Future<void> _prepopulate(Database db) async {
    // Change this number to 2, 3, or 4 if your instructor wants a specific amount.
    const int suitsToUse = 4;

    final allSuits = ['Spades', 'Hearts', 'Diamonds', 'Clubs'];
    final selectedSuits = allSuits.take(suitsToUse).toList();

    final ranks = <Map<String, String>>[
      {'name': 'Ace', 'code': 'A'},
      {'name': '2', 'code': '2'},
      {'name': '3', 'code': '3'},
      {'name': '4', 'code': '4'},
      {'name': '5', 'code': '5'},
      {'name': '6', 'code': '6'},
      {'name': '7', 'code': '7'},
      {'name': '8', 'code': '8'},
      {'name': '9', 'code': '9'},
      {'name': '10', 'code': '0'}, // Deck of Cards API uses 0 for 10
      {'name': 'Jack', 'code': 'J'},
      {'name': 'Queen', 'code': 'Q'},
      {'name': 'King', 'code': 'K'},
    ];

    final suitCode = {
      'Spades': 'S',
      'Hearts': 'H',
      'Diamonds': 'D',
      'Clubs': 'C',
    };

    final now = DateTime.now().toIso8601String();

    for (final suit in selectedSuits) {
      final folderId = await db.insert('folders', {
        'folder_name': suit,
        'timestamp': now,
      });

      for (final rank in ranks) {
        final code = '${rank['code']}${suitCode[suit]}';
        final imageUrl = 'https://deckofcardsapi.com/static/img/$code.png';

        await db.insert('cards', {
          'card_name': rank['name'],
          'suit': suit,
          'image_url': imageUrl,
          'folder_id': folderId,
        });
      }
    }
  }
}