import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  // Singleton pattern
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'hedieaty_app.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        Events TEXT UNIQUE NOT NULL,
        preferences TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE Events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        location TEXT,
        description TEXT,
        user_id INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES Users (id)
      );
    ''');

    await db.execute('''
      CREATE TABLE Gifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT,
        price REAL,
        status TEXT,
        event_id INTEGER NOT NULL,
        FOREIGN KEY (event_id) REFERENCES Events (id)
      );
    ''');

    await db.execute('''
      CREATE TABLE Friends (
        user_id INTEGER NOT NULL,
        friend_id INTEGER NOT NULL,
        PRIMARY KEY (user_id, friend_id),
        FOREIGN KEY (user_id) REFERENCES Users (id),
        FOREIGN KEY (friend_id) REFERENCES Users (id)
      );
    ''');
  }

// Insert a user
Future<int> insertUser(Map<String, dynamic> user) async {
  final db = await database;
  return db.insert('Users', user);
}

// Get all users
Future<List<Map<String, dynamic>>> getUsers() async {
  final db = await database;
  return db.query('Users');
}

// Insert an event
Future<int> insertEvent(Map<String, dynamic> event) async {
  final db = await database;
  return db.insert('Events', event);
}

// Get events by user ID
Future<List<Map<String, dynamic>>> getEventsByUserId(int userId) async {
  final db = await database;
  return db.query('Events', where: 'user_id = ?', whereArgs: [userId]);
}

// Insert a gift
Future<int> insertGift(Map<String, dynamic> gift) async {
  final db = await database;
  return db.insert('Gifts', gift);
}

// Get gifts by event ID
Future<List<Map<String, dynamic>>> getGiftsByEventId(int eventId) async {
  final db = await database;
  return db.query('Gifts', where: 'event_id = ?', whereArgs: [eventId]);
}

// Add a friend
Future<int> addFriend(int userId, int friendId) async {
  final db = await database;
  return db.insert('Friends', {'user_id': userId, 'friend_id': friendId});
}

// Get friends for a user
Future<List<Map<String, dynamic>>> getFriends(int userId) async {
  final db = await database;
  return db.query('Friends', where: 'user_id = ?', whereArgs: [userId]);
}


}
