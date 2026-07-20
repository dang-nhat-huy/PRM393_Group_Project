// lib/services/order.service.dart
import '../models/order.model.dart';
import 'api.service.dart';
import '../constants/order.constant.dart';

class OrderService {
  final ApiService _api;

  OrderService(this._api);

  /// Paginated list of all orders.
  Future<PaginatedOrderResponse> getAll({
    int? pageSize,
    int? pageIndex,
    OrderStatus? status,
  }) async {
    final query = <String, String>{};
    if (pageSize != null) query['pageSize'] = pageSize.toString();
    if (pageIndex != null) query['pageIndex'] = pageIndex.toString();
    if (status != null) query['status'] = status.name;
    final data = await _api.get('/api/v1/Order/order-list', query: query);
    return PaginatedOrderResponse.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// Orders by customer account ID.
  Future<PaginatedOrderResponse> getByCustomerId(int id, {
    int? pageSize,
    int? pageIndex,
    OrderStatus? status,
  }) async {
    final query = <String, String>{};
    if (pageSize != null) query['pageSize'] = pageSize.toString();
    if (pageIndex != null) query['pageIndex'] = pageIndex.toString();
    if (status != null) query['status'] = status.name;
    final data = await _api.get('/api/v1/Order/order-list-by-customer/$id', query: query);
    return PaginatedOrderResponse.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// Orders for the currently logged-in account.
  Future<PaginatedOrderResponse> getByCurrentAccount({
    int? pageSize,
    int? pageIndex,
    OrderStatus? status,
  }) async {
    final query = <String, String>{};
    if (pageSize != null) query['pageSize'] = pageSize.toString();
    if (pageIndex != null) query['pageIndex'] = pageIndex.toString();
    if (status != null) query['status'] = status.name;
    final data = await _api.get('/api/v1/Order/order-list-by-current-account', query: query);
    return PaginatedOrderResponse.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// Single order detail by orderId.
  Future<Order> getById(int orderId) async {
    final data = await _api.get('/api/v1/Order/order/$orderId');
    return Order.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// Orders by customer name (search).
  Future<PaginatedOrderResponse> getByCustomerName(String name, {
    int? pageSize,
    int? pageIndex,
  }) async {
    final query = <String, String>{};
    if (pageSize != null) query['pageSize'] = pageSize.toString();
    if (pageIndex != null) query['pageIndex'] = pageIndex.toString();
    final data = await _api.get('/api/v1/Order/order-list-by-customer-name/$name', query: query);
    return PaginatedOrderResponse.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// Orders by customer email.
  Future<PaginatedOrderResponse> getByEmail(String email, {
    int? pageSize,
    int? pageIndex,
    OrderStatus? status,
  }) async {
    final query = <String, String>{};
    if (pageSize != null) query['pageSize'] = pageSize.toString();
    if (pageIndex != null) query['pageIndex'] = pageIndex.toString();
    if (status != null) query['status'] = status.name;
    final data = await _api.get('/api/v1/Order/order-list-by-emal/$email', query: query);
    return PaginatedOrderResponse.fromJson(data['data'] as Map<String, dynamic>);
  }

  // ── POST endpoints ──

  /// Orders within a date range.
  Future<PaginatedOrderResponse> getByDate({
    required String date,
  }) async {
    final data = await _api.post(
      '/api/v1/Order/order-list-by-date',
      data: {'date': date},
    );
    return PaginatedOrderResponse.fromJson(data['data'] as Map<String, dynamic>);
  }

  // ── PUT endpoints (status updates) ──

  /// Update order status to DELIVERED.
  Future<void> updateDeliveryStatus(int orderId) async {
    await _api.put('/api/v1/Order/updateDeliveryStatus/$orderId');
  }

  /// Update order status to COMPLETED.
  Future<void> updateCompletedStatus(int orderId) async {
    await _api.put('/api/v1/Order/updateCompletedStatus/$orderId');
  }

  /// Update order status to CANCELLED.
  Future<void> updateCancelStatus(int orderId) async {
    await _api.put('/api/v1/Order/updateCancelStatus/$orderId');
  }

  /// Create a new order.
  Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> orderItems,
    required String shippingAddress,
  }) async {
    return await _api.post(
      '/api/v1/Order/create',
      data: {
        'orderItems': orderItems,
        'shippingAddress': shippingAddress,
      },
    );
  }

  /// Generate a VNPay payment URL for an existing order.
  ///
  /// [orderId] is the ID of the order to pay for.
  /// [returnUrl] is an optional custom return URL (deep link) that VNPay
  /// will redirect to after payment completion. Use a custom scheme like
  /// `fruitstore://payment-callback?orderId=X` for mobile deep linking.
  Future<String> createOrderPayment(int orderId, {String? returnUrl}) async {
    final Map<String, dynamic>? dataPayload;
    if (returnUrl != null) {
      dataPayload = {'returnUrl': returnUrl};
    } else {
      dataPayload = null;
    }

    final response = await _api.post(
      '/api/v1/Order/createOrderPayment/$orderId',
      data: dataPayload,
    );

    // The response may contain the URL in 'data' or directly as a string
    final data = response['data'];
    if (data is String) return data;
    if (data is Map && data.containsKey('paymentUrl')) return data['paymentUrl'] as String;
    return data.toString();
  }

  /// Check payment status for an order.
  Future<Map<String, dynamic>> checkPaymentStatus(int orderId) async {
    final response = await _api.get('/api/vnpay/PaymentByOrderId/$orderId');
    return response;
  }
}