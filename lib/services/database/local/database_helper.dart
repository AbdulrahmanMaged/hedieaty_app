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
        id TEXT PRIMARY KEY,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        preferences TEXT
        );

    ''');

    await db.execute('''
      CREATE TABLE Events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
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
Future<void> insertUser(Map<String, dynamic> user) async {
  final db = await database;
  await db.insert(
    'users',
    user,
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

// Get all users
Future<List<Map<String, dynamic>>> getUsers() async {
  final db = await database;
  return db.query('Users');
}

  Future<List<Map<String, dynamic>>> getUsersById(String userId) async {
    final db = await database;
    return db.query(
      'Users',
      where: 'userID = ?', // stores userID
      whereArgs: [userId],
    );
  }



// Insert an event
Future<int> insertEvent(Map<String, dynamic> event) async {
  final db = await database;
  return db.insert('Events', event);
}
// clear a user
  Future<void> clearUsers() async {
    final db = await database;
    await db.delete('users');
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
