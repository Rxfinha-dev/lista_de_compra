import 'package:flutter/material.dart';
import 'package:lista_de_compra/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

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
                  border: OutlineInputBorder(),
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
        return Container();
      },
    );
  }
}
