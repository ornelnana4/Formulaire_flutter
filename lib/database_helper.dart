import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class User {
  int? id;
  String name;
  String email;
  String password;

  User({this.id, required this.name, required this.email, required this.password});

  // Convertir un utilisateur en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
    };
  }

  // Créer un utilisateur depuis un Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
    );
  }
}

class DatabaseHelper {
  static Future<Database> _getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'users.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, email TEXT, password TEXT)',
        );
      },
      version: 1,
    );
  }

  // Insérer un utilisateur
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await _getDatabase();
    return await db.insert('users', user);
  }

  // Récupérer tous les utilisateurs
  Future<List<User>> getUsers() async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  // Mettre à jour un utilisateur
  Future<int> updateUser(User user) async {
    final db = await _getDatabase();
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Supprimer un utilisateur
  Future<void> deleteUser(int id) async {
    final db = await _getDatabase();
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
