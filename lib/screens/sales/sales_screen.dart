import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recyleto_app/l10n/app_localizations.dart';

import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import 'add_transaction_screen.dart';
import 'transaction_detail_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _filteredTransactions = [];
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _salesStats = {};
  String? _currentSearch;
  String _currentFilter = 'all'; // all | today | week | month | year
  String _currentSort =
      'date_desc'; // date_desc | date_asc | amount_desc | amount_asc

  @override
  void initState() {
    super.initState();
    print('💼 Sales: initState called - Sales Screen starting...');
    _checkAuthStatus();
    _loadTransactions();
  }

  void _checkAuthStatus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (!authProvider.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  Future<void> _loadTransactions() async {
    try {
      print('💼 Sales: Starting to load transactions...');
      setState(() {
        _isLoading = true;
        _error = null;
      });

      await _apiService.initialize();
      print('💼 Sales: API service initialized');

      // Load transactions from API
      final allTransactions = await _apiService.getTransactions();
      print('💼 Sales: Loaded ${allTransactions.length} transactions from API');
      print('💼 Sales: Transaction details:');
      for (int i = 0; i < allTransactions.length; i++) {
        final tx = allTransactions[i];
        print(
            '💼 Sales: Transaction ${i + 1}: ${tx['_id']} - Amount: ${tx['totalAmount'] ?? tx['total'] ?? tx['amount'] ?? 0.0} - Status: ${tx['status']}');
      }

      // Show all transactions (both single and multiple items)
      final allValidTransactions = allTransactions.where((transaction) {
        // Show all transactions that have items
        final items = transaction['items'] as List? ?? [];
        return items.isNotEmpty; // Show all transactions with items
      }).toList();

      print('💼 Sales: All transactions found: ${allValidTransactions.length}');

      setState(() {
        _transactions = allValidTransactions;
        _isLoading = false;
      });

      // Calculate sales stats
      print('💼 Sales: Calculating sales stats...');
      _calculateSalesStats();
      print('💼 Sales: Sales stats calculated');

      // Apply current filters
      _applyFilters();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load transactions: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadTransactions,
            ),
          ),
        );
      }
    }
  }

  void _calculateSalesStats() {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    print(
        '💼 Sales: Calculating stats for dates: ${today.toString()} and ${yesterday.toString()}');
    print('💼 Sales: Total transactions to check: ${_transactions.length}');

    final recentTransactions = _transactions.where((tx) {
      final txDate = DateTime.parse(tx['createdAt'] ?? tx['date'] ?? '');
      final isToday = txDate.year == today.year &&
          txDate.month == today.month &&
          txDate.day == today.day;
      final isYesterday = txDate.year == yesterday.year &&
          txDate.month == yesterday.month &&
          txDate.day == yesterday.day;
      final isRecent = isToday || isYesterday;
      final isCompleted = tx['status'] == 'completed';

      print('💼 Sales: Transaction ${tx['_id']}:');
      print('💼 Sales:   Date: ${txDate.toString()}');
      print('💼 Sales:   Status: ${tx['status']}');
      print('💼 Sales:   Is Today: $isToday');
      print('💼 Sales:   Is Yesterday: $isYesterday');
      print('💼 Sales:   Is Recent: $isRecent');
      print('💼 Sales:   Is Completed: $isCompleted');
      print(
          '💼 Sales:   Amount: ${tx['totalAmount'] ?? tx['total'] ?? tx['amount'] ?? 0.0}');

      return isRecent && isCompleted;
    }).toList();

    final recentSales = recentTransactions.fold<double>(
        0,
        (sum, tx) =>
            sum + (tx['totalAmount'] ?? tx['total'] ?? tx['amount'] ?? 0.0));

    print('💼 Sales: Recent Sales calculated: $recentSales');
    print('💼 Sales: Recent Transactions count: ${recentTransactions.length}');

    // Log each transaction for debugging
    for (int i = 0; i < recentTransactions.length; i++) {
      final tx = recentTransactions[i];
      final amount = tx['totalAmount'] ?? tx['total'] ?? tx['amount'] ?? 0.0;
      print('💼 Sales Transaction ${i + 1}: \$${amount.toStringAsFixed(2)}');
    }

    setState(() {
      _salesStats = {
        'todaySales': recentSales,
        'totalTransactions': _transactions.length,
        'completedTransactions':
            _transactions.where((tx) => tx['status'] == 'completed').length,
        'refundedTransactions':
            _transactions.where((tx) => tx['status'] == 'refunded').length,
      };
    });

    // Update DashboardProvider with the calculated sales data
    try {
      print('💼 Sales: Attempting to update DashboardProvider...');
      final dashboardProvider = context.read<DashboardProvider>();
      print(
          '💼 Sales: DashboardProvider obtained: ${dashboardProvider.runtimeType}');
      print(
          '💼 Sales: Current statistics before update: ${dashboardProvider.statistics}');

      // Ensure DashboardProvider is initialized
      if (dashboardProvider.statistics == null) {
        print(
            '💼 Sales: DashboardProvider not initialized, initializing first...');
        dashboardProvider.updateStatistics({
          'totalSales': 0.0,
          'totalPurchases': 0.0,
          'expiringCount': 0,
          'pendingRequestsCount': 0,
        });
      }

      dashboardProvider.updateSalesData(recentSales);
      print(
          '💼 Sales: Successfully updated DashboardProvider with sales data: $recentSales');
      print(
          '💼 Sales: Statistics after update: ${dashboardProvider.statistics}');
    } catch (e) {
      print('💼 Sales: Error updating DashboardProvider: $e');
      print('💼 Sales: Error stack trace: ${StackTrace.current}');
    }

    // Also update purchases data (checkout transactions)
    try {
      print('🛒 Sales: Calculating customer purchases data...');
      final customerPurchases = _transactions.where((tx) {
        final txDate = DateTime.parse(tx['createdAt'] ?? tx['date'] ?? '');
        final isToday = txDate.year == today.year &&
            txDate.month == today.month &&
            txDate.day == today.day;
        final isYesterday = txDate.year == yesterday.year &&
            txDate.month == yesterday.month &&
            txDate.day == yesterday.day;
        final isRecent = isToday || isYesterday;
        final isCompleted = tx['status'] == 'completed';
        final paymentCompleted = tx['payment']?['status'] == 'completed';

        // Check if this is a customer purchase (you buying from suppliers)
        final isCustomerPurchase = tx['type'] == 'purchase' ||
            tx['transactionType'] == 'purchase' ||
            tx['role'] == 'customer' ||
            tx['isCustomerTransaction'] == true;

        return isRecent &&
            isCompleted &&
            paymentCompleted &&
            isCustomerPurchase;
      }).toList();

      final customerPurchasesTotal = customerPurchases.fold<double>(
          0,
          (sum, tx) =>
              sum + (tx['totalAmount'] ?? tx['total'] ?? tx['amount'] ?? 0.0));

      print('🛒 Sales: Calculated customer purchases: $customerPurchasesTotal');
      print(
          '🛒 Sales: Customer checkout transactions count: ${customerPurchases.length}');

      // Log each customer purchase for debugging
      for (int i = 0; i < customerPurchases.length; i++) {
        final tx = customerPurchases[i];
        final amount = tx['totalAmount'] ?? tx['total'] ?? tx['amount'] ?? 0.0;
        print(
            '🛒 Sales Customer Purchase ${i + 1}: \$${amount.toStringAsFixed(2)} - Type: ${tx['type']} - Role: ${tx['role']}');
      }

      final dashboardProvider = context.read<DashboardProvider>();
      dashboardProvider.updatePurchasesData(customerPurchasesTotal);
      print(
          '🛒 Sales: Successfully updated DashboardProvider with customer purchases data: $customerPurchasesTotal');
    } catch (e) {
      print(
          '🛒 Sales: Error updating DashboardProvider with customer purchases: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.sales),
            if (_currentSearch != null ||
                _currentFilter != 'all' ||
                _currentSort != 'date_desc')
              Text(
                _getActiveFiltersText(),
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showSearchDialog,
            icon: Stack(
              children: [
                const Icon(Icons.search),
                if (_currentSearch != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showFilterDialog,
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_currentFilter != 'all')
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showSortDialog,
            icon: Stack(
              children: [
                const Icon(Icons.sort),
                if (_currentSort != 'date_desc')
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${AppLocalizations.of(context)!.error}: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTransactions,
                        child: Text(AppLocalizations.of(context)!.retry),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Summary Cards
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              AppLocalizations.of(context)!.todaySales,
                              '\$${(_salesStats['todaySales'] ?? 0.0).toStringAsFixed(2)}',
                              AppTheme.successGreen,
                              Icons.trending_up,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSummaryCard(
                              AppLocalizations.of(context)!.totalOrders,
                              '${_salesStats['totalTransactions'] ?? 0}',
                              AppTheme.primaryTeal,
                              Icons.receipt_long,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Transactions List
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadTransactions,
                        child: _filteredTransactions.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_outlined,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _transactions.isEmpty
                                          ? AppLocalizations.of(context)!
                                              .noTransactionsFound
                                          : AppLocalizations.of(context)!
                                              .noTransactionsMatchFilters,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _transactions.isEmpty
                                          ? AppLocalizations.of(context)!
                                              .startByCreatingFirstSale
                                          : AppLocalizations.of(context)!
                                              .tryAdjustingSearchFilter,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.grey[500],
                                          ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _filteredTransactions.length,
                                itemBuilder: (context, index) {
                                  final transaction =
                                      _filteredTransactions[index];
                                  return _buildTransactionCard(transaction);
                                },
                              ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(),
            ),
          );
          if (result == true) {
            await _loadTransactions();
          }
        },
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.newSale),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.darkGray.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final statusColor = transaction['status'] == 'completed'
        ? AppTheme.successGreen
        : transaction['status'] == 'refunded'
            ? AppTheme.errorRed
            : AppTheme.warningOrange;

    final transactionDate = DateTime.parse(transaction['createdAt'] ??
        transaction['date'] ??
        DateTime.now().toIso8601String());
    final formattedDate =
        '${transactionDate.year}-${transactionDate.month.toString().padLeft(2, '0')}-${transactionDate.day.toString().padLeft(2, '0')}';
    final formattedTime =
        '${transactionDate.hour.toString().padLeft(2, '0')}:${transactionDate.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.receipt,
            color: AppTheme.primaryTeal,
            size: 24,
          ),
        ),
        title: Text(
          'Invoice ${transaction['transactionId'] ?? transaction['transactionReference'] ?? transaction['id'] ?? 'Unknown'}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryTeal,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '$formattedDate ${AppLocalizations.of(context)!.at} $formattedTime',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.darkGray.withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              'Complete Invoice • ${transaction['items']?.length ?? 0} Medicines',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.darkGray.withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              'Pharmacy: ${transaction['pharmacyId']?.substring(0, 8).toUpperCase() ?? 'ABC'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryTeal.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${(transaction['totalAmount'] ?? transaction['total'] ?? transaction['amount'] ?? 0.0).toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTeal,
                  ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                (transaction['status'] ?? 'pending').toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TransactionDetailScreen(transaction: transaction),
            ),
          );
        },
      ),
    );
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_transactions);

    // Apply search filter
    if (_currentSearch != null && _currentSearch!.isNotEmpty) {
      final searchTerm = _currentSearch!.toLowerCase();
      filtered = filtered.where((transaction) {
        return (transaction['customerInfo']?['name']
                    ?.toString()
                    .toLowerCase()
                    .contains(searchTerm) ??
                false) ||
            (transaction['customerName']
                    ?.toString()
                    .toLowerCase()
                    .contains(searchTerm) ??
                false) ||
            (transaction['transactionId']
                    ?.toString()
                    .toLowerCase()
                    .contains(searchTerm) ??
                false) ||
            (transaction['id']?.toString().toLowerCase().contains(searchTerm) ??
                false) ||
            (transaction['items']
                    ?.toString()
                    .toLowerCase()
                    .contains(searchTerm) ??
                false);
      }).toList();
    }

    // Apply date filter
    final now = DateTime.now();
    switch (_currentFilter) {
      case 'today':
        filtered = filtered.where((transaction) {
          final date = DateTime.tryParse(transaction['createdAt'] ?? '');
          return date != null &&
              date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        }).toList();
        break;
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        filtered = filtered.where((transaction) {
          final date = DateTime.tryParse(transaction['createdAt'] ?? '');
          return date != null && date.isAfter(weekAgo);
        }).toList();
        break;
      case 'month':
        final monthAgo = now.subtract(const Duration(days: 30));
        filtered = filtered.where((transaction) {
          final date = DateTime.tryParse(transaction['createdAt'] ?? '');
          return date != null && date.isAfter(monthAgo);
        }).toList();
        break;
      case 'year':
        final yearAgo = now.subtract(const Duration(days: 365));
        filtered = filtered.where((transaction) {
          final date = DateTime.tryParse(transaction['createdAt'] ?? '');
          return date != null && date.isAfter(yearAgo);
        }).toList();
        break;
    }

    // Apply sorting
    switch (_currentSort) {
      case 'date_desc':
        filtered.sort((a, b) {
          final dateA = DateTime.tryParse(a['createdAt'] ?? '');
          final dateB = DateTime.tryParse(b['createdAt'] ?? '');
          if (dateA == null || dateB == null) return 0;
          return dateB.compareTo(dateA);
        });
        break;
      case 'date_asc':
        filtered.sort((a, b) {
          final dateA = DateTime.tryParse(a['createdAt'] ?? '');
          final dateB = DateTime.tryParse(b['createdAt'] ?? '');
          if (dateA == null || dateB == null) return 0;
          return dateA.compareTo(dateB);
        });
        break;
      case 'amount_desc':
        filtered.sort((a, b) {
          final amountA = (a['totalAmount'] ?? a['total'] ?? 0).toDouble();
          final amountB = (b['totalAmount'] ?? b['total'] ?? 0).toDouble();
          return amountB.compareTo(amountA);
        });
        break;
      case 'amount_asc':
        filtered.sort((a, b) {
          final amountA = (a['totalAmount'] ?? a['total'] ?? 0).toDouble();
          final amountB = (b['totalAmount'] ?? b['total'] ?? 0).toDouble();
          return amountA.compareTo(amountB);
        });
        break;
    }

    setState(() {
      _filteredTransactions = filtered;
    });
  }

  Future<void> _showSearchDialog() async {
    final controller = TextEditingController(text: _currentSearch ?? '');
    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.search),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: AppLocalizations.of(context)!.searchTransactions,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text(AppLocalizations.of(context)!.search),
            ),
          ],
        );
      },
    );
    if (value != null) {
      setState(() {
        _currentSearch = value.isEmpty ? null : value;
      });
      _applyFilters();
    }
  }

  Future<void> _showFilterDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(AppLocalizations.of(context)!.filter),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'all'),
              child: Text(AppLocalizations.of(context)!.all),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'today'),
              child: Text(AppLocalizations.of(context)!.today),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'week'),
              child: Text(AppLocalizations.of(context)!.thisWeek),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'month'),
              child: Text(AppLocalizations.of(context)!.thisMonth),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'year'),
              child: Text(AppLocalizations.of(context)!.thisYear),
            ),
          ],
        );
      },
    );
    if (selected != null) {
      setState(() {
        _currentFilter = selected;
      });
      _applyFilters();
    }
  }

  Future<void> _showSortDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(AppLocalizations.of(context)!.sortBy),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'date_desc'),
              child: Text(AppLocalizations.of(context)!.newestFirst),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'date_asc'),
              child: Text(AppLocalizations.of(context)!.oldestFirst),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'amount_desc'),
              child: Text(AppLocalizations.of(context)!.highestAmount),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'amount_asc'),
              child: Text(AppLocalizations.of(context)!.lowestAmount),
            ),
          ],
        );
      },
    );
    if (selected != null) {
      setState(() {
        _currentSort = selected;
      });
      _applyFilters();
    }
  }

  String _getActiveFiltersText() {
    List<String> activeFilters = [];

    if (_currentSearch != null) {
      activeFilters.add(
          'Search: ${_currentSearch!.length > 20 ? '${_currentSearch!.substring(0, 20)}...' : _currentSearch!}');
    }

    if (_currentFilter != 'all') {
      switch (_currentFilter) {
        case 'today':
          activeFilters.add(AppLocalizations.of(context)!.today);
          break;
        case 'week':
          activeFilters.add(AppLocalizations.of(context)!.thisWeek);
          break;
        case 'month':
          activeFilters.add(AppLocalizations.of(context)!.thisMonth);
          break;
        case 'year':
          activeFilters.add(AppLocalizations.of(context)!.thisYear);
          break;
      }
    }

    if (_currentSort != 'date_desc') {
      switch (_currentSort) {
        case 'date_asc':
          activeFilters.add(AppLocalizations.of(context)!.oldestFirst);
          break;
        case 'amount_desc':
          activeFilters.add(AppLocalizations.of(context)!.highestAmount);
          break;
        case 'amount_asc':
          activeFilters.add(AppLocalizations.of(context)!.lowestAmount);
          break;
      }
    }

    return activeFilters.join(' • ');
  }
}
