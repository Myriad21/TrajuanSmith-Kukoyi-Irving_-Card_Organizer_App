import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
  version: 2,
  onCreate: _createDB,
  onUpgrade: _upgradeDB,
);
  }

  Future _createDB(Database db, int version) async {

    // Create Folders table
    await db.execute('''
      CREATE TABLE folders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_name TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // Create Cards table with foreign key
    await db.execute('''
      CREATE TABLE cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_name TEXT NOT NULL,
        suit TEXT NOT NULL,
        image_url TEXT,
        folder_id INTEGER,
        FOREIGN KEY (folder_id) REFERENCES folders (id)
        ON DELETE CASCADE
      )
    ''');

    await _prepopulateFolders(db);
    await _prepopulateCards(db);
  }

Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
  await db.execute('PRAGMA foreign_keys = ON');

  // Ensures tables exist
  await db.execute('''
    CREATE TABLE IF NOT EXISTS folders(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      folder_name TEXT NOT NULL,
      timestamp TEXT NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS cards(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      card_name TEXT NOT NULL,
      suit TEXT NOT NULL,
      image_url TEXT,
      folder_id INTEGER,
      FOREIGN KEY (folder_id) REFERENCES folders (id)
      ON DELETE CASCADE
    )
  ''');

  // ---- v1 -> v2 example: add a column, but only if missing
  if (oldVersion < 2) {
    final cols = await db.rawQuery("PRAGMA table_info(cards)");
    final hasNotes = cols.any((c) => c['name'] == 'notes');
    if (!hasNotes) {
      await db.execute("ALTER TABLE cards ADD COLUMN notes TEXT DEFAULT ''");
    }
  }

  // ---- Seed missing data (only if empty)
  final folderCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM folders'),
      ) ??
      0;

  if (folderCount == 0) {
    await _prepopulateFolders(db);
  }

  final cardCount =
      Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM cards')) ??
          0;

  if (cardCount == 0) {
    await _prepopulateCards(db);
  }
}

  Future _prepopulateFolders(Database db) async {
    final folders = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];

    for (var folder in folders) {
      await db.insert('folders', {
        'folder_name': folder,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  Future _prepopulateCards(Database db) async {
    final suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];
    final cards = [
      'Ace','2','3','4','5','6','7','8','9','10','Jack','Queen','King'
    ];

    for (int folderId = 1; folderId <= suits.length; folderId++) {
      for (var card in cards) {
        await db.insert('cards', {
          'card_name': card,
          'suit': suits[folderId - 1],
          'image_url': 'assets/cards/${suits[folderId - 1].toLowerCase()}_${card.toLowerCase()}.png',
          'folder_id': folderId,
        });
      }
    }
  }
}