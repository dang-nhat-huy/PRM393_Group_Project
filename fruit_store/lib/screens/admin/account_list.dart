import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../constants/user.constant.dart';
import '../../models/user.model.dart';
import '../../services/user.service.dart';
import '../../widgets/pagination_bar.dart';
import '../../widgets/status_badge.dart';
import 'account_create.dart';
import 'account_detail.dart';
import 'account_search_result.dart';

class AccountListScreen extends StatefulWidget {
  final UserService userService;

  const AccountListScreen({super.key, required this.userService});

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Pagination
  int _pageIndex = 1;
  int _totalItems = 0;
  int _totalPages = 0;
  final int _pageSize = 10;
  bool _hasNext = false;
  bool _hasPrevious = false;

  // Filters
  UserStatus? _selectedStatus;
  UserRole? _selectedRole;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    debugPrint(
        'Loading users with status: $_selectedStatus, role: $_selectedRole');
    try {
      final response = await widget.userService.getAll(
        pageSize: _pageSize,
        pageIndex: _pageIndex,
        status: _selectedStatus,
        role: _selectedRole,
      );

      setState(() {
        _users = response.items;
        _totalItems = response.totalItemCount;
        _totalPages = response.totalPagesCount;
        _pageIndex = response.pageIndex;
        _hasNext = response.next;
        _hasPrevious = response.previous;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load accounts: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AccountSearchResultScreen(
            userService: widget.userService,
            emailQuery: query,
          ),
        ),
      );
    }
  }

  Future<void> _refreshUsers() async {
    _pageIndex = 1;
    await _loadUsers();
  }

  void _navigateToCreate() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AccountCreateScreen(userService: widget.userService),
      ),
    );
    if (result == true) {
      _refreshUsers();
    }
  }

  void _navigateToDetail(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AccountDetailScreen(
          user: user,
          userService: widget.userService,
        ),
      ),
    ).then((_) => _loadUsers());
  }

  void _goToPage(int page) {
    setState(() {
      _pageIndex = page;
    });
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by email...',
                prefixIcon:
                    const Icon(Icons.search, color: AppTheme.textGray),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onSubmitted: (_) => _onSearch(),
              textInputAction: TextInputAction.search,
            ),
          ),

          // Filter chips
          if (_selectedStatus != null || _selectedRole != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  if (_selectedStatus != null)
                    Chip(
                      label: Text(
                          'Status: ${_selectedStatus!.name[0].toUpperCase() + _selectedStatus!.name.substring(1)}'),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _selectedStatus = null;
                        });
                        _refreshUsers();
                      },
                    ),
                  if (_selectedRole != null)
                    Chip(
                      label: Text(
                          'Role: ${_selectedRole!.name[0].toUpperCase() + _selectedRole!.name.substring(1)}'),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _selectedRole = null;
                        });
                        _refreshUsers();
                      },
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedStatus = null;
                        _selectedRole = null;
                      });
                      _refreshUsers();
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),

          // Stats bar
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppTheme.lightOrange.withValues(alpha: 0.1),
            child: Row(
              children: [
                Text(
                  '$_totalItems accounts found',
                  style: const TextStyle(
                    color: AppTheme.textGray,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: _buildContent(),
          ),

          // Pagination
          if (_hasNext)
            PaginationBar(
              pageIndex: _pageIndex,
              totalPages: _totalPages,
              hasNext: _hasNext,
              hasPrevious: _hasPrevious,
              onPageChanged: _goToPage,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreate,
        icon: const Icon(Icons.add),
        label: const Text('Create Account'),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppTheme.errorRed),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline,
                size: 64,
                color: AppTheme.textGray.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              'No accounts found',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedStatus != null || _selectedRole != null
                  ? 'Try adjusting your filters'
                  : 'Click + to create a new account',
              style: const TextStyle(color: AppTheme.textGray),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshUsers,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _users.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final user = _users[index];
          return _buildUserTile(user);
        },
      ),
    );
  }

  Widget _buildUserTile(User user) {
    final profile = user.accountProfile;
    final fullName = profile?.fullName ?? 'No name';
    final email = user.email;

    Color statusColor;
    switch (user.status) {
      case UserStatus.active:
        statusColor = AppTheme.successGreen;
        break;
      case UserStatus.deactivated:
      case UserStatus.banned:
        statusColor = AppTheme.errorRed;
        break;
      case UserStatus.suspended:
        statusColor = Colors.orange;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.15),
          child: Text(
            fullName.isNotEmpty
                ? fullName[0].toUpperCase()
                : email[0].toUpperCase(),
            style: const TextStyle(
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          fullName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(email, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                StatusBadge(
                    text: user.role.name, color: AppTheme.primaryOrange),
                const SizedBox(width: 8),
                StatusBadge(
                  text: user.status.name.toUpperCase(),
                  color: statusColor,
                  background: statusColor.withValues(alpha: 0.1),
                ),
              ],
            ),
          ],
        ),
        trailing:
            const Icon(Icons.chevron_right, color: AppTheme.textGray),
        onTap: () => _navigateToDetail(user),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Accounts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text('Status',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setStatus) {
                  return Wrap(
                    spacing: 8,
                    children: UserStatus.values.map((status) {
                      final isSelected = _selectedStatus == status;
                      return ChoiceChip(
                        label: Text(status.name[0].toUpperCase() +
                            status.name.substring(1)),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryOrange,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.white
                              : AppTheme.textDark,
                        ),
                        onSelected: (selected) {
                          setStatus(() {
                            _selectedStatus = selected ? status : null;
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text('Role',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setRole) {
                  return Wrap(
                    spacing: 8,
                    children: UserRole.values.map((role) {
                      final isSelected = _selectedRole == role;
                      return ChoiceChip(
                        label: Text(role.name[0].toUpperCase() +
                            role.name.substring(1)),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryOrange,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.white
                              : AppTheme.textDark,
                        ),
                        onSelected: (selected) {
                          setRole(() {
                            _selectedRole = selected ? role : null;
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _refreshUsers();
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}