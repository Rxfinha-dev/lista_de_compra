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
    final database = await openDatabase(databasePath, version: 8, onCreate: (
      db,
      version,
    ) {
      db.execute('''
      CREATE TABLE $_productsTableName 
      (
        $_id INTEGER PRIMARY KEY,
        $_name text NOT NULL,
        $_price text,
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
      {
        _name: name,
        _isBought: 0,
        _price: "",
      },
    );
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final data = await db.query(_productsTableName);
    List<Product> products = data
        .map((e) => Product(
              id: e["id"] as int,
              isBought: e["isBought"] as int,
              name: e["name"] as String,
              price: e["price"].toString(),
            ))
        .toList();
    return products;
  }

  void updateProductIsBought(int id, int isBought) async {
    final db = await database;
    await db.update(
        _productsTableName,
        {
          _isBought: isBought,
        },
        where: 'id = ?',
        whereArgs: [
          id,
        ]);
  }

  void deleteProduct(int id) async {
    final db = await database;
    await db.delete(_productsTableName, where: 'id = ?', whereArgs: [
      id,
    ]);
  }

  void setPrice(String price, int id) async {
    final db = await database;
    await db.update(
        _productsTableName,
        {
          _price: price,
        },
        where: 'id = ?',
        whereArgs: [id]);
  }

void cleanPurchases() async {
  final db = await database;

  try {
    print("Limpando todos os produtos...");
    // Certifique-se de que os nomes das colunas estão corretos
    await db.update(
      _productsTableName, // Nome da tabela
      {
        _price: "",   // Definindo preço como uma string vazia
        _isBought: 0, // Definindo isBought como 0 (não comprado)
      },
      where: 'price <> "" or isBought = 1',
       // Atualiza todos os registros
    );
    print("Produtos limpos com sucesso!");
  } catch (e) {
    print("Erro ao limpar os produtos: $e");
  }
}


}
