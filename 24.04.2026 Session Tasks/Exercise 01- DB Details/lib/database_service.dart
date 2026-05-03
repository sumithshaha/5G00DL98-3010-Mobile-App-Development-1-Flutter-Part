import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'student.dart';

class DatabaseService {
  static final DatabaseService _databaseService = DatabaseService._internal();
  factory DatabaseService() => _databaseService;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'flutter_database.db');

    return await openDatabase(
      path,
      onCreate: _onCreate,
      // onUpgrade not used in this example
      version: 1,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('DROP TABLE IF EXISTS student');
    await db.execute(
      'CREATE TABLE student (id INTEGER PRIMARY KEY, firstname TEXT, lastname TEXT)',
    );
  }

  // --- CRUD operations ---

  Future<void> insertStudent(Student student) async {
    final db = await database;
    await db.insert(
      'student',
      student.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Student>> students() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('student');
    return List.generate(maps.length, (index) => Student.fromMap(maps[index]));
  }

  Future<List<Student>> findByName(String name) async {
    final db = await database;
    final q = '$name%';
    final List<Map<String, dynamic>> maps =
        await db.query('student', where: 'lastname like ?', whereArgs: [q]);
    return List.generate(maps.length, (index) => Student.fromMap(maps[index]));
  }

  Future<void> updateStudent(Student student) async {
    final db = await database;
    await db.update('student', student.toMap(),
        where: 'id = ?', whereArgs: [student.id]);
  }

  Future<void> deleteStudent(int id) async {
    final db = await database;
    await db.delete('student', where: 'id = ?', whereArgs: [id]);
  }

  // Inserts sample data on first run
  Future<void> populateData() async {
    final existing = await students();
    if (existing.isNotEmpty) return;

    await insertStudent(const Student(id: 0, firstName: 'Max', lastName: 'Mustermann'));
    await insertStudent(const Student(id: 0, firstName: 'Anna', lastName: 'Schmidt'));
    await insertStudent(const Student(id: 0, firstName: 'Lisa', lastName: 'Braun'));
    await insertStudent(const Student(id: 0, firstName: 'Jonas', lastName: 'Bauer'));
  }
}
