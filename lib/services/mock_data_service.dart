class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  // Simulate API delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Mock medicines data for inventory
  final List<Map<String, dynamic>> mockMedicines = [
    {
      'id': '1',
      'name': 'Paracetamol 500mg',
      'genericName': 'Acetaminophen',
      'form': 'Tablet',
      'packSize': '20 tablets',
      'stock': 150,
      'quantity': 150,
      'price': 25.50,
      'expiryDate': '2025-06-15',
      'manufacturer': 'PharmaCorp',
      'category': 'Pain Relief',
      'barcode': '1234567890123',
    },
    {
      'id': '2',
      'name': 'Amoxicillin 250mg',
      'genericName': 'Amoxicillin',
      'form': 'Capsule',
      'packSize': '21 capsules',
      'stock': 8,
      'quantity': 8,
      'price': 45.00,
      'expiryDate': '2024-12-20',
      'manufacturer': 'MediLife',
      'category': 'Antibiotic',
      'barcode': '1234567890124',
    },
    {
      'id': '3',
      'name': 'Vitamin C 1000mg',
      'genericName': 'Ascorbic Acid',
      'form': 'Tablet',
      'packSize': '30 tablets',
      'stock': 200,
      'quantity': 200,
      'price': 35.75,
      'expiryDate': '2026-03-10',
      'manufacturer': 'VitHealth',
      'category': 'Vitamin',
      'barcode': '1234567890125',
    },
    {
      'id': '4',
      'name': 'Insulin Pen',
      'genericName': 'Human Insulin',
      'form': 'Injection',
      'packSize': '1 pen',
      'stock': 3,
      'quantity': 3,
      'price': 120.00,
      'expiryDate': '2024-11-30',
      'manufacturer': 'DiabCare',
      'category': 'Diabetes',
      'barcode': '1234567890126',
    },
    {
      'id': '5',
      'name': 'Aspirin 100mg',
      'genericName': 'Acetylsalicylic Acid',
      'form': 'Tablet',
      'packSize': '100 tablets',
      'stock': 75,
      'quantity': 75,
      'price': 15.25,
      'expiryDate': '2024-10-15',
      'manufacturer': 'CardioMed',
      'category': 'Cardiovascular',
      'barcode': '1234567890127',
    },
    {
      'id': '6',
      'name': 'Metformin 500mg',
      'genericName': 'Metformin HCl',
      'form': 'Tablet',
      'packSize': '60 tablets',
      'stock': 120,
      'quantity': 120,
      'price': 28.90,
      'expiryDate': '2025-08-22',
      'manufacturer': 'DiabCare',
      'category': 'Diabetes',
      'barcode': '1234567890128',
    },
    {
      'id': '7',
      'name': 'Ibuprofen 400mg',
      'genericName': 'Ibuprofen',
      'form': 'Tablet',
      'packSize': '24 tablets',
      'stock': 5,
      'quantity': 5,
      'price': 32.00,
      'expiryDate': '2025-01-18',
      'manufacturer': 'PainRelief Inc',
      'category': 'Pain Relief',
      'barcode': '1234567890129',
    },
    {
      'id': '8',
      'name': 'Omeprazole 20mg',
      'genericName': 'Omeprazole',
      'form': 'Capsule',
      'packSize': '28 capsules',
      'stock': 90,
      'quantity': 90,
      'price': 55.50,
      'expiryDate': '2025-04-30',
      'manufacturer': 'GastroMed',
      'category': 'Gastrointestinal',
      'barcode': '1234567890130',
    },
    {
      'id': '9',
      'name': 'Lisinopril 10mg',
      'genericName': 'Lisinopril',
      'form': 'Tablet',
      'packSize': '30 tablets',
      'stock': 60,
      'quantity': 60,
      'price': 42.75,
      'expiryDate': '2025-07-12',
      'manufacturer': 'CardioMed',
      'category': 'Cardiovascular',
      'barcode': '1234567890131',
    },
    {
      'id': '10',
      'name': 'Atorvastatin 20mg',
      'genericName': 'Atorvastatin',
      'form': 'Tablet',
      'packSize': '30 tablets',
      'stock': 45,
      'quantity': 45,
      'price': 68.25,
      'expiryDate': '2025-09-05',
      'manufacturer': 'CholMed',
      'category': 'Cardiovascular',
      'barcode': '1234567890132',
    },
  ];

  // Get all medicines
  Future<List<Map<String, dynamic>>> getMedicines({String? search}) async {
    await _simulateDelay();

    List<Map<String, dynamic>> filteredMedicines = List.from(mockMedicines);

    if (search != null && search.isNotEmpty) {
      final searchTerm = search.toLowerCase();
      filteredMedicines = filteredMedicines.where((med) {
        return (med['name']?.toString().toLowerCase().contains(searchTerm) ??
                false) ||
            (med['genericName']
                    ?.toString()
                    .toLowerCase()
                    .contains(searchTerm) ??
                false) ||
            (med['manufacturer']
                    ?.toString()
                    .toLowerCase()
                    .contains(searchTerm) ??
                false);
      }).toList();
    }

    return filteredMedicines;
  }

  // Get low stock medicines
  Future<List<Map<String, dynamic>>> getLowStockMedicines() async {
    await _simulateDelay();
    return mockMedicines.where((med) => (med['stock'] ?? 0) < 10).toList();
  }

  // Get expiring medicines
  Future<List<Map<String, dynamic>>> getExpiringMedicines() async {
    await _simulateDelay();
    final now = DateTime.now();
    final tenDaysFromNow = now.add(const Duration(days: 10));

    return mockMedicines.where((med) {
      final expiryDate = DateTime.tryParse(med['expiryDate'] ?? '');
      return expiryDate != null && expiryDate.isBefore(tenDaysFromNow);
    }).map((med) {
      // Add transaction number to each medicine
      return {
        ...med,
        'transactionNumber':
            'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}-${med['id']}',
        'purchaseDate': DateTime.now()
            .subtract(Duration(days: (med['id'] == '1') ? 5 : 3))
            .toIso8601String()
            .split('T')[0],
      };
    }).toList();
  }

  // Get medicine by ID
  Future<Map<String, dynamic>?> getMedicineById(String id) async {
    await _simulateDelay();
    try {
      return mockMedicines.firstWhere((med) => med['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Update medicine
  Future<bool> updateMedicine(String id, Map<String, dynamic> updates) async {
    await _simulateDelay();
    try {
      final index = mockMedicines.indexWhere((med) => med['id'] == id);
      if (index != -1) {
        mockMedicines[index].addAll(updates);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Delete medicine
  Future<bool> deleteMedicine(String id) async {
    await _simulateDelay();
    try {
      final index = mockMedicines.indexWhere((med) => med['id'] == id);
      if (index != -1) {
        mockMedicines.removeAt(index);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Add new medicine
  Future<bool> addMedicine(Map<String, dynamic> medicine) async {
    await _simulateDelay();
    try {
      final newId = (mockMedicines.length + 1).toString();
      medicine['id'] = newId;
      mockMedicines.add(medicine);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Mock user profile data
  final Map<String, dynamic> mockUserProfile = {
    'id': 'user_123',
    'email': 'pharmacy@example.com',
    'firstName': 'Ahmed',
    'lastName': 'Hassan',
    'pharmacyName': 'Green Valley Pharmacy',
    'role': 'pharmacy_owner',
    'phone': '+201234567890',
    'address': 'Tahrir Square, Cairo',
    'licenseNumber': 'PH123456789',
    'isVerified': true,
    'createdAt': '2024-01-15T10:30:00Z',
    'lastLogin': '2024-01-20T14:25:00Z',
  };

  // Mock dashboard data
  final Map<String, dynamic> mockDashboardData = {
    'kpis': {
      'totalSales': 125000.0,
      'totalPurchases': 85000.0,
      'lowStockCount': 8,
      'expiringCount': 12,
      'pendingRequestsCount': 5,
    },
    'lowStockItems': [
      {
        'id': 'PROD001',
        'productId': {'name': 'Paracetamol 500mg'},
        'currentStock': 5,
        'minStock': 10,
        'category': 'Pain Relief',
      },
      {
        'id': 'PROD002',
        'productId': {'name': 'Vitamin C 1000mg'},
        'currentStock': 3,
        'minStock': 15,
        'category': 'Vitamins',
      },
      {
        'id': 'PROD003',
        'productId': {'name': 'Amoxicillin 250mg'},
        'currentStock': 2,
        'minStock': 20,
        'category': 'Antibiotics',
      },
      {
        'id': 'PROD004',
        'productId': {'name': 'Insulin Pen'},
        'currentStock': 1,
        'minStock': 5,
        'category': 'Diabetes',
      },
    ],
    'expiringMedications': [
      {
        'id': 'PROD005',
        'productId': {'name': 'Aspirin 100mg'},
        'expiryDate': '2024-02-15',
        'daysUntilExpiry': 26,
        'category': 'Pain Relief',
      },
      {
        'id': 'PROD006',
        'productId': {'name': 'Metformin 500mg'},
        'expiryDate': '2024-02-20',
        'daysUntilExpiry': 31,
        'category': 'Diabetes',
      },
      {
        'id': 'PROD007',
        'productId': {'name': 'Lisinopril 10mg'},
        'expiryDate': '2024-02-25',
        'daysUntilExpiry': 36,
        'category': 'Cardiovascular',
      },
    ],
    'recentActivity': [
      {
        'id': 'ACT001',
        'title': 'New Sale Completed',
        'subtitle': 'Transaction #TX-20240120-001',
        'amount': 150.0,
        'type': 'sale',
        'timeAgo': '2 hours ago',
        'timestamp':
            DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': 'ACT002',
        'title': 'Medicine Added',
        'subtitle': 'Paracetamol 500mg added to inventory',
        'amount': 25.0,
        'type': 'inventory',
        'timeAgo': '4 hours ago',
        'timestamp':
            DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
      },
      {
        'id': 'ACT003',
        'title': 'Refund Processed',
        'subtitle': 'Refund #REF-001 processed',
        'amount': 75.0,
        'type': 'refund',
        'timeAgo': '6 hours ago',
        'timestamp':
            DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
      },
      {
        'id': 'ACT004',
        'title': 'New Request',
        'subtitle': 'Medicine request from Dr. Smith',
        'amount': 0.0,
        'type': 'request',
        'timeAgo': '8 hours ago',
        'timestamp':
            DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
      },
      {
        'id': 'ACT005',
        'title': 'Stock Updated',
        'subtitle': 'Vitamin C stock replenished',
        'amount': 45.0,
        'type': 'inventory',
        'timeAgo': '1 day ago',
        'timestamp':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
    ],
  };

  // Mock notifications data
  final List<Map<String, dynamic>> mockNotifications = [
    {
      'id': 'NOTIF001',
      'title': 'Low Stock Alert',
      'message': 'Paracetamol 500mg is running low (5 units remaining)',
      'type': 'warning',
      'isRead': false,
      'timestamp':
          DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
    },
    {
      'id': 'NOTIF002',
      'title': 'New Order Received',
      'message': 'Order #ORD001 has been placed by John Smith',
      'type': 'info',
      'isRead': false,
      'timestamp':
          DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
    {
      'id': 'NOTIF003',
      'title': 'Product Expiring Soon',
      'message': 'Amoxicillin 250mg expires in 26 days',
      'type': 'warning',
      'isRead': false,
      'timestamp':
          DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
    },
    {
      'id': 'NOTIF004',
      'title': 'Monthly Report Ready',
      'message': 'Your January sales report is now available',
      'type': 'success',
      'isRead': true,
      'timestamp':
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
    {
      'id': 'NOTIF005',
      'title': 'System Update',
      'message': 'New features have been added to your dashboard',
      'type': 'system',
      'isRead': true,
      'timestamp':
          DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    },
    {
      'id': 'NOTIF006',
      'title': 'Payment Received',
      'message': 'Payment of \$150.00 received for Order #ORD001',
      'type': 'success',
      'isRead': true,
      'timestamp':
          DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
    },
  ];

  // Mock sales data
  final Map<String, dynamic> mockSalesData = {
    'totalRevenue': 125000.0,
    'totalOrders': 450,
    'averageOrderValue': 277.78,
    'salesByMonth': [
      {'month': 'Jan', 'sales': 25000.0},
      {'month': 'Feb', 'sales': 30000.0},
      {'month': 'Mar', 'sales': 28000.0},
      {'month': 'Apr', 'sales': 32000.0},
      {'month': 'May', 'sales': 35000.0},
      {'month': 'Jun', 'sales': 40000.0},
    ],
    'salesByWeek': [
      {'week': 'Week 1', 'sales': 18500.0, 'orders': 45, 'growth': 12.5},
      {'week': 'Week 2', 'sales': 22100.0, 'orders': 52, 'growth': 8.3},
      {'week': 'Week 3', 'sales': 19800.0, 'orders': 48, 'growth': -2.1},
      {'week': 'Week 4', 'sales': 25600.0, 'orders': 61, 'growth': 15.7},
    ],
    'topSellingProducts': [
      {'name': 'Paracetamol 500mg', 'sales': 150, 'revenue': 3750.0},
      {'name': 'Vitamin C 1000mg', 'sales': 120, 'revenue': 5400.0},
      {'name': 'Amoxicillin 250mg', 'sales': 80, 'revenue': 6400.0},
    ],
  };

  // Mock weekly performance metrics
  final Map<String, dynamic> mockWeeklyMetrics = {
    'currentWeek': {
      'sales': 25600.0,
      'orders': 61,
      'customers': 45,
      'growth': 15.7,
      'completionRate': 98.5,
      'responseTime': 2.3,
      'satisfaction': 4.8,
    },
    'previousWeek': {
      'sales': 19800.0,
      'orders': 48,
      'customers': 38,
      'growth': -2.1,
      'completionRate': 96.2,
      'responseTime': 2.8,
      'satisfaction': 4.6,
    },
    'weeklyTrends': [
      {'day': 'Mon', 'sales': 3200.0, 'orders': 8},
      {'day': 'Tue', 'sales': 4100.0, 'orders': 10},
      {'day': 'Wed', 'sales': 3800.0, 'orders': 9},
      {'day': 'Thu', 'sales': 4500.0, 'orders': 11},
      {'day': 'Fri', 'sales': 5200.0, 'orders': 13},
      {'day': 'Sat', 'sales': 2800.0, 'orders': 7},
      {'day': 'Sun', 'sales': 2000.0, 'orders': 5},
    ],
  };

  // Mock login function
  Future<Map<String, dynamic>> mockLogin(String email, String password) async {
    await _simulateDelay();

    // Accept any email and password for demo purposes
    if (email.isNotEmpty && password.isNotEmpty) {
      return {
        'success': true,
        'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          ...mockUserProfile,
          'email': email,
          'firstName': email.split('@')[0].split('.')[0],
          'lastName': email.split('@')[0].split('.').length > 1
              ? email.split('@')[0].split('.')[1]
              : 'User',
        },
        'message': 'Login successful',
      };
    } else {
      throw Exception('Email and password are required');
    }
  }

  // Mock register function
  Future<Map<String, dynamic>> mockRegister(
      Map<String, dynamic> userData) async {
    await _simulateDelay();

    // Validate required fields
    if (userData['email'] == null || userData['email'].toString().isEmpty) {
      throw Exception('Email is required');
    }
    if (userData['password'] == null ||
        userData['password'].toString().isEmpty) {
      throw Exception('Password is required');
    }

    return {
      'success': true,
      'data': {
        'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
        'email': userData['email'],
        'firstName': userData['firstName'] ??
            userData['email'].toString().split('@')[0].split('.')[0],
        'lastName': userData['lastName'] ?? 'User',
        'pharmacyName': userData['pharmacyName'] ?? 'New Pharmacy',
        'role': userData['role'] ?? 'pharmacy_owner',
        'phone': userData['phone'] ?? '+201234567890',
        'address': userData['address'] ?? 'Tahrir Square, Cairo',
        'licenseNumber': 'PH${DateTime.now().millisecondsSinceEpoch}',
        'isVerified': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
      'message': 'Account created successfully',
    };
  }

  // Mock dashboard data
  Future<Map<String, dynamic>> getDashboardData() async {
    await _simulateDelay();
    return mockDashboardData;
  }

  // Mock notifications
  Future<List<Map<String, dynamic>>> getNotifications() async {
    await _simulateDelay();
    return mockNotifications;
  }

  // Mock user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    await _simulateDelay();
    return mockUserProfile;
  }

  // Mock market medicines search
  Future<List<Map<String, dynamic>>> searchMarketMedicines(String query) async {
    await _simulateDelay();

    if (query.isEmpty) {
      return mockMarketMedicines;
    }

    return mockMarketMedicines.where((medicine) {
      return medicine['name']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          medicine['category']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          medicine['manufacturer']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase());
    }).toList();
  }

  // Mock sales data
  Future<Map<String, dynamic>> getSalesData() async {
    await _simulateDelay();
    return mockSalesData;
  }

  // Mock weekly performance metrics
  Future<Map<String, dynamic>> getWeeklyMetrics() async {
    await _simulateDelay();
    return mockWeeklyMetrics;
  }

  // Mock user profile update
  Future<Map<String, dynamic>> updateUserProfile(
      Map<String, dynamic> profileData) async {
    await _simulateDelay();

    return {
      'success': true,
      'data': {
        ...mockUserProfile,
        ...profileData,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      'message': 'Profile updated successfully',
    };
  }

  // Mock password change
  Future<Map<String, dynamic>> changePassword(
      String currentPassword, String newPassword) async {
    await _simulateDelay();

    if (currentPassword.isEmpty || newPassword.isEmpty) {
      throw Exception('Current password and new password are required');
    }

    if (newPassword.length < 6) {
      throw Exception('New password must be at least 6 characters long');
    }

    return {
      'success': true,
      'message': 'Password changed successfully',
    };
  }

  // Mock logout
  Future<Map<String, dynamic>> logout() async {
    await _simulateDelay();

    return {
      'success': true,
      'message': 'Logged out successfully',
    };
  }

  // Mock support messages
  final List<Map<String, dynamic>> mockSupportMessages = [
    {
      'id': 'MSG001',
      'text': 'Welcome to our support chat! How can I help you today?',
      'isUser': false,
      'timestamp':
          DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      'sender': 'Support Agent',
    },
    {
      'id': 'MSG002',
      'text': 'Hi! I need help with my pharmacy account setup.',
      'isUser': true,
      'timestamp': DateTime.now()
          .subtract(const Duration(hours: 1, minutes: 45))
          .toIso8601String(),
      'sender': 'You',
    },
    {
      'id': 'MSG003',
      'text':
          'I\'d be happy to help you with your pharmacy account setup. What specific issue are you facing?',
      'isUser': false,
      'timestamp': DateTime.now()
          .subtract(const Duration(hours: 1, minutes: 40))
          .toIso8601String(),
      'sender': 'Support Agent',
    },
    {
      'id': 'MSG004',
      'text': 'I can\'t seem to add my pharmacy license information.',
      'isUser': true,
      'timestamp': DateTime.now()
          .subtract(const Duration(hours: 1, minutes: 35))
          .toIso8601String(),
      'sender': 'You',
    },
    {
      'id': 'MSG005',
      'text':
          'Let me help you with that. Please make sure your license image is in JPG or PNG format and under 5MB. You can try uploading it again from the Pharmacy Registration screen.',
      'isUser': false,
      'timestamp': DateTime.now()
          .subtract(const Duration(hours: 1, minutes: 30))
          .toIso8601String(),
      'sender': 'Support Agent',
    },
  ];

  // Mock get support messages
  Future<List<Map<String, dynamic>>> getSupportMessages() async {
    await _simulateDelay();
    return mockSupportMessages;
  }

  // Mock send support message
  Future<Map<String, dynamic>> sendSupportMessage(
      Map<String, dynamic> messageData) async {
    await _simulateDelay();

    // Add message to mock data
    final newMessage = {
      'id': 'MSG${DateTime.now().millisecondsSinceEpoch}',
      'text': messageData['message'],
      'isUser': true,
      'timestamp': DateTime.now().toIso8601String(),
      'sender': 'You',
      'status': 'sent',
    };

    mockSupportMessages.add(newMessage);

    return {
      'success': true,
      'message': 'Message sent successfully',
      'data': newMessage,
    };
  }

  // Mock sales report data
  final Map<String, dynamic> mockSalesReport = {
    'summary': {
      'totalSales': 125000.0,
      'totalOrders': 156,
      'averageOrderValue': 801.28,
      'growthRate': 15.7,
      'topSellingCategory': 'Pain Relief',
      'topSellingProduct': 'Paracetamol 500mg',
    },
    'dailySales': [
      {'date': '2024-01-01', 'sales': 3200.0, 'orders': 8},
      {'date': '2024-01-02', 'sales': 4100.0, 'orders': 12},
      {'date': '2024-01-03', 'sales': 2800.0, 'orders': 6},
      {'date': '2024-01-04', 'sales': 3500.0, 'orders': 9},
      {'date': '2024-01-05', 'sales': 4200.0, 'orders': 11},
      {'date': '2024-01-06', 'sales': 3800.0, 'orders': 10},
      {'date': '2024-01-07', 'sales': 4500.0, 'orders': 13},
    ],
    'categoryBreakdown': [
      {'category': 'Pain Relief', 'sales': 45000.0, 'percentage': 36.0},
      {'category': 'Antibiotics', 'sales': 32000.0, 'percentage': 25.6},
      {'category': 'Vitamins', 'sales': 28000.0, 'percentage': 22.4},
      {'category': 'Diabetes', 'sales': 15000.0, 'percentage': 12.0},
      {'category': 'Other', 'sales': 5000.0, 'percentage': 4.0},
    ],
    'paymentMethodBreakdown': [
      {'method': 'Cash', 'amount': 75000.0, 'percentage': 60.0},
      {'method': 'Card', 'amount': 35000.0, 'percentage': 28.0},
      {'method': 'Transfer', 'amount': 10000.0, 'percentage': 8.0},
      {'method': 'Mobile Money', 'amount': 5000.0, 'percentage': 4.0},
    ],
    'topProducts': [
      {'name': 'Paracetamol 500mg', 'sales': 8500.0, 'quantity': 170},
      {'name': 'Amoxicillin 500mg', 'sales': 7200.0, 'quantity': 120},
      {'name': 'Vitamin D3', 'sales': 6800.0, 'quantity': 85},
      {'name': 'Metformin 500mg', 'sales': 5600.0, 'quantity': 112},
      {'name': 'Ibuprofen 400mg', 'sales': 4800.0, 'quantity': 96},
    ],
  };

  // Mock inventory report data
  final Map<String, dynamic> mockInventoryReport = {
    'summary': {
      'totalProducts': 245,
      'totalValue': 125000.0,
      'lowStockItems': 12,
      'expiringSoon': 8,
      'outOfStock': 3,
    },
    'stockStatus': [
      {'status': 'In Stock', 'count': 222, 'percentage': 90.6},
      {'status': 'Low Stock', 'count': 12, 'percentage': 4.9},
      {'status': 'Out of Stock', 'count': 3, 'percentage': 1.2},
      {'status': 'Expired', 'count': 8, 'percentage': 3.3},
    ],
    'categoryBreakdown': [
      {'category': 'Pain Relief', 'products': 45, 'value': 25000.0},
      {'category': 'Antibiotics', 'products': 38, 'value': 32000.0},
      {'category': 'Vitamins', 'products': 52, 'value': 18000.0},
      {'category': 'Diabetes', 'products': 28, 'value': 22000.0},
      {'category': 'Hypertension', 'products': 35, 'value': 15000.0},
      {'category': 'Other', 'products': 47, 'value': 13000.0},
    ],
    'lowStockItems': [
      {
        'name': 'Paracetamol 500mg',
        'currentStock': 5,
        'minStock': 20,
        'category': 'Pain Relief'
      },
      {
        'name': 'Amoxicillin 500mg',
        'currentStock': 8,
        'minStock': 15,
        'category': 'Antibiotics'
      },
      {
        'name': 'Vitamin D3',
        'currentStock': 3,
        'minStock': 10,
        'category': 'Vitamins'
      },
      {
        'name': 'Metformin 500mg',
        'currentStock': 7,
        'minStock': 12,
        'category': 'Diabetes'
      },
    ],
    'expiringSoon': [
      {
        'name': 'Aspirin 100mg',
        'expiryDate': '2024-02-15',
        'daysLeft': 26,
        'category': 'Pain Relief'
      },
      {
        'name': 'Ciprofloxacin 500mg',
        'expiryDate': '2024-02-20',
        'daysLeft': 31,
        'category': 'Antibiotics'
      },
      {
        'name': 'Vitamin B12',
        'expiryDate': '2024-02-25',
        'daysLeft': 36,
        'category': 'Vitamins'
      },
    ],
  };

  // Mock performance report data
  final Map<String, dynamic> mockPerformanceReport = {
    'summary': {
      'totalRevenue': 125000.0,
      'totalOrders': 156,
      'averageOrderValue': 801.28,
      'customerSatisfaction': 4.8,
      'orderCompletionRate': 98.5,
      'averageResponseTime': 2.3,
    },
    'monthlyTrends': [
      {'month': 'Jan', 'revenue': 120000.0, 'orders': 150, 'satisfaction': 4.7},
      {'month': 'Feb', 'revenue': 125000.0, 'orders': 156, 'satisfaction': 4.8},
      {'month': 'Mar', 'revenue': 130000.0, 'orders': 162, 'satisfaction': 4.9},
    ],
    'kpiMetrics': [
      {'metric': 'Revenue Growth', 'value': 15.7, 'unit': '%', 'trend': 'up'},
      {'metric': 'Order Volume', 'value': 156, 'unit': 'orders', 'trend': 'up'},
      {
        'metric': 'Customer Satisfaction',
        'value': 4.8,
        'unit': '/5',
        'trend': 'up'
      },
      {
        'metric': 'Response Time',
        'value': 2.3,
        'unit': 'hours',
        'trend': 'down'
      },
    ],
    'topPerformers': [
      {
        'name': 'Dr. Sarah Johnson',
        'role': 'Pharmacist',
        'orders': 45,
        'rating': 4.9
      },
      {'name': 'Mike Chen', 'role': 'Manager', 'orders': 38, 'rating': 4.8},
      {
        'name': 'Emily Davis',
        'role': 'Pharmacist',
        'orders': 42,
        'rating': 4.7
      },
    ],
  };

  // Mock get sales report
  Future<Map<String, dynamic>> getSalesReport() async {
    await _simulateDelay();
    return mockSalesReport;
  }

  // Mock get inventory report
  Future<Map<String, dynamic>> getInventoryReport() async {
    await _simulateDelay();
    return mockInventoryReport;
  }

  // Mock get performance report
  Future<Map<String, dynamic>> getPerformanceReport() async {
    await _simulateDelay();
    return mockPerformanceReport;
  }

  // Mock users data
  final List<Map<String, dynamic>> mockUsers = [
    {
      'id': 'USER001',
      'name': 'Dr. Sarah Johnson',
      'email': 'sarah.johnson@pharmacy.com',
      'phone': '+1-555-0123',
      'role': 'pharmacist',
      'isActive': true,
      'status': 'active',
      'joinDate': '2023-01-15',
      'lastLogin': '2024-01-20T10:30:00Z',
      'permissions': ['view_inventory', 'manage_orders', 'view_reports'],
      'profileImage': null,
    },
    {
      'id': 'USER002',
      'name': 'Mike Chen',
      'email': 'mike.chen@pharmacy.com',
      'phone': '+1-555-0124',
      'role': 'manager',
      'isActive': true,
      'status': 'active',
      'joinDate': '2022-08-20',
      'lastLogin': '2024-01-20T09:15:00Z',
      'permissions': [
        'view_inventory',
        'manage_orders',
        'view_reports',
        'manage_users',
        'manage_inventory'
      ],
      'profileImage': null,
    },
    {
      'id': 'USER003',
      'name': 'Emily Davis',
      'email': 'emily.davis@pharmacy.com',
      'phone': '+1-555-0125',
      'role': 'pharmacist',
      'isActive': true,
      'status': 'active',
      'joinDate': '2023-03-10',
      'lastLogin': '2024-01-19T16:45:00Z',
      'permissions': ['view_inventory', 'manage_orders', 'view_reports'],
      'profileImage': null,
    },
    {
      'id': 'USER004',
      'name': 'James Wilson',
      'email': 'james.wilson@pharmacy.com',
      'phone': '+1-555-0126',
      'role': 'cashier',
      'isActive': true,
      'status': 'active',
      'joinDate': '2023-06-05',
      'lastLogin': '2024-01-20T14:20:00Z',
      'permissions': ['view_inventory', 'manage_orders'],
      'profileImage': null,
    },
    {
      'id': 'USER005',
      'name': 'Lisa Anderson',
      'email': 'lisa.anderson@pharmacy.com',
      'phone': '+1-555-0127',
      'role': 'pharmacist',
      'isActive': false,
      'status': 'inactive',
      'joinDate': '2022-11-12',
      'lastLogin': '2024-01-10T11:30:00Z',
      'permissions': ['view_inventory', 'manage_orders', 'view_reports'],
      'profileImage': null,
    },
    {
      'id': 'USER006',
      'name': 'Robert Brown',
      'email': 'robert.brown@pharmacy.com',
      'phone': '+1-555-0128',
      'role': 'admin',
      'isActive': true,
      'status': 'active',
      'joinDate': '2022-01-01',
      'lastLogin': '2024-01-20T08:00:00Z',
      'permissions': [
        'view_inventory',
        'manage_orders',
        'view_reports',
        'manage_users',
        'manage_inventory',
        'admin_access'
      ],
      'profileImage': null,
    },
    {
      'id': 'USER007',
      'name': 'Maria Garcia',
      'email': 'maria.garcia@pharmacy.com',
      'phone': '+1-555-0129',
      'role': 'cashier',
      'isActive': true,
      'status': 'active',
      'joinDate': '2023-09-18',
      'lastLogin': '2024-01-20T13:15:00Z',
      'permissions': ['view_inventory', 'manage_orders'],
      'profileImage': null,
    },
    {
      'id': 'USER008',
      'name': 'David Lee',
      'email': 'david.lee@pharmacy.com',
      'phone': '+1-555-0130',
      'role': 'pharmacist',
      'isActive': false,
      'status': 'suspended',
      'joinDate': '2023-02-28',
      'lastLogin': '2024-01-15T15:45:00Z',
      'permissions': ['view_inventory', 'manage_orders', 'view_reports'],
      'profileImage': null,
    },
  ];

  // Mock get users
  Future<List<Map<String, dynamic>>> getUsers() async {
    await _simulateDelay();
    return mockUsers;
  }

  // Mock add user
  Future<Map<String, dynamic>> addUser(Map<String, dynamic> userData) async {
    await _simulateDelay();

    final newUser = {
      'id': 'USER${DateTime.now().millisecondsSinceEpoch}',
      'name': userData['name'],
      'email': userData['email'],
      'phone': userData['phone'],
      'role': userData['role'],
      'isActive': userData['isActive'] ?? true,
      'status': 'active',
      'joinDate': DateTime.now().toIso8601String().split('T')[0],
      'lastLogin': null,
      'permissions': _getDefaultPermissions(userData['role']),
      'profileImage': null,
    };

    mockUsers.add(newUser);

    return {
      'success': true,
      'message': 'User added successfully',
      'data': newUser,
    };
  }

  // Mock update user
  Future<Map<String, dynamic>> updateUser(
      String userId, Map<String, dynamic> userData) async {
    await _simulateDelay();

    final userIndex = mockUsers.indexWhere((user) => user['id'] == userId);
    if (userIndex == -1) {
      throw Exception('User not found');
    }

    mockUsers[userIndex].addAll(userData);

    return {
      'success': true,
      'message': 'User updated successfully',
      'data': mockUsers[userIndex],
    };
  }

  // Mock delete user
  Future<Map<String, dynamic>> deleteUser(String userId) async {
    await _simulateDelay();

    final userIndex = mockUsers.indexWhere((user) => user['id'] == userId);
    if (userIndex == -1) {
      throw Exception('User not found');
    }

    mockUsers.removeAt(userIndex);

    return {
      'success': true,
      'message': 'User deleted successfully',
    };
  }

  List<String> _getDefaultPermissions(String role) {
    switch (role) {
      case 'admin':
        return [
          'view_inventory',
          'manage_orders',
          'view_reports',
          'manage_users',
          'manage_inventory',
          'admin_access'
        ];
      case 'manager':
        return [
          'view_inventory',
          'manage_orders',
          'view_reports',
          'manage_users',
          'manage_inventory'
        ];
      case 'pharmacist':
        return ['view_inventory', 'manage_orders', 'view_reports'];
      case 'cashier':
        return ['view_inventory', 'manage_orders'];
      default:
        return ['view_inventory'];
    }
  }

  // Mock deliveries data
  final List<Map<String, dynamic>> mockDeliveries = [
    {
      'id': 'DEL001',
      'orderId': 'ORD-20240120-001',
      'customerName': 'John Smith',
      'customerPhone': '+1-555-0101',
      'customerAddress': '123 Main St, New York, NY 10001',
      'deliveryAddress': '123 Main St, New York, NY 10001',
      'status': 'delivered',
      'deliveryType': 'standard',
      'orderItems': [
        {'name': 'Paracetamol 500mg', 'quantity': 2, 'price': 15.99},
        {'name': 'Vitamin D3', 'quantity': 1, 'price': 25.50},
      ],
      'totalAmount': 57.48,
      'deliveryFee': 5.99,
      'scheduledDate': '2024-01-20',
      'scheduledTime': '14:00',
      'deliveredDate': '2024-01-20',
      'deliveredTime': '14:15',
      'driverName': 'Mike Johnson',
      'driverPhone': '+1-555-0201',
      'notes': 'Left at front door',
      'trackingNumber': 'TRK001234567',
      'createdAt': '2024-01-20T10:00:00Z',
    },
    {
      'id': 'DEL002',
      'orderId': 'ORD-20240120-002',
      'customerName': 'Sarah Wilson',
      'customerPhone': '+1-555-0102',
      'customerAddress': '456 Oak Ave, Los Angeles, CA 90210',
      'deliveryAddress': '456 Oak Ave, Los Angeles, CA 90210',
      'status': 'in_transit',
      'deliveryType': 'express',
      'orderItems': [
        {'name': 'Amoxicillin 500mg', 'quantity': 1, 'price': 35.99},
        {'name': 'Ibuprofen 400mg', 'quantity': 3, 'price': 12.99},
      ],
      'totalAmount': 74.96,
      'deliveryFee': 9.99,
      'scheduledDate': '2024-01-20',
      'scheduledTime': '16:00',
      'deliveredDate': null,
      'deliveredTime': null,
      'driverName': 'Emily Davis',
      'driverPhone': '+1-555-0202',
      'notes': 'Customer requested express delivery',
      'trackingNumber': 'TRK001234568',
      'createdAt': '2024-01-20T11:30:00Z',
    },
    {
      'id': 'DEL003',
      'orderId': 'ORD-20240120-003',
      'customerName': 'Robert Brown',
      'customerPhone': '+1-555-0103',
      'customerAddress': '789 Pine St, Chicago, IL 60601',
      'deliveryAddress': '789 Pine St, Chicago, IL 60601',
      'status': 'confirmed',
      'deliveryType': 'standard',
      'orderItems': [
        {'name': 'Metformin 500mg', 'quantity': 2, 'price': 28.50},
        {'name': 'Vitamin B12', 'quantity': 1, 'price': 18.99},
      ],
      'totalAmount': 75.99,
      'deliveryFee': 5.99,
      'scheduledDate': '2024-01-21',
      'scheduledTime': '10:00',
      'deliveredDate': null,
      'deliveredTime': null,
      'driverName': 'David Lee',
      'driverPhone': '+1-555-0203',
      'notes': 'Customer will be home all day',
      'trackingNumber': 'TRK001234569',
      'createdAt': '2024-01-20T13:15:00Z',
    },
    {
      'id': 'DEL004',
      'orderId': 'ORD-20240119-001',
      'customerName': 'Maria Garcia',
      'customerPhone': '+1-555-0104',
      'customerAddress': '321 Elm St, Miami, FL 33101',
      'deliveryAddress': '321 Elm St, Miami, FL 33101',
      'status': 'pending',
      'deliveryType': 'same_day',
      'orderItems': [
        {'name': 'Aspirin 100mg', 'quantity': 1, 'price': 8.99},
        {'name': 'Vitamin C', 'quantity': 2, 'price': 22.50},
      ],
      'totalAmount': 54.48,
      'deliveryFee': 15.99,
      'scheduledDate': '2024-01-20',
      'scheduledTime': '18:00',
      'deliveredDate': null,
      'deliveredTime': null,
      'driverName': 'James Wilson',
      'driverPhone': '+1-555-0204',
      'notes': 'Same day delivery requested',
      'trackingNumber': 'TRK001234570',
      'createdAt': '2024-01-19T16:45:00Z',
    },
    {
      'id': 'DEL005',
      'orderId': 'ORD-20240118-001',
      'customerName': 'Lisa Anderson',
      'customerPhone': '+1-555-0105',
      'customerAddress': '654 Maple Dr, Seattle, WA 98101',
      'deliveryAddress': '654 Maple Dr, Seattle, WA 98101',
      'status': 'cancelled',
      'deliveryType': 'standard',
      'orderItems': [
        {'name': 'Ciprofloxacin 500mg', 'quantity': 1, 'price': 45.99},
      ],
      'totalAmount': 51.98,
      'deliveryFee': 5.99,
      'scheduledDate': '2024-01-19',
      'scheduledTime': '12:00',
      'deliveredDate': null,
      'deliveredTime': null,
      'driverName': 'Mike Johnson',
      'driverPhone': '+1-555-0201',
      'notes': 'Customer cancelled due to change of address',
      'trackingNumber': 'TRK001234571',
      'createdAt': '2024-01-18T14:20:00Z',
    },
    {
      'id': 'DEL006',
      'orderId': 'ORD-20240117-001',
      'customerName': 'Michael Chen',
      'customerPhone': '+1-555-0106',
      'customerAddress': '987 Cedar Ln, Boston, MA 02101',
      'deliveryAddress': '987 Cedar Ln, Boston, MA 02101',
      'status': 'delivered',
      'deliveryType': 'express',
      'orderItems': [
        {'name': 'Lisinopril 10mg', 'quantity': 1, 'price': 32.99},
        {'name': 'Atorvastatin 20mg', 'quantity': 1, 'price': 38.50},
      ],
      'totalAmount': 81.48,
      'deliveryFee': 9.99,
      'scheduledDate': '2024-01-17',
      'scheduledTime': '15:00',
      'deliveredDate': '2024-01-17',
      'deliveredTime': '15:30',
      'driverName': 'Emily Davis',
      'driverPhone': '+1-555-0202',
      'notes': 'Delivered to customer directly',
      'trackingNumber': 'TRK001234572',
      'createdAt': '2024-01-17T09:30:00Z',
    },
  ];

  // Mock get deliveries
  Future<List<Map<String, dynamic>>> getDeliveries() async {
    await _simulateDelay();
    return mockDeliveries;
  }

  // Mock add delivery
  Future<Map<String, dynamic>> addDelivery(
      Map<String, dynamic> deliveryData) async {
    await _simulateDelay();

    final newDelivery = {
      'id': 'DEL${DateTime.now().millisecondsSinceEpoch}',
      'orderId':
          'ORD-${DateTime.now().toIso8601String().split('T')[0]}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      'customerName': deliveryData['customerName'],
      'customerPhone': deliveryData['customerPhone'],
      'customerAddress': deliveryData['customerAddress'],
      'deliveryAddress': deliveryData['deliveryAddress'],
      'status': 'pending',
      'deliveryType': deliveryData['deliveryType'] ?? 'standard',
      'orderItems': deliveryData['orderItems'] ?? [],
      'totalAmount': deliveryData['totalAmount'] ?? 0.0,
      'deliveryFee': deliveryData['deliveryFee'] ?? 5.99,
      'scheduledDate': deliveryData['scheduledDate'],
      'scheduledTime': deliveryData['scheduledTime'],
      'deliveredDate': null,
      'deliveredTime': null,
      'driverName': deliveryData['driverName'],
      'driverPhone': deliveryData['driverPhone'],
      'notes': deliveryData['notes'] ?? '',
      'trackingNumber': 'TRK${DateTime.now().millisecondsSinceEpoch}',
      'createdAt': DateTime.now().toIso8601String(),
    };

    mockDeliveries.add(newDelivery);

    return {
      'success': true,
      'message': 'Delivery added successfully',
      'data': newDelivery,
    };
  }

  // Mock update delivery status
  Future<Map<String, dynamic>> updateDeliveryStatus(
      String deliveryId, String status) async {
    await _simulateDelay();

    final deliveryIndex =
        mockDeliveries.indexWhere((delivery) => delivery['id'] == deliveryId);
    if (deliveryIndex == -1) {
      throw Exception('Delivery not found');
    }

    mockDeliveries[deliveryIndex]['status'] = status;

    if (status == 'delivered') {
      final now = DateTime.now();
      mockDeliveries[deliveryIndex]['deliveredDate'] =
          now.toIso8601String().split('T')[0];
      mockDeliveries[deliveryIndex]['deliveredTime'] =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    }

    return {
      'success': true,
      'message': 'Delivery status updated successfully',
      'data': mockDeliveries[deliveryIndex],
    };
  }

  // Mock export data
  Future<Map<String, dynamic>> exportData(
      String type, Map<String, dynamic> params) async {
    await _simulateDelay();

    // Simulate export process
    final fileName = 'report_${DateTime.now().millisecondsSinceEpoch}.$type';

    return {
      'success': true,
      'message': 'Data exported successfully',
      'fileName': fileName,
      'downloadUrl': 'https://example.com/downloads/$fileName',
    };
  }

  // Mock update user role
  Future<Map<String, dynamic>> updateUserRole(
      String userId, String newRole) async {
    await _simulateDelay();

    final userIndex = mockUsers.indexWhere((user) => user['id'] == userId);
    if (userIndex == -1) {
      throw Exception('User not found');
    }

    mockUsers[userIndex]['role'] = newRole;
    mockUsers[userIndex]['permissions'] = _getDefaultPermissions(newRole);

    return {
      'success': true,
      'message': 'User role updated successfully',
      'data': mockUsers[userIndex],
    };
  }

  // Mock market invoices data
  final List<Map<String, dynamic>> mockMarketInvoices = [
    {
      'type': 'invoice',
      'id': 'inv1',
      'pharmacyName': 'صيدلية النور',
      'pharmacyAddress': 'شارع التحرير، القاهرة',
      'pharmacyPhone': '+201234567890',
      'invoiceNumber': 'INV-2024-001',
      'transactionNumber': 'TXN-20240120-001',
      'invoiceType': 'complete', // complete or partial
      'date': '2024-01-20',
      'totalAmount': 245.75,
      'discount': 10,
      'finalAmount': 221.18,
      'medicines': [
        {
          'id': 'm1',
          'name': 'Paracetamol 500mg',
          'genericName': 'Acetaminophen',
          'activeIngredient': 'Acetaminophen 500mg',
          'form': 'Tablet',
          'packSize': '20 tablets',
          'quantity': 2,
          'price': 25.50,
          'totalPrice': 51.00,
          'manufacturer': 'PharmaCorp',
          'category': 'Pain Relief',
          'expiryDate': '2025-06-15',
          'isOTC': true,
        },
        {
          'id': 'm3',
          'name': 'Vitamin C 1000mg',
          'genericName': 'Ascorbic Acid',
          'activeIngredient': 'Ascorbic Acid 1000mg',
          'form': 'Tablet',
          'packSize': '30 tablets',
          'quantity': 1,
          'price': 35.75,
          'totalPrice': 35.75,
          'manufacturer': 'VitaHealth',
          'category': 'Vitamins',
          'expiryDate': '2026-03-10',
          'isOTC': true,
        },
        {
          'id': 'm6',
          'name': 'Metformin 500mg',
          'genericName': 'Metformin',
          'activeIngredient': 'Metformin HCl 500mg',
          'form': 'Tablet',
          'packSize': '60 tablets',
          'quantity': 3,
          'price': 55.00,
          'totalPrice': 165.00,
          'manufacturer': 'DiabCare',
          'category': 'Diabetes',
          'expiryDate': '2025-04-30',
          'isOTC': false,
        },
      ],
    },
    {
      'type': 'invoice',
      'id': 'inv2',
      'pharmacyName': 'صيدلية الشفاء',
      'pharmacyAddress': 'شارع النيل، الجيزة',
      'pharmacyPhone': '+201987654321',
      'invoiceNumber': 'INV-2024-002',
      'transactionNumber': 'TXN-20240119-002',
      'invoiceType': 'partial', // complete or partial
      'date': '2024-01-19',
      'totalAmount': 180.25,
      'discount': 5,
      'finalAmount': 171.24,
      'medicines': [
        {
          'id': 'm4',
          'name': 'Ibuprofen 400mg',
          'genericName': 'Ibuprofen',
          'activeIngredient': 'Ibuprofen 400mg',
          'form': 'Tablet',
          'packSize': '30 tablets',
          'quantity': 2,
          'price': 28.90,
          'totalPrice': 57.80,
          'manufacturer': 'PainFree Pharma',
          'category': 'Pain Relief',
          'expiryDate': '2025-08-22',
          'isOTC': true,
        },
        {
          'id': 'm7',
          'name': 'Omeprazole 20mg',
          'genericName': 'Omeprazole',
          'activeIngredient': 'Omeprazole 20mg',
          'form': 'Capsule',
          'packSize': '28 capsules',
          'quantity': 1,
          'price': 42.30,
          'totalPrice': 42.30,
          'manufacturer': 'GastroMed',
          'category': 'Gastrointestinal',
          'expiryDate': '2025-09-12',
          'isOTC': true,
        },
        {
          'id': 'm5',
          'name': 'Loratadine 10mg',
          'genericName': 'Loratadine',
          'activeIngredient': 'Loratadine 10mg',
          'form': 'Tablet',
          'packSize': '10 tablets',
          'quantity': 2,
          'price': 18.50,
          'totalPrice': 37.00,
          'manufacturer': 'AllergyCare',
          'category': 'Allergy',
          'expiryDate': '2025-11-15',
          'isOTC': true,
        },
      ],
    },
    {
      'type': 'invoice',
      'id': 'inv3',
      'pharmacyName': 'صيدلية الأمل',
      'pharmacyAddress': 'شارع الهرم، الجيزة',
      'pharmacyPhone': '+201555123456',
      'invoiceNumber': 'INV-2024-003',
      'transactionNumber': 'TXN-20240118-003',
      'invoiceType': 'complete', // complete or partial
      'date': '2024-01-18',
      'totalAmount': 320.50,
      'discount': 15,
      'finalAmount': 272.43,
      'medicines': [
        {
          'id': 'm8',
          'name': 'Atorvastatin 20mg',
          'genericName': 'Atorvastatin',
          'activeIngredient': 'Atorvastatin Calcium 20mg',
          'form': 'Tablet',
          'packSize': '30 tablets',
          'quantity': 2,
          'price': 65.00,
          'totalPrice': 130.00,
          'manufacturer': 'HeartCare',
          'category': 'Heart',
          'expiryDate': '2025-07-08',
          'isOTC': false,
        },
        {
          'id': 'm9',
          'name': 'Cough Syrup',
          'genericName': 'Dextromethorphan',
          'activeIngredient': 'Dextromethorphan HBr 15mg/5ml',
          'form': 'Syrup',
          'packSize': '100ml',
          'quantity': 1,
          'price': 22.75,
          'totalPrice': 22.75,
          'manufacturer': 'ColdRelief',
          'category': 'Cold & Flu',
          'expiryDate': '2025-01-20',
          'isOTC': true,
        },
        {
          'id': 'm10',
          'name': 'Multivitamin Complex',
          'genericName': 'Multivitamin',
          'activeIngredient': 'Multiple Vitamins & Minerals',
          'form': 'Tablet',
          'packSize': '60 tablets',
          'quantity': 2,
          'price': 48.90,
          'totalPrice': 97.80,
          'manufacturer': 'VitaMax',
          'category': 'Vitamins',
          'expiryDate': '2026-02-14',
          'isOTC': true,
        },
        {
          'id': 'm11',
          'name': 'Aspirin 100mg',
          'genericName': 'Acetylsalicylic Acid',
          'activeIngredient': 'Acetylsalicylic Acid 100mg',
          'form': 'Tablet',
          'packSize': '100 tablets',
          'quantity': 1,
          'price': 15.25,
          'totalPrice': 15.25,
          'manufacturer': 'CardioMed',
          'category': 'Heart',
          'expiryDate': '2025-12-05',
          'isOTC': true,
        },
      ],
    },
    {
      'type': 'invoice',
      'id': 'inv3',
      'pharmacyName': 'صيدلية الشفاء',
      'pharmacyAddress': 'شارع النيل، الإسكندرية',
      'pharmacyPhone': '+201234567891',
      'invoiceNumber': 'INV-2024-003',
      'transactionNumber': 'TXN-20240122-003',
      'invoiceType': 'partial',
      'date': '2024-01-22',
      'totalAmount': 1250.50,
      'discount': 15,
      'finalAmount': 1062.93,
      'medicines': [
        {
          'id': 'm12',
          'name': 'Paracetamol 500mg',
          'genericName': 'Acetaminophen',
          'activeIngredient': 'Acetaminophen 500mg',
          'form': 'Tablet',
          'packSize': '20 tablets',
          'quantity': 2,
          'price': 25.50,
          'totalPrice': 51.00,
          'manufacturer': 'PharmaCorp',
          'category': 'Pain Relief',
          'expiryDate': '2025-06-15',
          'isOTC': true,
        },
        {
          'id': 'm13',
          'name': 'Amoxicillin 250mg',
          'genericName': 'Amoxicillin',
          'activeIngredient': 'Amoxicillin Trihydrate 250mg',
          'form': 'Capsule',
          'packSize': '21 capsules',
          'quantity': 1,
          'price': 45.00,
          'totalPrice': 45.00,
          'manufacturer': 'MediLife',
          'category': 'Antibiotics',
          'expiryDate': '2024-12-20',
          'isOTC': false,
        },
        {
          'id': 'm14',
          'name': 'Vitamin C 1000mg',
          'genericName': 'Ascorbic Acid',
          'activeIngredient': 'Ascorbic Acid 1000mg',
          'form': 'Tablet',
          'packSize': '30 tablets',
          'quantity': 1,
          'price': 35.75,
          'totalPrice': 35.75,
          'manufacturer': 'VitaHealth',
          'category': 'Vitamins',
          'expiryDate': '2026-03-10',
          'isOTC': true,
        },
        {
          'id': 'm15',
          'name': 'Insulin Pen',
          'genericName': 'Human Insulin',
          'activeIngredient': 'Human Insulin 100 IU/ml',
          'form': 'Injection',
          'packSize': '1 pen',
          'quantity': 1,
          'price': 120.00,
          'totalPrice': 120.00,
          'manufacturer': 'DiabCare',
          'category': 'Diabetes',
          'expiryDate': '2024-11-30',
          'isOTC': false,
        },
        {
          'id': 'm16',
          'name': 'Aspirin 100mg',
          'genericName': 'Acetylsalicylic Acid',
          'activeIngredient': 'Acetylsalicylic Acid 100mg',
          'form': 'Tablet',
          'packSize': '100 tablets',
          'quantity': 1,
          'price': 15.25,
          'totalPrice': 15.25,
          'manufacturer': 'CardioMed',
          'category': 'Heart',
          'expiryDate': '2025-12-05',
          'isOTC': true,
        },
        {
          'id': 'm17',
          'name': 'Metformin 500mg',
          'genericName': 'Metformin',
          'activeIngredient': 'Metformin HCl 500mg',
          'form': 'Tablet',
          'packSize': '60 tablets',
          'quantity': 2,
          'price': 55.00,
          'totalPrice': 110.00,
          'manufacturer': 'DiabCare',
          'category': 'Diabetes',
          'expiryDate': '2025-04-30',
          'isOTC': false,
        },
        {
          'id': 'm18',
          'name': 'Omeprazole 20mg',
          'genericName': 'Omeprazole',
          'activeIngredient': 'Omeprazole 20mg',
          'form': 'Capsule',
          'packSize': '14 capsules',
          'quantity': 1,
          'price': 85.50,
          'totalPrice': 85.50,
          'manufacturer': 'GastroMed',
          'category': 'Gastrointestinal',
          'expiryDate': '2025-08-15',
          'isOTC': false,
        },
        {
          'id': 'm19',
          'name': 'Cetirizine 10mg',
          'genericName': 'Cetirizine',
          'activeIngredient': 'Cetirizine HCl 10mg',
          'form': 'Tablet',
          'packSize': '30 tablets',
          'quantity': 1,
          'price': 28.75,
          'totalPrice': 28.75,
          'manufacturer': 'AllergyCare',
          'category': 'Allergy',
          'expiryDate': '2025-10-20',
          'isOTC': true,
        },
        {
          'id': 'm20',
          'name': 'Calcium Carbonate 500mg',
          'genericName': 'Calcium Carbonate',
          'activeIngredient': 'Calcium Carbonate 500mg',
          'form': 'Tablet',
          'packSize': '60 tablets',
          'quantity': 1,
          'price': 42.00,
          'totalPrice': 42.00,
          'manufacturer': 'BoneHealth',
          'category': 'Vitamins',
          'expiryDate': '2026-01-10',
          'isOTC': true,
        },
        {
          'id': 'm21',
          'name': 'Lisinopril 10mg',
          'genericName': 'Lisinopril',
          'activeIngredient': 'Lisinopril 10mg',
          'form': 'Tablet',
          'packSize': '30 tablets',
          'quantity': 1,
          'price': 65.25,
          'totalPrice': 65.25,
          'manufacturer': 'CardioMed',
          'category': 'Heart',
          'expiryDate': '2025-09-30',
          'isOTC': false,
        },
        {
          'id': 'm22',
          'name': 'Ibuprofen 400mg',
          'genericName': 'Ibuprofen',
          'activeIngredient': 'Ibuprofen 400mg',
          'form': 'Tablet',
          'packSize': '20 tablets',
          'quantity': 2,
          'price': 38.50,
          'totalPrice': 77.00,
          'manufacturer': 'PainRelief',
          'category': 'Pain Relief',
          'expiryDate': '2025-07-25',
          'isOTC': true,
        },
        {
          'id': 'm23',
          'name': 'Simvastatin 20mg',
          'genericName': 'Simvastatin',
          'activeIngredient': 'Simvastatin 20mg',
          'form': 'Tablet',
          'packSize': '30 tablets',
          'quantity': 1,
          'price': 95.00,
          'totalPrice': 95.00,
          'manufacturer': 'CholMed',
          'category': 'Heart',
          'expiryDate': '2025-11-15',
          'isOTC': false,
        },
      ],
    },
  ];

  // Mock market medicines data
  final List<Map<String, dynamic>> mockMarketMedicines = [
    {
      'type': 'medicine',
      'id': 'm1',
      'name': 'Paracetamol 500mg',
      'genericName': 'Acetaminophen',
      'form': 'Tablet',
      'packSize': '20 tablets',
      'stock': 150,
      'price': 25.50,
      'originalPrice': 30.00,
      'expiryDate': '2025-06-15',
      'manufacturer': 'PharmaCorp',
      'category': 'Pain Relief',
      'description':
          'Effective pain relief and fever reducer for headaches, muscle aches, and fever. Safe for adults and children over 12 years.',
      'imageUrl':
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400&h=400&fit=crop&crop=center',
      'rating': 4.5,
      'reviews': 128,
      'isOTC': true,
      'discount': 15,
      'batchNumber': 'PC2024001',
      'ingredients': 'Acetaminophen 500mg',
      'dosage': '1-2 tablets every 4-6 hours as needed',
      'sideEffects': 'Rare: allergic reactions, liver damage with overdose',
      'warnings':
          'Do not exceed 4g per day. Consult doctor if pregnant or breastfeeding.',
    },
    {
      'type': 'medicine',
      'id': 'm2',
      'name': 'Amoxicillin 250mg',
      'genericName': 'Amoxicillin',
      'form': 'Capsule',
      'packSize': '21 capsules',
      'stock': 8,
      'price': 45.00,
      'originalPrice': 45.00,
      'expiryDate': '2024-12-20',
      'manufacturer': 'MediLife',
      'category': 'Antibiotics',
      'description':
          'Broad-spectrum antibiotic for bacterial infections including respiratory, urinary, and skin infections. Prescription required.',
      'imageUrl':
          'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=400&fit=crop&crop=center',
      'rating': 4.2,
      'reviews': 89,
      'isOTC': false,
      'discount': 0,
      'batchNumber': 'ML2024002',
      'ingredients': 'Amoxicillin 250mg',
      'dosage': '1 capsule every 8 hours for 7-10 days',
      'sideEffects': 'Nausea, diarrhea, skin rash, allergic reactions',
      'warnings':
          'Prescription required. Complete full course even if feeling better.',
    },
    {
      'type': 'medicine',
      'id': 'm3',
      'name': 'Vitamin C 1000mg',
      'genericName': 'Ascorbic Acid',
      'form': 'Tablet',
      'packSize': '30 tablets',
      'stock': 200,
      'price': 35.75,
      'originalPrice': 40.00,
      'expiryDate': '2026-03-10',
      'manufacturer': 'VitaHealth',
      'category': 'Vitamins',
      'description':
          'High potency vitamin C for immune support, collagen synthesis, and antioxidant protection. Natural citrus flavor.',
      'imageUrl':
          'https://images.unsplash.com/photo-1550572017-edd951aa0b0a?w=400&h=400&fit=crop&crop=center',
      'rating': 4.7,
      'reviews': 256,
      'isOTC': true,
      'discount': 10,
      'batchNumber': 'VH2024003',
      'ingredients': 'Ascorbic Acid 1000mg, Natural Citrus Flavor',
      'dosage': '1 tablet daily with food',
      'sideEffects': 'Mild stomach upset, diarrhea with high doses',
      'warnings': 'Consult doctor if pregnant or have kidney stones.',
    },
    {
      'type': 'medicine',
      'id': 'm4',
      'name': 'Ibuprofen 400mg',
      'genericName': 'Ibuprofen',
      'form': 'Tablet',
      'packSize': '30 tablets',
      'stock': 75,
      'price': 28.90,
      'originalPrice': 32.00,
      'expiryDate': '2025-08-22',
      'manufacturer': 'PainFree Pharma',
      'category': 'Pain Relief',
      'description':
          'Anti-inflammatory pain reliever for arthritis, muscle pain, headaches, and fever. Fast-acting formula.',
      'imageUrl':
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400&h=400&fit=crop&crop=center',
      'rating': 4.3,
      'reviews': 167,
      'isOTC': true,
      'discount': 9,
      'batchNumber': 'PF2024004',
      'ingredients': 'Ibuprofen 400mg',
      'dosage': '1 tablet every 4-6 hours as needed',
      'sideEffects': 'Stomach upset, dizziness, headache',
      'warnings': 'Take with food. Do not use if allergic to aspirin.',
    },
    {
      'type': 'medicine',
      'id': 'm5',
      'name': 'Loratadine 10mg',
      'genericName': 'Loratadine',
      'form': 'Tablet',
      'packSize': '10 tablets',
      'stock': 120,
      'price': 18.50,
      'originalPrice': 20.00,
      'expiryDate': '2025-11-15',
      'manufacturer': 'AllergyCare',
      'category': 'Allergy',
      'description':
          'Non-drowsy antihistamine for seasonal allergies, hay fever, and hives. 24-hour relief.',
      'imageUrl':
          'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=400&fit=crop&crop=center',
      'rating': 4.4,
      'reviews': 94,
      'isOTC': true,
      'discount': 7,
      'batchNumber': 'AC2024005',
      'ingredients': 'Loratadine 10mg',
      'dosage': '1 tablet daily',
      'sideEffects': 'Dry mouth, headache, fatigue',
      'warnings': 'May cause drowsiness in some people. Avoid alcohol.',
    },
    {
      'type': 'medicine',
      'id': 'm6',
      'name': 'Metformin 500mg',
      'genericName': 'Metformin',
      'form': 'Tablet',
      'packSize': '60 tablets',
      'stock': 45,
      'price': 55.00,
      'originalPrice': 60.00,
      'expiryDate': '2025-04-30',
      'manufacturer': 'DiabCare',
      'category': 'Diabetes',
      'description':
          'First-line treatment for type 2 diabetes. Helps control blood sugar levels and improves insulin sensitivity.',
      'imageUrl':
          'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=400&fit=crop&crop=center',
      'rating': 4.1,
      'reviews': 73,
      'isOTC': false,
      'discount': 8,
      'batchNumber': 'DC2024006',
      'ingredients': 'Metformin HCl 500mg',
      'dosage': '1 tablet twice daily with meals',
      'sideEffects': 'Nausea, diarrhea, metallic taste',
      'warnings': 'Prescription required. Monitor blood sugar regularly.',
    },
    {
      'type': 'medicine',
      'id': 'm7',
      'name': 'Omeprazole 20mg',
      'genericName': 'Omeprazole',
      'form': 'Capsule',
      'packSize': '28 capsules',
      'stock': 90,
      'price': 42.30,
      'originalPrice': 47.00,
      'expiryDate': '2025-09-12',
      'manufacturer': 'GastroMed',
      'category': 'Gastrointestinal',
      'description':
          'Proton pump inhibitor for acid reflux, heartburn, and stomach ulcers. 24-hour protection.',
      'imageUrl':
          'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=400&fit=crop&crop=center',
      'rating': 4.6,
      'reviews': 142,
      'isOTC': true,
      'discount': 10,
      'batchNumber': 'GM2024007',
      'ingredients': 'Omeprazole 20mg',
      'dosage': '1 capsule daily before breakfast',
      'sideEffects': 'Headache, nausea, diarrhea',
      'warnings': 'Take on empty stomach. Do not crush or chew.',
    },
    {
      'type': 'medicine',
      'id': 'm8',
      'name': 'Atorvastatin 20mg',
      'genericName': 'Atorvastatin',
      'form': 'Tablet',
      'packSize': '30 tablets',
      'stock': 60,
      'price': 65.00,
      'originalPrice': 70.00,
      'expiryDate': '2025-07-08',
      'manufacturer': 'HeartCare',
      'category': 'Heart',
      'description':
          'Statin medication for cholesterol management and cardiovascular protection. Reduces risk of heart attack.',
      'imageUrl':
          'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=400&fit=crop&crop=center',
      'rating': 4.0,
      'reviews': 58,
      'isOTC': false,
      'discount': 7,
      'batchNumber': 'HC2024008',
      'ingredients': 'Atorvastatin Calcium 20mg',
      'dosage': '1 tablet daily with or without food',
      'sideEffects': 'Muscle pain, liver problems, digestive issues',
      'warnings': 'Prescription required. Regular liver function tests needed.',
    },
    {
      'type': 'medicine',
      'id': 'm9',
      'name': 'Cough Syrup',
      'genericName': 'Dextromethorphan',
      'form': 'Syrup',
      'packSize': '100ml',
      'stock': 35,
      'price': 22.75,
      'originalPrice': 25.00,
      'expiryDate': '2025-01-20',
      'manufacturer': 'ColdRelief',
      'category': 'Cold & Flu',
      'description':
          'Effective cough suppressant syrup for dry coughs. Cherry flavor, alcohol-free formula.',
      'imageUrl':
          'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=400&fit=crop&crop=center',
      'rating': 4.2,
      'reviews': 81,
      'isOTC': true,
      'discount': 9,
      'batchNumber': 'CR2024009',
      'ingredients': 'Dextromethorphan HBr 15mg/5ml',
      'dosage': '10ml every 4-6 hours as needed',
      'sideEffects': 'Drowsiness, dizziness, nausea',
      'warnings': 'May cause drowsiness. Do not drive or operate machinery.',
    },
    {
      'type': 'medicine',
      'id': 'm10',
      'name': 'Multivitamin Complex',
      'genericName': 'Multivitamin',
      'form': 'Tablet',
      'packSize': '60 tablets',
      'stock': 180,
      'price': 48.90,
      'originalPrice': 55.00,
      'expiryDate': '2026-02-14',
      'manufacturer': 'VitaMax',
      'category': 'Vitamins',
      'description':
          'Complete daily multivitamin supplement with 23 essential vitamins and minerals for overall health.',
      'imageUrl':
          'https://images.unsplash.com/photo-1550572017-edd951aa0b0a?w=400&h=400&fit=crop&crop=center',
      'rating': 4.5,
      'reviews': 203,
      'isOTC': true,
      'discount': 11,
      'batchNumber': 'VM2024010',
      'ingredients': '23 Essential Vitamins & Minerals',
      'dosage': '1 tablet daily with food',
      'sideEffects': 'Mild stomach upset, constipation',
      'warnings':
          'Keep out of reach of children. Do not exceed recommended dose.',
    },
    {
      'type': 'medicine',
      'id': 'm11',
      'name': 'Aspirin 100mg',
      'genericName': 'Acetylsalicylic Acid',
      'form': 'Tablet',
      'packSize': '100 tablets',
      'stock': 95,
      'price': 15.25,
      'originalPrice': 17.00,
      'expiryDate': '2025-12-05',
      'manufacturer': 'CardioMed',
      'category': 'Heart',
      'description':
          'Low-dose aspirin for cardiovascular protection and blood thinning. Enteric-coated for stomach protection.',
      'imageUrl':
          'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=400&fit=crop&crop=center',
      'rating': 4.3,
      'reviews': 156,
      'isOTC': true,
      'discount': 10,
      'batchNumber': 'CM2024011',
      'ingredients': 'Acetylsalicylic Acid 100mg',
      'dosage': '1 tablet daily as directed by doctor',
      'sideEffects': 'Stomach irritation, bleeding risk',
      'warnings': 'Consult doctor before use. May increase bleeding risk.',
    },
    {
      'type': 'medicine',
      'id': 'm12',
      'name': 'Ciprofloxacin 500mg',
      'genericName': 'Ciprofloxacin',
      'form': 'Tablet',
      'packSize': '10 tablets',
      'stock': 25,
      'price': 38.50,
      'originalPrice': 42.00,
      'expiryDate': '2024-10-18',
      'manufacturer': 'AntibioCorp',
      'category': 'Antibiotics',
      'description':
          'Broad-spectrum fluoroquinolone antibiotic for serious bacterial infections. Prescription required.',
      'imageUrl':
          'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=400&fit=crop&crop=center',
      'rating': 4.1,
      'reviews': 67,
      'isOTC': false,
      'discount': 8,
      'batchNumber': 'AC2024012',
      'ingredients': 'Ciprofloxacin HCl 500mg',
      'dosage': '1 tablet twice daily for 7-14 days',
      'sideEffects': 'Nausea, diarrhea, tendon problems',
      'warnings':
          'Prescription required. Avoid sun exposure. May cause tendon rupture.',
    },
  ];

  // Mock cart items
  List<Map<String, dynamic>> mockCartItems = [
    {
      'id': 'cart_1',
      'medicineId': 'm1',
      'name': 'Paracetamol 500mg',
      'genericName': 'Acetaminophen',
      'form': 'Tablet',
      'manufacturer': 'PharmaCorp',
      'packSize': '20 tablets',
      'price': 25.50,
      'originalPrice': 30.00,
      'quantity': 2,
      'expiryDate': '2025-06-15',
      'batchNumber': 'PC2024001',
      'isOTC': true,
      'discount': 15,
      'imageUrl':
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400&h=400&fit=crop&crop=center',
    },
    {
      'id': 'cart_2',
      'medicineId': 'm3',
      'name': 'Vitamin C 1000mg',
      'genericName': 'Ascorbic Acid',
      'form': 'Tablet',
      'manufacturer': 'VitaHealth',
      'packSize': '30 tablets',
      'price': 35.75,
      'originalPrice': 40.00,
      'quantity': 1,
      'expiryDate': '2026-03-10',
      'batchNumber': 'VH2024003',
      'isOTC': true,
      'discount': 10,
      'imageUrl':
          'https://images.unsplash.com/photo-1550572017-edd951aa0b0a?w=400&h=400&fit=crop&crop=center',
    },
  ];

  // Get market medicines
  Future<List<Map<String, dynamic>>> getMarketMedicines(
      {String? search}) async {
    await _simulateDelay();

    List<Map<String, dynamic>> medicines = List.from(mockMarketMedicines);

    if (search != null && search.isNotEmpty) {
      medicines = medicines
          .where((medicine) =>
              medicine['name'].toLowerCase().contains(search.toLowerCase()) ||
              medicine['description']
                  .toLowerCase()
                  .contains(search.toLowerCase()) ||
              medicine['manufacturer']
                  .toLowerCase()
                  .contains(search.toLowerCase()))
          .toList();
    }

    return medicines;
  }

  // Get market invoices
  Future<List<Map<String, dynamic>>> getMarketInvoices({String? search}) async {
    await _simulateDelay();

    List<Map<String, dynamic>> invoices = List.from(mockMarketInvoices);

    if (search != null && search.isNotEmpty) {
      invoices = invoices
          .where((invoice) =>
              invoice['pharmacyName']
                  .toLowerCase()
                  .contains(search.toLowerCase()) ||
              invoice['invoiceNumber']
                  .toLowerCase()
                  .contains(search.toLowerCase()) ||
              invoice['medicines'].any((medicine) =>
                  medicine['name']
                      .toLowerCase()
                      .contains(search.toLowerCase()) ||
                  medicine['manufacturer']
                      .toLowerCase()
                      .contains(search.toLowerCase())))
          .toList();
    }

    return invoices;
  }

  // Get all market products (medicines + invoices)
  Future<List<Map<String, dynamic>>> getAllMarketProducts(
      {String? search}) async {
    await _simulateDelay();

    List<Map<String, dynamic>> allProducts = [];

    // Add medicines
    allProducts.addAll(mockMarketMedicines);

    // Add invoices
    allProducts.addAll(mockMarketInvoices);

    if (search != null && search.isNotEmpty) {
      allProducts = allProducts.where((product) {
        if (product['type'] == 'medicine') {
          return product['name'].toLowerCase().contains(search.toLowerCase()) ||
              product['description']
                  .toLowerCase()
                  .contains(search.toLowerCase()) ||
              product['manufacturer']
                  .toLowerCase()
                  .contains(search.toLowerCase());
        } else if (product['type'] == 'invoice') {
          return product['pharmacyName']
                  .toLowerCase()
                  .contains(search.toLowerCase()) ||
              product['invoiceNumber']
                  .toLowerCase()
                  .contains(search.toLowerCase()) ||
              product['medicines'].any((medicine) =>
                  medicine['name']
                      .toLowerCase()
                      .contains(search.toLowerCase()) ||
                  medicine['manufacturer']
                      .toLowerCase()
                      .contains(search.toLowerCase()));
        }
        return false;
      }).toList();
    }

    return allProducts;
  }

  // Add to cart
  Future<Map<String, dynamic>> addToCart(Map<String, dynamic> cartItem) async {
    await _simulateDelay();

    // Check if item already exists in cart
    final existingIndex = mockCartItems
        .indexWhere((item) => item['medicineId'] == cartItem['medicineId']);

    if (existingIndex != -1) {
      // Update quantity
      mockCartItems[existingIndex]['quantity'] += cartItem['quantity'];
    } else {
      // Add new item
      mockCartItems.add(cartItem);
    }

    return {
      'success': true,
      'message': 'Item added to cart successfully',
      'data': cartItem,
    };
  }

  // Add invoice to cart
  Future<Map<String, dynamic>> addInvoiceToCart(
      Map<String, dynamic> invoice) async {
    await _simulateDelay();

    // Add invoice to cart
    mockCartItems.add(invoice);

    return {
      'success': true,
      'message': 'Invoice added to cart successfully',
      'data': invoice,
    };
  }

  // Get cart items
  Future<List<Map<String, dynamic>>> getCartItems() async {
    await _simulateDelay();
    return List.from(mockCartItems);
  }

  // Remove from cart
  Future<Map<String, dynamic>> removeFromCart(String itemId) async {
    await _simulateDelay();

    mockCartItems.removeWhere((item) => item['id'] == itemId);

    return {
      'success': true,
      'message': 'Item removed from cart successfully',
    };
  }

  // Update cart item quantity
  Future<Map<String, dynamic>> updateCartItemQuantity(
      String itemId, int quantity) async {
    await _simulateDelay();

    final itemIndex = mockCartItems.indexWhere((item) => item['id'] == itemId);

    if (itemIndex != -1) {
      if (quantity <= 0) {
        mockCartItems.removeAt(itemIndex);
      } else {
        mockCartItems[itemIndex]['quantity'] = quantity;
      }
    }

    return {
      'success': true,
      'message': 'Cart updated successfully',
    };
  }

  // Clear cart
  Future<Map<String, dynamic>> clearCart() async {
    await _simulateDelay();

    mockCartItems.clear();

    return {
      'success': true,
      'message': 'Cart cleared successfully',
    };
  }
}
