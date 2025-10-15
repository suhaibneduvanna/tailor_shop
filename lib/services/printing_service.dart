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

  // Method to print combined invoice and measurement slip with cutting line
  static Future<void> printCombinedSlip(
    Order order,
    Customer customer,
    GarmentType garmentType,
  ) async {
    final pdf = await _generateCombinedSlipPdf(order, customer, garmentType);

    // Use layoutPdf to show proper print dialog with preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Combined_Slip_${order.invoiceNumber}',
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
              // _buildHeader(),
              // pw.SizedBox(height: 20),

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
              pw.SizedBox(height: 20),

              // Notes section
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'NOTES',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        order.notes!,
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
      padding: const pw.EdgeInsets.only(top: 10, bottom: 10),
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
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'TAILORING & CUTPIECE CENTER',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.black),
          ),
          pw.SizedBox(height: 5),
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
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${customer.name}',
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                '${customer.phoneNumber}',
                style: const pw.TextStyle(color: PdfColors.black),
              ),
              if (customer.address != null)
                pw.Text(
                  '${customer.address}',
                  style: const pw.TextStyle(color: PdfColors.black),
                ),
            ],
          ),

          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Invoice #: ${order.invoiceNumber}',
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontWeight: pw.FontWeight.bold,
                ),
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
        ],
      ),
    );
  }

  static pw.Widget _buildMeasurementCustomerAndOrderDetails(
    Order order,
    Customer customer,
  ) {
    return pw.Container(
      child: pw.Column(
        children: [
          pw.Text(
            "MEASUREMENT SLIP",
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Customer details (left side)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${customer.name}',
                    style: pw.TextStyle(
                      color: PdfColors.black,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '${customer.phoneNumber}',
                    style: const pw.TextStyle(color: PdfColors.black),
                  ),
                  if (customer.address != null)
                    pw.Text(
                      '${customer.address}',
                      style: const pw.TextStyle(color: PdfColors.black),
                    ),
                ],
              ),
              // Order info (right side)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
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
        ],
      ),
    );
  }

  static pw.Widget _buildOrderDetails(Order order, GarmentType garmentType) {
    // Get additional items from the separate field
    List<Map<String, dynamic>> additionalItems = order.additionalItems ?? [];

    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
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
                        '${_formatQuantity(item['quantity'] ?? 1.0)}',
                        style: const pw.TextStyle(color: PdfColors.black),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        '${(item['price'] ?? 0.0).toStringAsFixed(2)}',
                        style: const pw.TextStyle(color: PdfColors.black),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        '${((item['price'] ?? 0.0) * (item['quantity'] ?? 1.0)).toStringAsFixed(2)}',
                        style: const pw.TextStyle(color: PdfColors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
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
                      'Subtotal',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.Text(
                      'Rs. ${order.totalPrice.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 10,
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
                          fontSize: 10,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Text(
                        'Rs. ${order.advancePayment!.toStringAsFixed(2)}',
                        style: const pw.TextStyle(
                          fontSize: 10,
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
                        'Balance Amount',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Text(
                        'Rs. ${(order.totalPrice - order.advancePayment!).toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 12,
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
                        'Grand Total',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Text(
                        'Rs. ${order.totalPrice.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 12,
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
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
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

  // Private method to generate combined invoice and measurement slip PDF
  static Future<pw.Document> _generateCombinedSlipPdf(
    Order order,
    Customer customer,
    GarmentType garmentType,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape, // Set to landscape orientation
        margin: const pw.EdgeInsets.all(15),
        build: (pw.Context context) {
          return pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // LEFT SIDE - INVOICE (Full standalone invoice)
              pw.Expanded(
                flex: 1,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(),
                      pw.SizedBox(height: 10),

                      // Invoice and Customer details
                      _buildInvoiceAndCustomerDetails(order, customer),
                      pw.SizedBox(height: 10),

                      // Order details
                      _buildOrderDetails(order, garmentType),
                      pw.Spacer(),
                    ],
                  ),
                ),
              ),

              // SEPARATOR LINE
              pw.Container(
                width: 2,
                margin: const pw.EdgeInsets.symmetric(horizontal: 10),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    left: pw.BorderSide(
                      color: PdfColors.grey600,
                      width: 1,
                      style: pw.BorderStyle.dashed,
                    ),
                  ),
                ),
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Transform.rotate(
                      angle: 1.5708, // 90 degrees in radians
                      child: pw.Text(
                        '',
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // RIGHT SIDE - MEASUREMENT SLIP (Full standalone measurement slip)
              pw.Expanded(
                flex: 1,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Customer details and order info
                      _buildMeasurementCustomerAndOrderDetails(order, customer),
                      pw.SizedBox(height: 15),

                      // Garment type
                      pw.Text(
                        'Garment Type: ${garmentType.name}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.SizedBox(height: 10),

                      // Measurements
                      _buildMeasurementDetails(order, garmentType),

                      // Notes section in combined slip
                      if (order.notes != null && order.notes!.isNotEmpty) ...[
                        pw.SizedBox(height: 10),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey400),
                            borderRadius: pw.BorderRadius.circular(5),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'NOTES:',
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.SizedBox(height: 3),
                              pw.Text(
                                order.notes!,
                                style: const pw.TextStyle(
                                  fontSize: 8,
                                  color: PdfColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      pw.Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Helper method to format quantity (remove unnecessary decimal places)
  static String _formatQuantity(dynamic quantity) {
    if (quantity is int) return quantity.toString();
    if (quantity is double) {
      return quantity % 1 == 0
          ? quantity.toInt().toString()
          : quantity.toString();
    }
    double qty = double.tryParse(quantity.toString()) ?? 1.0;
    return qty % 1 == 0 ? qty.toInt().toString() : qty.toString();
  }
}
