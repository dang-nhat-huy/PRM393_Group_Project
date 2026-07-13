// lib/screens/customer/shop_tab.dart
import 'package:flutter/material.dart';

import '../../constants/app_theme.dart';
import 'package:fruit_store/models/product.model.dart';
import '../../services/cart.service.dart';
import '../../services/product.service.dart';

class ShopTab extends StatefulWidget {
  final ProductService productService;
  final CartService cartService;

  const ShopTab({
    super.key,
    required this.productService,
    required this.cartService,
  });

  @override
  State<ShopTab> createState() => _ShopTabState();
}

class _ShopTabState extends State<ShopTab> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _allProducts = [];
  List<Product> _displayedProducts = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';
  String? _error;

  final List<String> _categories = ['All', 'Rau Ăn Lá', 'Củ', 'Quả'];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await widget.productService.getProducts(pageSize: 50);
      setState(() {
        _allProducts = list;
        _filterAndSearch();
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load products. Tap to retry.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterAndSearch() {
    var list = [..._allProducts];
    
    // Category filter
    if (_selectedCategory != 'All') {
      list = list.where((p) => p.categoryName == _selectedCategory).toList();
    }

    // Search query filter
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((p) => p.productName.toLowerCase().contains(query)).toList();
    }

    setState(() {
      _displayedProducts = list;
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _filterAndSearch();
    });
  }

  Future<void> _addToCart(Product product, int quantity) async {
    try {
      await widget.cartService.addToCart(product.productId, quantity);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${product.productName} to cart successfully!'),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add product to cart.'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showProductDetails(Product product) {
    int orderQuantity = 1;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Pull handler
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.borderGray,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  
                  // Product info
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: product.image != null && product.image!.isNotEmpty
                                ? Image.network(
                                    product.image!,
                                    width: double.infinity,
                                    height: 220,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildPlaceholderImage(220),
                                  )
                                : _buildPlaceholderImage(220),
                          ),
                          const SizedBox(height: 18),
                          
                          // Name and category
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  product.productName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ),
                              if (product.categoryName != null)
                                Chip(
                                  label: Text(product.categoryName!),
                                  visualDensity: VisualDensity.compact,
                                ),
                            ],
                          ),
                          
                          // Price & Unit
                          const SizedBox(height: 8),
                          Text(
                            '${product.price.toStringAsFixed(0)}đ${product.unit != null ? " / ${product.unit}" : ""}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryOrange,
                            ),
                          ),
                          
                          // Stock count
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                product.stockQuantity > 0 ? Icons.check_circle_outline : Icons.error_outline,
                                size: 16,
                                color: product.stockQuantity > 0 ? AppTheme.successGreen : AppTheme.errorRed,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                product.stockQuantity > 0 ? 'In Stock (${product.stockQuantity})' : 'Out of stock',
                                style: TextStyle(
                                  color: product.stockQuantity > 0 ? AppTheme.successGreen : AppTheme.errorRed,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          
                          // Description
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.description ?? 'No description available for this delicious organic fruit item.',
                            style: const TextStyle(
                              color: AppTheme.textGray,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Bottom action bar
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      border: Border(top: BorderSide(color: AppTheme.borderGray.withValues(alpha: 0.5))),
                    ),
                    child: Row(
                      children: [
                        // Quantity controls
                        if (product.stockQuantity > 0) ...[
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.borderGray),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 18),
                                  onPressed: orderQuantity > 1
                                      ? () => setModalState(() => orderQuantity--)
                                      : null,
                                ),
                                Text(
                                  '$orderQuantity',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 18),
                                  onPressed: orderQuantity < product.stockQuantity
                                      ? () => setModalState(() => orderQuantity++)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        
                        // Add Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: product.stockQuantity > 0
                                ? () {
                                    Navigator.pop(context);
                                    _addToCart(product, orderQuantity);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: product.stockQuantity > 0
                                  ? AppTheme.primaryOrange
                                  : AppTheme.textGray,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              product.stockQuantity > 0
                                  ? 'Add to Cart • ${(product.price * orderQuantity).toStringAsFixed(0)}đ'
                                  : 'Out of Stock',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlaceholderImage(double height) {
    return Container(
      width: double.infinity,
      height: height,
      color: Colors.orange.shade50,
      child: const Icon(
        Icons.image_outlined,
        color: AppTheme.primaryOrange,
        size: 50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organic Store'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          )
        ],
      ),
      body: Column(
        children: [
          // Banner & Welcome
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppTheme.primaryOrange,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Healthy Organic Fruits!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Freshly harvested directly from farm to your tables.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 16),
                // Search field
                TextField(
                  controller: _searchController,
                  onChanged: (_) => _filterAndSearch(),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textGray),
                    fillColor: AppTheme.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Category Selector
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => _onCategorySelected(category),
                    selectedColor: AppTheme.primaryOrange,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.white : AppTheme.textDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: AppTheme.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),

          // Main product grid list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryOrange),
                  )
                : _error != null
                    ? Center(
                        child: TextButton.icon(
                          onPressed: _loadProducts,
                          icon: const Icon(Icons.refresh),
                          label: Text(_error!),
                        ),
                      )
                    : _displayedProducts.isEmpty
                        ? const Center(
                            child: Text(
                              'No products found.',
                              style: TextStyle(color: AppTheme.textGray),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _displayedProducts.length,
                            itemBuilder: (context, index) {
                              final product = _displayedProducts[index];
                              return Card(
                                elevation: 1,
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: InkWell(
                                  onTap: () => _showProductDetails(product),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Product Image
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                          ),
                                          child: product.image != null && product.image!.isNotEmpty
                                              ? Image.network(
                                                  product.image!,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => _buildPlaceholderImage(120),
                                                )
                                              : _buildPlaceholderImage(120),
                                        ),
                                      ),
                                      
                                      // Details
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.productName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: AppTheme.textDark,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              product.categoryName ?? 'Fruit',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.textGray,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${product.price.toStringAsFixed(0)}đ',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                      color: AppTheme.primaryOrange,
                                                    ),
                                                  ),
                                                ),
                                                
                                                // Add to Cart shortcut button
                                                product.stockQuantity > 0
                                                    ? InkWell(
                                                        onTap: () => _addToCart(product, 1),
                                                        borderRadius: BorderRadius.circular(20),
                                                        child: Container(
                                                          padding: const EdgeInsets.all(6),
                                                          decoration: const BoxDecoration(
                                                            color: AppTheme.primaryOrange,
                                                            shape: BoxShape.circle,
                                                          ),
                                                          child: const Icon(
                                                            Icons.add_shopping_cart,
                                                            color: AppTheme.white,
                                                            size: 16,
                                                          ),
                                                        ),
                                                      )
                                                    : const Text(
                                                        'Hết hàng',
                                                        style: TextStyle(
                                                          color: AppTheme.errorRed,
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
