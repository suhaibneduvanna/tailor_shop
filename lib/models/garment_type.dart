import 'package:hive/hive.dart';

part 'garment_type.g.dart';

@HiveType(typeId: 0)
class GarmentType extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<String> measurements;

  @HiveField(3)
  double basePrice;

  @HiveField(4)
  DateTime createdAt;

  GarmentType({
    required this.id,
    required this.name,
    required this.measurements,
    required this.basePrice,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'measurements': measurements,
      'basePrice': basePrice,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static GarmentType fromJson(Map<String, dynamic> json) {
    return GarmentType(
      id: json['id'],
      name: json['name'],
      measurements: List<String>.from(json['measurements']),
      basePrice: json['basePrice'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
