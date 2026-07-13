import 'package:flutter/material.dart';

import 'package:fruit_store/core/constants/app_colors.dart';
import 'package:fruit_store/features/products/data/models/product_model.dart';
import 'package:fruit_store/features/products/data/services/product_service.dart';
import 'package:fruit_store/features/products/presentation/widgets/product_card.dart';
import 'package:fruit_store/services/app_session.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<ProductModel>> _productsFuture;

  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<ProductModel>> _loadProducts() async {
    final products = await _productService.getProducts();

    _allProducts = products;
    _filteredProducts = products;

    return products;
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _productsFuture = _loadProducts();
    });

    await _productsFuture;
  }

  void _searchProducts(String keyword) {
    final query = keyword.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((product) {
          final name = product.productName.toLowerCase();
          final category = product.categoryName.toLowerCase();
          final cropName = product.cropName.toLowerCase();

          return name.contains(query) ||
              category.contains(query) ||
              cropName.contains(query);
        }).toList();
      }
    });
  }

  void _goToProductDetail(ProductModel product) {
    Navigator.pushNamed(
      context,
      '/product-detail',
      arguments: product,
    );
  }

  void _openSideMenu() {
    final session = AppSession.instance;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Menu',
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.78,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF171717),
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(22),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      if (session.isLoggedIn)
                        _buildLoggedInMenuCard(session)
                      else
                        _buildSideMenuItem(
                          icon: Icons.login,
                          title: 'Login',
                          subtitle: 'Đăng nhập tài khoản',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/login');
                          },
                        ),

                      const SizedBox(height: 14),

                      _buildDisabledSideMenuItem(
                        icon: Icons.person_outline,
                        title: 'Thông tin cá nhân',
                      ),

                      const SizedBox(height: 14),

                      _buildDisabledSideMenuItem(
                        icon: Icons.shopping_basket_outlined,
                        title: 'Giỏ hàng của tôi',
                      ),

                      const SizedBox(height: 14),

                      _buildDisabledSideMenuItem(
                        icon: Icons.receipt_long_outlined,
                        title: 'Đơn hàng',
                      ),

                      if (session.isLoggedIn) ...[
                        const SizedBox(height: 14),
                        _buildLogoutItem(),
                      ],

                      const Spacer(),

                      const Center(
                        child: Text(
                          'Fruit Store',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Center(
                        child: Text(
                          'Phiên bản: 1.0.0',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  void _goToCart() {
    Navigator.pushNamed(context, '/cart');
  }

  Widget _buildLoggedInMenuCard(AppSession session) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Text(
              session.avatarLetter,
              style: const TextStyle(
                color: AppColors.primaryOrange,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.displayName ?? 'Customer',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  session.role ?? 'Customer',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.verified_user_outlined,
            color: AppColors.primaryOrange,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildSideMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF333333),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primaryOrange,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledSideMenuItem({
    required IconData icon,
    required String title,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primaryOrange,
            size: 27,
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const Icon(
            Icons.lock_outline,
            color: Colors.white24,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutItem() {
    return GestureDetector(
      onTap: () {
        AppSession.instance.clear();

        Navigator.pop(context);

        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã đăng xuất'),
            backgroundColor: AppColors.primaryOrange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        decoration: BoxDecoration(
          color: const Color(0xFF303030),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.logout,
              color: AppColors.primaryOrange,
              size: 27,
            ),
            SizedBox(width: 18),
            Expanded(
              child: Text(
                'Đăng xuất',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(ProductModel product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm ${product.productName.trim()} vào giỏ hàng'),
        backgroundColor: AppColors.primaryOrange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _openFilter() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng lọc sản phẩm sẽ được phát triển sau'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: SafeArea(
        child: FutureBuilder<List<ProductModel>>(
          future: _productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryOrange,
                ),
              );
            }

            if (snapshot.hasError) {
              return _buildError(snapshot.error.toString());
            }

            return RefreshIndicator(
              color: AppColors.primaryOrange,
              onRefresh: _refreshProducts,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(),
                  ),

                  SliverToBoxAdapter(
                    child: _buildSearchAndFilter(),
                  ),

                  SliverToBoxAdapter(
                    child: _buildSectionTitle(),
                  ),

                  if (_filteredProducts.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmpty(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final product = _filteredProducts[index];

                            return ProductCard(
                              product: product,
                              onTap: () => _goToProductDetail(product),
                              onAddToCart: () => _addToCart(product),
                            );
                          },
                          childCount: _filteredProducts.length,
                        ),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 18,
                          crossAxisSpacing: 16,
                          mainAxisExtent: 255,                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIconButton(
                icon: Icons.menu,
                onTap: _openSideMenu,
              ),

              const Spacer(),

              GestureDetector(
                onTap: _goToCart,
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF3E5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_basket_outlined,
                        color: AppColors.primaryOrange,
                        size: 21,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'My basket',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const SizedBox(height: 4),

          const Text(
            'What fruit do you want to buy today?',
            style: TextStyle(
              color: Color(0xFF27214D),
              fontSize: 20,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5FA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _searchProducts,
                decoration: const InputDecoration(
                  hintText: 'Search for fruit salad combos',
                  hintStyle: TextStyle(
                    color: Color(0xFFAAA6C3),
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFFAAA6C3),
                    size: 21,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 15,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          GestureDetector(
            onTap: _openFilter,
            child: Container(
              width: 48,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.tune,
                color: AppColors.primaryOrange,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 2, 20, 16),
      child: Text(
        'Recommended Fruits',
        style: TextStyle(
          color: Color(0xFF27214D),
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 38,
        height: 38,
        child: Icon(
          icon,
          color: const Color(0xFF27214D),
          size: 25,
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.primaryOrange,
              size: 48,
            ),

            const SizedBox(height: 12),

            const Text(
              'Không thể tải sản phẩm',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  _productsFuture = _loadProducts();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text(
        'Không tìm thấy sản phẩm phù hợp',
        style: TextStyle(
          color: AppColors.textGrey,
          fontSize: 15,
        ),
      ),
    );
  }
}