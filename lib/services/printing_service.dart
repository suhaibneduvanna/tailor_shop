import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/customer.dart';
import '../models/garment_type.dart';
import '../models/order.dart';

class PrintingService {
  // Method to show invoice with proper print dialog
  static Future<void> printInvoice(
    Order order,
    Customer customer,
    GarmentType garmentType,
  ) async {
    final pdf = await _generateInvoicePdf(order, customer, garmentType);

    // Use layoutPdf to show proper print dialog with preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_${order.invoiceNumber}',
      format: PdfPageFormat.a4,
    );
  }

  // Method to show measurement slip with proper print dialog
  static Future<void> printMeasurementSlip(
    Order order,
    Customer customer,
    GarmentType garmentType,
  ) async {
    final pdf = await _generateMeasurementSlipPdf(order, customer, garmentType);

    // Use layoutPdf to show proper print dialog with preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Measurement_Slip_${order.invoiceNumber}',
      format: PdfPageFormat.a4,
    );
  }

  // Private method to generate invoice PDF
  static Future<pw.Document> _generateInvoicePdf(
    Order order,
    Customer customer,
    GarmentType garmentType,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              pw.SizedBox(height: 20),

              // Invoice and Customer details in single box
              _buildInvoiceAndCustomerDetails(order, customer),
              pw.SizedBox(height: 20),

              // Order details
              _buildOrderDetails(order, garmentType),
              pw.SizedBox(height: 30),

              // Footer
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  // Private method to generate measurement slip PDF
  static Future<pw.Document> _generateMeasurementSlipPdf(
    Order order,
    Customer customer,
    GarmentType garmentType,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              pw.SizedBox(height: 20),

              // Title
              pw.Center(
                child: pw.Text(
                  'MEASUREMENT SLIP',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Customer details and order info in single box
              _buildMeasurementCustomerAndOrderDetails(order, customer),
              pw.SizedBox(height: 20),

              // Garment type
              pw.Text(
                'Garment Type: ${garmentType.name}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 10),

              // Measurements
              _buildMeasurementDetails(order, garmentType),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'LIBASU THAQVA',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'TAILORING & CUTPIECE CENTER',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.black),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Near ICICI Bank, Chemmad',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
          ),
          pw.Text(
            'Phone: +91 94460 96209',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInvoiceAndCustomerDetails(
    Order order,
    Customer customer,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Invoice details (left side)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'INVOICE',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Invoice #: ${order.invoiceNumber}',
                style: const pw.TextStyle(color: PdfColors.black),
              ),
              pw.Text(
                'Order Date: ${_formatDate(order.orderDate)}',
                style: const pw.TextStyle(color: PdfColors.black),
              ),
              pw.Text(
                'Delivery Date: ${_formatDate(order.deliveryDate)}',
                style: const pw.TextStyle(color: PdfColors.black),
              ),
            ],
          ),
          // Customer details (right side)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'CUSTOMER DETAILS',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Name: ${customer.name}',
                style: const pw.TextStyle(color: PdfColors.black),
              ),
              pw.Text(
                'Phone: ${customer.phoneNumber}',
                style: const pw.TextStyle(color: PdfColors.black),
              ),
              if (customer.address != null)
                pw.Text(
                  'Address: ${customer.address}',
                  style: const pw.TextStyle(color: PdfColors.black),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMeasurementCustomerAndOrderDetails(
    Order order,
    Customer customer,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Customer details (left side)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'CUSTOMER DETAILS',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Name: ${customer.name}',
                style: const pw.TextStyle(color: PdfColors.black),
              ),
              pw.Text(
                'Phone: ${customer.phoneNumber}',
                style: const pw.TextStyle(color: PdfColors.black),
              ),
              if (customer.address != null)
                pw.Text(
                  'Address: ${customer.address}',
                  style: const pw.TextStyle(color: PdfColors.black),
                ),
            ],
          ),
          // Order info (right side)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'ORDER INFO',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Invoice No: ${order.invoiceNumber}',
                style: const pw.TextStyle(color: PdfColors.black),
              ),
              pw.Text(
                'Delivery Date: ${_formatDate(order.deliveryDate)}',
                style: const pw.TextStyle(color: PdfColors.black),
              ),
              pw.Text(
                'Quantity: ${order.quantity}',
                style: const pw.TextStyle(color: PdfColors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildOrderDetails(Order order, GarmentType garmentType) {
    // Parse additional items from notes
    List<Map<String, dynamic>> additionalItems = _parseAdditionalItems(
      order.notes,
    );

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ORDER DETAILS',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 10),

          // Garment and pricing table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Item',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Quantity',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Unit Price',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Total',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                  ),
                ],
              ),
              // Main garment row
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      garmentType.name,
                      style: const pw.TextStyle(color: PdfColors.black),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      '${order.quantity}',
                      style: const pw.TextStyle(color: PdfColors.black),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      '${garmentType.basePrice.toStringAsFixed(2)}',
                      style: const pw.TextStyle(color: PdfColors.black),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      '${(garmentType.basePrice * order.quantity).toStringAsFixed(2)}',
                      style: const pw.TextStyle(color: PdfColors.black),
                    ),
                  ),
                ],
              ),
              // Additional items rows
              ...additionalItems.map(
                (item) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        item['name'] ?? 'Additional Item',
                        style: const pw.TextStyle(color: PdfColors.black),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        '1',
                        style: const pw.TextStyle(color: PdfColors.black),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        '${item['price'].toStringAsFixed(2)}',
                        style: const pw.TextStyle(color: PdfColors.black),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        '${item['price'].toStringAsFixed(2)}',
                        style: const pw.TextStyle(color: PdfColors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 15),

          // Payment details
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: const pw.BoxDecoration(color: PdfColors.grey100),
            child: pw.Column(
              children: [
                // Subtotal
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'SUBTOTAL',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.Text(
                      'Rs. ${order.totalPrice.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ),

                // Advance payment if any
                if (order.advancePayment != null &&
                    order.advancePayment! > 0) ...[
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Advance Payment',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Text(
                        'Rs. ${order.advancePayment!.toStringAsFixed(2)}',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Container(height: 0.5, color: PdfColors.grey400),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'BALANCE AMOUNT',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Text(
                        'Rs. ${(order.totalPrice - order.advancePayment!).toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  pw.SizedBox(height: 5),
                  pw.Container(height: 0.5, color: PdfColors.grey400),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'TOTAL AMOUNT',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Text(
                        'Rs. ${order.totalPrice.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMeasurementDetails(
    Order order,
    GarmentType garmentType,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'MEASUREMENTS',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 10),

          // Measurements table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Measurement',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Value (inches)',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                  ),
                ],
              ),
              ...order.measurements.entries
                  .map(
                    (entry) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            entry.key,
                            style: const pw.TextStyle(color: PdfColors.black),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '${entry.value}"',
                            style: const pw.TextStyle(color: PdfColors.black),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Thank you for choosing our services!',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'For any queries, please contact us at the above mentioned details.',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Helper method to parse additional items from order notes
  static List<Map<String, dynamic>> _parseAdditionalItems(String? notes) {
    List<Map<String, dynamic>> items = [];

    if (notes == null || notes.isEmpty) return items;

    // Look for the "Additional Items:" section in notes
    final lines = notes.split('\n');
    for (String line in lines) {
      if (line.startsWith('Additional Items:')) {
        final itemsText = line.replaceFirst('Additional Items:', '').trim();
        if (itemsText.isNotEmpty) {
          // Parse items like "Item Name (₹100), Another Item (₹200)"
          final itemsList = itemsText.split(',');
          for (String item in itemsList) {
            final trimmedItem = item.trim();
            if (trimmedItem.isNotEmpty) {
              // Extract name and price using regex
              final match = RegExp(
                r'(.+?)\s*\(₹(\d+(?:\.\d+)?)\)',
              ).firstMatch(trimmedItem);
              if (match != null) {
                final name = match.group(1)?.trim() ?? 'Additional Item';
                final priceStr = match.group(2) ?? '0';
                final price = double.tryParse(priceStr) ?? 0.0;
                items.add({'name': name, 'price': price});
              }
            }
          }
        }
        break; // Found the additional items line, no need to continue
      }
    }

    return items;
  }
}
