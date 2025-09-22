import 'package:flutter/material.dart';
import 'package:recyleto_app/l10n/app_localizations.dart';

import '../../services/mock_data_service.dart';
import '../../utils/app_theme.dart';

class AdminReviewScreen extends StatefulWidget {
  const AdminReviewScreen({super.key});

  @override
  State<AdminReviewScreen> createState() => _AdminReviewScreenState();
}

class _AdminReviewScreenState extends State<AdminReviewScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _approvedRequests = [];
  List<Map<String, dynamic>> _rejectedRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
    });

    // Mock data for medicine requests
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _pendingRequests = [
        {
          'id': 'REQ001',
          'medicineName': 'Paracetamol 500mg',
          'genericName': 'Acetaminophen',
          'category': 'Pain Relief',
          'packSize': '20 tablets',
          'quantity': 100,
          'price': 25.50,
          'manufacturer': 'PharmaCorp',
          'description': 'Pain relief medication',
          'requestedBy': 'Dr. Ahmed Hassan',
          'requestedAt': '2024-01-20T10:30:00Z',
          'status': 'pending',
          'urgency': 'medium',
        },
        {
          'id': 'REQ002',
          'medicineName': 'Amoxicillin 250mg',
          'genericName': 'Amoxicillin',
          'category': 'Antibiotics',
          'packSize': '21 capsules',
          'quantity': 50,
          'price': 45.00,
          'manufacturer': 'MediLife',
          'description': 'Antibiotic for bacterial infections',
          'requestedBy': 'Dr. Sarah Johnson',
          'requestedAt': '2024-01-20T09:15:00Z',
          'status': 'pending',
          'urgency': 'high',
        },
        {
          'id': 'REQ003',
          'medicineName': 'Insulin Pen',
          'genericName': 'Human Insulin',
          'category': 'Diabetes',
          'packSize': '1 pen',
          'quantity': 20,
          'price': 120.00,
          'manufacturer': 'DiabCare',
          'description': 'Insulin for diabetes management',
          'requestedBy': 'Dr. Mike Chen',
          'requestedAt': '2024-01-19T16:45:00Z',
          'status': 'pending',
          'urgency': 'urgent',
        },
      ];

      _approvedRequests = [
        {
          'id': 'REQ004',
          'medicineName': 'Vitamin C 1000mg',
          'genericName': 'Ascorbic Acid',
          'category': 'Vitamins',
          'packSize': '30 tablets',
          'quantity': 200,
          'price': 35.75,
          'manufacturer': 'VitHealth',
          'description': 'Vitamin C supplement',
          'requestedBy': 'Dr. Emily Davis',
          'requestedAt': '2024-01-18T14:20:00Z',
          'approvedAt': '2024-01-19T10:00:00Z',
          'status': 'approved',
          'urgency': 'low',
        },
      ];

      _rejectedRequests = [
        {
          'id': 'REQ005',
          'medicineName': 'Experimental Drug',
          'genericName': 'Unknown',
          'category': 'Other',
          'packSize': '10 tablets',
          'quantity': 5,
          'price': 500.00,
          'manufacturer': 'Unknown',
          'description': 'Experimental medication',
          'requestedBy': 'Dr. Test User',
          'requestedAt': '2024-01-17T11:30:00Z',
          'rejectedAt': '2024-01-18T09:00:00Z',
          'status': 'rejected',
          'urgency': 'medium',
          'rejectionReason': 'Experimental drug not approved for use',
        },
      ];

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.medicineRequests,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              text: AppLocalizations.of(context)!.pendingRequests,
              icon: const Icon(Icons.pending_actions),
            ),
            Tab(
              text: AppLocalizations.of(context)!.approvedRequests,
              icon: const Icon(Icons.check_circle),
            ),
            Tab(
              text: AppLocalizations.of(context)!.rejectedRequests,
              icon: const Icon(Icons.cancel),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadRequests,
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context)!.refresh,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsList(_pendingRequests, 'pending'),
          _buildRequestsList(_approvedRequests, 'approved'),
          _buildRequestsList(_rejectedRequests, 'rejected'),
        ],
      ),
    );
  }

  Widget _buildRequestsList(
      List<Map<String, dynamic>> requests, String status) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (requests.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _buildRequestCard(request);
        },
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    String title;
    String message;
    IconData icon;

    switch (status) {
      case 'pending':
        title = AppLocalizations.of(context)!.noPendingRequests;
        message = AppLocalizations.of(context)!.noPendingRequestsDescription;
        icon = Icons.check_circle_outline;
        break;
      case 'approved':
        title = AppLocalizations.of(context)!.noApprovedRequests;
        message = AppLocalizations.of(context)!.noApprovedRequestsDescription;
        icon = Icons.approval;
        break;
      case 'rejected':
        title = AppLocalizations.of(context)!.noRejectedRequests;
        message = AppLocalizations.of(context)!.noRejectedRequestsDescription;
        icon = Icons.cancel_outlined;
        break;
      default:
        title = AppLocalizations.of(context)!.noRequests;
        message = AppLocalizations.of(context)!.noRequestsDescription;
        icon = Icons.inbox;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppTheme.darkGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.darkGray.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final urgency = request['urgency'] ?? 'medium';
    final status = request['status'] ?? 'pending';

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
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with urgency and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      urgencyIcon,
                      color: urgencyColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getUrgencyText(urgency),
                      style: TextStyle(
                        color: urgencyColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(status)),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Medicine details
            Text(
              request['medicineName'] ?? 'Unknown Medicine',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTeal,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              request['genericName'] ?? 'Unknown Generic',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.darkGray.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 8),

            // Details row
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.category,
                    AppLocalizations.of(context)!.category,
                    request['category'] ?? 'Unknown',
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.inventory_2,
                    AppLocalizations.of(context)!.packSize,
                    request['packSize'] ?? 'Unknown',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.numbers,
                    AppLocalizations.of(context)!.quantity,
                    '${request['quantity'] ?? 0}',
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.attach_money,
                    AppLocalizations.of(context)!.price,
                    '\$${request['price']?.toStringAsFixed(2) ?? '0.00'}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            _buildDetailItem(
              Icons.business,
              AppLocalizations.of(context)!.manufacturer,
              request['manufacturer'] ?? 'Unknown',
            ),
            const SizedBox(height: 8),

            _buildDetailItem(
              Icons.person,
              AppLocalizations.of(context)!.requestedBy,
              request['requestedBy'] ?? 'Unknown',
            ),
            const SizedBox(height: 8),

            _buildDetailItem(
              Icons.access_time,
              AppLocalizations.of(context)!.requestDate,
              _formatDate(request['requestedAt']),
            ),

            if (request['description'] != null &&
                request['description'].isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.description,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                request['description'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.darkGray.withOpacity(0.8),
                    ),
              ),
            ],

            if (request['rejectionReason'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.errorRed.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.cancel,
                          color: AppTheme.errorRed,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.rejectionReason,
                          style: const TextStyle(
                            color: AppTheme.errorRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request['rejectionReason'],
                      style: TextStyle(
                        color: AppTheme.errorRed.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action buttons for pending requests
            if (status == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectRequest(request),
                      icon: const Icon(Icons.cancel, size: 18),
                      label: Text(AppLocalizations.of(context)!.rejectRequest),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorRed,
                        side: const BorderSide(color: AppTheme.errorRed),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveRequest(request),
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(AppLocalizations.of(context)!.approveRequest),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.darkGray.withOpacity(0.6),
        ),
        const SizedBox(width: 8),
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
    );
  }

  String _getUrgencyText(String urgency) {
    switch (urgency) {
      case 'urgent':
        return AppLocalizations.of(context)!.urgent;
      case 'high':
        return AppLocalizations.of(context)!.highPriority;
      case 'low':
        return AppLocalizations.of(context)!.lowPriority;
      default:
        return AppLocalizations.of(context)!.mediumPriority;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return AppLocalizations.of(context)!.pending;
      case 'approved':
        return AppLocalizations.of(context)!.approved;
      case 'rejected':
        return AppLocalizations.of(context)!.rejected;
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.warningOrange;
      case 'approved':
        return AppTheme.successGreen;
      case 'rejected':
        return AppTheme.errorRed;
      default:
        return AppTheme.darkGray;
    }
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

  Future<void> _approveRequest(Map<String, dynamic> request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.approveRequest),
        content: Text(
          '${AppLocalizations.of(context)!.areYouSureApprove} "${request['medicineName']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.approve),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        request['status'] = 'approved';
        request['approvedAt'] = DateTime.now().toIso8601String();
        _pendingRequests.remove(request);
        _approvedRequests.add(request);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.requestApproved),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  Future<void> _rejectRequest(Map<String, dynamic> request) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.rejectRequest),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${AppLocalizations.of(context)!.areYouSureReject} "${request['medicineName']}"?',
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.rejectionReason,
                hintText: AppLocalizations.of(context)!.enterRejectionReason,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final reasonController = TextEditingController();
              Navigator.of(context).pop(reasonController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.reject),
          ),
        ],
      ),
    );

    if (reason != null && reason.isNotEmpty) {
      setState(() {
        request['status'] = 'rejected';
        request['rejectedAt'] = DateTime.now().toIso8601String();
        request['rejectionReason'] = reason;
        _pendingRequests.remove(request);
        _rejectedRequests.add(request);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.requestRejected),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }
}
