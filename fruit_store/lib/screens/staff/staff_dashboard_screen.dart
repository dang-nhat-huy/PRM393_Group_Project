import 'package:flutter/material.dart';
import 'package:fruit_store/models/order.model.dart';
import 'package:fruit_store/screens/staff/order_detail_screen.dart';

import '../../services/api.service.dart';
import '../../services/staff.service.dart';

import '../../widgets/order/order_card.dart';
import '../../widgets/order/order_filter_bar.dart';
import '../../widgets/order/order_search_bar.dart';
import '../../widgets/pagination_bar.dart';

class StaffDashboardScreen extends StatefulWidget {
  final ApiService apiService;

  const StaffDashboardScreen({super.key, required this.apiService});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  late final StaffOrderService _orderService;

  final TextEditingController _searchController = TextEditingController();

  List<Order> orders = [];

  bool isLoading = true;

  String error = "";

  String statusFilter = "All";

  final List<String> filters = const [
    "All",
    "Paid",
    "Undischarged",
    "Pending",
    "Delivered",
    "Completed",
    "Cancelled",
  ];

  // Pagination

  int pageIndex = 1;

  int totalPages = 1;

  int totalItems = 0;

  bool hasNext = false;

  bool hasPrevious = false;

  final int pageSize = 10;

  @override
  void initState() {
    super.initState();

    _orderService = StaffOrderService(widget.apiService);

    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
      error = "";
    });

    try {
      String? status;

      switch (statusFilter) {
        case "All":
          status = null;
          break;
        case "Paid":
          status = "PAID";
          break;
        case "Undischarged":
          status = "UNDISCHARGED";
          break;
        case "Pending":
          status = "PENDING";
          break;
        case "Delivered":
          status = "DELIVERED";
          break;
        case "Completed":
          status = "COMPLETED";
          break;
        case "Cancelled":
          status = "CANCELLED";
          break;
      }

      final response = await _orderService.getOrders(
        pageIndex: pageIndex,
        pageSize: pageSize,
        status: status,
      );

      setState(() {
        orders = response.items;

        totalItems = response.totalItemCount;

        totalPages = response.totalPagesCount;

        pageIndex = response.pageIndex;

        hasNext = response.next;

        hasPrevious = response.previous;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> searchOrderById(String value) async {
    if (value.trim().isEmpty) {
      pageIndex = 1;
      fetchOrders();
      return;
    }

    setState(() {
      isLoading = true;
      error = "";
    });

    try {
      final order = await _orderService.getOrderById(int.parse(value));

      setState(() {
        if (order == null) {
          orders = [];
        } else {
          orders = [order];
        }

        totalItems = orders.length;

        totalPages = 1;

        pageIndex = 1;

        hasNext = false;

        hasPrevious = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildContent() {
    if (isLoading) {
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

            ElevatedButton(onPressed: fetchOrders, child: const Text("Retry")),
          ],
        ),
      );
    }

    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 70, color: Colors.grey),

            SizedBox(height: 16),

            Text("No orders found", style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchOrders,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          return OrderCard(
            order: order,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(
                    orderId: order.orderId,
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
        title: const Text("Staff Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Search
                OrderSearchBar(
                  controller: _searchController,
                  onSubmitted: (value) {
                    searchOrderById(value);
                  },
                  onChanged: (value) {
                    if (value.isEmpty) {
                      pageIndex = 1;
                      fetchOrders();
                    }
                  },
                  onClear: () {
                    pageIndex = 1;
                    fetchOrders();
                  },
                ),

                const SizedBox(height: 16),

                /// Filter
                OrderFilterBar(
                  filters: filters,
                  selectedFilter: statusFilter,
                  onSelected: (value) {
                    setState(() {
                      statusFilter = value;
                      pageIndex = 1;
                    });

                    fetchOrders();
                  },
                ),

                const SizedBox(height: 16),

                /// Total Orders
                Row(
                  children: [
                    Text(
                      "$totalItems Orders",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),

          /// Order List
          Expanded(child: _buildContent()),

          /// Pagination
          if (!isLoading && error.isEmpty && orders.isNotEmpty)
            PaginationBar(
              pageIndex: pageIndex,
              totalPages: totalPages,
              hasNext: hasNext,
              hasPrevious: hasPrevious,
              onPageChanged: (page) {
                setState(() {
                  pageIndex = page;
                });

                fetchOrders();
              },
            ),
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
