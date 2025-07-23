import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tailor_shop_provider.dart';
import '../models/garment_type.dart';
import 'add_edit_garment_type_screen.dart';

class GarmentTypesScreen extends StatelessWidget {
  const GarmentTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.checkroom_rounded, size: 24),
            SizedBox(width: 8),
            Text('Garment Types'),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => _showAddGarmentTypeDialog(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              tooltip: 'Add Garment Type',
            ),
          ),
        ],
      ),
      body: Consumer<TailorShopProvider>(
        builder: (context, provider, child) {
          final garmentTypes = provider.garmentTypes;

          if (garmentTypes.isEmpty) {
            return const Center(child: Text('No garment types found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: garmentTypes.length,
            itemBuilder: (context, index) {
              final garmentType = garmentTypes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      garmentType.name.isNotEmpty
                          ? garmentType.name[0].toUpperCase()
                          : 'G',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    garmentType.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Base Price: ₹${garmentType.basePrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Measurements Required:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children:
                                garmentType.measurements.map((measurement) {
                                  return Chip(
                                    label: Text(measurement),
                                    backgroundColor: Colors.blue.withOpacity(
                                      0.1,
                                    ),
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed:
                                    () => _showEditGarmentTypeDialog(
                                      context,
                                      garmentType,
                                    ),
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit'),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed:
                                    () => _showDeleteConfirmation(
                                      context,
                                      garmentType,
                                    ),
                                icon: const Icon(Icons.delete),
                                label: const Text('Delete'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddGarmentTypeDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditGarmentTypeScreen()),
    );
  }

  void _showEditGarmentTypeDialog(
    BuildContext context,
    GarmentType garmentType,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddEditGarmentTypeScreen(garmentType: garmentType),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, GarmentType garmentType) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Garment Type'),
            content: Text(
              'Are you sure you want to delete "${garmentType.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final provider = Provider.of<TailorShopProvider>(
                    context,
                    listen: false,
                  );
                  await provider.deleteGarmentType(garmentType.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Garment type deleted successfully'),
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
