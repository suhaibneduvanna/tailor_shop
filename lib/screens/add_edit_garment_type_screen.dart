import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/garment_type.dart';
import '../providers/tailor_shop_provider.dart';

class AddEditGarmentTypeScreen extends StatefulWidget {
  final GarmentType? garmentType;

  const AddEditGarmentTypeScreen({super.key, this.garmentType});

  @override
  State<AddEditGarmentTypeScreen> createState() =>
      _AddEditGarmentTypeScreenState();
}

class _AddEditGarmentTypeScreenState extends State<AddEditGarmentTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _measurementController = TextEditingController();

  List<String> _measurements = [];

  bool get _isEditing => widget.garmentType != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.garmentType!.name;
      _priceController.text = widget.garmentType!.basePrice.toString();
      _measurements = List.from(widget.garmentType!.measurements);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _measurementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.style_rounded, size: 24),
            const SizedBox(width: 8),
            Text(_isEditing ? 'Edit Garment Type' : 'Add Garment Type'),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Garment Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter garment name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Base Price (₹)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter base price';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Measurements Section
              const Text(
                'Measurements Required',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Add measurement field
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _measurementController,
                      decoration: const InputDecoration(
                        labelText: 'Measurement Name',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Chest, Shoulder, etc.',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addMeasurement,
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Current measurements
              if (_measurements.isNotEmpty) ...[
                const Text(
                  'Current Measurements:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _measurements.asMap().entries.map((entry) {
                        final index = entry.key;
                        final measurement = entry.value;
                        return Chip(
                          label: Text(measurement),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () => _removeMeasurement(index),
                          backgroundColor: Colors.blue.withOpacity(0.1),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 24),
              ],

              // Default measurements suggestion
              if (_measurements.isEmpty) ...[
                const Text(
                  'Suggested Measurements by Category:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                _buildSuggestedMeasurements(),
                const SizedBox(height: 24),
              ],

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveGarmentType,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _isEditing ? 'Update Garment Type' : 'Add Garment Type',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
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

  Widget _buildSuggestedMeasurements() {
    final suggestions = {
      'Shirt': ['Chest', 'Shoulder', 'Sleeve Length', 'Collar', 'Length'],
      'Pant': ['Waist', 'Hip', 'Inseam', 'Outseam', 'Thigh'],
      'Suit': [
        'Chest',
        'Shoulder',
        'Sleeve Length',
        'Waist',
        'Hip',
        'Jacket Length',
        'Pant Length',
      ],
      'Dress': ['Bust', 'Waist', 'Hip', 'Length', 'Shoulder'],
      'Skirt': ['Waist', 'Hip', 'Length'],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          suggestions.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      '${entry.key}:',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      children:
                          entry.value.map((measurement) {
                            return ActionChip(
                              label: Text(
                                measurement,
                                style: const TextStyle(fontSize: 12),
                              ),
                              onPressed:
                                  () => _addSuggestedMeasurement(measurement),
                              backgroundColor: Colors.grey.withOpacity(0.1),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  void _addMeasurement() {
    final measurement = _measurementController.text.trim();
    if (measurement.isNotEmpty && !_measurements.contains(measurement)) {
      setState(() {
        _measurements.add(measurement);
        _measurementController.clear();
      });
    }
  }

  void _addSuggestedMeasurement(String measurement) {
    if (!_measurements.contains(measurement)) {
      setState(() {
        _measurements.add(measurement);
      });
    }
  }

  void _removeMeasurement(int index) {
    setState(() {
      _measurements.removeAt(index);
    });
  }

  void _saveGarmentType() async {
    if (_formKey.currentState!.validate()) {
      if (_measurements.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one measurement'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final provider = Provider.of<TailorShopProvider>(context, listen: false);
      final now = DateTime.now();

      final garmentType = GarmentType(
        id: _isEditing ? widget.garmentType!.id : const Uuid().v4(),
        name: _nameController.text,
        measurements: _measurements,
        basePrice: double.parse(_priceController.text),
        createdAt: _isEditing ? widget.garmentType!.createdAt : now,
      );

      try {
        if (_isEditing) {
          await provider.updateGarmentType(garmentType);
        } else {
          await provider.addGarmentType(garmentType);
        }

        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Garment type updated successfully'
                    : 'Garment type added successfully',
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
