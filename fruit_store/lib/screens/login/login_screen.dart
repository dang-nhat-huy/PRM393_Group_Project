import 'package:flutter/material.dart';
import 'package:fruit_store/core/constants/api_constants.dart';
import 'package:fruit_store/screens/staff/staff_home_screen.dart';
import '../../constants/app_theme.dart';
import '../../services/api.service.dart';
import '../../services/auth.service.dart';
import '../admin/admin_home_screen.dart';
import '../customer/customer_home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authApiService = ApiService(baseUrl: ApiConstants.authBaseUrl);
  final _mainApiService = ApiService();
  late final _authService = AuthService(_authApiService);

  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter email and password');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = await _authService.login(
        email,
        password,
      );

      // Sync the JWT token to the main API service (port 5002)
      _mainApiService.setToken(auth.token);

      if (!mounted) return;

      switch (auth.role) {
        case "Admin":
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminHomeScreen(
                apiService: _mainApiService,
              ),
            ),
          );
          break;

        case "Staff":
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StaffHomeScreen(
                apiService: _mainApiService,
              ),
            ),
          );
          break;

        case "Customer":
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CustomerHomeScreen(
                apiService: _mainApiService,
                email: email,
              ),
            ),
          );
          break;

        default:
          setState(() {
            _error = "Role '${auth.role}' is not supported";
          });
      }
    } catch (e) {
      setState(() {
        _error = 'Login failed. Check your credentials.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    color: AppTheme.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Fruit Farm',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue',
                  style: TextStyle(color: AppTheme.textGray),
                ),
                const SizedBox(height: 40),

                // Error
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppTheme.errorRed, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: AppTheme.errorRed),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Email
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 24),

                // Sign In button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.white,
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Register link
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterScreen(),
                    ),
                  ),
                  child: const Text(
                    "Don't have an account? Register",
                    style: TextStyle(color: AppTheme.primaryOrange),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}