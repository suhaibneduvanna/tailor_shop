import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/order.dart';
import '../models/customer.dart';
import '../models/garment_type.dart';
import '../providers/tailor_shop_provider.dart';

class AddEditOrderScreen extends StatefulWidget {
  final Order? order;

  const AddEditOrderScreen({super.key, this.order});

  @override
  State<AddEditOrderScreen> createState() => _AddEditOrderScreenState();
}

class _AddEditOrderScreenState extends State<AddEditOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();
  final _advancePaymentController = TextEditingController();

  Customer? _selectedCustomer;
  GarmentType? _selectedGarmentType;
  DateTime _orderDate = DateTime.now();
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 7));
  OrderStatus _status = OrderStatus.pending;
  Map<String, double> _measurements = {};
  Map<String, TextEditingController> _measurementControllers = {};
  bool _showCustomerSearch = false;
  List<Map<String, dynamic>> _additionalItems = [];

  bool get _isEditing => widget.order != null;

  @override
  void initState() {
    super.initState();
    // Set default quantity to 1
    _quantityController.text = '1';
    // Set default advance payment to 0
    _advancePaymentController.text = '0';

    if (_isEditing) {
      _loadOrderData();
    }
  }

  void _loadOrderData() {
    final provider = Provider.of<TailorShopProvider>(context, listen: false);
    final order = widget.order!;

    _selectedCustomer = provider.getCustomerById(order.customerId);
    _selectedGarmentType = provider.getGarmentTypeById(order.garmentTypeId);
    _quantityController.text = order.quantity.toString();
    _notesController.text = order.notes ?? '';
    _orderDate = order.orderDate;
    _deliveryDate = order.deliveryDate;
    _status = order.status;
    _measurements = Map.from(order.measurements);

    // Load advance payment
    _advancePaymentController.text = (order.advancePayment ?? 0.0).toString();

    // Initialize measurement controllers for editing
    if (_selectedGarmentType != null) {
      for (final measurement in _selectedGarmentType!.measurements) {
        final value = _measurements[measurement] ?? 0.0;
        _measurementControllers[measurement] = TextEditingController(
          text: value.toString(),
        );
      }
    }

    // Load cloth data if exists (assuming these fields exist in the Order model)
    // Note: You'll need to update the Order model to include these fields
    // _withCloth = order.withCloth ?? false;
    // _clothNameController.text = order.clothName ?? '';
    // _clothPriceController.text = order.clothPrice?.toString() ?? '';
  }

  Future<void> _fetchPreviousMeasurements() async {
    if (_selectedCustomer == null || _selectedGarmentType == null) return;

    final provider = Provider.of<TailorShopProvider>(context, listen: false);

    // Get customer's previous orders for the same garment type
    final customerOrders =
        provider.orders
            .where(
              (order) =>
                  order.customerId == _selectedCustomer!.id &&
                  order.garmentTypeId == _selectedGarmentType!.id,
            )
            .toList();

    if (customerOrders.isNotEmpty) {
      // Sort by creation date and get the most recent order
      customerOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final latestOrder = customerOrders.first;

      // Show confirmation dialog
      final shouldFetch = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Previous Measurements Found'),
              content: Text(
                'Found measurements from a previous ${_selectedGarmentType!.name} order '
                'placed on ${_formatDate(latestOrder.orderDate)}. '
                'Would you like to use these measurements?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No, Keep Current'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Yes, Use Previous'),
                ),
              ],
            ),
      );

      if (shouldFetch == true) {
        setState(() {
          _measurements = Map.from(latestOrder.measurements);
          // Update the controllers with the new values
          for (var entry in latestOrder.measurements.entries) {
            if (_measurementControllers.containsKey(entry.key)) {
              _measurementControllers[entry.key]!.text = entry.value.toString();
            }
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Previous measurements loaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No previous ${_selectedGarmentType!.name} orders found for ${_selectedCustomer!.name}',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    _advancePaymentController.dispose();
    // Dispose measurement controllers
    for (var controller in _measurementControllers.values) {
      controller.dispose();
    }
    // Dispose additional item controllers
    for (var item in _additionalItems) {
      item['nameController']?.dispose();
      item['priceController']?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.receipt_long_rounded, size: 24),
            const SizedBox(width: 8),
            Text(_isEditing ? 'Edit Order' : 'Add Order'),
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
              // Customer Selection
              _buildCustomerSelection(),
              const SizedBox(height: 12),

              // Garment Type Selection
              _buildGarmentTypeSelection(),
              const SizedBox(height: 12),

              // Measurements
              if (_selectedGarmentType != null) ...[
                _buildMeasurementsSection(),
                const SizedBox(height: 12),
              ],

              // Additional Items Section
              _buildAdditionalItemsSection(),
              const SizedBox(height: 12),

              // Quantity and Dates
              _buildQuantityAndDatesSection(),
              const SizedBox(height: 12),

              // Advance Payment
              _buildAdvancePaymentSection(),
              const SizedBox(height: 20),

              // Status (only for editing)
              if (_isEditing) ...[
                DropdownButtonFormField<OrderStatus>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      OrderStatus.values
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.name),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                    });
                  },
                ),
                const SizedBox(height: 12),
              ],

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Total Price Display
              if (_selectedGarmentType != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Unit Price (${_selectedGarmentType!.name}):',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              '₹${_selectedGarmentType!.basePrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (_additionalItems.isNotEmpty) ...[
                          ...(_additionalItems.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${item['nameController'].text.isEmpty ? "Additional Item" : item['nameController'].text}:',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    '₹${(double.tryParse(item['priceController'].text) ?? 0.0).toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Quantity:',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              '${_getValidQuantity()}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Price:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₹${_calculateTotalPrice().toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        if (double.tryParse(_advancePaymentController.text) !=
                                null &&
                            double.parse(_advancePaymentController.text) >
                                0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Advance Payment:',
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                '₹${double.parse(_advancePaymentController.text).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Balance Amount:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '₹${_calculateBalanceAmount().toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(_isEditing ? 'Update Order' : 'Create Order'),
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

  Widget _buildCustomerSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap:
                    () => setState(
                      () => _showCustomerSearch = !_showCustomerSearch,
                    ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCustomer?.name ?? 'Select Customer',
                        style: TextStyle(
                          color:
                              _selectedCustomer == null
                                  ? Colors.grey
                                  : Colors.black,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: () => _showAddCustomerDialog(),
                icon: const Icon(Icons.person_add, color: Colors.white),
                tooltip: 'Add New Customer',
              ),
            ),
          ],
        ),
        if (_showCustomerSearch) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search customers...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Consumer<TailorShopProvider>(
            builder: (context, provider, child) {
              final customers = provider.searchCustomers(
                _searchController.text,
              );
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListView.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return ListTile(
                      title: Text(customer.name),
                      subtitle: Text(customer.phoneNumber),
                      onTap: () {
                        setState(() {
                          _selectedCustomer = customer;
                          _showCustomerSearch = false;
                          _searchController.clear();
                        });
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildGarmentTypeSelection() {
    return Consumer<TailorShopProvider>(
      builder: (context, provider, child) {
        return DropdownButtonFormField<GarmentType>(
          value: _selectedGarmentType,
          decoration: const InputDecoration(
            labelText: 'Garment Type',
            border: OutlineInputBorder(),
          ),
          items:
              provider.garmentTypes
                  .map(
                    (garmentType) => DropdownMenuItem(
                      value: garmentType,
                      child: Text(
                        '${garmentType.name} - ₹${garmentType.basePrice}',
                      ),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            setState(() {
              _selectedGarmentType = value;
              _measurements = {};
              // Dispose existing controllers
              for (var controller in _measurementControllers.values) {
                controller.dispose();
              }
              _measurementControllers.clear();

              // Initialize measurements with default values and create controllers
              if (value != null) {
                for (final measurement in value.measurements) {
                  _measurements[measurement] = 0.0;
                  _measurementControllers[measurement] = TextEditingController(
                    text: '0',
                  );
                }
              }
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a garment type';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildMeasurementsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Measurements (inches)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (_selectedCustomer != null && !_isEditing)
                  ElevatedButton.icon(
                    onPressed: _fetchPreviousMeasurements,
                    icon: const Icon(Icons.history, size: 16),
                    label: const Text('Load Previous'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _selectedGarmentType!.measurements.length,
              itemBuilder: (context, index) {
                final measurement = _selectedGarmentType!.measurements[index];
                return TextFormField(
                  controller: _measurementControllers[measurement],
                  decoration: InputDecoration(
                    labelText: measurement,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _measurements[measurement] = double.tryParse(value) ?? 0.0;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid';
                    }
                    return null;
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalItemsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Additional Items',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _addNewItem,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            if (_additionalItems.isNotEmpty) ...[
              const SizedBox(height: 12),
              ..._additionalItems.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> item = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: item['nameController'],
                          decoration: const InputDecoration(
                            labelText: 'Item Name',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter item name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: item['priceController'],
                          decoration: const InputDecoration(
                            labelText: 'Price (₹)',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => setState(() {}),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter price';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid price';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _removeItem(index),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Remove Item',
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
            if (_additionalItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No additional items added',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _addNewItem() {
    setState(() {
      _additionalItems.add({
        'nameController': TextEditingController(),
        'priceController': TextEditingController(),
      });
    });
  }

  void _removeItem(int index) {
    setState(() {
      // Dispose controllers before removing
      _additionalItems[index]['nameController']?.dispose();
      _additionalItems[index]['priceController']?.dispose();
      _additionalItems.removeAt(index);
    });
  }

  Widget _buildQuantityAndDatesSection() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quantity',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Minus button
                    Material(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                        onTap: () {
                          final currentQty =
                              int.tryParse(_quantityController.text) ?? 1;
                          if (currentQty > 1) {
                            _quantityController.text =
                                (currentQty - 1).toString();
                            setState(() {});
                          }
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          child: const Icon(
                            Icons.remove,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    // Quantity display/input
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter quantity';
                          }
                          if (int.tryParse(value) == null ||
                              int.parse(value) <= 0) {
                            return 'Please enter a valid quantity';
                          }
                          return null;
                        },
                      ),
                    ),
                    // Plus button
                    Material(
                      color: Colors.blue[50],
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        onTap: () {
                          final currentQty =
                              int.tryParse(_quantityController.text) ?? 1;
                          _quantityController.text =
                              (currentQty + 1).toString();
                          setState(() {});
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          child: const Icon(
                            Icons.add,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDateField(
            'Order Date',
            _orderDate,
            (date) => setState(() => _orderDate = date),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDateField(
            'Delivery Date',
            _deliveryDate,
            (date) => setState(() => _deliveryDate = date),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancePaymentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Advance Payment (₹)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _advancePaymentController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '0',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => setState(() {}),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final advance = double.tryParse(value);
                            if (advance == null || advance < 0) {
                              return 'Enter valid amount';
                            }
                            final total = _calculateTotalPrice();
                            if (advance > total) {
                              return 'Cannot exceed total amount';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Balance Amount',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey.shade50,
                        ),
                        child: Text(
                          '₹${_calculateBalanceAmount().toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(
    String label,
    DateTime date,
    Function(DateTime) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (selectedDate != null) {
              onChanged(selectedDate);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDate(date),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add New Customer'),
            content: SizedBox(
              width: 400,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter customer name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final provider = Provider.of<TailorShopProvider>(
                      context,
                      listen: false,
                    );

                    final newCustomer = Customer(
                      id: const Uuid().v4(),
                      name: nameController.text.trim(),
                      phoneNumber: phoneController.text.trim(),
                      address:
                          addressController.text.trim().isEmpty
                              ? null
                              : addressController.text.trim(),
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );

                    try {
                      await provider.addCustomer(newCustomer);

                      // Close dialog and select the new customer
                      if (mounted) {
                        Navigator.pop(context);
                        setState(() {
                          _selectedCustomer = newCustomer;
                        });

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Customer added successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      // Show error message
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error adding customer: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add Customer'),
              ),
            ],
          ),
    );
  }

  double _calculateTotalPrice() {
    if (_selectedGarmentType == null) return 0.0;
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    // Ensure quantity is at least 1 to avoid showing 0 price
    final validQuantity = quantity <= 0 ? 1 : quantity;
    final garmentTotal = _selectedGarmentType!.basePrice * validQuantity;
    final additionalItemsTotal = _getAdditionalItemsTotal();
    final total = garmentTotal + additionalItemsTotal;

    // Debug print to see if calculation is being called
    print(
      'Calculating price: (${_selectedGarmentType!.basePrice} x $validQuantity) + $additionalItemsTotal = $total',
    );

    return total;
  }

  double _getAdditionalItemsTotal() {
    double total = 0.0;
    for (var item in _additionalItems) {
      final price = double.tryParse(item['priceController'].text) ?? 0.0;
      total += price;
    }
    return total;
  }

  double _calculateBalanceAmount() {
    final total = _calculateTotalPrice();
    final advance = double.tryParse(_advancePaymentController.text) ?? 0.0;
    return total - advance;
  }

  String? _buildOrderNotes() {
    List<String> notesParts = [];

    // Add regular notes if any
    if (_notesController.text.isNotEmpty) {
      notesParts.add(_notesController.text);
    }

    // Add additional items information
    if (_additionalItems.isNotEmpty) {
      List<String> itemsInfo = [];
      for (var item in _additionalItems) {
        String itemName =
            item['nameController'].text.isNotEmpty
                ? item['nameController'].text
                : "Additional Item";
        String itemPrice =
            item['priceController'].text.isNotEmpty
                ? "₹${item['priceController'].text}"
                : "₹0";
        itemsInfo.add("$itemName ($itemPrice)");
      }
      notesParts.add("Additional Items: ${itemsInfo.join(', ')}");
    }

    return notesParts.isEmpty ? null : notesParts.join('\n');
  }

  int _getValidQuantity() {
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    return quantity <= 0 ? 1 : quantity;
  }

  void _saveOrder() async {
    if (_formKey.currentState!.validate() && _selectedCustomer != null) {
      final provider = Provider.of<TailorShopProvider>(context, listen: false);
      final now = DateTime.now();

      final order = Order(
        id: _isEditing ? widget.order!.id : const Uuid().v4(),
        invoiceNumber:
            _isEditing
                ? widget.order!.invoiceNumber
                : provider.generateInvoiceNumber(),
        customerId: _selectedCustomer!.id,
        garmentTypeId: _selectedGarmentType!.id,
        measurements: _measurements,
        quantity: int.parse(_quantityController.text),
        totalPrice: _calculateTotalPrice(),
        orderDate: _orderDate,
        deliveryDate: _deliveryDate,
        status: _status,
        notes: _buildOrderNotes(),
        createdAt: _isEditing ? widget.order!.createdAt : now,
        updatedAt: now,
        advancePayment: double.tryParse(_advancePaymentController.text),
      );

      try {
        if (_isEditing) {
          await provider.updateOrder(order);
        } else {
          await provider.addOrder(order);
        }

        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Order updated successfully'
                    : 'Order created successfully',
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
    } else if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
