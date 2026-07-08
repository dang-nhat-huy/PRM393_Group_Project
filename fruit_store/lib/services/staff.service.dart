import '../models/order.dart';
import 'api.service.dart';

class StaffOrderService {
  final ApiService _api;

  StaffOrderService(this._api);

  /// ===============================
  /// Get All Orders
  /// ===============================
  Future<List<Order>> getOrders({
    int pageIndex = 1,
    int pageSize = 20,
  }) async {
    final response = await _api.get(
      '/api/v1/Order/order-list',
      query: {
        'pageIndex': pageIndex.toString(),
        'pageSize': pageSize.toString(),
      },
    );

    final List<dynamic> items =
        response['data']?['items'] as List<dynamic>? ?? [];

    return items
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// ===============================
  /// Get Order By Id
  /// ===============================
  Future<Order?> getOrderById(int orderId) async {
    final response = await _api.get(
      '/api/v1/Order/order/$orderId',
    );

    if (response['data'] == null) {
      return null;
    }

    return Order.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  /// ===============================
  /// Search By Email
  /// ===============================
  Future<List<Order>> getByEmail(
    String email, {
    int pageIndex = 1,
    int pageSize = 20,
  }) async {
    final response = await _api.get(
      '/api/v1/Order/order-list-by-emal/$email',
      query: {
        'pageIndex': pageIndex.toString(),
        'pageSize': pageSize.toString(),
      },
    );

    final List<dynamic> items =
        response['data']?['items'] as List<dynamic>? ?? [];

    return items
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// ===============================
  /// Search By Customer Name
  /// ===============================
  Future<List<Order>> getByCustomerName(
    String customerName, {
    int pageIndex = 1,
    int pageSize = 20,
  }) async {
    final response = await _api.get(
      '/api/v1/Order/order-list-by-customer-name/$customerName',
      query: {
        'pageIndex': pageIndex.toString(),
        'pageSize': pageSize.toString(),
      },
    );

    final List<dynamic> items =
        response['data']?['items'] as List<dynamic>? ?? [];

    return items
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// ===============================
  /// Filter By Status
  /// ===============================
  Future<List<Order>> getByStatus(
    String status, {
    int pageIndex = 1,
    int pageSize = 20,
  }) async {
    final response = await _api.get(
      '/api/v1/Order/order-list',
      query: {
        'status': status,
        'pageIndex': pageIndex.toString(),
        'pageSize': pageSize.toString(),
      },
    );

    final List<dynamic> items =
        response['data']?['items'] as List<dynamic>? ?? [];

    return items
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// ===============================
  /// Filter By Date
  /// ===============================
  Future<List<Order>> getByDate(String date) async {
    final response = await _api.post(
      '/api/v1/Order/order-list-by-date',
      data: {
        'date': date,
      },
    );

    final List<dynamic> items =
        response['data']?['items'] as List<dynamic>? ?? [];

    return items
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// ===============================
  /// Update Delivery
  /// ===============================
  Future<void> updateDeliveryStatus(int orderId) async {
    await _api.put(
      '/api/v1/Order/updateDeliveryStatus/$orderId',
    );
  }

  /// ===============================
  /// Update Completed
  /// ===============================
  Future<void> updateCompletedStatus(int orderId) async {
    await _api.put(
      '/api/v1/Order/updateCompletedStatus/$orderId',
    );
  }

  /// ===============================
  /// Update Cancel
  /// ===============================
  Future<void> updateCancelStatus(int orderId) async {
    await _api.put(
      '/api/v1/Order/updateCancelStatus/$orderId',
    );
  }
}