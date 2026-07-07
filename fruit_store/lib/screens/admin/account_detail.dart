import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../constants/user.constant.dart';
import '../../models/user.model.dart';
import '../../services/user.service.dart';
import 'account_edit.dart';

class AccountDetailScreen extends StatefulWidget {
  final User user;
  final UserService userService;

  const AccountDetailScreen({
    super.key,
    required this.user,
    required this.userService,
  });

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  late User _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  Future<void> _toggleStatus() async {
    final newStatus = _user.status == UserStatus.active
        ? UserStatus.deactivated
        : UserStatus.active;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Status Change'),
        content: Text(
          'Change status from ${_user.status.name.toUpperCase()} to ${newStatus.name.toUpperCase()}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await widget.userService.updateStatus(_user.accountId);
        setState(() {
          _user = User(
            accountId: _user.accountId,
            email: _user.email,
            role: _user.role,
            status: newStatus,
            accountProfile: _user.accountProfile,
            createdAt: _user.createdAt,
            updatedAt: _user.updatedAt,
          );
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status changed to ${newStatus.name}'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update status: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  void _navigateToEdit() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AccountEditScreen(
          user: _user,
          userService: widget.userService,
        ),
      ),
    );
    if (result == true && mounted) {
      // Refresh user data
      try {
        final updated = await widget.userService.getByEmail(_user.email);
        setState(() => _user = updated);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _user.accountProfile;
    final fullName = profile?.fullName ?? 'No name';
    final email = _user.email;
    final phone = profile?.phone ?? 'N/A';
    final gender = profile?.gender ?? Gender.male;
    final address = profile?.address ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEdit,
          ),
          IconButton(
            icon: Icon(
              _user.status == UserStatus.active
                  ? Icons.block
                  : Icons.check_circle,
            ),
            onPressed: _toggleStatus,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor:
                                AppTheme.primaryOrange.withValues(alpha: 0.15),
                            child: Text(
                              fullName.isNotEmpty
                                  ? fullName[0].toUpperCase()
                                  : email[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 32,
                                color: AppTheme.primaryOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: const TextStyle(
                              color: AppTheme.textGray,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildInfoChip(
                                _user.role.name.toUpperCase(),
                                AppTheme.primaryOrange,
                              ),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                _user.status.name.toUpperCase(),
                                _user.status == UserStatus.active
                                    ? AppTheme.successGreen
                                    : AppTheme.errorRed,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Account Info
                  _buildSection(
                    'Account Information',
                    [
                      _buildInfoRow('Account ID', _user.accountId.toString()),
                      _buildInfoRow('Email', _user.email),
                      _buildInfoRow('Role', _user.role.name),
                      _buildInfoRow('Status', _user.status.name.toUpperCase()),
                      _buildInfoRow('Created At', _user.createdAt),
                      if (_user.updatedAt != null)
                        _buildInfoRow('Updated At', _user.updatedAt!),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Profile Info
                  _buildSection(
                    'Profile Information',
                    [
                      _buildInfoRow('Full Name', fullName),
                      _buildInfoRow('Phone', phone),
                      _buildInfoRow(
                        'Gender',
                        gender.name[0].toUpperCase() +
                            gender.name.substring(1),
                      ),
                      _buildInfoRow('Address', address),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryOrange,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textGray,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}