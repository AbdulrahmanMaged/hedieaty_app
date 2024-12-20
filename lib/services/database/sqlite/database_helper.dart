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

  //print in terminal the contents of all tables
  Future<void> printAllTables() async {
    final db = await database;

    // Get all table names
    final List<Map<String, dynamic>> tableList = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");

    for (var table in tableList) {
      final tableName = table['name'];

      // Query all rows from the table
      final List<Map<String, dynamic>> rows = await db.query(tableName);

      // Print the table name and its rows
      print('Table: $tableName');
      for (var row in rows) {
        print(row);
      }
      print('-----------------------');
    }
  }

  //Delete all rows based on table name
  Future<void> deleteTable(String tableName) async {
    final db = await database;

    // Check if the table exists
    final tableExists = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name = ?", [tableName]);

    if (tableExists.isNotEmpty) {
      // Delete all rows in the table
      await db.delete(tableName);
      print('Table "$tableName" has been cleared.');
    } else {
      print('Table "$tableName" does not exist.');
    }
  }

  ///Fetches current user for profile screen
  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    final db = await database;

    // Query the Users table to get the current user
    final List<Map<String, dynamic>> result = await db.query(
      'Users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    // Return the user data if found, otherwise null
    if (result.isNotEmpty) {
      return result.first; // Return the first (and only) result
    } else {
      return null; // No user found with the given ID
    }
  }

  ///Updates personal info locally as draft
  Future<void> updateUserDataLocally(String userId, Map<String, dynamic> updatedFields) async {
    final db = await database;

    try {
      final int result = await db.update(
        'Users', // Table name
        updatedFields, // Map of fields to update
        where: 'id = ?', // Condition to match the user
        whereArgs: [userId],
      );

      if (result > 0) {
        print('User with ID $userId updated successfully.');
      } else {
        print('No user found with ID $userId to update.');
      }
    } catch (e) {
      print('Error updating user with ID $userId: $e');
    }
  }

  /// saves as a draft the event
  Future<void> updateEventLocally(String eventId, Map<String, dynamic> eventData) async {
    final db = await database;

    try {
      final result = await db.update(
        'Events',
        eventData,
        where: 'id = ?',
        whereArgs: [eventId],
      );

      if (result == 0) {
        print('No event found with ID $eventId to update.');
      } else {
        print('Event with ID $eventId updated successfully.');
      }
    } catch (e) {
      print('Error updating event with ID $eventId: $e');
    }
  }

  /// saves as a draft the gifts
  Future<void> updateGiftLocally(String giftId, Map<String, dynamic> giftData) async {
    final db = await database;

    try {
      final result = await db.update(
        'Gifts',
        giftData,
        where: 'id = ?',
        whereArgs: [giftId],
      );

      if (result == 0) {
        print('No gift found with ID $giftId to update.');
      } else {
        print('Gift with ID $giftId updated successfully.');
      }
    } catch (e) {
      print('Error updating gift with ID $giftId: $e');
    }
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
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        status TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        location TEXT,
        user_id TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES Users (id)
      );
    ''');

    await db.execute('''
      CREATE TABLE Gifts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT,
        priceRange TEXT,
        status TEXT,
        event_id TEXT NOT NULL,
        FOREIGN KEY (event_id) REFERENCES Events (id)
      );
    ''');

    await db.execute('''
      CREATE TABLE Friends (
        user_id TEXT PRIMARY KEY,
        friend_id INTEGER NOT NULL,
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
  Future<void> insertEvent(Map<String, dynamic> eventData) async {
    final db = await database;

    try {
      await db.insert(
        'Events',
        eventData,
        conflictAlgorithm: ConflictAlgorithm.replace, // Overwrite if event already exists
      );
      print('Event inserted with ID: ${eventData['id']}');
    } catch (e) {
      print('Error inserting event: $e');
      throw Exception('Failed to insert event');
    }
  }

  Future<void> insertGift(Map<String, dynamic> giftData) async {
    final db = await database;

    try {
      await db.insert(
        'Gifts',
        giftData,
        conflictAlgorithm: ConflictAlgorithm.replace, // Overwrite if gift already exists
      );
      print('Gift inserted with ID: ${giftData['id']}');
    } catch (e) {
      print('Error inserting gift: $e');
      throw Exception('Failed to insert gift');
    }
  }


// clear a user
  Future<void> clearUsers() async {
    final db = await database;
    await db.delete('users');
  }

  Future<void> printTableColumns(String tableName) async {
    final db = await database;

    try {
      // Query the table schema
      final List<Map<String, dynamic>> result =
      await db.rawQuery("PRAGMA table_info($tableName)");

      // Print the columns
      print('Table: $tableName');
      for (var row in result) {
        print('Column: ${row['name']}, Type: ${row['type']}, NotNull: ${row['notnull']}, DefaultValue: ${row['dflt_value']}');
      }
    } catch (e) {
      print('Error retrieving columns for table $tableName: $e');
    }
  }

  Future<void> deleteDatabaseFile() async {
    try {
      final dbPath = join(await getDatabasesPath(), 'hedieaty_app.db');
      await deleteDatabase(dbPath); // Deletes the database file
      print('Database deleted successfully.');
    } catch (e) {
      print('Error deleting database: $e');
    }
  }




}
