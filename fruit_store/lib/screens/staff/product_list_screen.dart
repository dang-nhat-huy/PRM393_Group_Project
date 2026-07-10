import 'package:flutter/material.dart';

import '../../models/product.model.dart';
import '../../services/api.service.dart';
import '../../services/product.service.dart';
import '../../widgets/product/product_table.dart';

class ProductListScreen extends StatefulWidget {
  final ApiService apiService;

  const ProductListScreen({
    super.key,
    required this.apiService,
  });

  @override
  State<ProductListScreen> createState() =>
      _ProductListScreenState();
}

class _ProductListScreenState
    extends State<ProductListScreen> {
  late ProductService _service;

  List<Product> products = [];

  bool loading = true;

  String error = "";

  @override
  void initState() {
    super.initState();

    _service = ProductService(widget.apiService);

    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final result = await _service.getProducts();

      setState(() {
        products = result;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error.isNotEmpty
              ? Center(
                  child: Text(error),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ProductTable(
                    products: products,
                  ),
                ),
    );
  }
}