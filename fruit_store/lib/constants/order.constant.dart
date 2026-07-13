enum OrderStatus {
  unpaid(0, 'UNPAID'),
  paid(1, 'PAID'),
  undischarged(2, 'UNDISCHARGED'),
  pending(3, 'PENDING'),
  delivered(4, 'DELIVERED'),
  completed(5, 'COMPLETED'),
  cancelled(6, 'CANCELLED');


  final int id;
  final String name;

  const OrderStatus(this.id, this.name);

  /// Handles both int (5) and String ("ACTIVE") from API
  static OrderStatus orderStatusFromJson(dynamic value) {
    if (value is int) {
      return OrderStatus.values.firstWhere(
        (s) => s.id == value,
        orElse: () => throw ArgumentError('Unknown OrderStatus id: $value'),
      );
    }
    if (value is String) {
      return OrderStatus.values.firstWhere(
        (s) => s.name == value.toUpperCase(),
        orElse: () => throw ArgumentError('Unknown OrderStatus text: $value'),
      );
    }
    throw ArgumentError('Invalid OrderStatus type: $value');
  }

  static int? orderStatusToJson(OrderStatus? status) => status?.id;
}