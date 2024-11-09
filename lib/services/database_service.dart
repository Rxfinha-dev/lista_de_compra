import 'package:lista_de_compra/models/product.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseService {
  static Database? _db;
  static final DataBaseService instance = DataBaseService._constructor();

  final String _productsTableName = 'products';
  final String _name = 'name';
  final String _id = 'id';
  final String _isBought = 'isBought';
  final String _price = 'price';

  DataBaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "lista.db");
    final database = await openDatabase(databasePath, version: 7, onCreate: (
      db,
      version,
    ) {
      db.execute('''
      CREATE TABLE $_productsTableName 
      (
        $_id INTEGER PRIMARY KEY,
        $_name text NOT NULL,
        $_price INTEGER,
        $_isBought INTEGER NOT NULL
      )
     ''');
    });
    return database;
  }

  void addProduct(
    String name,
  ) async {
    final db = await database;

    await db.insert(
      _productsTableName,
      {_name: name, _isBought: 0, _price: 0},
    );
  }

  Future<List<Product>?> getProducts() async {
    final db = await database;
    final data = await db.query(_productsTableName);
    print(data);
  }
}
