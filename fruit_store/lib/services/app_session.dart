class AppSession {
  AppSession._();

  static final AppSession instance = AppSession._();

  String? token;
  String? role;
  int? accountId;
  String? email;
  String? displayName;

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  void setAuth({
    required String token,
    required String role,
    required int accountId,
    required String email,
    String? displayName,
  }) {
    this.token = token;
    this.role = role;
    this.accountId = accountId;
    this.email = email;
    this.displayName = displayName ?? _getNameFromEmail(email);
  }

  void clear() {
    token = null;
    role = null;
    accountId = null;
    email = null;
    displayName = null;
  }

  String get avatarLetter {
    final name = displayName ?? email ?? 'U';

    if (name.trim().isEmpty) {
      return 'U';
    }

    return name.trim()[0].toUpperCase();
  }

  String _getNameFromEmail(String email) {
    final cleanEmail = email.trim();

    if (!cleanEmail.contains('@')) {
      return cleanEmail;
    }

    return cleanEmail.split('@').first;
  }
}