import 'package:flutter/material.dart';
import 'package:fruit_store/widgets/order/order_action_card.dart';

import '../../models/order.model.dart';
import '../../services/api.service.dart';
import '../../services/staff.service.dart';

import '../../widgets/order/customer_information_card.dart';
import '../../widgets/order/order_information_card.dart';
import '../../widgets/order/product_card.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  final ApiService apiService;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    required this.apiService,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late final StaffOrderService _orderService;

  Order? order;
  bool _updated = false;
  bool isLoading = true;

  String error = "";

  @override
  void initState() {
    super.initState();

    _orderService = StaffOrderService(widget.apiService);

    fetchOrder();
  }

  Future<void> fetchOrder() async {
    setState(() {
      isLoading = true;
      error = "";
    });

    try {
      final result = await _orderService.getOrderById(widget.orderId);

      setState(() {
        order = result;
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

  Future<void> _deliverOrder() async {
    await _orderService.updateDeliveryStatus(widget.orderId);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Order marked as Delivered")));
    _updated = true;
    await fetchOrder();
  }

  Future<void> _completeOrder() async {
    await _orderService.updateCompletedStatus(widget.orderId);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Order marked as Completed")));
    _updated = true;

    await fetchOrder();
  }

  Future<void> _cancelOrder() async {
    await _orderService.updateCancelStatus(widget.orderId);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Order Cancelled")));
    _updated = true;

    await fetchOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, _updated);
          },
        ),
        title: Text("Order #${widget.orderId}"),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),

      backgroundColor: Colors.grey.shade100,

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error.isNotEmpty) {
      return Center(child: Text(error));
    }

    if (order == null) {
      return const Center(child: Text("Order not found"));
    }

    return RefreshIndicator(
      onRefresh: fetchOrder,
      child: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        children: [
          CustomerInformationCard(order: order!),

          OrderInformationCard(order: order!),

          /// Products Title
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              "Products",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
          ),

          /// Products
          ...(order!.orderDetails ?? [])
              .map((item) => ProductCard(item: item))
              .toList(),

          const SizedBox(height: 12),

          OrderActionCard(
            status: order!.status,
            onDeliver: _deliverOrder,
            onComplete: _completeOrder,
            onCancel: _cancelOrder,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
