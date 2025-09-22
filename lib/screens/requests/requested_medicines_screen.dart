import 'package:flutter/material.dart';
import 'package:recyleto_app/l10n/app_localizations.dart';

import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class RequestedMedicinesScreen extends StatefulWidget {
  const RequestedMedicinesScreen({super.key});

  @override
  State<RequestedMedicinesScreen> createState() =>
      _RequestedMedicinesScreenState();
}

class _RequestedMedicinesScreenState extends State<RequestedMedicinesScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _requestedMedicines = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadRequestedMedicines();
  }

  Future<void> _loadRequestedMedicines() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get medicine requests from API
      final requests = await _apiService.getMedicineRequests();

      // Filter only approved requests for this screen
      final approvedRequests = requests
          .where((request) =>
              request['status'] == 'approved' ||
              request['status'] == 'completed')
          .toList();

      setState(() {
        _requestedMedicines = approvedRequests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading requests: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredMedicines {
    List<Map<String, dynamic>> filtered = _requestedMedicines;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((medicine) => medicine['category'] == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((medicine) {
        final name = medicine['medicineName']?.toString().toLowerCase() ?? '';
        final genericName =
            medicine['genericName']?.toString().toLowerCase() ?? '';
        final manufacturer =
            medicine['manufacturer']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();

        return name.contains(query) ||
            genericName.contains(query) ||
            manufacturer.contains(query);
      }).toList();
    }

    return filtered;
  }

  List<String> get _categories {
    final categories = _requestedMedicines
        .map((m) => m['category'] as String)
        .toSet()
        .toList();
    categories.sort();
    return ['All', ...categories];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.requestedMedicines,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.successGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadRequestedMedicines,
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context)!.refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchMedicines,
                    prefixIcon:
                        const Icon(Icons.search, color: AppTheme.successGreen),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppTheme.successGreen, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 12),

                // Category Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          selectedColor: AppTheme.successGreen.withOpacity(0.2),
                          checkmarkColor: AppTheme.successGreen,
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.successGreen
                                : Colors.grey[300]!,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Medicines List
          Expanded(
            child: _buildMedicinesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicinesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredMedicines = _filteredMedicines;

    if (filteredMedicines.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadRequestedMedicines,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: filteredMedicines.length,
        itemBuilder: (context, index) {
          final medicine = filteredMedicines[index];
          return _buildMedicineCard(medicine);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication,
            size: 64,
            color: AppTheme.darkGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noRequestedMedicines,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.noRequestedMedicinesDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.darkGray.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine) {
    final urgency = medicine['urgency'] ?? 'medium';

    Color urgencyColor;
    IconData urgencyIcon;

    switch (urgency) {
      case 'urgent':
        urgencyColor = AppTheme.errorRed;
        urgencyIcon = Icons.emergency;
        break;
      case 'high':
        urgencyColor = AppTheme.warningOrange;
        urgencyIcon = Icons.priority_high;
        break;
      case 'low':
        urgencyColor = AppTheme.successGreen;
        urgencyIcon = Icons.schedule;
        break;
      default:
        urgencyColor = AppTheme.primaryTeal;
        urgencyIcon = Icons.warning_amber;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showMedicineDetails(medicine),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medicine Image
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: medicine['imageUrl'] != null
                      ? Image.network(
                          medicine['imageUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.medication,
                              size: 40,
                              color: Colors.grey[400],
                            );
                          },
                        )
                      : Icon(
                          Icons.medication,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                ),
              ),
              const SizedBox(height: 8),

              // Medicine Name
              Text(
                medicine['medicineName'] ?? 'Unknown Medicine',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Generic Name
              Text(
                medicine['genericName'] ?? 'Unknown Generic',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.darkGray.withOpacity(0.7),
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Category and Urgency
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.successGreen.withOpacity(0.3)),
                      ),
                      child: Text(
                        medicine['category'] ?? 'Unknown',
                        style: const TextStyle(
                          color: AppTheme.successGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    urgencyIcon,
                    color: urgencyColor,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Price
              Text(
                '\$${medicine['price']?.toStringAsFixed(2) ?? '0.00'}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successGreen,
                    ),
              ),
              const SizedBox(height: 4),

              // Pack Size
              Text(
                medicine['packSize'] ?? 'Unknown',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.darkGray.withOpacity(0.6),
                    ),
              ),
              const Spacer(),

              // Requested By
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 12,
                    color: AppTheme.darkGray.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      medicine['requestedBy'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.darkGray.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMedicineDetails(Map<String, dynamic> medicine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Medicine Image
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: medicine['imageUrl'] != null
                          ? Image.network(
                              medicine['imageUrl'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.medication,
                                  size: 60,
                                  color: Colors.grey[400],
                                );
                              },
                            )
                          : Icon(
                              Icons.medication,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Medicine Name
                Text(
                  medicine['medicineName'] ?? 'Unknown Medicine',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                ),
                const SizedBox(height: 8),

                // Generic Name
                Text(
                  medicine['genericName'] ?? 'Unknown Generic',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.darkGray.withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 20),

                // Details
                _buildDetailRow(
                  Icons.category,
                  AppLocalizations.of(context)!.category,
                  medicine['category'] ?? 'Unknown',
                ),
                _buildDetailRow(
                  Icons.inventory_2,
                  AppLocalizations.of(context)!.packSize,
                  medicine['packSize'] ?? 'Unknown',
                ),
                _buildDetailRow(
                  Icons.numbers,
                  AppLocalizations.of(context)!.quantity,
                  '${medicine['quantity'] ?? 0}',
                ),
                _buildDetailRow(
                  Icons.attach_money,
                  AppLocalizations.of(context)!.price,
                  '\$${medicine['price']?.toStringAsFixed(2) ?? '0.00'}',
                ),
                _buildDetailRow(
                  Icons.business,
                  AppLocalizations.of(context)!.manufacturer,
                  medicine['manufacturer'] ?? 'Unknown',
                ),
                _buildDetailRow(
                  Icons.person,
                  AppLocalizations.of(context)!.requestedBy,
                  medicine['requestedBy'] ?? 'Unknown',
                ),
                _buildDetailRow(
                  Icons.access_time,
                  AppLocalizations.of(context)!.requestDate,
                  _formatDate(medicine['requestedAt']),
                ),
                _buildDetailRow(
                  Icons.check_circle,
                  AppLocalizations.of(context)!.approvedAt,
                  _formatDate(medicine['approvedAt']),
                ),

                if (medicine['description'] != null &&
                    medicine['description'].isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.description,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    medicine['description'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.darkGray.withOpacity(0.8),
                        ),
                  ),
                ],

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.darkGray.withOpacity(0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.darkGray.withOpacity(0.6),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid Date';
    }
  }
}
