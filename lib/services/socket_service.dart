import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _dataUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Getters
  bool get isConnected => _isConnected;
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;
  Stream<Map<String, dynamic>> get dataUpdateStream =>
      _dataUpdateController.stream;

  // Initialize socket connection
  Future<void> initialize() async {
    try {
      print('🔌 Socket: Initializing connection...');

      _socket = IO.io('http://38.242.214.193:5000', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'timeout': 20000,
      });

      _setupEventListeners();

      _socket!.connect();

      print('🔌 Socket: Connection initiated');
    } catch (e) {
      print('❌ Socket: Failed to initialize: $e');
    }
  }

  // Setup event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      print('🔌 Socket: Connected successfully');
      _isConnected = true;
      _joinUserRoom();
    });

    _socket!.onDisconnect((_) {
      print('🔌 Socket: Disconnected');
      _isConnected = false;
    });

    _socket!.onConnectError((error) {
      print('❌ Socket: Connection error: $error');
      _isConnected = false;
    });

    _socket!.onError((error) {
      print('❌ Socket: Error: $error');
    });

    // Notification events
    _socket!.on('notification', (data) {
      print('🔔 Socket: Received notification: $data');
      _notificationController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('low_stock_alert', (data) {
      print('⚠️ Socket: Low stock alert: $data');
      _notificationController.add({
        'type': 'low_stock',
        'title': 'Low Stock Alert',
        'message':
            '${data['medicineName']} is running low on stock (${data['currentStock']} remaining)',
        'medicineId': data['medicineId'],
        'medicineName': data['medicineName'],
        'currentStock': data['currentStock'],
        'priority': 'high',
        'timestamp': DateTime.now().toIso8601String(),
      });
    });

    _socket!.on('sale_completed', (data) {
      print('💰 Socket: Sale completed: $data');
      _notificationController.add({
        'type': 'sale',
        'title': 'Sale Completed',
        'message':
            'Invoice sold successfully! ${data['totalItems']} items for \$${data['totalAmount']}',
        'transactionId': data['transactionId'],
        'totalItems': data['totalItems'],
        'totalAmount': data['totalAmount'],
        'priority': 'medium',
        'timestamp': DateTime.now().toIso8601String(),
      });
    });

    // Data update events
    _socket!.on('inventory_updated', (data) {
      print('📦 Socket: Inventory updated: $data');
      _dataUpdateController.add({
        'type': 'inventory',
        'data': data,
      });
    });

    _socket!.on('sales_updated', (data) {
      print('💰 Socket: Sales updated: $data');
      _dataUpdateController.add({
        'type': 'sales',
        'data': data,
      });
    });

    _socket!.on('dashboard_updated', (data) {
      print('📊 Socket: Dashboard updated: $data');
      _dataUpdateController.add({
        'type': 'dashboard',
        'data': data,
      });
    });

    // Medicine events
    _socket!.on('medicine_added', (data) {
      print('💊 Socket: Medicine added: $data');
      _dataUpdateController.add({
        'type': 'medicine_added',
        'data': data,
      });
    });

    _socket!.on('medicine_updated', (data) {
      print('💊 Socket: Medicine updated: $data');
      _dataUpdateController.add({
        'type': 'medicine_updated',
        'data': data,
      });
    });

    _socket!.on('medicine_deleted', (data) {
      print('💊 Socket: Medicine deleted: $data');
      _dataUpdateController.add({
        'type': 'medicine_deleted',
        'data': data,
      });
    });
  }

  // Join user-specific room
  void _joinUserRoom() {
    if (_socket == null || !_isConnected) return;

    try {
      // Get user ID from storage or use a default
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _socket!.emit('join_user_room', {'userId': userId});
      print('🔌 Socket: Joined user room: $userId');
    } catch (e) {
      print('❌ Socket: Failed to join user room: $e');
    }
  }

  // Send notification
  void sendNotification(Map<String, dynamic> notification) {
    if (_socket == null || !_isConnected) {
      print('❌ Socket: Cannot send notification - not connected');
      return;
    }

    try {
      _socket!.emit('send_notification', notification);
      print('🔔 Socket: Notification sent: $notification');
    } catch (e) {
      print('❌ Socket: Failed to send notification: $e');
    }
  }

  // Send low stock alert
  void sendLowStockAlert(Map<String, dynamic> alertData) {
    if (_socket == null || !_isConnected) return;

    try {
      _socket!.emit('low_stock_alert', alertData);
      print('⚠️ Socket: Low stock alert sent: $alertData');
    } catch (e) {
      print('❌ Socket: Failed to send low stock alert: $e');
    }
  }

  // Send sale completed event
  void sendSaleCompleted(Map<String, dynamic> saleData) {
    if (_socket == null || !_isConnected) return;

    try {
      _socket!.emit('sale_completed', saleData);
      print('💰 Socket: Sale completed event sent: $saleData');
    } catch (e) {
      print('❌ Socket: Failed to send sale completed: $e');
    }
  }

  // Send inventory update
  void sendInventoryUpdate(Map<String, dynamic> inventoryData) {
    if (_socket == null || !_isConnected) return;

    try {
      _socket!.emit('inventory_updated', inventoryData);
      print('📦 Socket: Inventory update sent: $inventoryData');
    } catch (e) {
      print('❌ Socket: Failed to send inventory update: $e');
    }
  }

  // Disconnect socket
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      print('🔌 Socket: Disconnected and disposed');
    }
  }

  // Dispose resources
  void dispose() {
    disconnect();
    _notificationController.close();
    _dataUpdateController.close();
  }
}
