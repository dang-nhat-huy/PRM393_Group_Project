// lib/screens/customer/profile_tab.dart
import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../models/user.model.dart';
import '../../services/api.service.dart';
import '../../services/user.service.dart';
import '../login/login_screen.dart';

class ProfileTab extends StatefulWidget {
  final String email;
  final ApiService apiService;

  const ProfileTab({
    super.key,
    required this.email,
    required this.apiService,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late final UserService _userService;
  User? _user;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _userService = UserService(widget.apiService);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userProfile = await _userService.getByEmail(widget.email);
      setState(() {
        _user = userProfile;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load profile details.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _signOut() {
    // Clear token
    widget.apiService.setToken(null);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _user?.accountProfile;
    final fullName = profile?.fullName ?? 'Valued Customer';
    final phone = profile?.phone ?? 'Not provided';
    final address = profile?.address ?? 'Not provided';
    final gender = profile?.gender?.name ?? 'Not specified';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
          : _error != null
              ? Center(
                  child: TextButton.icon(
                    onPressed: _loadProfile,
                    icon: const Icon(Icons.refresh),
                    label: Text(_error!),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Profile Image & Welcome
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.orange.shade50,
                              child: const Icon(Icons.person, size: 50, color: AppTheme.primaryOrange),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              fullName,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryOrange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _user?.role.name.toUpperCase() ?? 'CUSTOMER',
                                style: const TextStyle(
                                  color: AppTheme.primaryOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Details Cards
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            children: [
                              _buildProfileRow(Icons.email_outlined, 'Email', widget.email),
                              const Divider(height: 1),
                              _buildProfileRow(Icons.phone_outlined, 'Phone', phone),
                              const Divider(height: 1),
                              _buildProfileRow(Icons.location_on_outlined, 'Address', address),
                              const Divider(height: 1),
                              _buildProfileRow(Icons.wc_outlined, 'Gender', gender),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Log out card
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _signOut,
                          icon: const Icon(Icons.logout),
                          label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorRed,
                            side: const BorderSide(color: AppTheme.errorRed),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileRow(IconData icon, String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.textGray, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textGray, fontSize: 12)),
                const SizedBox(height: 4),
                Text(val, style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w500, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
