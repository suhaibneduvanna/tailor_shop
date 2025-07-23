import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/customer.dart';
import '../models/garment_type.dart';
import '../models/order.dart';

class BackupService {
  // Create a backup file with all database data
  static Future<String?> createBackup() async {
    try {
      // Get all data from Hive boxes
      final customersBox = Hive.box<Customer>('customers');
      final garmentTypesBox = Hive.box<GarmentType>('garment_types');
      final ordersBox = Hive.box<Order>('orders');

      // Convert data to JSON-serializable format
      final backupData = {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'customers':
            customersBox.values
                .map(
                  (customer) => {
                    'id': customer.id,
                    'name': customer.name,
                    'phoneNumber': customer.phoneNumber,
                    'address': customer.address,
                    'createdAt': customer.createdAt.toIso8601String(),
                    'updatedAt': customer.updatedAt.toIso8601String(),
                  },
                )
                .toList(),
        'garmentTypes':
            garmentTypesBox.values
                .map(
                  (garmentType) => {
                    'id': garmentType.id,
                    'name': garmentType.name,
                    'measurements': garmentType.measurements,
                    'basePrice': garmentType.basePrice,
                    'createdAt': garmentType.createdAt.toIso8601String(),
                  },
                )
                .toList(),
        'orders':
            ordersBox.values
                .map(
                  (order) => {
                    'id': order.id,
                    'invoiceNumber': order.invoiceNumber,
                    'customerId': order.customerId,
                    'garmentTypeId': order.garmentTypeId,
                    'measurements': order.measurements,
                    'quantity': order.quantity,
                    'totalPrice': order.totalPrice,
                    'orderDate': order.orderDate.toIso8601String(),
                    'deliveryDate': order.deliveryDate.toIso8601String(),
                    'status': order.status.name,
                    'notes': order.notes,
                    'createdAt': order.createdAt.toIso8601String(),
                    'updatedAt': order.updatedAt.toIso8601String(),
                  },
                )
                .toList(),
      };

      // Convert to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      // Get documents directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'tailor_shop_backup_$timestamp.json';
      final filePath = '${directory.path}/$fileName';

      // Write to file
      final file = File(filePath);
      await file.writeAsString(jsonString);

      return filePath;
    } catch (e) {
      throw Exception('Failed to create backup: ${e.toString()}');
    }
  }

  // Export backup to user-selected location
  static Future<bool> exportBackup() async {
    try {
      // Create backup file
      final backupPath = await createBackup();
      if (backupPath == null) return false;

      // Let user choose save location
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup File',
        fileName:
            'tailor_shop_backup_${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        // Copy backup to selected location
        final backupFile = File(backupPath);
        await backupFile.copy(result);

        // Clean up temporary backup file
        await backupFile.delete();

        return true;
      }

      // Clean up if user cancelled
      await File(backupPath).delete();
      return false;
    } catch (e) {
      throw Exception('Failed to export backup: ${e.toString()}');
    }
  }

  // Import backup from user-selected file
  static Future<bool> importBackup() async {
    try {
      // Let user select backup file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Select Backup File to Restore',
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        await restoreFromFile(filePath);
        return true;
      }

      return false;
    } catch (e) {
      throw Exception('Failed to import backup: ${e.toString()}');
    }
  }

  // Restore database from backup file
  static Future<void> restoreFromFile(String filePath) async {
    try {
      // Read backup file
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString);

      // Validate backup format
      if (backupData['version'] == null ||
          backupData['customers'] == null ||
          backupData['garmentTypes'] == null ||
          backupData['orders'] == null) {
        throw Exception('Invalid backup file format');
      }

      // Get Hive boxes
      final customersBox = Hive.box<Customer>('customers');
      final garmentTypesBox = Hive.box<GarmentType>('garment_types');
      final ordersBox = Hive.box<Order>('orders');

      // Clear existing data
      await customersBox.clear();
      await garmentTypesBox.clear();
      await ordersBox.clear();

      // Restore customers
      for (final customerData in backupData['customers']) {
        final customer = Customer(
          id: customerData['id'],
          name: customerData['name'],
          phoneNumber: customerData['phoneNumber'],
          address: customerData['address'],
          createdAt: DateTime.parse(customerData['createdAt']),
          updatedAt: DateTime.parse(customerData['updatedAt']),
        );
        await customersBox.put(customer.id, customer);
      }

      // Restore garment types
      for (final garmentTypeData in backupData['garmentTypes']) {
        final garmentType = GarmentType(
          id: garmentTypeData['id'],
          name: garmentTypeData['name'],
          measurements: List<String>.from(garmentTypeData['measurements']),
          basePrice: garmentTypeData['basePrice'].toDouble(),
          createdAt: DateTime.parse(garmentTypeData['createdAt']),
        );
        await garmentTypesBox.put(garmentType.id, garmentType);
      }

      // Restore orders
      for (final orderData in backupData['orders']) {
        final order = Order(
          id: orderData['id'],
          invoiceNumber: orderData['invoiceNumber'],
          customerId: orderData['customerId'],
          garmentTypeId: orderData['garmentTypeId'],
          measurements: Map<String, double>.from(
            orderData['measurements'].map(
              (key, value) => MapEntry(key, value.toDouble()),
            ),
          ),
          quantity: orderData['quantity'],
          totalPrice: orderData['totalPrice'].toDouble(),
          orderDate: DateTime.parse(orderData['orderDate']),
          deliveryDate: DateTime.parse(orderData['deliveryDate']),
          status: OrderStatus.values.firstWhere(
            (status) => status.name == orderData['status'],
          ),
          notes: orderData['notes'],
          createdAt: DateTime.parse(orderData['createdAt']),
          updatedAt: DateTime.parse(orderData['updatedAt']),
        );
        await ordersBox.put(order.id, order);
      }
    } catch (e) {
      throw Exception('Failed to restore backup: ${e.toString()}');
    }
  }

  // Delete a specific backup
  static Future<bool> deleteBackup(String filePath) async {
    try {
      await File(filePath).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}

class BackupInfo {
  final String fileName;
  final String filePath;
  final DateTime createdAt;
  final int size;

  BackupInfo({
    required this.fileName,
    required this.filePath,
    required this.createdAt,
    required this.size,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}
