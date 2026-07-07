// lib/screens/admin/revenue_screen.dart
import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../constants/order.constant.dart';
import '../../models/order.model.dart';
import '../../services/order.service.dart';
import '../../widgets/pagination_bar.dart';
import '../../widgets/status_badge.dart';
import 'order_detail_screen.dart';
import 'revenue_search_result.dart';

class RevenueScreen extends StatefulWidget {
  final OrderService orderService;

  const RevenueScreen({super.key, required this.orderService});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Pagination
  int _pageIndex = 1;
  int _totalItems = 0;
  int _totalPages = 0;
  final int _pageSize = 10;
  bool _hasNext = false;
  bool _hasPrevious = false;

  // Filters
  OrderStatus? _selectedStatus;
  final TextEditingController _searchController = TextEditingController();

  // Computed revenue totals (from current page data)
  int _totalRevenue = 0;
  double _averageOrderValue = 0;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await widget.orderService.getAll(
        pageSize: _pageSize,
        pageIndex: _pageIndex,
        status: _selectedStatus,
      );

      final orders = response.items;
      final totalRevenue =
          orders.fold<int>(0, (sum, o) => sum + o.totalPrice);
      final avgValue =
          orders.isNotEmpty ? totalRevenue / orders.length : 0.0;

      setState(() {
        _orders = orders;
        _totalItems = response.totalItemCount;
        _totalPages = response.totalPagesCount;
        _pageIndex = response.pageIndex;
        _hasNext = response.next;
        _hasPrevious = response.previous;
        _totalRevenue = totalRevenue;
        _averageOrderValue = avgValue;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load orders: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RevenueSearchResultScreen(
            orderService: widget.orderService,
            query: query,
          ),
        ),
      );
    }
  }

  Future<void> _refreshOrders() async {
    _pageIndex = 1;
    await _loadOrders();
  }

  void _goToPage(int page) {
    setState(() {
      _pageIndex = page;
    });
    _loadOrders();
  }

  void _navigateToDetail(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(
          order: order,
          orderService: widget.orderService,
        ),
      ),
    );
  }

  Color _statusColor(OrderStatus? status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.active:
        return Colors.blue;
      case OrderStatus.delivered:
        return AppTheme.successGreen;
      case OrderStatus.completed:
        return const Color(0xFF1B5E20);
      case OrderStatus.cancelled:
        return AppTheme.errorRed;
      default:
        return AppTheme.textGray;
    }
  }

  String _formatCurrency(int amount) {
    return '₫${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revenue Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by customer name or email...',
                prefixIcon:
                    const Icon(Icons.search, color: AppTheme.textGray),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onSubmitted: (_) => _onSearch(),
              textInputAction: TextInputAction.search,
            ),
          ),

          // Filter chips
          if (_selectedStatus != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Chip(
                    label: Text(
                      'Status: ${_selectedStatus!.name[0].toUpperCase() + _selectedStatus!.name.substring(1)}',
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _selectedStatus = null;
                      });
                      _refreshOrders();
                    },
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedStatus = null;
                      });
                      _refreshOrders();
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),

          // Revenue summary cards
          _buildSummaryCards(),

          // Stats bar
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppTheme.lightOrange.withValues(alpha: 0.1),
            child: Row(
              children: [
                Text(
                  '$_totalItems orders',
                  style: const TextStyle(
                    color: AppTheme.textGray,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '·  ${_formatCurrency(_totalRevenue)} total',
                  style: const TextStyle(
                    color: AppTheme.textGray,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: _buildContent(),
          ),

          // Pagination
          if (_hasNext || _hasPrevious)
            PaginationBar(
              pageIndex: _pageIndex,
              totalPages: _totalPages,
              hasNext: _hasNext,
              hasPrevious: _hasPrevious,
              onPageChanged: _goToPage,
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppTheme.white,
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              icon: Icons.attach_money,
              label: 'Revenue',
              value: _formatCurrency(_totalRevenue),
              color: AppTheme.successGreen,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SummaryCard(
              icon: Icons.shopping_cart,
              label: 'Orders',
              value: '$_totalItems',
              color: AppTheme.primaryOrange,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SummaryCard(
              icon: Icons.trending_up,
              label: 'Avg / Order',
              value: _formatCurrency(_averageOrderValue.round()),
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppTheme.errorRed),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshOrders,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long,
                size: 64,
                color: AppTheme.textGray.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              'No orders found',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedStatus != null
                  ? 'Try adjusting your filters'
                  : 'Orders will appear here',
              style: const TextStyle(color: AppTheme.textGray),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshOrders,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _orders.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final order = _orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final itemCount = order.orderItems?.length ?? 0;
    final customerName = order.fullname ?? 'Unknown';
    final status = order.status;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.15),
          child: Text(
            '#${order.orderId}',
            style: const TextStyle(
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                customerName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              _formatCurrency(order.totalPrice),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryOrange,
                fontSize: 15,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  order.createdAt,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textGray),
                ),
                const SizedBox(width: 8),
                Text(
                  itemCount == 1 ? '1 item' : '$itemCount items',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textGray),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (status != null)
              StatusBadge(
                text: status.name.toUpperCase(),
                color: _statusColor(status),
                background: _statusColor(status).withValues(alpha: 0.1),
              ),
          ],
        ),
        trailing:
            const Icon(Icons.chevron_right, color: AppTheme.textGray),
        onTap: () => _navigateToDetail(order),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Orders',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text('Status',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setStatus) {
                  return Wrap(
                    spacing: 8,
                    children: OrderStatus.values.map((status) {
                      final isSelected = _selectedStatus == status;
                      return ChoiceChip(
                        label: Text(status.name[0].toUpperCase() +
                            status.name.substring(1)),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryOrange,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.white
                              : AppTheme.textDark,
                        ),
                        onSelected: (selected) {
                          setStatus(() {
                            _selectedStatus = selected ? status : null;
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _refreshOrders();
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Summary Card widget ──

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textGray,
            ),
          ),
        ],
      ),
    );
  }
}