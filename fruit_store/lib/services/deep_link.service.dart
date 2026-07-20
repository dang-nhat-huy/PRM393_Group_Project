// lib/services/deep_link.service.dart

/// Handles deep links for the app, particularly VNPay payment callbacks.
///
/// The app registers a custom URL scheme `fruitstore://payment-callback`
/// so that after a user completes payment on VNPay, they are redirected
/// back to the app instead of staying in the browser.
class DeepLinkService {
  /// The custom URL scheme used for payment callbacks.
  static const String scheme = 'fruitstore';
  static const String host = 'payment-callback';

  /// Builds the return URL for VNPay payment callback.
  ///
  /// This URL is passed to the backend when creating an order,
  /// and the backend uses it as the VNPay return URL.
  /// After payment, VNPay redirects to this URL, which opens the app.
  static String buildPaymentReturnUrl(int orderId) {
    return '$scheme://$host?orderId=$orderId';
  }

  /// Parses a deep link URI and extracts the orderId.
  ///
  /// Returns the orderId if the URI matches the expected format, or null.
  static int? parseOrderIdFromUri(Uri uri) {
    if (uri.scheme == scheme && uri.host == host) {
      final orderIdStr = uri.queryParameters['orderId'];
      if (orderIdStr != null) {
        return int.tryParse(orderIdStr);
      }
    }
    return null;
  }

  /// Checks if a URI is a payment callback deep link.
  static bool isPaymentCallback(Uri uri) {
    return uri.scheme == scheme && uri.host == host;
  }
}