class CurrencyFormatter {
  static String formatVnd(num value) {
    final text = value.toStringAsFixed(0);

    final formatted = text.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
    );

    return '${formatted}đ';
  }
}