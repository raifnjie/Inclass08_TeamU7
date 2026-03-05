import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('card_organizer_local_assets.db');
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

  // Map suit names to the exact words used in your filenames
  String _suitWord(String suit) => suit.toLowerCase(); // clubs/hearts/diamonds/spades

  // Build filename based on your naming convention
  // examples: ace_of_spades.png, 2_of_clubs.png, 10_of_hearts.png, jack_of_diamonds.png
  String _assetPath(String rankName, String suit) {
    final rank = rankName.toLowerCase(); // ace, 2, 3, ..., 10, jack, queen, king
    final s = _suitWord(suit);
    return 'assets/cards/${rank}_of_${s}.png';
  }

  Future<void> _prepopulate(Database db) async {
    // Choose 2, 3, or 4 suits (assignment: 2-4). :contentReference[oaicite:1]{index=1}
    const int suitsToUse = 4;

    final allSuits = ['Spades', 'Hearts', 'Diamonds', 'Clubs'];
    final selectedSuits = allSuits.take(suitsToUse).toList();

    final ranks = <String>[
      'Ace',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      'Jack',
      'Queen',
      'King',
    ];

    final now = DateTime.now().toIso8601String();

    for (final suit in selectedSuits) {
      final folderId = await db.insert('folders', {
        'folder_name': suit,
        'timestamp': now,
      });

      for (final rank in ranks) {
        final asset = _assetPath(rank, suit);

        await db.insert('cards', {
          'card_name': rank,
          'suit': suit,
          'image_url': asset,
          'folder_id': folderId,
        });
      }
    }
  }
}