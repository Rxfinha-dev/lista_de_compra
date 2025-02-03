import 'package:flutter/material.dart';
import 'package:lista_de_compra/services/database_service.dart';
import '../models/product.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DataBaseService _databaseService = DataBaseService.instance;

  String? _product;
  String? _price;
  int ?_isBought;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _floatingActionButtons(),
      body: _productList(),
    );
  }

  Widget _floatingActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Botão para adicionar produto (azul)
        FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Adicione o Produto'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _product = value;
                        });
                      },
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        hintText: 'Nome do Produto',
                      ),
                    ),
                    MaterialButton(
                      color: Colors.blueAccent, // Cor azul para o botão de adicionar
                      onPressed: () {
                        if (_product == null || _product == '') return;
                        _databaseService.addProduct(_product!);
                        setState(() {
                          _product = null;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Adicionar',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          backgroundColor: Colors.blue, // Cor azul para o botão de adicionar
          child: const Icon(Icons.add, color: Colors.white),
        ),
        const SizedBox(width: 10), // Espaço entre os botões
        // Novo FloatingActionButton ao lado (vermelho)
        FloatingActionButton(
          onPressed: () {
            // Limpar todos os produtos da compra
            _databaseService.cleanPurchases();
            setState(() {
              _databaseService.getProducts();
            });
            
          },
          backgroundColor: Colors.red, // Cor vermelha para o novo botão
          child: const Icon(Icons.delete, color: Colors.white),
        ),
      ],
    );
  }

  Widget _productList() {
  return FutureBuilder<List<Product>>(
    future: _databaseService.getProducts(),  // Aqui você já está buscando os produtos
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final products = snapshot.data!;
      return ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          Product product = products[index];
          return ListTile(
            onLongPress: () {
              _databaseService.deleteProduct(product.id);
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
                  child: _priceTextField(product),
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
        },
      );
    },
  );
}

  Widget _priceTextField(Product product) {
    // FocusNode and Controller for this TextField
    final FocusNode focusNode = FocusNode();
    final TextEditingController controller =
        TextEditingController(text: product.price);

    // Add listener to handle onBlur (losing focus)
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        // Update price in the database
        _databaseService.setPrice(controller.text, product.id);
        setState(() {});
      }
    });

    return TextField(
      focusNode: focusNode, // Attach FocusNode
      controller: controller, // Attach Controller
      keyboardType: TextInputType.number, // Make it suitable for numeric input
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
    );
  }
}
