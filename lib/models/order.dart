import 'package:hive/hive.dart';

part 'order.g.dart';

@HiveType(typeId: 2)
class Order extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String invoiceNumber;

  @HiveField(2)
  String customerId;

  @HiveField(3)
  String garmentTypeId;

  @HiveField(4)
  Map<String, double> measurements;

  @HiveField(5)
  int quantity;

  @HiveField(6)
  double totalPrice;

  @HiveField(7)
  DateTime orderDate;

  @HiveField(8)
  DateTime deliveryDate;

  @HiveField(9)
  OrderStatus status;

  @HiveField(10)
  String? notes;

  @HiveField(11)
  DateTime createdAt;

  @HiveField(12)
  DateTime updatedAt;

  @HiveField(13)
  double? advancePayment;

  @HiveField(14)
  List<Map<String, dynamic>>? additionalItems;

  Order({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.garmentTypeId,
    required this.measurements,
    required this.quantity,
    required this.totalPrice,
    required this.orderDate,
    required this.deliveryDate,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.advancePayment,
    this.additionalItems,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'customerId': customerId,
      'garmentTypeId': garmentTypeId,
      'measurements': measurements,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate.toIso8601String(),
      'status': status.index,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'advancePayment': advancePayment,
      'additionalItems': additionalItems,
    };
  }

  static Order fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      customerId: json['customerId'],
      garmentTypeId: json['garmentTypeId'],
      measurements: Map<String, double>.from(json['measurements']),
      quantity: json['quantity'],
      totalPrice: json['totalPrice'].toDouble(),
      orderDate: DateTime.parse(json['orderDate']),
      deliveryDate: DateTime.parse(json['deliveryDate']),
      status: OrderStatus.values[json['status']],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      advancePayment: json['advancePayment']?.toDouble(),
      additionalItems:
          json['additionalItems'] != null
              ? List<Map<String, dynamic>>.from(json['additionalItems'])
              : null,
    );
  }
}

@HiveType(typeId: 3)
enum OrderStatus {
  @HiveField(0)
  pending,

  @HiveField(1)
  inProgress,

  @HiveField(2)
  completed,

  @HiveField(3)
  delivered,

  @HiveField(4)
  cancelled,
}
