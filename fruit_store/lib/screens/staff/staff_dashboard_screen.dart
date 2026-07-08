import 'package:flutter/material.dart';

import '../../models/order.dart';
import '../../services/api.service.dart';
import '../../services/staff.service.dart';

import '../../widgets/order/order_filter_bar.dart';
import '../../widgets/order/order_search_bar.dart';
import '../../widgets/order/order_table.dart';

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

  String error = '';

  String statusFilter = "All";

  final List<String> filters = const [
    "All",
    "Paid",
    "Pending",
    "Processing",
    "Delivered",
    "Completed",
    "Cancelled",
  ];

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
      final result = await _orderService.getOrders();

      setState(() {
        orders = result;
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

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ===========================
            /// Search + Filter
            /// ===========================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: OrderSearchBar(
                    controller: _searchController,

                    onSubmitted: (value) {
                      searchOrderById(value);
                    },

                    onChanged: (value) {
                      if (value.isEmpty) {
                        fetchOrders();
                      }
                    },

                    onClear: () {
                      fetchOrders();
                    },
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  flex: 2,
                  child: OrderFilterBar(
                    filters: filters,

                    selectedFilter: statusFilter,

                    onSelected: (value) {
                      setState(() {
                        statusFilter = value;
                      });


                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// ===========================
            /// Table
            /// ===========================
            Expanded(
              child: OrderTable(
                orders: orders,

                isLoading: isLoading,

                error: error,

                onRefresh: fetchOrders,

                onViewDetail: (order) {
                  print("Order ID: ${order.orderId}");

                  /// TODO
                  ///
                  /// Navigator.push(
                  ///   context,
                  ///   MaterialPageRoute(
                  ///      builder: (_) =>
                  ///      OrderDetailScreen(order: order),
                  ///   ),
                  /// );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }
}
