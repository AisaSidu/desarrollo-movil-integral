import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // 1. Patrón Singleton: Única instancia de la clase
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  // Constructor privado para evitar que se creen más instancias
  DatabaseHelper._internal();

  // Factory constructor que devuelve la única instancia
  factory DatabaseHelper() {
    return _instance;
  }

  // Variable para guardar la conexión a la base de datos
  static Database? _database;

  // 2. Lazy Initialization: Solo abrimos la base de datos si no está abierta
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }

  // Configuración inicial de la base de datos
  Future<Database> _initDatabase() async {
    // Obtenemos la ruta segura en el dispositivo
    String path = join(await getDatabasesPath(), 'salud_mental.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate, // Se ejecuta solo la primera vez que se instala la app
    );
  }

  // 3. Creación de Tablas (Esquema basado en tus requisitos)
  Future _onCreate(Database db, int version) async {
    // Tabla para el Registro de Ánimo (Sprint 2)
    await db.execute('''
      CREATE TABLE moods(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,         -- Fecha ISO-8601
        mood_value INTEGER, -- Escala numérica para las gráficas (ej. 1-5)
        emoji TEXT         -- Emoji visual
      )
    ''');

    // Tabla para el Diario de Notas (Sprint 2)
    // NOTA: El contenido se guardará cifrado más adelante usando la librería 'encrypt'
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        title TEXT,
        content TEXT       -- Aquí guardaremos el texto cifrado
      )
    ''');

    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE,
        password TEXT -- Se guardará cifrada
      )
    ''');
  }
}