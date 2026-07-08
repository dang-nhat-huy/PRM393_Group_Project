class AuthResult {
  final String token;
  final String role;
  final int accountId;

  AuthResult({
    required this.token,
    required this.role,
    required this.accountId,
  });
}