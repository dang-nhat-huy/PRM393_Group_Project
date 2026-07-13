import 'package:flutter/material.dart';

import '../../constants/app_theme.dart';
import '../../models/user.model.dart';
import '../../services/user.service.dart';
import 'account_detail.dart';

/// Screen for displaying email search results.
class AccountSearchResultScreen extends StatefulWidget {
  final UserService userService;
  final String emailQuery;

  const AccountSearchResultScreen({
    super.key,
    required this.userService,
    required this.emailQuery,
  });

  @override
  State<AccountSearchResultScreen> createState() =>
      _AccountSearchResultScreenState();
}

class _AccountSearchResultScreenState extends State<AccountSearchResultScreen> {
  User? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _search();
  }

  Future<void> _search() async {
    try {
      final user = await widget.userService.getByEmail(widget.emailQuery);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Account not found';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Result')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off,
                          size: 64, color: AppTheme.textGray),
                      const SizedBox(height: 16),
                      const Text(
                        'No account found with email:',
                        style: TextStyle(color: AppTheme.textGray),
                      ),
                      Text(
                        widget.emailQuery,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Back to List'),
                      ),
                    ],
                  ),
                )
              : _user != null
                  ? AccountDetailScreen(
                      user: _user!,
                      userService: widget.userService,
                    )
                  : const SizedBox.shrink(),
    );
  }
}