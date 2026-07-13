import 'package:flutter/material.dart';
import 'package:fruit_store/screens/staff/product_detail_screen.dart';

import '../../models/product.model.dart';
import '../../services/api.service.dart';
import '../../services/product.service.dart';

import '../../widgets/product/product_card.dart';
import '../../widgets/product/product_search_bar.dart';

class ProductListScreen extends StatefulWidget {
  final ApiService apiService;

  const ProductListScreen({super.key, required this.apiService});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late final ProductService _service;

  final TextEditingController _searchController = TextEditingController();

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
    setState(() {
      loading = true;
      error = "";
    });

    try {
      final result = await _service.getProducts();

      if (!mounted) return;

      setState(() {
        products = result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> searchProduct(String keyword) async {
    if (keyword.trim().isEmpty) {
      loadProducts();
      return;
    }

    setState(() {
      loading = true;
      error = "";
    });

    try {
      final result = await _service.searchProduct(keyword);

      if (!mounted) return;

      setState(() {
        products = result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Widget _buildContent() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),

            const SizedBox(height: 16),

            Text(error, textAlign: TextAlign.center),

            const SizedBox(height: 16),

            ElevatedButton(onPressed: loadProducts, child: const Text("Retry")),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 70, color: Colors.grey),

            SizedBox(height: 16),

            Text("No products found", style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadProducts,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];

          return ProductCard(
            product: product,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(
                    productId: product.productId,
                    apiService: widget.apiService,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductSearchBar(
                  controller: _searchController,
                  onSubmitted: searchProduct,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      loadProducts();
                    }
                  },
                  onClear: () {
                    _searchController.clear();
                    loadProducts();
                  },
                ),

                const SizedBox(height: 16),

                Text(
                  "${products.length} Products",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),

          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
