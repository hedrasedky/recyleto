import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recyleto_app/l10n/app_localizations.dart';

import '../../services/mock_data_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MockDataService _mockDataService = MockDataService();

  // Date filters
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedCategory = 'All';
  String _selectedPaymentMethod = 'All';
  String _selectedStockStatus = 'All';
  String _selectedExpiryStatus = 'All';

  // Data
  Map<String, dynamic>? _salesReport;
  Map<String, dynamic>? _inventoryReport;
  Map<String, dynamic>? _performanceReport;

  // Loading states
  bool _isLoadingSales = false;
  bool _isLoadingInventory = false;
  bool _isLoadingPerformance = false;

  // Error states
  String? _salesError;
  String? _inventoryError;
  String? _performanceError;

  final List<String> _categories = [
    'All',
    'Pain Relief',
    'Antibiotics',
    'Vitamins',
    'Diabetes',
    'Hypertension',
    'Other'
  ];

  final List<String> _paymentMethods = [
    'All',
    'Cash',
    'Card',
    'Transfer',
    'Mobile Money'
  ];

  final List<String> _stockStatuses = [
    'All',
    'In Stock',
    'Low Stock',
    'Out of Stock'
  ];

  final List<String> _expiryStatuses = [
    'All',
    'Valid',
    'Expiring Soon',
    'Expired'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _endDate = DateTime.now();
    _startDate = DateTime.now().subtract(const Duration(days: 30));
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    await Future.wait([
      _loadSalesReport(),
      _loadInventoryReport(),
      _loadPerformanceReport(),
    ]);
  }

  Future<void> _loadSalesReport() async {
    setState(() {
      _isLoadingSales = true;
      _salesError = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate loading
      _salesReport = await _mockDataService.getSalesReport();
    } catch (e) {
      setState(() {
        _salesError = e.toString();
        _isLoadingSales = false;
      });
    } finally {
      setState(() {
        _isLoadingSales = false;
      });
    }
  }

  Future<void> _loadInventoryReport() async {
    setState(() {
      _isLoadingInventory = true;
      _inventoryError = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate loading
      _inventoryReport = await _mockDataService.getInventoryReport();
    } catch (e) {
      setState(() {
        _inventoryError = e.toString();
        _isLoadingInventory = false;
      });
    } finally {
      setState(() {
        _isLoadingInventory = false;
      });
    }
  }

  Future<void> _loadPerformanceReport() async {
    setState(() {
      _isLoadingPerformance = true;
      _performanceError = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate loading
      _performanceReport = await _mockDataService.getPerformanceReport();
    } catch (e) {
      setState(() {
        _performanceError = e.toString();
        _isLoadingPerformance = false;
      });
    } finally {
      setState(() {
        _isLoadingPerformance = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        end: _endDate ?? DateTime.now(),
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadReports();
    }
  }

  Future<void> _exportReport(String type) async {
    try {
      final exportParams = {
        'startDate': _startDate?.toIso8601String().split('T')[0],
        'endDate': _endDate?.toIso8601String().split('T')[0],
        'category': _selectedCategory == 'All' ? null : _selectedCategory,
        'format': type,
      };

      await _mockDataService.exportData(type, exportParams);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.reportExportedSuccessfully),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.failedToExportReport}: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.reportsAnalytics),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range),
            tooltip: AppLocalizations.of(context)!.selectDateRange,
          ),
          PopupMenuButton<String>(
            onSelected: _exportReport,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart),
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.exportCSV),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf),
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.exportPDF),
                  ],
                ),
              ),
            ],
            child: const Icon(Icons.download),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Section
          _buildFiltersSection(),

          // Tab Bar
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryTeal,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primaryTeal,
              tabs: [
                Tab(text: AppLocalizations.of(context)!.sales),
                Tab(text: AppLocalizations.of(context)!.inventory),
                Tab(text: AppLocalizations.of(context)!.performance),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSalesTab(),
                _buildInventoryTab(),
                _buildPerformanceTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.filters,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Date Range Display
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${DateFormat('MMM dd, yyyy').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Filter Dropdowns
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  label: AppLocalizations.of(context)!.category,
                  value: _selectedCategory,
                  items: _categories,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                    _loadReports();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterDropdown(
                  label: AppLocalizations.of(context)!.paymentMethod,
                  value: _selectedPaymentMethod,
                  items: _paymentMethods,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                    _loadReports();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  label: AppLocalizations.of(context)!.stockStatus,
                  value: _selectedStockStatus,
                  items: _stockStatuses,
                  onChanged: (value) {
                    setState(() {
                      _selectedStockStatus = value!;
                    });
                    _loadReports();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterDropdown(
                  label: AppLocalizations.of(context)!.expiryStatus,
                  value: _selectedExpiryStatus,
                  items: _expiryStatuses,
                  onChanged: (value) {
                    setState(() {
                      _selectedExpiryStatus = value!;
                    });
                    _loadReports();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSalesTab() {
    if (_isLoadingSales) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_salesError != null) {
      return _buildErrorWidget(_salesError!, () => _loadSalesReport());
    }

    if (_salesReport == null) {
      return Center(
          child: Text(AppLocalizations.of(context)!.noSalesDataAvailable));
    }

    final sales = _salesReport!['data'] ?? _salesReport!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(sales['summary'] ?? {}),
          const SizedBox(height: 24),
          _buildSalesChart(sales['chart'] ?? {}),
          const SizedBox(height: 24),
          _buildTopProducts(sales['topProducts'] ?? []),
          const SizedBox(height: 24),
          _buildSalesByCategory(sales['byCategory'] ?? []),
        ],
      ),
    );
  }

  Widget _buildInventoryTab() {
    if (_isLoadingInventory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_inventoryError != null) {
      return _buildErrorWidget(_inventoryError!, () => _loadInventoryReport());
    }

    if (_inventoryReport == null) {
      return Center(
          child: Text(AppLocalizations.of(context)!.noInventoryDataAvailable));
    }

    final inventory = _inventoryReport!['data'] ?? _inventoryReport!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInventorySummaryCards(inventory['summary'] ?? {}),
          const SizedBox(height: 24),
          _buildStockLevelsChart(inventory['stockLevels'] ?? {}),
          const SizedBox(height: 24),
          _buildExpiryAlerts(inventory['expiryAlerts'] ?? []),
          const SizedBox(height: 24),
          _buildCategoryBreakdown(inventory['byCategory'] ?? []),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    if (_isLoadingPerformance) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_performanceError != null) {
      return _buildErrorWidget(
          _performanceError!, () => _loadPerformanceReport());
    }

    if (_performanceReport == null) {
      return Center(
          child:
              Text(AppLocalizations.of(context)!.noPerformanceDataAvailable));
    }

    final performance = _performanceReport!['data'] ?? _performanceReport!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPerformanceMetrics(performance['metrics'] ?? {}),
          const SizedBox(height: 24),
          _buildTrendAnalysis(performance['trends'] ?? {}),
          const SizedBox(height: 24),
          _buildCustomerSatisfaction(performance['satisfaction'] ?? {}),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> summary) {
    final cards = [
      {
        'title': 'Total Sales',
        'value': '\$${(summary['totalSales'] ?? 0).toStringAsFixed(2)}',
        'change': '${summary['salesChange'] ?? 0}%',
        'isPositive': (summary['salesChange'] ?? 0) >= 0,
        'icon': Icons.trending_up,
        'color': AppTheme.successGreen,
      },
      {
        'title': 'Total Orders',
        'value': '${summary['totalOrders'] ?? 0}',
        'change': '${summary['ordersChange'] ?? 0}%',
        'isPositive': (summary['ordersChange'] ?? 0) >= 0,
        'icon': Icons.shopping_cart,
        'color': AppTheme.primaryTeal,
      },
      {
        'title': 'Average Order Value',
        'value': '\$${(summary['averageOrderValue'] ?? 0).toStringAsFixed(2)}',
        'change': '${summary['aovChange'] ?? 0}%',
        'isPositive': (summary['aovChange'] ?? 0) >= 0,
        'icon': Icons.attach_money,
        'color': AppTheme.warningOrange,
      },
      {
        'title': 'Customer Count',
        'value': '${summary['customerCount'] ?? 0}',
        'change': '${summary['customersChange'] ?? 0}%',
        'isPositive': (summary['customersChange'] ?? 0) >= 0,
        'icon': Icons.people,
        'color': AppTheme.darkTeal,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      card['icon'] as IconData,
                      color: card['color'] as Color,
                      size: 24,
                    ),
                    const Spacer(),
                    Icon(
                      card['isPositive'] as bool
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: card['isPositive'] as bool
                          ? AppTheme.successGreen
                          : AppTheme.errorRed,
                      size: 16,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  card['title'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  card['value'] as String,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  card['change'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: card['isPositive'] as bool
                            ? AppTheme.successGreen
                            : AppTheme.errorRed,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInventorySummaryCards(Map<String, dynamic> summary) {
    final cards = [
      {
        'title': 'Total Items',
        'value': '${summary['totalItems'] ?? 0}',
        'icon': Icons.inventory_2,
        'color': AppTheme.primaryTeal,
      },
      {
        'title': 'Low Stock',
        'value': '${summary['lowStock'] ?? 0}',
        'icon': Icons.warning,
        'color': AppTheme.warningOrange,
      },
      {
        'title': 'Expiring Soon',
        'value': '${summary['expiringSoon'] ?? 0}',
        'icon': Icons.schedule,
        'color': AppTheme.errorRed,
      },
      {
        'title': 'Categories',
        'value': '${summary['categories'] ?? 0}',
        'icon': Icons.category,
        'color': AppTheme.darkTeal,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  card['icon'] as IconData,
                  color: card['color'] as Color,
                  size: 24,
                ),
                const Spacer(),
                Text(
                  card['title'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  card['value'] as String,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceMetrics(Map<String, dynamic> metrics) {
    final metricCards = [
      {
        'title': 'Customer Satisfaction',
        'value': '${(metrics['satisfaction'] ?? 0).toStringAsFixed(1)}/5.0',
        'icon': Icons.star,
        'color': AppTheme.successGreen,
      },
      {
        'title': 'Order Accuracy',
        'value': '${(metrics['accuracy'] ?? 0).toStringAsFixed(1)}%',
        'icon': Icons.check_circle,
        'color': AppTheme.primaryTeal,
      },
      {
        'title': 'Response Time',
        'value': '${metrics['responseTime'] ?? 'N/A'}',
        'icon': Icons.speed,
        'color': AppTheme.warningOrange,
      },
      {
        'title': 'Return Rate',
        'value': '${(metrics['returnRate'] ?? 0).toStringAsFixed(1)}%',
        'icon': Icons.assignment_return,
        'color': AppTheme.errorRed,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: metricCards.length,
      itemBuilder: (context, index) {
        final card = metricCards[index];
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  card['icon'] as IconData,
                  color: card['color'] as Color,
                  size: 24,
                ),
                const Spacer(),
                Text(
                  card['title'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  card['value'] as String,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSalesChart(Map<String, dynamic> chartData) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Trend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Chart visualization would go here',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockLevelsChart(Map<String, dynamic> chartData) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock Levels',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Stock chart visualization would go here',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProducts(List<dynamic> products) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Selling Products',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (products.isEmpty)
              Center(
                child: Text(
                  'No product data available',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: AppTheme.primaryTeal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(product['name'] ?? 'Unknown Product'),
                    subtitle: Text(
                        '${product['category'] ?? 'N/A'} • ${product['quantity'] ?? 0} sold'),
                    trailing: Text(
                      '\$${(product['revenue'] ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successGreen,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesByCategory(List<dynamic> categories) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales by Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (categories.isEmpty)
              Center(
                child: Text(
                  'No category data available',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
                      child: const Icon(
                        Icons.category,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    title: Text(category['name'] ?? 'Unknown Category'),
                    subtitle: Text('${category['orders'] ?? 0} orders'),
                    trailing: Text(
                      '\$${(category['revenue'] ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successGreen,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryAlerts(List<dynamic> alerts) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expiry Alerts',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (alerts.isEmpty)
              Center(
                child: Text(
                  'No expiry alerts',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  final daysUntilExpiry = alert['daysUntilExpiry'] ?? 0;
                  final isCritical = daysUntilExpiry <= 7;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCritical
                          ? AppTheme.errorRed.withOpacity(0.1)
                          : AppTheme.warningOrange.withOpacity(0.1),
                      child: Icon(
                        isCritical ? Icons.error : Icons.warning,
                        color: isCritical
                            ? AppTheme.errorRed
                            : AppTheme.warningOrange,
                      ),
                    ),
                    title: Text(alert['medicineName'] ?? 'Unknown Medicine'),
                    subtitle: Text(
                      'Expires in $daysUntilExpiry days • Stock: ${alert['currentStock'] ?? 0}',
                    ),
                    trailing: Text(
                      alert['expiryDate'] ?? 'N/A',
                      style: TextStyle(
                        color: isCritical
                            ? AppTheme.errorRed
                            : AppTheme.warningOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(List<dynamic> categories) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inventory by Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (categories.isEmpty)
              Center(
                child: Text(
                  'No category data available',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
                      child: const Icon(
                        Icons.category,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    title: Text(category['name'] ?? 'Unknown Category'),
                    subtitle: Text('${category['items'] ?? 0} items'),
                    trailing: Text(
                      '${category['totalValue']?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successGreen,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendAnalysis(Map<String, dynamic> trends) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Trends',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Trend analysis chart would go here',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSatisfaction(Map<String, dynamic> satisfaction) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Satisfaction',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Satisfaction metrics visualization would go here',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorRed.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load data',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CustomButton(
            onPressed: onRetry,
            text: 'Retry',
            backgroundColor: AppTheme.primaryTeal,
          ),
        ],
      ),
    );
  }
}
