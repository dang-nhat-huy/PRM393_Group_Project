import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/order.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  List<Order> orders = [];
  bool isLoading = true;
  String error = '';
  String searchQuery = '';
  String statusFilter = 'All';

  final String token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1laWQiOiIzIiwicm9sZSI6IlN0YWZmIiwibmJmIjoxNzgzMzIxMjg3LCJleHAiOjE3ODMzMjg0ODcsImlhdCI6MTc4MzMyMTI4NywiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo3MDY3LyIsImF1ZCI6Imh0dHA6Ly9sb2NhbGhvc3Q6NzA2Ny8ifQ.B5TM609R90l7hYzMttJTfFJpXF0cuIgsLq_T_-s5Mes";

  // Fetch danh sách đơn hàng
  // Fetch danh sách
  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://iotfarm.onrender.com/api/v1/Order/order-list?pageIndex=1&pageSize=20',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Fetch List - Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['data']?['items'] ?? [];

        setState(() {
          orders = items.map((json) => Order.fromJson(json)).toList();
        });
      } else {
        setState(() => error = 'Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => error = 'Lỗi kết nối: $e');
      print('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Tìm theo ID
  Future<void> searchOrderById(String id) async {
    if (id.trim().isEmpty) {
      fetchOrders();
      return;
    }

    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://iotfarm.onrender.com/api/v1/Order/order/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Search ID $id - Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          final order = Order.fromJson(data['data']);
          setState(() => orders = [order]);
        } else {
          setState(() => error = 'Không tìm thấy đơn hàng');
        }
      } else {
        setState(() => error = 'Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => error = 'Lỗi kết nối: $e');
      print('Search Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Orders'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm theo ID đơn hàng...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onSubmitted: (value) {
                searchOrderById(value.trim());
              },
              onChanged: (value) {
                if (value.isEmpty) {
                  fetchOrders();
                }
              },
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Active', 'Delivered', 'In Progress']
                    .map(
                      (label) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(label),
                          selected: statusFilter == label,
                          onSelected: (selected) {
                            setState(() => statusFilter = label);
                          },
                          backgroundColor: statusFilter == label
                              ? Colors.indigo
                              : null,
                          labelStyle: TextStyle(
                            color: statusFilter == label ? Colors.white : null,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey[100],
            child: const Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'ID',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Customer',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 40),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error.isNotEmpty
                ? Center(child: Text(error))
                : ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 1, child: Text('#${order.orderId}')),
                            Expanded(flex: 2, child: Text(order.fullname)),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${order.totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}đ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Chip(
                                label: Text(order.status),
                                backgroundColor: _getStatusColor(order.status),
                              ),
                            ),
                            const Icon(Icons.more_vert, size: 20),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green.shade100;
      case 'in progress':
        return Colors.orange.shade100;
      case 'active':
      case 'paid':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}
