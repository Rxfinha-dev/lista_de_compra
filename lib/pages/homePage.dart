import 'package:flutter/material.dart';
import 'package:lista_de_compra/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

import '../models/product.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DataBaseService _databaseService = DataBaseService.instance;

  String? _product = null;
  @override
  Widget build(Object context) {
    return Scaffold(
      floatingActionButton: _addProductButton(),
      body: _productList(),
    );
  }

  Widget _addProductButton() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Adcione o Produto'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    _product = value;
                  });
                },
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  hintText: 'Nome do Produto',
                ),
              ),
              MaterialButton(
                color: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  if (_product == null || _product == '') return;
                  _databaseService.addProduct(_product!);
                  setState(() {
                    _product = null;
                  });
                  Navigator.pop(
                    context,
                  );
                },
                child: const Text(
                  'Adicionar',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              )
            ]),
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }

  Widget _productList() {
    return FutureBuilder(
      future: _databaseService.getProducts(),
      builder: (context, snapshot) {
        return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              Product product = snapshot.data![index];
              return ListTile(
                onLongPress: () {
                  _databaseService.deleteProduct(
                    product.id,
                  );
                  setState(() {});
                },
                title: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(product.name),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        onChanged: (price) {
                          _databaseService.setPrice(price, product.id);
                          setState(() {});
                        },
                        controller: TextEditingController(
                            text: product.price), // Valor inicial
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: Checkbox(
                  value: product.isBought == 1,
                  onChanged: (value) {
                    _databaseService.updateProductIsBought(
                      product.id,
                      value == true ? 1 : 0,
                    );
                    setState(() {});
                  },
                ),
              );
            });
      },
    );
  }
}
